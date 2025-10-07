# MES系统逻辑模型

## 概述

本文档描述了MES制造执行系统的逻辑数据模型，作为数据库设计的单一事实来源。该模型定义了系统中所有核心实体的结构、关系和约束，支持完整的制造业业务流程，包括采购、生产、品质、物流、追溯等各个业务域。

## 模型原则

### 设计原则
1. **业务完整性**：覆盖完整的MES业务流程
2. **数据一致性**：通过约束确保数据完整性
3. **可追溯性**：支持正向和反向追溯
4. **可扩展性**：支持未来业务需求扩展
5. **多租户支持**：支持多租户架构

### 技术原则
1. **MySQL优化**：针对MySQL数据库优化设计
2. **性能优先**：合理的索引和分区策略
3. **版本控制**：支持数据版本管理
4. **审计跟踪**：完整的操作历史记录

## 核心业务域

### 1. 基础数据域

#### 1.1 物料主数据 (item_master)
**描述**：系统中所有物料的基础信息
**主键**：`item_id`
**属性**：
- `item_id` VARCHAR(32) - 物料编码（ITM-YYYYMM-XXXX）
- `item_code` VARCHAR(64) - ERP物料编码
- `item_name` VARCHAR(255) - 物料名称
- `item_type` ENUM - 物料类型（RAW/COMPONENT/FINISHED/TOOL/CONSUMABLE）
- `uom` VARCHAR(16) - 计量单位
- `specification` TEXT - 规格说明
- `supplier_id` VARCHAR(32) - 默认供应商
- `status` ENUM - 状态（ACTIVE/INACTIVE/OBSOLETE）
- `tenant_id` VARCHAR(32) - 租户ID
- `site_id` VARCHAR(32) - 站点ID
- 审计字段：`created_by`, `created_at`, `updated_by`, `updated_at`

**约束**：
- 主键：`item_id`
- 唯一约束：`item_code`
- 外键：`supplier_id` → `supplier_master.supplier_id`

#### 1.2 供应商主数据 (supplier_master)
**描述**：供应商基础信息管理
**主键**：`supplier_id`
**属性**：
- `supplier_id` VARCHAR(32) - 供应商编码（SUP-XXXXX）
- `supplier_code` VARCHAR(64) - 供应商代码
- `supplier_name` VARCHAR(255) - 供应商名称
- `contact_person` VARCHAR(100) - 联系人
- `contact_phone` VARCHAR(50) - 联系电话
- `contact_email` VARCHAR(100) - 联系邮箱
- `address` TEXT - 地址
- `status` ENUM - 状态（ACTIVE/INACTIVE/BLACKLIST）
- `quality_rating` DECIMAL(3,2) - 质量评分
- `tenant_id` VARCHAR(32) - 租户ID
- 审计字段：`created_by`, `created_at`, `updated_by`, `updated_at`

**约束**：
- 主键：`supplier_id`
- 唯一约束：`supplier_code`

#### 1.3 模具主数据 (mold_master)
**描述**：模具基础信息管理
**主键**：`mold_id`
**属性**：
- `mold_id` VARCHAR(32) - 模具编码（MLD-SUP-XXXX）
- `mold_code` VARCHAR(64) - 模具代码
- `mold_name` VARCHAR(255) - 模具名称
- `supplier_id` VARCHAR(32) - 供应商ID
- `item_id` VARCHAR(32) - 对应物料ID
- `mold_type` ENUM - 模具类型（INJECTION/STAMPING/ASSEMBLY/TESTING）
- `status` ENUM - 状态（ACTIVE/MAINTENANCE/RETIRED）
- `last_maintenance_date` DATE - 最后维护日期
- `next_maintenance_date` DATE - 下次维护日期
- `tenant_id` VARCHAR(32) - 租户ID
- 审计字段：`created_by`, `created_at`, `updated_by`, `updated_at`

**约束**：
- 主键：`mold_id`
- 唯一约束：`mold_code`
- 外键：`supplier_id` → `supplier_master.supplier_id`
- 外键：`item_id` → `item_master.item_id`

### 2. 采购管理域

#### 2.1 采购订单 (purchase_order)
**描述**：采购订单主表
**主键**：`po_id`
**属性**：
- `po_id` VARCHAR(32) - 采购订单号（PO-YYYYMMDD-SEQ）
- `po_no` VARCHAR(64) - ERP采购订单号
- `supplier_id` VARCHAR(32) - 供应商ID
- `po_date` DATE - 采购日期
- `expected_delivery_date` DATE - 预期交货日期
- `status` ENUM - 状态（DRAFT/CONFIRMED/PARTIAL_RECEIVED/COMPLETED/CANCELLED）
- `total_amount` DECIMAL(18,2) - 总金额
- `currency` VARCHAR(8) - 币种
- `remarks` TEXT - 备注
- `tenant_id` VARCHAR(32) - 租户ID
- 审计字段：`created_by`, `created_at`, `updated_by`, `updated_at`

**约束**：
- 主键：`po_id`
- 唯一约束：`po_no`
- 外键：`supplier_id` → `supplier_master.supplier_id`

#### 2.2 采购订单明细 (purchase_order_item)
**描述**：采购订单明细表
**主键**：`id` (BIGINT AUTO_INCREMENT)
**属性**：
- `id` BIGINT - 自增主键
- `po_id` VARCHAR(32) - 采购订单ID
- `item_id` VARCHAR(32) - 物料ID
- `quantity` DECIMAL(18,4) - 采购数量
- `unit_price` DECIMAL(18,4) - 单价
- `total_amount` DECIMAL(18,2) - 总金额
- `received_quantity` DECIMAL(18,4) - 已收货数量
- `status` ENUM - 状态（PENDING/PARTIAL_RECEIVED/COMPLETED）
- `tenant_id` VARCHAR(32) - 租户ID
- 审计字段：`created_by`, `created_at`, `updated_by`, `updated_at`

**约束**：
- 主键：`id`
- 外键：`po_id` → `purchase_order.po_id`
- 外键：`item_id` → `item_master.item_id`

#### 2.3 收货单 (goods_receipt_note)
**描述**：收货单主表
**主键**：`grn_id`
**属性**：
- `grn_id` VARCHAR(32) - 收货单号（GRN-YYYYMMDD-SEQ）
- `po_id` VARCHAR(32) - 采购订单ID
- `supplier_id` VARCHAR(32) - 供应商ID
- `grn_date` DATE - 收货日期
- `delivery_note_no` VARCHAR(64) - 送货单号
- `status` ENUM - 状态（DRAFT/RECEIVED/INSPECTED/ACCEPTED/REJECTED）
- `total_quantity` DECIMAL(18,4) - 总数量
- `remarks` TEXT - 备注
- `tenant_id` VARCHAR(32) - 租户ID
- 审计字段：`created_by`, `created_at`, `updated_by`, `updated_at`

**约束**：
- 主键：`grn_id`
- 外键：`po_id` → `purchase_order.po_id`
- 外键：`supplier_id` → `supplier_master.supplier_id`

#### 2.4 收货明细 (goods_receipt_item)
**描述**：收货明细表
**主键**：`id` (BIGINT AUTO_INCREMENT)
**属性**：
- `id` BIGINT - 自增主键
- `grn_id` VARCHAR(32) - 收货单ID
- `item_id` VARCHAR(32) - 物料ID
- `lot_id` VARCHAR(32) - 批次号
- `quantity` DECIMAL(18,4) - 收货数量
- `unit_price` DECIMAL(18,4) - 单价
- `total_amount` DECIMAL(18,2) - 总金额
- `location_id` VARCHAR(32) - 库位ID
- `status` ENUM - 状态（RECEIVED/INSPECTED/ACCEPTED/REJECTED）
- `tenant_id` VARCHAR(32) - 租户ID
- 审计字段：`created_by`, `created_at`, `updated_by`, `updated_at`

**约束**：
- 主键：`id`
- 外键：`grn_id` → `goods_receipt_note.grn_id`
- 外键：`item_id` → `item_master.item_id`

### 3. 生产管理域

#### 3.1 生产工单 (work_order)
**描述**：生产工单主表
**主键**：`wo_id`
**属性**：
- `wo_id` VARCHAR(32) - 工单号（WO-LINE-SEQ）
- `wo_no` VARCHAR(64) - 工单编号
- `item_id` VARCHAR(32) - 生产物料ID
- `planned_quantity` DECIMAL(18,4) - 计划数量
- `actual_quantity` DECIMAL(18,4) - 实际数量
- `line_id` VARCHAR(32) - 产线ID
- `priority` ENUM - 优先级（LOW/NORMAL/HIGH/URGENT）
- `status` ENUM - 状态（DRAFT/RELEASED/IN_PROGRESS/COMPLETED/CANCELLED/ON_HOLD）
- `planned_start_date` DATETIME - 计划开始时间
- `planned_end_date` DATETIME - 计划结束时间
- `actual_start_date` DATETIME - 实际开始时间
- `actual_end_date` DATETIME - 实际结束时间
- `routing_id` VARCHAR(32) - 工艺路线ID
- `remarks` TEXT - 备注
- `tenant_id` VARCHAR(32) - 租户ID
- 审计字段：`created_by`, `created_at`, `updated_by`, `updated_at`

**约束**：
- 主键：`wo_id`
- 唯一约束：`wo_no`
- 外键：`item_id` → `item_master.item_id`

#### 3.2 生产批次 (production_lot)
**描述**：生产批次表
**主键**：`lot_id`
**属性**：
- `lot_id` VARCHAR(32) - 批次号（LOT-YYYYMMDD-SEQ）
- `wo_id` VARCHAR(32) - 工单ID
- `item_id` VARCHAR(32) - 物料ID
- `lot_quantity` DECIMAL(18,4) - 批次数量
- `start_date` DATETIME - 开始时间
- `end_date` DATETIME - 结束时间
- `status` ENUM - 状态（PLANNED/IN_PROGRESS/COMPLETED/CANCELLED）
- `fai_status` ENUM - 首件状态（PENDING/PASS/FAIL）
- `fai_date` DATETIME - 首件验证日期
- `fai_by` VARCHAR(64) - 首件验证人
- `remarks` TEXT - 备注
- `tenant_id` VARCHAR(32) - 租户ID
- 审计字段：`created_by`, `created_at`, `updated_by`, `updated_at`

**约束**：
- 主键：`lot_id`
- 外键：`wo_id` → `work_order.wo_id`
- 外键：`item_id` → `item_master.item_id`

#### 3.3 序列号 (serial_number)
**描述**：序列号表
**主键**：`sn`
**属性**：
- `sn` VARCHAR(64) - 序列号（SN-{lot_id}-{SEQ}）
- `lot_id` VARCHAR(32) - 批次ID
- `item_id` VARCHAR(32) - 物料ID
- `wo_id` VARCHAR(32) - 工单ID
- `status` ENUM - 状态（PLANNED/IN_PROGRESS/COMPLETED/REJECTED/REWORK）
- `created_date` DATETIME - 创建日期
- `completed_date` DATETIME - 完成日期
- `box_no` VARCHAR(64) - 箱号
- `pallet_no` VARCHAR(64) - 托盘号
- `tenant_id` VARCHAR(32) - 租户ID
- 审计字段：`created_by`, `created_at`, `updated_by`, `updated_at`

**约束**：
- 主键：`sn`
- 外键：`lot_id` → `production_lot.lot_id`
- 外键：`item_id` → `item_master.item_id`
- 外键：`wo_id` → `work_order.wo_id`

### 4. 工艺管理域

#### 4.1 工艺路线 (routing)
**描述**：工艺路线表
**主键**：`routing_id`
**属性**：
- `routing_id` VARCHAR(32) - 工艺路线ID
- `item_id` VARCHAR(32) - 物料ID
- `version` INT - 版本号
- `effective_from` DATETIME - 生效开始时间
- `effective_to` DATETIME - 生效结束时间
- `status` ENUM - 状态（DRAFT/ACTIVE/OBSOLETE）
- `description` TEXT - 描述
- `tenant_id` VARCHAR(32) - 租户ID
- 审计字段：`created_by`, `created_at`, `updated_by`, `updated_at`

**约束**：
- 主键：`routing_id`
- 外键：`item_id` → `item_master.item_id`

#### 4.2 工序定义 (operation)
**描述**：工序定义表
**主键**：`op_id`
**属性**：
- `op_id` VARCHAR(32) - 工序ID
- `routing_id` VARCHAR(32) - 工艺路线ID
- `op_seq` INT - 工序序号
- `op_code` VARCHAR(32) - 工序代码
- `op_name` VARCHAR(128) - 工序名称
- `station_id` VARCHAR(32) - 工位ID
- `sop_id` VARCHAR(32) - SOP文档ID
- `sop_version` INT - SOP版本
- `sample_plan` JSON - 抽检计划配置
- `check_items` JSON - 检验项目配置
- `estimated_time` INT - 预估时间(分钟)
- `tenant_id` VARCHAR(32) - 租户ID
- 审计字段：`created_by`, `created_at`, `updated_by`, `updated_at`

**约束**：
- 主键：`op_id`
- 外键：`routing_id` → `routing.routing_id`
- 唯一约束：`routing_id`, `op_seq`

### 5. 品质管理域

#### 5.1 检验单 (inspection)
**描述**：检验单主表
**主键**：`insp_id`
**属性**：
- `insp_id` VARCHAR(32) - 检验单号（INSP-{type}-YYYYMMDD-SEQ）
- `type` ENUM - 检验类型（IQC/IPQC/OQC/FAI）
- `ref_id` VARCHAR(32) - 关联单据ID
- `ref_type` ENUM - 关联单据类型（GRN/LOT/WO/BOX/SN）
- `result` ENUM - 检验结果（PASS/FAIL/SPECIAL/PENDING）
- `sample_size` INT - 抽样数量
- `defect_quantity` INT - 缺陷数量
- `aql_level` VARCHAR(16) - AQL等级
- `inspector` VARCHAR(64) - 检验员
- `inspection_date` DATETIME - 检验日期
- `remarks` TEXT - 备注
- `tenant_id` VARCHAR(32) - 租户ID
- 审计字段：`created_by`, `created_at`, `updated_by`, `updated_at`

**约束**：
- 主键：`insp_id`

#### 5.2 检验明细 (inspection_item)
**描述**：检验明细表
**主键**：`id` (BIGINT AUTO_INCREMENT)
**属性**：
- `id` BIGINT - 自增主键
- `insp_id` VARCHAR(32) - 检验单ID
- `item_key` VARCHAR(64) - 检验项目
- `item_name` VARCHAR(128) - 检验项目名称
- `standard_value` VARCHAR(255) - 标准值
- `actual_value` VARCHAR(255) - 实际值
- `unit` VARCHAR(16) - 单位
- `result` ENUM - 单项结果（PASS/FAIL/SPECIAL）
- `defect_code` VARCHAR(32) - 缺陷代码
- `cause_code` VARCHAR(32) - 原因代码
- `action_code` VARCHAR(32) - 处置代码
- `remarks` TEXT - 备注
- `tenant_id` VARCHAR(32) - 租户ID
- 审计字段：`created_by`, `created_at`

**约束**：
- 主键：`id`
- 外键：`insp_id` → `inspection.insp_id`

#### 5.3 测试记录 (test_record)
**描述**：测试记录表
**主键**：`id` (BIGINT AUTO_INCREMENT)
**属性**：
- `id` BIGINT - 自增主键
- `sn` VARCHAR(64) - 序列号
- `station` VARCHAR(64) - 测试工位
- `test_type` VARCHAR(32) - 测试类型
- `result` ENUM - 测试结果（PASS/FAIL）
- `defect_code` VARCHAR(32) - 缺陷代码
- `test_data` JSON - 测试数据
- `operator` VARCHAR(64) - 操作员
- `tested_at` DATETIME - 测试时间
- `tenant_id` VARCHAR(32) - 租户ID
- 审计字段：`created_at`

**约束**：
- 主键：`id`

### 6. 库存管理域

#### 6.1 库存 (stock)
**描述**：库存表
**主键**：`id` (BIGINT AUTO_INCREMENT)
**属性**：
- `id` BIGINT - 自增主键
- `item_id` VARCHAR(32) - 物料ID
- `lot_id` VARCHAR(32) - 批次号
- `location_id` VARCHAR(32) - 库位ID
- `quantity` DECIMAL(18,4) - 库存数量
- `available_quantity` DECIMAL(18,4) - 可用数量
- `reserved_quantity` DECIMAL(18,4) - 预留数量
- `unit_cost` DECIMAL(18,4) - 单位成本
- `total_cost` DECIMAL(18,2) - 总成本
- `status` ENUM - 状态（AVAILABLE/RESERVED/QUARANTINE/REJECTED）
- `expiry_date` DATE - 过期日期
- `tenant_id` VARCHAR(32) - 租户ID
- 审计字段：`created_by`, `created_at`, `updated_by`, `updated_at`

**约束**：
- 主键：`id`
- 外键：`item_id` → `item_master.item_id`
- 唯一约束：`item_id`, `lot_id`, `location_id`

#### 6.2 库存事务 (stock_transaction)
**描述**：库存事务表
**主键**：`id` (BIGINT AUTO_INCREMENT)
**属性**：
- `id` BIGINT - 自增主键
- `transaction_id` VARCHAR(32) - 事务ID
- `item_id` VARCHAR(32) - 物料ID
- `lot_id` VARCHAR(32) - 批次号
- `location_id` VARCHAR(32) - 库位ID
- `transaction_type` ENUM - 事务类型（IN/OUT/TRANSFER/ADJUST/RESERVE/UNRESERVE）
- `quantity` DECIMAL(18,4) - 数量
- `unit_cost` DECIMAL(18,4) - 单位成本
- `total_cost` DECIMAL(18,2) - 总成本
- `reference_type` VARCHAR(32) - 关联单据类型
- `reference_id` VARCHAR(32) - 关联单据ID
- `remarks` TEXT - 备注
- `tenant_id` VARCHAR(32) - 租户ID
- 审计字段：`created_by`, `created_at`

**约束**：
- 主键：`id`
- 外键：`item_id` → `item_master.item_id`

### 7. 追溯系统域

#### 7.1 追溯事件 (trace_event)
**描述**：追溯事件表（事件溯源核心表）
**主键**：`event_id`
**属性**：
- `event_id` VARCHAR(40) - 事件ID
- `entity_type` VARCHAR(32) - 实体类型（SN/LOT/WO/GRN/BOX/PLT/INSP）
- `entity_id` VARCHAR(64) - 实体ID
- `action` VARCHAR(32) - 动作（START/END/PASS/FAIL/REWORK/MOVE/PACK/SHIP）
- `occurred_at` DATETIME - 发生时间
- `op_id` VARCHAR(32) - 工序ID
- `op_name` VARCHAR(64) - 工序名称
- `op_start_at` DATETIME - 工序开始时间
- `op_end_at` DATETIME - 工序结束时间
- `operator_id` VARCHAR(64) - 操作员ID
- `result` ENUM - 结果（PASS/FAIL/REWORK/HOLD）
- `station_id` VARCHAR(64) - 工位ID
- `shift_code` VARCHAR(16) - 班次代码
- `ref_id` VARCHAR(64) - 关联单据ID
- `data` JSON - 扩展数据
- `prev_event_id` VARCHAR(40) - 前一个事件ID
- `correlation_id` VARCHAR(64) - 关联ID
- `tenant_id` VARCHAR(32) - 租户ID
- `site_id` VARCHAR(32) - 站点ID
- `source_system` VARCHAR(32) - 来源系统
- 审计字段：`created_at`

**约束**：
- 主键：`event_id`

#### 7.2 序列号映射 (map_sn)
**描述**：序列号映射表
**主键**：`sn`
**属性**：
- `sn` VARCHAR(64) - 序列号
- `lot_id` VARCHAR(32) - 批次ID
- `wo_id` VARCHAR(32) - 工单ID
- `box_no` VARCHAR(64) - 箱号
- `pallet_no` VARCHAR(64) - 托盘号
- `shipment_id` VARCHAR(32) - 出货单ID
- `tenant_id` VARCHAR(32) - 租户ID
- `site_id` VARCHAR(32) - 站点ID
- 审计字段：`created_at`, `created_by`

**约束**：
- 主键：`sn`
- 外键：`lot_id` → `production_lot.lot_id`
- 外键：`wo_id` → `work_order.wo_id`

#### 7.3 批次用料映射 (map_lot_material)
**描述**：批次用料映射表
**主键**：`id` (BIGINT AUTO_INCREMENT)
**属性**：
- `id` BIGINT - 自增主键
- `lot_id` VARCHAR(32) - 批次ID
- `item_id` VARCHAR(32) - 物料ID
- `supplier_id` VARCHAR(32) - 供应商ID
- `grn_id` VARCHAR(32) - 收货单ID
- `mold_id` VARCHAR(32) - 模具ID
- `qty_used` DECIMAL(18,4) - 使用数量
- `tenant_id` VARCHAR(32) - 租户ID
- 审计字段：`created_at`

**约束**：
- 主键：`id`
- 外键：`lot_id` → `production_lot.lot_id`
- 外键：`item_id` → `item_master.item_id`
- 外键：`supplier_id` → `supplier_master.supplier_id`
- 外键：`mold_id` → `mold_master.mold_id`

### 8. 系统配置域

#### 8.1 品质代码 (qms_code)
**描述**：品质代码表
**主键**：`code_type`, `code`
**属性**：
- `code_type` VARCHAR(16) - 代码类型（DEFECT/CAUSE/ACTION）
- `code` VARCHAR(32) - 代码
- `description` VARCHAR(255) - 描述
- `category` VARCHAR(64) - 分类
- `status` ENUM - 状态（ACTIVE/INACTIVE）
- `tenant_id` VARCHAR(32) - 租户ID
- 审计字段：`created_by`, `created_at`, `updated_by`, `updated_at`

**约束**：
- 主键：`code_type`, `code`

#### 8.2 附件 (attachment)
**描述**：附件表
**主键**：`id` (BIGINT AUTO_INCREMENT)
**属性**：
- `id` BIGINT - 自增主键
- `file_name` VARCHAR(255) - 文件名
- `file_path` VARCHAR(500) - 文件路径
- `file_size` BIGINT - 文件大小
- `file_type` VARCHAR(64) - 文件类型
- `biz_type` VARCHAR(32) - 业务类型
- `biz_id` VARCHAR(32) - 业务ID
- `checksum` CHAR(64) - 文件校验和
- `tenant_id` VARCHAR(32) - 租户ID
- `site_id` VARCHAR(32) - 站点ID
- 审计字段：`created_by`, `created_at`

**约束**：
- 主键：`id`

### 9. BI数据聚合域

#### 9.1 良率聚合 (agg_yield_5m)
**描述**：良率聚合表（5分钟）
**主键**：`bucket_start`
**属性**：
- `bucket_start` DATETIME - 时间桶开始时间
- `pass_cnt` INT - 通过数量
- `fail_cnt` INT - 失败数量
- `yield` DECIMAL(5,2) - 良率
- `station` VARCHAR(64) - 工位
- `item_id` VARCHAR(32) - 物料ID
- 审计字段：`updated_at`

**约束**：
- 主键：`bucket_start`

#### 9.2 WIP状态聚合 (agg_wip_status)
**描述**：WIP状态聚合表
**主键**：`id` (BIGINT AUTO_INCREMENT)
**属性**：
- `id` BIGINT - 自增主键
- `bucket_start` DATETIME - 时间桶开始时间
- `wo_id` VARCHAR(32) - 工单ID
- `item_id` VARCHAR(32) - 物料ID
- `station` VARCHAR(64) - 工位
- `status` ENUM - 状态（PLANNED/IN_PROGRESS/COMPLETED/REJECTED/REWORK）
- `quantity` DECIMAL(18,4) - 数量
- 审计字段：`updated_at`

**约束**：
- 主键：`id`

#### 9.3 生产进度聚合 (agg_production_progress)
**描述**：生产进度聚合表
**主键**：`id` (BIGINT AUTO_INCREMENT)
**属性**：
- `id` BIGINT - 自增主键
- `bucket_start` DATETIME - 时间桶开始时间
- `wo_id` VARCHAR(32) - 工单ID
- `item_id` VARCHAR(32) - 物料ID
- `planned_quantity` DECIMAL(18,4) - 计划数量
- `actual_quantity` DECIMAL(18,4) - 实际数量
- `progress_rate` DECIMAL(5,2) - 进度百分比
- `yield_rate` DECIMAL(5,2) - 良品率
- 审计字段：`updated_at`

**约束**：
- 主键：`id`

#### 9.4 设备效率聚合 (agg_equipment_efficiency)
**描述**：设备效率聚合表
**主键**：`id` (BIGINT AUTO_INCREMENT)
**属性**：
- `id` BIGINT - 自增主键
- `bucket_start` DATETIME - 时间桶开始时间
- `equipment_id` VARCHAR(32) - 设备ID
- `station` VARCHAR(64) - 工位
- `planned_time` INT - 计划时间(分钟)
- `actual_time` INT - 实际时间(分钟)
- `efficiency` DECIMAL(5,2) - 效率百分比
- `downtime_minutes` INT - 停机时间(分钟)
- 审计字段：`updated_at`

**约束**：
- 主键：`id`

#### 9.5 品质统计聚合 (agg_quality_stats)
**描述**：品质统计聚合表
**主键**：`id` (BIGINT AUTO_INCREMENT)
**属性**：
- `id` BIGINT - 自增主键
- `bucket_start` DATETIME - 时间桶开始时间
- `inspection_type` ENUM - 检验类型（IQC/IPQC/OQC/FAI）
- `total_inspections` INT - 总检验数
- `pass_count` INT - 通过数
- `fail_count` INT - 失败数
- `pass_rate` DECIMAL(5,2) - 通过率
- `defect_top_5` JSON - Top5缺陷
- 审计字段：`updated_at`

**约束**：
- 主键：`id`

#### 9.6 库存周转聚合 (agg_inventory_turnover)
**描述**：库存周转聚合表
**主键**：`id` (BIGINT AUTO_INCREMENT)
**属性**：
- `id` BIGINT - 自增主键
- `bucket_start` DATETIME - 时间桶开始时间
- `item_id` VARCHAR(32) - 物料ID
- `location_id` VARCHAR(32) - 库位ID
- `opening_stock` DECIMAL(18,4) - 期初库存
- `closing_stock` DECIMAL(18,4) - 期末库存
- `in_quantity` DECIMAL(18,4) - 入库数量
- `out_quantity` DECIMAL(18,4) - 出库数量
- `turnover_rate` DECIMAL(5,2) - 周转率
- 审计字段：`updated_at`

**约束**：
- 主键：`id`

#### 9.7 供应商绩效聚合 (agg_supplier_performance)
**描述**：供应商绩效聚合表
**主键**：`id` (BIGINT AUTO_INCREMENT)
**属性**：
- `id` BIGINT - 自增主键
- `bucket_start` DATETIME - 时间桶开始时间
- `supplier_id` VARCHAR(32) - 供应商ID
- `total_deliveries` INT - 总交货次数
- `on_time_deliveries` INT - 准时交货次数
- `quality_pass_rate` DECIMAL(5,2) - 质量通过率
- `delivery_performance` DECIMAL(5,2) - 交货绩效
- `overall_score` DECIMAL(5,2) - 综合评分
- 审计字段：`updated_at`

**约束**：
- 主键：`id`

#### 9.8 成本分析聚合 (agg_cost_analysis)
**描述**：成本分析聚合表
**主键**：`id` (BIGINT AUTO_INCREMENT)
**属性**：
- `id` BIGINT - 自增主键
- `bucket_start` DATETIME - 时间桶开始时间
- `item_id` VARCHAR(32) - 物料ID
- `material_cost` DECIMAL(18,2) - 物料成本
- `labor_cost` DECIMAL(18,2) - 人工成本
- `overhead_cost` DECIMAL(18,2) - 制造费用
- `total_cost` DECIMAL(18,2) - 总成本
- `unit_cost` DECIMAL(18,4) - 单位成本
- `cost_variance` DECIMAL(18,2) - 成本差异
- 审计字段：`updated_at`

**约束**：
- 主键：`id`

#### 9.9 告警统计聚合 (agg_alert_stats)
**描述**：告警统计聚合表
**主键**：`id` (BIGINT AUTO_INCREMENT)
**属性**：
- `id` BIGINT - 自增主键
- `bucket_start` DATETIME - 时间桶开始时间
- `alert_type` VARCHAR(32) - 告警类型
- `alert_level` ENUM - 告警级别（INFO/WARNING/ERROR/CRITICAL）
- `alert_count` INT - 告警数量
- `resolved_count` INT - 已解决数量
- `resolution_rate` DECIMAL(5,2) - 解决率
- `avg_resolution_time` INT - 平均解决时间(分钟)
- 审计字段：`updated_at`

**约束**：
- 主键：`id`

## 实体关系图

### 核心关系
1. **物料** → **供应商**：多对一关系
2. **物料** → **模具**：一对多关系
3. **采购订单** → **供应商**：多对一关系
4. **采购订单** → **采购订单明细**：一对多关系
5. **工单** → **物料**：多对一关系
6. **批次** → **工单**：多对一关系
7. **序列号** → **批次**：多对一关系
8. **工艺路线** → **物料**：多对一关系
9. **工序** → **工艺路线**：多对一关系
10. **检验单** → **关联实体**：多对一关系
11. **库存** → **物料**：多对一关系
12. **追溯事件** → **实体**：多对一关系

### 追溯关系
1. **序列号** → **批次** → **工单** → **物料**
2. **批次** → **用料映射** → **供应商/模具**
3. **追溯事件** → **工序/操作员/工位**

## 数据完整性约束

### 1. 实体完整性
- 所有表都有主键约束
- 主键值不能为空
- 主键值必须唯一

### 2. 参照完整性
- 所有外键都有对应的主键
- 外键值必须在被引用表中存在
- 删除被引用记录时考虑级联操作

### 3. 域完整性
- 枚举类型约束
- 数值范围约束
- 字符串长度约束
- 日期时间约束

### 4. 业务完整性
- 唯一性约束
- 检查约束
- 触发器约束

## 性能优化策略

### 1. 索引策略
- 主键自动创建聚簇索引
- 外键创建普通索引
- 查询频繁字段创建索引
- 复合查询创建复合索引

### 2. 分区策略
- 大表按时间分区
- 追溯事件表按日期分区
- 测试记录表按日期分区

### 3. 存储策略
- 历史数据归档
- 冷热数据分离
- 数据压缩存储

## 扩展性设计

### 1. 水平扩展
- 分库分表策略
- 读写分离
- 分布式事务

### 2. 垂直扩展
- 字段扩展
- 表结构扩展
- 功能模块扩展

### 3. 版本管理
- 数据版本控制
- 结构变更管理
- 向后兼容性保证