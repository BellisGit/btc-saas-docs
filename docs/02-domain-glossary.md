# MES系统领域词汇表

## 概述

本文档定义了MES制造执行系统中使用的业务术语和技术概念，确保团队成员对业务领域有统一的理解。词汇表按照业务域分类，便于查找和理解。

## 基础数据域

### 物料管理
- **物料 (Item/Material)**：生产过程中使用的所有物品，包括原材料、半成品、成品、工具、耗材等
- **物料编码 (Item Code)**：物料的唯一标识符，格式：ITM-YYYYMM-XXXX
- **物料类型 (Item Type)**：
  - RAW：原材料
  - COMPONENT：组件/半成品
  - FINISHED：成品
  - TOOL：工具
  - CONSUMABLE：耗材
- **UOM (Unit of Measure)**：计量单位，如PCS、KG、M等
- **规格 (Specification)**：物料的详细技术规格和参数

### 供应商管理
- **供应商 (Supplier)**：提供物料或服务的合作伙伴
- **供应商编码 (Supplier Code)**：供应商的唯一标识符，格式：SUP-XXXXX
- **质量评分 (Quality Rating)**：基于历史表现对供应商的质量评价分数
- **供应商状态 (Supplier Status)**：
  - ACTIVE：活跃供应商
  - INACTIVE：非活跃供应商
  - BLACKLIST：黑名单供应商

### 模具管理
- **模具 (Mold)**：用于生产特定产品的工具
- **模具编码 (Mold Code)**：模具的唯一标识符，格式：MLD-SUP-XXXX
- **模具类型 (Mold Type)**：
  - INJECTION：注塑模具
  - STAMPING：冲压模具
  - ASSEMBLY：装配治具
  - TESTING：测试治具
- **模具维护 (Mold Maintenance)**：定期对模具进行保养和维修

## 采购管理域

### 采购流程
- **采购订单 (Purchase Order, PO)**：向供应商下达的采购指令
- **采购订单号 (PO Number)**：采购订单的唯一标识符，格式：PO-YYYYMMDD-SEQ
- **预期交货日期 (Expected Delivery Date)**：供应商承诺的交货时间
- **采购状态 (PO Status)**：
  - DRAFT：草稿
  - CONFIRMED：已确认
  - PARTIAL_RECEIVED：部分收货
  - COMPLETED：已完成
  - CANCELLED：已取消

### 收货管理
- **收货单 (Goods Receipt Note, GRN)**：记录实际收货信息的单据
- **收货单号 (GRN Number)**：收货单的唯一标识符，格式：GRN-YYYYMMDD-SEQ
- **送货单号 (Delivery Note Number)**：供应商提供的送货单据号
- **收货状态 (GRN Status)**：
  - DRAFT：草稿
  - RECEIVED：已收货
  - INSPECTED：已检验
  - ACCEPTED：已接受
  - REJECTED：已拒收

## 生产管理域

### 工单管理
- **工单 (Work Order, WO)**：生产任务的执行指令
- **工单号 (WO Number)**：工单的唯一标识符，格式：WO-LINE-SEQ
- **计划数量 (Planned Quantity)**：工单计划生产的产品数量
- **实际数量 (Actual Quantity)**：工单实际完成的产品数量
- **工单状态 (WO Status)**：
  - DRAFT：草稿
  - RELEASED：已发布
  - IN_PROGRESS：进行中
  - COMPLETED：已完成
  - CANCELLED：已取消
  - ON_HOLD：暂停

### 批次管理
- **生产批次 (Production Lot)**：一次生产任务产生的产品批次
- **批次号 (Lot Number)**：批次的唯一标识符，格式：LOT-YYYYMMDD-SEQ
- **批次数量 (Lot Quantity)**：该批次生产的产品数量
- **FAI (First Article Inspection)**：首件检验，批量生产前的首件验证
- **FAI状态 (FAI Status)**：
  - PENDING：待验证
  - PASS：通过
  - FAIL：失败

### 序列号管理
- **序列号 (Serial Number, SN)**：单个产品的唯一标识符
- **序列号格式 (SN Format)**：SN-{lot_id}-{SEQ}
- **序列号状态 (SN Status)**：
  - PLANNED：计划中
  - IN_PROGRESS：生产中
  - COMPLETED：已完成
  - REJECTED：已拒收
  - REWORK：返修中

## 工艺管理域

### 工艺路线
- **工艺路线 (Routing)**：产品生产的标准工艺流程
- **工艺路线ID (Routing ID)**：工艺路线的唯一标识符
- **版本 (Version)**：工艺路线的版本号，支持版本管理
- **生效期 (Effective Period)**：工艺路线的有效时间范围
- **工艺路线状态 (Routing Status)**：
  - DRAFT：草稿
  - ACTIVE：激活
  - OBSOLETE：废弃

### 工序管理
- **工序 (Operation)**：工艺路线中的单个操作步骤
- **工序ID (Operation ID)**：工序的唯一标识符
- **工序序号 (Operation Sequence)**：工序在工艺路线中的执行顺序
- **工序代码 (Operation Code)**：工序的编码，如SMT、DIP、ASSY等
- **工序名称 (Operation Name)**：工序的描述性名称
- **工位 (Station)**：执行工序的具体位置或设备
- **SOP (Standard Operating Procedure)**：标准作业程序
- **预估时间 (Estimated Time)**：工序的预估执行时间

## 品质管理域

### 检验管理
- **检验单 (Inspection)**：记录检验过程和结果的单据
- **检验单号 (Inspection Number)**：检验单的唯一标识符，格式：INSP-{type}-YYYYMMDD-SEQ
- **检验类型 (Inspection Type)**：
  - IQC (Incoming Quality Control)：来料检验
  - IPQC (In-Process Quality Control)：过程检验
  - OQC (Outgoing Quality Control)：出货检验
  - FAI (First Article Inspection)：首件检验
- **检验结果 (Inspection Result)**：
  - PASS：通过
  - FAIL：失败
  - SPECIAL：特采
  - PENDING：待检验

### 抽样检验
- **AQL (Acceptable Quality Level)**：可接受质量水平
- **抽样数量 (Sample Size)**：检验时抽取的样本数量
- **缺陷数量 (Defect Quantity)**：检验中发现的缺陷产品数量
- **检验员 (Inspector)**：执行检验的人员

### 缺陷管理
- **缺陷代码 (Defect Code)**：缺陷类型的编码
- **原因代码 (Cause Code)**：缺陷产生原因的编码
- **处置代码 (Action Code)**：缺陷处置方式的编码
- **NCR (Non-Conformance Report)**：不合格报告
- **SCAR (Supplier Corrective Action Request)**：供应商纠正措施要求

### 测试管理
- **测试记录 (Test Record)**：产品测试过程的记录
- **测试工位 (Test Station)**：执行测试的工位或设备
- **测试类型 (Test Type)**：测试的分类，如功能测试、性能测试等
- **测试数据 (Test Data)**：测试过程中产生的数据，以JSON格式存储
- **操作员 (Operator)**：执行测试的人员

## 库存管理域

### 库存基础
- **库存 (Stock)**：存储在仓库中的物料数量
- **库位 (Location)**：物料存储的具体位置
- **批次号 (Lot Number)**：库存物料的批次标识
- **库存数量 (Stock Quantity)**：当前库存的总数量
- **可用数量 (Available Quantity)**：可以使用的库存数量
- **预留数量 (Reserved Quantity)**：已被预留但未使用的库存数量

### 库存状态
- **库存状态 (Stock Status)**：
  - AVAILABLE：可用
  - RESERVED：预留
  - QUARANTINE：隔离
  - REJECTED：拒收
- **过期日期 (Expiry Date)**：物料的过期时间
- **单位成本 (Unit Cost)**：单个物料的成本
- **总成本 (Total Cost)**：库存的总价值

### 库存事务
- **库存事务 (Stock Transaction)**：库存变化的事务记录
- **事务类型 (Transaction Type)**：
  - IN：入库
  - OUT：出库
  - TRANSFER：移库
  - ADJUST：调整
  - RESERVE：预留
  - UNRESERVE：取消预留
- **关联单据 (Reference Document)**：引起库存变化的相关单据

## 追溯系统域

### 事件溯源
- **追溯事件 (Trace Event)**：生产过程中发生的可追溯事件
- **事件ID (Event ID)**：事件的唯一标识符
- **实体类型 (Entity Type)**：事件关联的实体类型，如SN、LOT、WO等
- **实体ID (Entity ID)**：事件关联的实体标识符
- **动作 (Action)**：事件的动作类型，如START、END、PASS、FAIL等
- **发生时间 (Occurred At)**：事件发生的具体时间
- **操作员 (Operator)**：执行操作的人员
- **工位 (Station)**：事件发生的工位或设备
- **班次 (Shift)**：事件发生的班次

### 追溯映射
- **序列号映射 (SN Mapping)**：序列号与其他实体的关联关系
- **批次用料映射 (Lot Material Mapping)**：批次与使用物料的关联关系
- **箱号 (Box Number)**：产品包装箱的标识符，格式：BOX-YYYYMMDD-SEQ
- **托盘号 (Pallet Number)**：产品托盘的标识符，格式：PLT-YYYYMMDD-SEQ
- **出货单 (Shipment)**：产品出货的单据，格式：SHP-YYYYMMDD-SEQ

### 追溯方向
- **正向追溯 (Forward Traceability)**：从订单到出货的追溯路径
- **反向追溯 (Backward Traceability)**：从序列号到原材料的追溯路径
- **关联ID (Correlation ID)**：相关事件的关联标识符
- **前一个事件 (Previous Event)**：事件链中的前一个事件

## BI数据聚合域

### 聚合基础
- **时间桶 (Time Bucket)**：数据聚合的时间窗口，如5分钟、1小时等
- **聚合表 (Aggregation Table)**：存储聚合数据的表
- **增量聚合 (Incremental Aggregation)**：基于时间增量的数据聚合
- **物化视图 (Materialized View)**：预计算的查询结果

### 关键指标
- **良率 (Yield Rate)**：合格产品占总产品的百分比
- **通过数量 (Pass Count)**：检验通过的产品数量
- **失败数量 (Fail Count)**：检验失败的产品数量
- **WIP (Work In Process)**：在制品，正在生产过程中的产品
- **设备效率 (Equipment Efficiency)**：设备实际运行时间与计划时间的比率
- **库存周转率 (Inventory Turnover)**：库存的周转速度指标

### 性能指标
- **响应时间 (Response Time)**：系统响应用户请求的时间
- **吞吐量 (Throughput)**：系统在单位时间内处理的事务数量
- **并发数 (Concurrency)**：同时访问系统的用户数量
- **可用性 (Availability)**：系统正常运行时间的百分比

## 系统集成域

### 外部系统
- **ERP (Enterprise Resource Planning)**：企业资源计划系统
- **ITL (Information Technology Laboratory)**：总部信息技术实验室
- **OSS (Object Storage Service)**：对象存储服务，用于文件存储
- **API (Application Programming Interface)**：应用程序编程接口

### 数据同步
- **实时同步 (Real-time Sync)**：数据变化的实时同步
- **批量同步 (Batch Sync)**：定时的批量数据同步
- **增量同步 (Incremental Sync)**：基于变化增量的数据同步
- **全量同步 (Full Sync)**：完整数据的同步

### 接口协议
- **REST API**：基于HTTP的RESTful接口
- **WebSocket**：实时双向通信协议
- **JSON**：JavaScript对象表示法，数据交换格式
- **JWT (JSON Web Token)**：用于身份验证的令牌

## 安全与合规域

### 身份认证
- **用户 (User)**：系统使用者
- **角色 (Role)**：用户的权限角色
- **权限 (Permission)**：用户可执行的操作权限
- **租户 (Tenant)**：多租户架构中的租户标识
- **站点 (Site)**：租户下的站点标识

### 数据安全
- **加密 (Encryption)**：数据的加密保护
- **脱敏 (Data Masking)**：敏感数据的脱敏处理
- **审计 (Audit)**：操作行为的审计记录
- **合规 (Compliance)**：符合相关法规要求

### 访问控制
- **行级权限 (Row-level Security)**：基于数据行的访问控制
- **列级权限 (Column-level Security)**：基于数据列的访问控制
- **API权限 (API Permission)**：接口访问权限控制
- **数据权限 (Data Permission)**：数据访问权限控制

## 运维管理域

### 监控告警
- **监控 (Monitoring)**：系统运行状态的监控
- **告警 (Alert)**：异常情况的告警通知
- **指标 (Metric)**：系统性能指标
- **日志 (Log)**：系统运行日志
- **链路追踪 (Tracing)**：请求的完整执行链路

### 备份恢复
- **备份 (Backup)**：数据的备份操作
- **恢复 (Recovery)**：数据的恢复操作
- **归档 (Archive)**：历史数据的归档存储
- **灾难恢复 (Disaster Recovery)**：灾难情况下的数据恢复

### 性能优化
- **索引 (Index)**：数据库查询性能优化
- **缓存 (Cache)**：数据缓存提升性能
- **分区 (Partition)**：大表的分区存储
- **负载均衡 (Load Balancing)**：请求的负载均衡分发

## 移动端域

### 移动应用
- **小程序 (Mini Program)**：微信小程序应用
- **APP**：移动应用程序
- **H5**：基于HTML5的移动网页应用
- **响应式设计 (Responsive Design)**：适配不同屏幕尺寸的设计

### 移动功能
- **扫码 (QR Code Scanning)**：二维码扫描功能
- **离线操作 (Offline Operation)**：无网络环境下的操作
- **数据同步 (Data Sync)**：移动端与服务器的数据同步
- **推送通知 (Push Notification)**：消息推送功能

## 技术术语

### 开发技术
- **Vue3**：前端开发框架
- **Element Plus**：Vue3组件库
- **uniapp**：跨平台移动应用开发框架
- **uview-plus**：uniapp UI组件库
- **ECharts**：数据可视化图表库
- **MySQL**：关系型数据库
- **Redis**：内存数据库
- **Node.js**：JavaScript运行环境

### 架构模式
- **微服务 (Microservices)**：微服务架构模式
- **事件驱动 (Event-driven)**：事件驱动架构
- **CQRS (Command Query Responsibility Segregation)**：命令查询职责分离
- **事件溯源 (Event Sourcing)**：事件溯源模式
- **DDD (Domain-Driven Design)**：领域驱动设计

### 设计模式
- **MVC (Model-View-Controller)**：模型-视图-控制器模式
- **Repository**：仓储模式
- **Factory**：工厂模式
- **Observer**：观察者模式
- **Strategy**：策略模式