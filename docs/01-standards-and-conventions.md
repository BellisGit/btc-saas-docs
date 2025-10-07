# MES系统标准与规范

## 概述

本文档定义了MES制造执行系统的标准与规范，包括数据库设计、API接口、前端开发、移动端开发等各个层面的规范要求。所有开发工作都应严格遵循这些规范，确保系统的一致性、可维护性和可扩展性。

## 数据库规范

### 1. 数据库和Schema命名

#### 1.1 数据库命名
- **主数据库**：`mes_core`（MES核心业务数据）
- **命名规则**：小写字母，下划线分隔，语义明确
- **示例**：`mes_core`、`mes_bi`、`mes_log`

#### 1.2 Schema命名（如需要）
- **业务域Schema**：`asset`、`quality`、`logistics`、`production`、`trace`
- **系统Schema**：`system`、`audit`、`config`

### 2. 表命名规范

#### 2.1 实体表命名
- **规则**：小写蛇形复数形式
- **示例**：
  - `item_master` - 物料主数据
  - `supplier_master` - 供应商主数据
  - `work_orders` - 生产工单
  - `production_lots` - 生产批次
  - `serial_numbers` - 序列号

#### 2.2 关联表命名
- **规则**：`a_b_links` 或 `a_b` 格式
- **示例**：
  - `employee_skills` - 员工技能关联
  - `purchase_order_items` - 采购订单明细
  - `goods_receipt_items` - 收货明细

#### 2.3 聚合表命名
- **规则**：`agg_` 前缀 + 描述性名称
- **示例**：
  - `agg_yield_5m` - 5分钟良率聚合
  - `agg_wip_status` - WIP状态聚合
  - `agg_production_progress` - 生产进度聚合

#### 2.4 视图命名
- **规则**：`v_` 前缀 + 描述性名称
- **示例**：
  - `v_work_order_summary` - 工单汇总视图
  - `v_inventory_status` - 库存状态视图

### 3. 列命名规范

#### 3.1 主键命名
- **规则**：`<entity_name>_id`
- **示例**：
  - `item_id` - 物料ID
  - `supplier_id` - 供应商ID
  - `work_order_id` - 工单ID

#### 3.2 外键命名
- **规则**：`<referenced_table>_id`
- **示例**：
  - `supplier_id` 引用 `supplier_master` 表
  - `item_id` 引用 `item_master` 表

#### 3.3 时间字段命名
- **创建时间**：`created_at`
- **更新时间**：`updated_at`
- **业务时间**：`<business>_at`（如：`tested_at`、`shipped_at`）
- **有效期**：`valid_from`、`valid_to`

#### 3.4 审计字段命名
- **创建人**：`created_by`
- **更新人**：`updated_by`
- **来源系统**：`source_system`

#### 3.5 多租户字段命名
- **租户ID**：`tenant_id`
- **站点ID**：`site_id`
- **组织ID**：`org_id`（可选）

### 4. 数据类型规范

#### 4.1 主键类型
- **首选**：VARCHAR(32) 用于业务主键
- **备选**：BIGINT AUTO_INCREMENT 用于自增ID
- **示例**：
  - `item_id VARCHAR(32) PRIMARY KEY` - 业务主键
  - `id BIGINT AUTO_INCREMENT PRIMARY KEY` - 自增主键

#### 4.2 时间类型
- **时间戳**：`DATETIME` 类型
- **日期**：`DATE` 类型
- **时间**：`TIME` 类型
- **时区**：所有时间戳使用UTC存储，前端显示时转换

#### 4.3 字符串类型
- **代码字段**：`VARCHAR(32)` 或 `VARCHAR(64)`
- **名称字段**：`VARCHAR(128)` 或 `VARCHAR(256)`
- **描述字段**：`TEXT` 类型
- **JSON数据**：`JSON` 类型

#### 4.4 数值类型
- **数量**：`DECIMAL(18,4)` 高精度小数
- **金额**：`DECIMAL(18,2)` 金额字段
- **百分比**：`DECIMAL(5,2)` 百分比字段
- **整数**：`BIGINT` 64位整数
- **布尔值**：`TINYINT(1)` 或 `ENUM('Y','N')`

### 5. 约束命名规范

#### 5.1 主键约束
- **规则**：`PRIMARY KEY`
- **示例**：`PRIMARY KEY (item_id)`

#### 5.2 外键约束
- **规则**：`fk_<table>_<referenced_table>`
- **示例**：
  - `fk_work_order_item` - 工单表的外键
  - `fk_purchase_order_supplier` - 采购订单表的外键

#### 5.3 唯一约束
- **规则**：`uk_<table>_<columns>`
- **示例**：
  - `uk_item_master_code` - 物料代码唯一约束
  - `uk_supplier_master_code` - 供应商代码唯一约束

#### 5.4 检查约束
- **规则**：`ck_<table>_<column>`
- **示例**：
  - `ck_work_order_quantity` - 工单数量检查约束

### 6. 索引命名规范

#### 6.1 普通索引
- **规则**：`idx_<table>_<columns>`
- **示例**：
  - `idx_work_order_status` - 工单状态索引
  - `idx_production_lot_wo_id` - 批次工单ID索引

#### 6.2 唯一索引
- **规则**：`uk_<table>_<columns>`
- **示例**：
  - `uk_serial_number_sn` - 序列号唯一索引

#### 6.3 复合索引
- **规则**：`idx_<table>_<column1>_<column2>`
- **示例**：
  - `idx_trace_event_entity_type_id` - 追溯事件复合索引

## MES业务标识规范

### 1. 编码规则

#### 1.1 物料编码
- **格式**：`ITM-YYYYMM-XXXX`
- **示例**：`ITM-202501-0001`
- **说明**：ITM + 年月 + 4位序号

#### 1.2 供应商编码
- **格式**：`SUP-XXXXX`
- **示例**：`SUP-ACME001`
- **说明**：SUP + 5位供应商代码

#### 1.3 模具编码
- **格式**：`MLD-SUP-XXXX`
- **示例**：`MLD-SUP-0001`
- **说明**：MLD + 供应商代码 + 4位序号

#### 1.4 采购订单编码
- **格式**：`PO-YYYYMMDD-SEQ`
- **示例**：`PO-20250107-001`
- **说明**：PO + 日期 + 3位序号

#### 1.5 工单编码
- **格式**：`WO-LINE-SEQ`
- **示例**：`WO-L1-0001`
- **说明**：WO + 产线 + 4位序号

#### 1.6 批次编码
- **格式**：`LOT-YYYYMMDD-SEQ`
- **示例**：`LOT-20250107-001`
- **说明**：LOT + 日期 + 3位序号

#### 1.7 序列号编码
- **格式**：`SN-{lot_id}-{SEQ}`
- **示例**：`SN-LOT-20250107-001-0001`
- **说明**：SN + 批次号 + 4位序号

#### 1.8 检验单编码
- **格式**：`INSP-{type}-YYYYMMDD-SEQ`
- **示例**：`INSP-IQC-20250107-001`
- **说明**：INSP + 检验类型 + 日期 + 3位序号

### 2. 状态枚举规范

#### 2.1 通用状态
- `ACTIVE` - 激活
- `INACTIVE` - 未激活
- `PENDING` - 待处理
- `PROCESSING` - 处理中
- `COMPLETED` - 已完成
- `CANCELLED` - 已取消
- `FAILED` - 失败

#### 2.2 工单状态
- `DRAFT` - 草稿
- `RELEASED` - 已发布
- `IN_PROGRESS` - 进行中
- `COMPLETED` - 已完成
- `CANCELLED` - 已取消
- `ON_HOLD` - 暂停

#### 2.3 检验结果
- `PASS` - 通过
- `FAIL` - 失败
- `SPECIAL` - 特采
- `PENDING` - 待检验

#### 2.4 库存状态
- `AVAILABLE` - 可用
- `RESERVED` - 预留
- `QUARANTINE` - 隔离
- `REJECTED` - 拒收

## API接口规范

### 1. RESTful API设计

#### 1.1 URL命名规范
- **规则**：小写字母，连字符分隔
- **示例**：
  - `GET /api/work-orders` - 获取工单列表
  - `POST /api/work-orders` - 创建工单
  - `GET /api/work-orders/{id}` - 获取单个工单
  - `PUT /api/work-orders/{id}` - 更新工单
  - `DELETE /api/work-orders/{id}` - 删除工单

#### 1.2 HTTP方法规范
- **GET**：查询操作
- **POST**：创建操作
- **PUT**：更新操作（全量更新）
- **PATCH**：更新操作（部分更新）
- **DELETE**：删除操作

#### 1.3 状态码规范
- **200**：成功
- **201**：创建成功
- **400**：请求参数错误
- **401**：未授权
- **403**：禁止访问
- **404**：资源不存在
- **500**：服务器内部错误

### 2. 请求响应格式

#### 2.1 统一响应格式
```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": "2025-01-07T10:30:00Z",
  "traceId": "trace-123456"
}
```

#### 2.2 分页响应格式
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "items": [],
    "pagination": {
      "page": 1,
      "size": 20,
      "total": 100,
      "pages": 5
    }
  }
}
```

#### 2.3 错误响应格式
```json
{
  "code": 400,
  "message": "参数错误",
  "errors": [
    {
      "field": "itemId",
      "message": "物料ID不能为空"
    }
  ],
  "timestamp": "2025-01-07T10:30:00Z",
  "traceId": "trace-123456"
}
```

### 3. 参数规范

#### 3.1 查询参数
- **分页参数**：`page`、`size`
- **排序参数**：`sort`、`order`
- **过滤参数**：`filter`、`search`
- **示例**：`GET /api/work-orders?page=1&size=20&sort=created_at&order=desc`

#### 3.2 路径参数
- **规则**：使用资源ID
- **示例**：`GET /api/work-orders/{workOrderId}`

#### 3.3 请求体参数
- **规则**：使用JSON格式
- **示例**：
```json
{
  "itemId": "ITM-202501-0001",
  "plannedQuantity": 1000,
  "priority": "HIGH"
}
```

## 前端开发规范

### 1. Vue3开发规范

#### 1.1 组件命名
- **规则**：PascalCase
- **示例**：`WorkOrderList.vue`、`QualityInspection.vue`

#### 1.2 文件结构
```
src/
├── components/          # 公共组件
├── views/              # 页面组件
├── router/             # 路由配置
├── store/              # 状态管理
├── api/                # API接口
├── utils/              # 工具函数
├── styles/             # 样式文件
└── assets/             # 静态资源
```

#### 1.3 组件开发规范
- 使用Composition API
- 使用TypeScript（推荐）
- 组件props定义类型
- 使用Element Plus组件库

#### 1.4 状态管理规范
- 使用Pinia进行状态管理
- 按模块划分store
- 使用TypeScript定义类型

### 2. Element Plus使用规范

#### 2.1 组件使用
- 优先使用Element Plus组件
- 保持UI风格一致
- 响应式设计

#### 2.2 表单验证
- 使用Element Plus表单验证
- 自定义验证规则
- 错误信息国际化

#### 2.3 表格使用
- 使用el-table组件
- 支持排序、筛选、分页
- 自定义列渲染

### 3. 样式规范

#### 3.1 CSS命名
- **规则**：BEM命名规范
- **示例**：`.work-order-list__item--active`

#### 3.2 响应式设计
- 使用Element Plus的栅格系统
- 移动端适配
- 断点设置：768px、1024px、1200px

## 移动端开发规范

### 1. uniapp开发规范

#### 1.1 页面命名
- **规则**：kebab-case
- **示例**：`work-order-list.vue`、`quality-inspection.vue`

#### 1.2 文件结构
```
src/
├── pages/              # 页面文件
├── components/         # 公共组件
├── static/             # 静态资源
├── store/              # 状态管理
├── api/                # API接口
├── utils/              # 工具函数
└── uni_modules/        # uni-app插件
```

#### 1.3 组件开发规范
- 使用Vue3 Composition API
- 使用uview-plus组件库
- 适配多端（H5、小程序、APP）

#### 1.4 页面配置
- 使用pages.json配置页面
- 设置页面标题和导航栏
- 配置tabBar

### 2. 移动端UI规范

#### 2.1 设计原则
- 简洁明了
- 操作便捷
- 信息层次清晰

#### 2.2 组件使用
- 使用uview-plus组件
- 保持设计一致性
- 适配不同屏幕尺寸

#### 2.3 交互规范
- 点击反馈
- 加载状态
- 错误提示

## 代码规范

### 1. JavaScript/TypeScript规范

#### 1.1 命名规范
- **变量**：camelCase
- **常量**：UPPER_SNAKE_CASE
- **函数**：camelCase
- **类**：PascalCase

#### 1.2 代码风格
- 使用ESLint进行代码检查
- 使用Prettier进行代码格式化
- 2空格缩进
- 单引号字符串

#### 1.3 注释规范
- 函数注释使用JSDoc
- 复杂逻辑添加行内注释
- 文件头部添加文件说明

### 2. 提交规范

#### 2.1 提交信息格式
```
<type>(<scope>): <subject>

<body>

<footer>
```

#### 2.2 类型说明
- `feat`：新功能
- `fix`：修复bug
- `docs`：文档更新
- `style`：代码格式调整
- `refactor`：代码重构
- `test`：测试相关
- `chore`：构建过程或辅助工具的变动

#### 2.3 示例
```
feat(work-order): 添加工单创建功能

- 支持工单基本信息录入
- 支持物料清单配置
- 支持工艺路线选择

Closes #123
```

## 测试规范

### 1. 单元测试
- 使用Jest进行单元测试
- 测试覆盖率要求>80%
- 测试文件命名：`*.test.js`或`*.spec.js`

### 2. 集成测试
- API接口测试
- 数据库集成测试
- 端到端测试

### 3. 性能测试
- 接口响应时间测试
- 数据库查询性能测试
- 前端页面加载性能测试

## 部署规范

### 1. 环境配置
- 开发环境：`development`
- 测试环境：`testing`
- 生产环境：`production`

### 2. 配置管理
- 使用环境变量管理配置
- 敏感信息加密存储
- 配置文件版本控制

### 3. 版本管理
- 使用语义化版本号
- 版本标签管理
- 发布说明文档

## 安全规范

### 1. 数据安全
- 敏感数据加密存储
- 数据传输HTTPS
- 数据库访问权限控制

### 2. 接口安全
- JWT身份认证
- API访问频率限制
- 输入参数验证

### 3. 前端安全
- XSS防护
- CSRF防护
- 内容安全策略

## 监控规范

### 1. 日志规范
- 结构化日志格式
- 日志级别：DEBUG、INFO、WARN、ERROR
- 日志轮转和归档

### 2. 监控指标
- 系统性能指标
- 业务指标监控
- 错误率监控

### 3. 告警机制
- 关键指标告警
- 异常情况告警
- 告警通知机制