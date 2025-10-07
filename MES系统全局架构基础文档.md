- # MES系统全局架构基础文档

  ## 一、系统总体设计思路

  ### 1. 总功能模块

  1. **BI 数据大屏看板**：用于数据追踪、报表展示与生产状态可视化。
2. **MES 后台管理系统**（核心系统）：包含资产管理、流程追踪、品质管控、物流管理等核心模块。
  3. **供应商端移动端/小程序**：支持多用户登录与多设备登录，负责模具状态、发货及质检协同。

  ### 2. 核心业务流程概览
  
  生产过程分为新旧项目两类：

  - **新项目（如验钞机、钱箱）**：需与总部（ITL）沟通试产方案并完成 FAI（首件验证）。
- **旧项目**：区分总部订单与三方订单，经首件验证后批量生产。
  
详细流程包括：海关报备与原料入库（物流域）→ IQC 进料检验（品质域）→ 试产/首件（生产域）→ 批量生产 + IPQC 抽检 → 测试、维修、OQC 抽检与出货 → 年度盘点与 ERP 数据比对。
  
  ------

  ## 二、架构分层与模块边界

  ### 1. 系统分层

  - **前端层**：Vue3 + Element Plus 实现 MES Web；BI 大屏使用 ECharts；移动端采用 uniapp 或小程序原生。
- **业务服务层**（REST API）：
    - 资产管理（模具/辅料/主料台账）
  - 品质（IQC、IPQC、OQC、返修、测试、NCR/SCAR）
    - 物流（入库/出库/盘点/备料/库存对账）
    - 生产（工单、SOP、工艺路线、首件/批次生产）
    - 追溯（正向/反向全链路追溯）
  - **数据层**：MySQL（事务库）+ Redis（缓存与锁）+ OSS（影像与附件）。
  
  ### 2. 系统集成
  
  - **ERP**：对接 BOM、工单、库存同步。
- **ITL 总部**：新项目 FAI 报告、ECN 文件上传。
  - **供应商系统**：订单发货与 IQC 状态同步。

  ------
  
  ## 三、数据架构与标识体系

  ### 1. 主要对象与标识

  | 对象   | 标识规则               |
| ------ | ---------------------- |
  | 物料   | ITM-YYYYMM-XXXX        |
| 模具   | MLD-SUP-XXXX           |
  | 订单   | PO-YYYYMMDD-SEQ        |
  | 工单   | WO-LINE-SEQ            |
  | 批次   | LOT-YYYYMMDD-SEQ       |
  | 序列号 | SN-LOT-SEQ             |
  | 检验单 | INSP-TYPE-YYYYMMDD-SEQ |
  
  ### 2. 追溯主线
  
  - **正向**：订单 → 工单 → 批次/序列号 → 测试/维修 → OQC → 出货。
- **反向**：序列号 → 批次 → 原料批次/供应商 → 模具 → IQC → 工序/责任人。
  
### 3. 数据表设计（MySQL）示例
  
  ```sql
CREATE TABLE inspection (
    insp_id     VARCHAR(32) PRIMARY KEY,
  type        VARCHAR(8),      -- IQC/IPQC/OQC/FAI
    ref_id      VARCHAR(32),     -- grn_id / lot_id / wo_id / box_no
    result      VARCHAR(16),     -- PASS/FAIL/SPECIAL
    sample_size INT,
    created_by  VARCHAR(64),
    created_at  DATETIME
  );
  
  CREATE TABLE test_record (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    sn         VARCHAR(64),
    station    VARCHAR(64),
    result     VARCHAR(8),       -- PASS/FAIL
    code       VARCHAR(32),      -- 失败代码
    tested_at  DATETIME
  );
  ```
  
  ### 4. Redis 应用场景
  
  - 会话：`session:{user_id}`；
- 分布式锁：`lock:pick:{wo_id}:{item_id}` 控制备料并发；
  - 缓存：看板指标（TTL 30–120s）；
- 幂等：`Idempotency-Key` 提交去重。
  
  ------
  
  ## 四、业务流程改进

  - **IQC 流程数字化**：电子 SOP + AQL 自动抽样 + 影像直传 OSS；不合格触发 NCR/SCAR 并计入供应商评分。
- **FAI 首件控制**：未通过禁止批量投产；生成首件合格报告归档。
  - **生产与巡检**：WIP 状态机（待投产→装配→初测→返修→复测→终测→打包）；IPQC 抽检频次随不合格率动态调整。
- **OQC 与盘点**：按客户协议配置 AQL；移动端扫码盘点与差异审计。
  
  ------
  
  ## 五、接口与 API 示例

  统一返回：`{code, message, data}`

  - `POST /iqc/inspections` → 创建检验单
- `GET /trace/reverse?sn=` → 反向追溯
  - `POST /stock/move` → 库存移库

  ------
  
  ## 六、非功能性要求（NFR）

  - **性能**：大表按日/周分区；热点数据缓存；统计查询走只读副本。
- **安全**：JWT + 刷新令牌；附件预签名 URL；行级数据权限。
  - **可靠性**：幂等与分布式锁；主从复制与定时备份。
- **可维护性**：TraceID 贯穿；操作审计与告警。
  
  ------
  
  ## 七、Element Plus 前端落地建议

  - IQC 检验：`ElForm`（动态校验）+ `ElUpload`（影像）+ AQL 计算器
- WIP 看板：`ElCard` 栅格 + ECharts 良率/在制
  - 追溯页：`ElInput`（SN/箱号）→ `ElTimeline`（节点轨迹）
- 盘点页：移动端扫码 + 差异即时提示
  
  ------
  
  ## 八、改进版流程图（主流程 + 多分支 + BI 伪实时闭环）

  ```mermaid
graph TD
      %% ===== 主干：生产全链 =====
    ROOT["🔹 订单需求发起"] --> RES["🟦 资源准备"]
      RES --> PROD["🟦 生产执行"]
      PROD --> WMS["🟦 物流仓储"]
      WMS --> QA["🟦 品质与出货"]
      QA --> TRACE["🟦 数据追溯与分析"]
      TRACE --> CLOSE["🔹 流程闭环归档"]
  
      %% ====== 分支入口（从主干分叉）======
      RES --> IQC_ENTRY[["📄 IQC检验（子流程）"]]
      PROD --> P_ENTRY[["📄 生产+IPQC（子流程）"]]
      QA --> OQC_ENTRY[["📄 OQC与出货（子流程）"]]
      WMS --> CC_ENTRY[["📄 盘点与审计（子流程）"]]
      TRACE --> CS_ENTRY[["📄 客诉追溯（子流程）"]]
  
      %% ====== IQC 子流程 ======
      subgraph IQC_Flow["IQC检验子流程"]
        direction TB
        IQ1["物料到货 / 建GRN"] --> IQ2["创建IQC检验单"]
        IQ2 --> IQ3{"AQL抽样与检测"}
        IQ3 -->|合格| IQ4["入库登记 → 可用库存"]
        IQ3 -->|不合格| IQ5["不合格隔离"]
        IQ5 --> IQ6["特采 / 退货 / 立NCR"]
        IQ6 --> IQ7["供应商评分联动"]
        IQ4 --> IQ8["检验报告归档"]
      end
      IQC_ENTRY -.进入.-> IQ1
      IQ8 -.返回主干.-> WMS
  
      %% ====== 生产+IPQC 子流程 ======
      subgraph P_Flow["生产与IPQC子流程"]
        direction TB
        P0["工单下发"] --> P1["备料交付生产"]
        P1 --> P2["装配 / 组装"]
        P2 --> P3["首件验证（FAI）"]
        P3 --> P4{"首件结果"}
        P4 -->|通过| P5["批量生产"]
        P4 -->|未通过| P6["工艺参数调整 → 重测"]
        P5 --> P7["IPQC巡检（动态频次）"]
        P7 --> P8{"抽检结果"}
        P8 -->|合格| P9["初测 → 终测 → 打包"]
        P8 -->|不合格| P10["暂停 → 返修分析（次数上限）"]
      end
      P_ENTRY -.进入.-> P0
      P9 -.良品打包→.-> QA
  
      %% ====== OQC+出货 子流程 ======
      subgraph OQC_Flow["OQC检验与出货子流程"]
        direction TB
        O1["成品打包完成"] --> O2["生成箱号 / 托盘号"]
        O2 --> O3["OQC抽检（AQL）"]
        O3 --> O4{"检验结果"}
        O4 -->|合格| O5["出货放行"]
        O4 -->|不合格| O6["隔离 / 返修 / 复检"]
        O5 --> O7["出货报告归档"]
      end
      OQC_ENTRY -.进入.-> O1
      O7 -.返回主干.-> TRACE
  
      %% ====== 盘点与审计 子流程 ======
      subgraph CC_Flow["盘点与库存审计子流程"]
        direction TB
        C1["生成盘点任务"] --> C2["移动端扫描盘点"]
        C2 --> C3["数据上传 / Redis缓存"]
        C3 --> C4["对比ERP库存"]
        C4 --> C5{"是否有差异"}
        C5 -->|无| C6["盘点结果归档"]
        C5 -->|有| C7["差异单复核"]
        C7 --> C8["责任归因分析"]
      end
      CC_ENTRY -.进入.-> C1
      C6 -.返回主干.-> TRACE
      C8 -.返回主干.-> TRACE
  
      %% ====== 客诉追溯 子流程 ======
      subgraph CS_Flow["客诉追溯子流程"]
        direction TB
        S1["接收客户SN/箱号"] --> S2["反查批次 / 工单"]
        S2 --> S3["关联用料批次 / 供应商 / 模具"]
        S3 --> S4["查询IQC / OQC结果"]
        S4 --> S5["提取测试 / 维修记录"]
        S5 --> S6["生成责任归因报告"]
      end
      CS_ENTRY -.进入.-> S1
      S6 -.返回主干.-> CLOSE
  
      %% ====== BI 伪实时（分钟级）子流程 ======
      subgraph BI_Flow["BI 近实时（分钟级）"]
        direction LR
        BI_COLLECT["数据采集（只读副本 / 增量）"] --> BI_AGG["5分钟增量聚合（物化表）"]
        BI_AGG --> BI_CACHE["Redis短期缓存（30–120s）"]
        BI_CACHE --> BI_PUSH["WebSocket / 轮询推送"]
        BI_PUSH --> BI_DASH["BI大屏 / 看板（Element + ECharts）"]
        BI_AGG --> BI_QC["新鲜度 / 质量监控（告警）"]
      end
  
      %% 从各子流程到 BI 数据采集（增量）
      IQ8 -.-> BI_COLLECT
      P7 -.-> BI_COLLECT
      P9 -.-> BI_COLLECT
      O3 -.-> BI_COLLECT
      O7 -.-> BI_COLLECT
      C3 -.-> BI_COLLECT
      C6 -.-> BI_COLLECT
  
      %% BI 反馈回主干（告警/提示）
      BI_QC -.-> QA
      BI_QC -.-> PROD
  
      %% 样式
      classDef trunk fill:#e3f2fd,stroke:#2196f3,stroke-width:1px;
      class ROOT,RES,PROD,WMS,QA,TRACE,CLOSE trunk;
  ```
  
  ------
  
  ## 九、BI 近实时（分钟级）体系设计

  > 目标：在不引入大数据栈前提下，仅用 **MySQL + Redis** 实现分钟级伪实时渲染，保障追踪、良率/进度等关键指标 1–5 分钟内更新。

  ### 9.1 指标域与 SLA

  - **生产域**：当日产量、工单达成率、WIP 分布 → **SLA：≤2 分钟**
- **品质域**：IQC/OQC 通过率、缺陷码 TopN、返修回圈时间 → **SLA：≤3 分钟**
  - **物流域**：库存周转、出入库节拍、盘点进度 → **SLA：≤5 分钟**

  ### 9.2 方案
  
  - 只读副本查询；增量物化表（1–5 分钟）；binlog 位点或 `updated_at > last_ts` 拉增量；
- Redis 终端指标缓存（TTL 30–120s）；WebSocket 推送；聚合作业幂等与回看窗口（10–15 分钟）。
  
### 9.3 表与示例 SQL
  
  **明细表**：`test_record(sn, station, result, code, tested_at)` / `inspection(...)` / `stock_txn(...)`
 **聚合表**：
  
```sql
  CREATE TABLE agg_yield_5m (
    bucket_start DATETIME PRIMARY KEY,
  pass_cnt INT, fail_cnt INT, yield DECIMAL(5,2),
    updated_at DATETIME
  );
  ```
  
  **刷新示例**：
  
  ```sql
REPLACE INTO agg_yield_5m (bucket_start, pass_cnt, fail_cnt, yield, updated_at)
  SELECT
  FROM_UNIXTIME(UNIX_TIMESTAMP(tested_at) - MOD(UNIX_TIMESTAMP(tested_at), 300)) AS bucket_start,
    SUM(result = 'PASS') AS pass_cnt,
    SUM(result = 'FAIL') AS fail_cnt,
    ROUND(100 * SUM(result = 'PASS') / GREATEST(COUNT(*),1), 2) AS yield,
    NOW()
  FROM test_record
  WHERE tested_at > (SELECT COALESCE(MAX(updated_at), '1970-01-01') FROM agg_yield_5m)
  GROUP BY bucket_start;
  ```
  
  ### 9.4 调度与并发
  
  - Cron：`*/1` 或 `*/3`；
- 分布式锁：`lock:agg:{table}:{bucket}`；
  - 幂等游标：`agg:cursor:{table}`；
- 失败重试与新鲜度告警。
  
  ### 9.5 前端契约（Element + ECharts）
  
  ```json
{
    "updated_at": "2025-10-07T10:12:00Z",
  "yield": [{"t":"10:05","value":96.2},{"t":"10:10","value":95.7}],
    "wip": {"assembling":120,"testing":45,"packing":30,"finished":60},
    "alerts": ["IPQC不合格率上升至5%（>3%阈值）"]
  }
  ```
  
  ------
  
  ## 十、追溯字段与数据规范（关键字段标准）

  > **追踪链路分层**：原材料（RAW） → 组件（COMPONENT） → 成品（FINISHED）
>  **核心属性**：对应工序、工序执行开始时间和结束时间、执行人、执行结果（PASS/FAIL/REWORK/HOLD），以及工位/设备、班次等上下文。
  
### 10.1 命名与通用约定
  
  - `snake_case`；主键 `*_id`；序列号 `sn`；编号前缀（`PO-`/`LOT-` 等）。
- 时间统一存 UTC，后端字段 `*_at`，前端本地化显示。
  - 多租户字段：`tenant_id` / `site_id`（可选 `org_id`）。
- 审计：`created_by/created_at/updated_by/updated_at/source_system`。
  - 受控变更：`version/effective_from/effective_to`。
  - 事件/追溯表不可更新删除（仅追加）。
  
  ### 10.2 核心标识体系（统一编码）
  
  | 实体      | 字段               | 规则示例                 | 说明                        |
| --------- | ------------------ | ------------------------ | --------------------------- |
  | 物料      | `item_id`          | ITM-YYYYMM-XXXX          | 与 ERP `item_code` 唯一映射 |
| 模具      | `mold_id`          | MLD-SUP-XXXX             | SUP 为供应商编码            |
  | 供应商    | `supplier_id`      | SUP-XXXXX                | 供应商主数据                |
  | 采购订单  | `po_id`            | PO-YYYYMMDD-SEQ          | 对应 ERP `po_no`            |
  | 收货/来料 | `grn_id`           | GRN-YYYYMMDD-SEQ         | 收货批                      |
  | 生产工单  | `wo_id`            | WO-LINE-SEQ              | 产线 LINE                   |
  | 生产批次  | `lot_id`           | LOT-YYYYMMDD-SEQ         | 与工单强关联                |
  | 序列号    | `sn`               | SN-{lot_id}-{SEQ}        | 强绑定批次                  |
  | 箱号      | `box_no`           | BOX-YYYYMMDD-SEQ         | 出货包装                    |
  | 托盘号    | `pallet_no`        | PLT-YYYYMMDD-SEQ         | 物流打托                    |
  | 出货单    | `shipment_id`      | SHP-YYYYMMDD-SEQ         | 出货主单                    |
  | 检验单    | `insp_id`          | INSP-{type}-YYYYMMDD-SEQ | type=IQC/IPQC/OQC/FAI       |
  | NCR/SCAR  | `ncr_id`/`scar_id` | NCR-.../SCAR-...         | 闭环质量                    |
  
  > 统一“发号器服务”防并发冲突；对内可 UUID，对外展示保前缀语义。
  
  ### 10.3 结构化追溯映射（四张关键映射表）

  ```sql
-- SN → 批次/工单/箱号/托盘
  CREATE TABLE map_sn (
  sn         VARCHAR(64) PRIMARY KEY,
    lot_id     VARCHAR(32) NOT NULL,
    wo_id      VARCHAR(32) NOT NULL,
    box_no     VARCHAR(64),
    pallet_no  VARCHAR(64),
    tenant_id  VARCHAR(32), site_id VARCHAR(32),
    created_at DATETIME, created_by VARCHAR(64)
  );
  CREATE INDEX idx_map_sn_lot ON map_sn(lot_id);
  CREATE INDEX idx_map_sn_box ON map_sn(box_no);
  
  -- 箱号 → SN
  CREATE TABLE map_box_sn (
    id        BIGINT PRIMARY KEY AUTO_INCREMENT,
    box_no    VARCHAR(64) NOT NULL,
    sn        VARCHAR(64) NOT NULL,
    tenant_id VARCHAR(32), site_id VARCHAR(32),
    created_at DATETIME
  );
  CREATE INDEX idx_box_sn_box ON map_box_sn(box_no);
  
  -- 托盘 → 箱号
  CREATE TABLE map_pallet_box (
    id        BIGINT PRIMARY KEY AUTO_INCREMENT,
    pallet_no VARCHAR(64) NOT NULL,
    box_no    VARCHAR(64) NOT NULL,
    created_at DATETIME
  );
  CREATE INDEX idx_pallet_box_pl ON map_pallet_box(pallet_no);
  
  -- 批次 → 用料来源（供应商/来料批次/模具）
  CREATE TABLE map_lot_material (
    id          BIGINT PRIMARY KEY AUTO_INCREMENT,
    lot_id      VARCHAR(32) NOT NULL,
    item_id     VARCHAR(32) NOT NULL,
    supplier_id VARCHAR(32),
    grn_id      VARCHAR(32),
    mold_id     VARCHAR(32),
    qty_used    DECIMAL(18,4),
    created_at  DATETIME
  );
  CREATE INDEX idx_lot_material_lot ON map_lot_material(lot_id);
  ```
  
  > 支持 **正向**（订单→出货）与 **反向**（SN→用料/模具/供应商）O(1~log n) 查询。
  
  ### 10.4 工艺/工序可扩展建模（插拔式）

  ```sql
-- 工艺路线（版本化）
  CREATE TABLE routing (
  routing_id     VARCHAR(32) PRIMARY KEY,
    item_id        VARCHAR(32),
    version        INT,
    effective_from DATETIME, effective_to DATETIME,
    status         VARCHAR(16)
  );
  
  -- 工序定义（可插拔，按序号排列）
  CREATE TABLE operation (
    op_id        VARCHAR(32) PRIMARY KEY,
    routing_id   VARCHAR(32) NOT NULL,
    op_seq       INT NOT NULL,
    op_code      VARCHAR(32),   -- 组装/上电/初测/终测/包装...
    station_id   VARCHAR(32),   -- 工位/设备
    sop_id       VARCHAR(32), sop_version INT,
    sample_plan  JSON,          -- 抽检/AQL参数
    check_items  JSON,          -- 质检项目模板
    UNIQUE KEY uk_routing_seq(routing_id, op_seq)
  );
  ```
  
  > 新增工序只需插入 `operation`，工单启动时将 `routing` 快照化为实例表 `wo_operation`。
  
  ### 10.5 事件溯源（**核心**：工序+人员+时间+结果）

  ```sql
-- 所有可追节点抽象为不可变事件
  CREATE TABLE trace_event (
  event_id       VARCHAR(40) PRIMARY KEY,
    entity_type    VARCHAR(32),   -- SN/LOT/WO/GRN/BOX/PLT/INSP
    entity_id      VARCHAR(64),
    action         VARCHAR(32),   -- START/END/PASS/FAIL/REWORK/MOVE/PACK/SHIP...
    occurred_at    DATETIME,
    op_id          VARCHAR(32),   -- 对应工序
    op_name        VARCHAR(64),
    op_start_at    DATETIME,
    op_end_at      DATETIME,
    operator_id    VARCHAR(64),
    result         VARCHAR(16),   -- PASS/FAIL/REWORK/HOLD
    station_id     VARCHAR(64),
    shift_code     VARCHAR(16),
    ref_id         VARCHAR(64),   -- 业务单据：insp_id/stock_txn等
    data           JSON,          -- 测量值/参数/附件key等
    prev_event_id  VARCHAR(40),   -- 链式追溯
    correlation_id VARCHAR(64),   -- 同事务/同工序相关性
    tenant_id      VARCHAR(32), site_id VARCHAR(32),
    source_system  VARCHAR(32),
    created_at     DATETIME
  );
  CREATE INDEX idx_event_entity ON trace_event(entity_type, entity_id, occurred_at);
  CREATE INDEX idx_event_action ON trace_event(action, occurred_at);
  ```
  
  - **新增追踪点** = 新 `action` + 对应上下文写入 `data`（无需改表）；
  - **正反向追溯**：以 `entity_type+entity_id`/`sn` 为入口串联 `prev_event_id`/`correlation_id`。
  
### 10.6 链路快照（三层：原材料/组件/成品）
  
  ```sql
-- 便捷链路快照，用于快速拉通层级（可按需开启）
  CREATE TABLE trace_link (
  id           BIGINT PRIMARY KEY AUTO_INCREMENT,
    level        ENUM('RAW','COMPONENT','FINISHED'),
    sn           VARCHAR(64),
    lot_id       VARCHAR(32),
    wo_id        VARCHAR(32),
    op_id        VARCHAR(32), op_name VARCHAR(64),
    op_start_at  DATETIME, op_end_at DATETIME,
    operator_id  VARCHAR(64),
    result       ENUM('PASS','FAIL','REWORK','HOLD'),
    station_id   VARCHAR(64),
    next_sn      VARCHAR(64),     -- 指向上层（组件→成品）的SN
    tenant_id    VARCHAR(32), site_id VARCHAR(32),
    created_at   DATETIME, updated_at DATETIME
  );
  CREATE INDEX idx_trace_link_sn   ON trace_link(sn);
  CREATE INDEX idx_trace_link_next ON trace_link(next_sn);
  ```
  
  > 快照表可由 `trace_event` 定时回填，提升查询速度；结构保持稳定，便于后续随时增加工序或追踪节点。
  
  ### 10.7 品质码表与检验明细对齐

  ```sql
-- 缺陷/原因/处置 三级字典
  CREATE TABLE qms_code (
  code_type   VARCHAR(16),   -- DEFECT/CAUSE/ACTION
    code        VARCHAR(32),
    description VARCHAR(255),
    PRIMARY KEY (code_type, code)
  );
  
  -- 检验明细对齐码表
  ALTER TABLE inspection_item
    ADD COLUMN defect_code VARCHAR(32),
    ADD COLUMN cause_code  VARCHAR(32),
    ADD COLUMN action_code VARCHAR(32);
  ```
  
  ### 10.8 附件与测量元数据
  
  ```sql
ALTER TABLE attachment
    ADD COLUMN tenant_id VARCHAR(32),
  ADD COLUMN site_id   VARCHAR(32),
    ADD COLUMN biz_path  VARCHAR(128),
    ADD COLUMN checksum  CHAR(64);
  
  CREATE TABLE measure_record (
    id          BIGINT PRIMARY KEY AUTO_INCREMENT,
    insp_id     VARCHAR(32),
    item_key    VARCHAR(64),
    value_num   DECIMAL(18,6),
    unit        VARCHAR(16),
    measured_at DATETIME
  );
  ```
  
  ### 10.9 条码/二维码
  
  - 建议 Code128（条码）+ QR（二维码）双制式；
- 内容：`key|value` 键值或 GS1（AI 码）；
  - 最小集合：`sn/lot_id/wo_id/box_no/pallet_no`。

  ### 10.10 追溯 API 契约（示例）
  
  - `GET /trace/reverse?sn=...`

  ```json
{
    "sn": "SN-LOT-0001-0012",
  "lot": "LOT-20251007-0001",
    "wo": "WO-L1-8899",
    "operations": [
      {"op_name":"终检","start":"2025-10-07T09:00Z","end":"2025-10-07T09:05Z","operator":"OP123","result":"PASS"}
    ],
    "materials": [{"item_id":"ITM-202510-0012","supplier_id":"SUP-ACME","grn_id":"GRN-20251007-017"}],
    "quality": {"iqc":"PASS","oqc":"PASS","defect_top":[{"code":"SOLDER-01","cnt":3}]},
    "shipping": {"box_no":"BOX-20251007-008","pallet_no":"PLT-20251007-003","shipment_id":"SHP-20251007-002"}
  }
  ```
  
  ### 10.11 索引/分区与性能
  
  - 分区：`trace_event/test_record/inspection_item/stock_txn` 按日/周；
- 覆盖索引：`(entity_type,entity_id,occurred_at)`、`(sn,tested_at)`、`(box_no)`、`(pallet_no)`；
  - BI 走只读库，事务走主库；大查询限时窗+分页。

  ### 10.12 字段演化与扩展机制
  
  - **新增工序**：仅增 `operation` 行；
- **新增追踪点**：仅增 `trace_event.action`；
  - **新增字段**：优先放 `data(JSON)`；
- **弃用字段**：标注 `deprecated_at`，避免物理删除。
