-- V20250107_1600__init_btc_core_tables.sql
-- 初始化BTC核心数据库表结构
-- 基于MES系统全局架构基础文档
-- 作者: MES开发团队
-- 日期: 2025-01-07

-- 使用BTC核心数据库
USE btc_core;

-- ==============================================
-- 1. 基础数据表（主数据管理）
-- ==============================================

-- 物料主数据表
CREATE TABLE IF NOT EXISTS item_master (
    item_id VARCHAR(32) PRIMARY KEY COMMENT '物料编码 ITM-YYYYMM-XXXX',
    item_code VARCHAR(64) NOT NULL COMMENT 'ERP物料编码',
    item_name VARCHAR(255) NOT NULL COMMENT '物料名称',
    item_type ENUM('RAW', 'COMPONENT', 'FINISHED', 'TOOL', 'CONSUMABLE') NOT NULL COMMENT '物料类型',
    uom VARCHAR(16) NOT NULL COMMENT '计量单位',
    specification TEXT COMMENT '规格说明',
    supplier_id VARCHAR(32) COMMENT '默认供应商',
    status ENUM('ACTIVE', 'INACTIVE', 'OBSOLETE') DEFAULT 'ACTIVE' COMMENT '状态',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_item_code (item_code),
    INDEX idx_item_type (item_type),
    INDEX idx_supplier (supplier_id),
    INDEX idx_tenant_site (tenant_id, site_id)
) COMMENT '物料主数据表';

-- 供应商主数据表
CREATE TABLE IF NOT EXISTS supplier_master (
    supplier_id VARCHAR(32) PRIMARY KEY COMMENT '供应商编码 SUP-XXXXX',
    supplier_code VARCHAR(64) NOT NULL COMMENT '供应商代码',
    supplier_name VARCHAR(255) NOT NULL COMMENT '供应商名称',
    contact_person VARCHAR(100) COMMENT '联系人',
    contact_phone VARCHAR(50) COMMENT '联系电话',
    contact_email VARCHAR(100) COMMENT '联系邮箱',
    address TEXT COMMENT '地址',
    status ENUM('ACTIVE', 'INACTIVE', 'BLACKLIST') DEFAULT 'ACTIVE' COMMENT '状态',
    quality_rating DECIMAL(3,2) DEFAULT 5.00 COMMENT '质量评分',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_supplier_code (supplier_code),
    INDEX idx_tenant (tenant_id)
) COMMENT '供应商主数据表';

-- 模具主数据表
CREATE TABLE IF NOT EXISTS mold_master (
    mold_id VARCHAR(32) PRIMARY KEY COMMENT '模具编码 MLD-SUP-XXXX',
    mold_code VARCHAR(64) NOT NULL COMMENT '模具代码',
    mold_name VARCHAR(255) NOT NULL COMMENT '模具名称',
    supplier_id VARCHAR(32) NOT NULL COMMENT '供应商ID',
    item_id VARCHAR(32) COMMENT '对应物料ID',
    mold_type ENUM('INJECTION', 'STAMPING', 'ASSEMBLY', 'TESTING') COMMENT '模具类型',
    status ENUM('ACTIVE', 'MAINTENANCE', 'RETIRED') DEFAULT 'ACTIVE' COMMENT '状态',
    last_maintenance_date DATE COMMENT '最后维护日期',
    next_maintenance_date DATE COMMENT '下次维护日期',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_mold_code (mold_code),
    INDEX idx_supplier (supplier_id),
    INDEX idx_tenant (tenant_id)
) COMMENT '模具主数据表';

-- ==============================================
-- 2. 采购与收货管理
-- ==============================================

-- 采购订单表
CREATE TABLE IF NOT EXISTS purchase_order (
    po_id VARCHAR(32) PRIMARY KEY COMMENT '采购订单号 PO-YYYYMMDD-SEQ',
    po_no VARCHAR(64) NOT NULL COMMENT 'ERP采购订单号',
    supplier_id VARCHAR(32) NOT NULL COMMENT '供应商ID',
    po_date DATE NOT NULL COMMENT '采购日期',
    expected_delivery_date DATE COMMENT '预期交货日期',
    status ENUM('DRAFT', 'CONFIRMED', 'PARTIAL_RECEIVED', 'COMPLETED', 'CANCELLED') DEFAULT 'DRAFT' COMMENT '状态',
    total_amount DECIMAL(18,2) COMMENT '总金额',
    currency VARCHAR(8) DEFAULT 'CNY' COMMENT '币种',
    remarks TEXT COMMENT '备注',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_po_no (po_no),
    INDEX idx_supplier (supplier_id),
    INDEX idx_po_date (po_date),
    INDEX idx_tenant (tenant_id)
) COMMENT '采购订单表';

-- 采购订单明细表
CREATE TABLE IF NOT EXISTS purchase_order_item (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    po_id VARCHAR(32) NOT NULL COMMENT '采购订单ID',
    item_id VARCHAR(32) NOT NULL COMMENT '物料ID',
    quantity DECIMAL(18,4) NOT NULL COMMENT '采购数量',
    unit_price DECIMAL(18,4) COMMENT '单价',
    total_amount DECIMAL(18,2) COMMENT '总金额',
    received_quantity DECIMAL(18,4) DEFAULT 0 COMMENT '已收货数量',
    status ENUM('PENDING', 'PARTIAL_RECEIVED', 'COMPLETED') DEFAULT 'PENDING' COMMENT '状态',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_po_item (po_id, item_id),
    INDEX idx_tenant (tenant_id)
) COMMENT '采购订单明细表';

-- 收货单表
CREATE TABLE IF NOT EXISTS goods_receipt_note (
    grn_id VARCHAR(32) PRIMARY KEY COMMENT '收货单号 GRN-YYYYMMDD-SEQ',
    po_id VARCHAR(32) NOT NULL COMMENT '采购订单ID',
    supplier_id VARCHAR(32) NOT NULL COMMENT '供应商ID',
    grn_date DATE NOT NULL COMMENT '收货日期',
    delivery_note_no VARCHAR(64) COMMENT '送货单号',
    status ENUM('DRAFT', 'RECEIVED', 'INSPECTED', 'ACCEPTED', 'REJECTED') DEFAULT 'DRAFT' COMMENT '状态',
    total_quantity DECIMAL(18,4) COMMENT '总数量',
    remarks TEXT COMMENT '备注',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_po (po_id),
    INDEX idx_supplier (supplier_id),
    INDEX idx_grn_date (grn_date),
    INDEX idx_tenant (tenant_id)
) COMMENT '收货单表';

-- 收货明细表
CREATE TABLE IF NOT EXISTS goods_receipt_item (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    grn_id VARCHAR(32) NOT NULL COMMENT '收货单ID',
    item_id VARCHAR(32) NOT NULL COMMENT '物料ID',
    lot_id VARCHAR(32) COMMENT '批次号',
    quantity DECIMAL(18,4) NOT NULL COMMENT '收货数量',
    unit_price DECIMAL(18,4) COMMENT '单价',
    total_amount DECIMAL(18,2) COMMENT '总金额',
    location_id VARCHAR(32) COMMENT '库位ID',
    status ENUM('RECEIVED', 'INSPECTED', 'ACCEPTED', 'REJECTED') DEFAULT 'RECEIVED' COMMENT '状态',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_grn_item (grn_id, item_id),
    INDEX idx_lot (lot_id),
    INDEX idx_tenant (tenant_id)
) COMMENT '收货明细表';

-- ==============================================
-- 3. 生产管理
-- ==============================================

-- 生产工单表
CREATE TABLE IF NOT EXISTS work_order (
    wo_id VARCHAR(32) PRIMARY KEY COMMENT '工单号 WO-LINE-SEQ',
    wo_no VARCHAR(64) NOT NULL COMMENT '工单编号',
    item_id VARCHAR(32) NOT NULL COMMENT '生产物料ID',
    planned_quantity DECIMAL(18,4) NOT NULL COMMENT '计划数量',
    actual_quantity DECIMAL(18,4) DEFAULT 0 COMMENT '实际数量',
    line_id VARCHAR(32) COMMENT '产线ID',
    priority ENUM('LOW', 'NORMAL', 'HIGH', 'URGENT') DEFAULT 'NORMAL' COMMENT '优先级',
    status ENUM('DRAFT', 'RELEASED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'ON_HOLD') DEFAULT 'DRAFT' COMMENT '状态',
    planned_start_date DATETIME COMMENT '计划开始时间',
    planned_end_date DATETIME COMMENT '计划结束时间',
    actual_start_date DATETIME COMMENT '实际开始时间',
    actual_end_date DATETIME COMMENT '实际结束时间',
    routing_id VARCHAR(32) COMMENT '工艺路线ID',
    remarks TEXT COMMENT '备注',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_wo_no (wo_no),
    INDEX idx_item (item_id),
    INDEX idx_line (line_id),
    INDEX idx_status (status),
    INDEX idx_planned_date (planned_start_date),
    INDEX idx_tenant (tenant_id)
) COMMENT '生产工单表';

-- 生产批次表
CREATE TABLE IF NOT EXISTS production_lot (
    lot_id VARCHAR(32) PRIMARY KEY COMMENT '批次号 LOT-YYYYMMDD-SEQ',
    wo_id VARCHAR(32) NOT NULL COMMENT '工单ID',
    item_id VARCHAR(32) NOT NULL COMMENT '物料ID',
    lot_quantity DECIMAL(18,4) NOT NULL COMMENT '批次数量',
    start_date DATETIME COMMENT '开始时间',
    end_date DATETIME COMMENT '结束时间',
    status ENUM('PLANNED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED') DEFAULT 'PLANNED' COMMENT '状态',
    fai_status ENUM('PENDING', 'PASS', 'FAIL') DEFAULT 'PENDING' COMMENT '首件状态',
    fai_date DATETIME COMMENT '首件验证日期',
    fai_by VARCHAR(64) COMMENT '首件验证人',
    remarks TEXT COMMENT '备注',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_wo (wo_id),
    INDEX idx_item (item_id),
    INDEX idx_status (status),
    INDEX idx_fai_status (fai_status),
    INDEX idx_tenant (tenant_id)
) COMMENT '生产批次表';

-- 序列号表
CREATE TABLE IF NOT EXISTS serial_number (
    sn VARCHAR(64) PRIMARY KEY COMMENT '序列号 SN-{lot_id}-{SEQ}',
    lot_id VARCHAR(32) NOT NULL COMMENT '批次ID',
    item_id VARCHAR(32) NOT NULL COMMENT '物料ID',
    wo_id VARCHAR(32) NOT NULL COMMENT '工单ID',
    status ENUM('PLANNED', 'IN_PROGRESS', 'COMPLETED', 'REJECTED', 'REWORK') DEFAULT 'PLANNED' COMMENT '状态',
    created_date DATETIME COMMENT '创建日期',
    completed_date DATETIME COMMENT '完成日期',
    box_no VARCHAR(64) COMMENT '箱号',
    pallet_no VARCHAR(64) COMMENT '托盘号',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_lot (lot_id),
    INDEX idx_item (item_id),
    INDEX idx_wo (wo_id),
    INDEX idx_status (status),
    INDEX idx_box (box_no),
    INDEX idx_pallet (pallet_no),
    INDEX idx_tenant (tenant_id)
) COMMENT '序列号表';

-- ==============================================
-- 4. 工艺路线与工序管理
-- ==============================================

-- 工艺路线表
CREATE TABLE IF NOT EXISTS routing (
    routing_id VARCHAR(32) PRIMARY KEY COMMENT '工艺路线ID',
    item_id VARCHAR(32) NOT NULL COMMENT '物料ID',
    version INT NOT NULL DEFAULT 1 COMMENT '版本号',
    effective_from DATETIME COMMENT '生效开始时间',
    effective_to DATETIME COMMENT '生效结束时间',
    status ENUM('DRAFT', 'ACTIVE', 'OBSOLETE') DEFAULT 'DRAFT' COMMENT '状态',
    description TEXT COMMENT '描述',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_item_version (item_id, version),
    INDEX idx_status (status),
    INDEX idx_tenant (tenant_id)
) COMMENT '工艺路线表';

-- 工序定义表
CREATE TABLE IF NOT EXISTS operation (
    op_id VARCHAR(32) PRIMARY KEY COMMENT '工序ID',
    routing_id VARCHAR(32) NOT NULL COMMENT '工艺路线ID',
    op_seq INT NOT NULL COMMENT '工序序号',
    op_code VARCHAR(32) NOT NULL COMMENT '工序代码',
    op_name VARCHAR(128) NOT NULL COMMENT '工序名称',
    station_id VARCHAR(32) COMMENT '工位ID',
    sop_id VARCHAR(32) COMMENT 'SOP文档ID',
    sop_version INT COMMENT 'SOP版本',
    sample_plan JSON COMMENT '抽检计划配置',
    check_items JSON COMMENT '检验项目配置',
    estimated_time INT COMMENT '预估时间(分钟)',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_routing_seq (routing_id, op_seq),
    INDEX idx_routing (routing_id),
    INDEX idx_station (station_id),
    INDEX idx_tenant (tenant_id)
) COMMENT '工序定义表';

-- ==============================================
-- 5. 品质管理
-- ==============================================

-- 检验单表
CREATE TABLE IF NOT EXISTS inspection (
    insp_id VARCHAR(32) PRIMARY KEY COMMENT '检验单号 INSP-{type}-YYYYMMDD-SEQ',
    type ENUM('IQC', 'IPQC', 'OQC', 'FAI') NOT NULL COMMENT '检验类型',
    ref_id VARCHAR(32) NOT NULL COMMENT '关联单据ID',
    ref_type ENUM('GRN', 'LOT', 'WO', 'BOX', 'SN') NOT NULL COMMENT '关联单据类型',
    result ENUM('PASS', 'FAIL', 'SPECIAL', 'PENDING') DEFAULT 'PENDING' COMMENT '检验结果',
    sample_size INT COMMENT '抽样数量',
    defect_quantity INT DEFAULT 0 COMMENT '缺陷数量',
    aql_level VARCHAR(16) COMMENT 'AQL等级',
    inspector VARCHAR(64) COMMENT '检验员',
    inspection_date DATETIME COMMENT '检验日期',
    remarks TEXT COMMENT '备注',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_type (type),
    INDEX idx_ref (ref_id, ref_type),
    INDEX idx_result (result),
    INDEX idx_inspector (inspector),
    INDEX idx_inspection_date (inspection_date),
    INDEX idx_tenant (tenant_id)
) COMMENT '检验单表';

-- 检验明细表
CREATE TABLE IF NOT EXISTS inspection_item (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    insp_id VARCHAR(32) NOT NULL COMMENT '检验单ID',
    item_key VARCHAR(64) NOT NULL COMMENT '检验项目',
    item_name VARCHAR(128) COMMENT '检验项目名称',
    standard_value VARCHAR(255) COMMENT '标准值',
    actual_value VARCHAR(255) COMMENT '实际值',
    unit VARCHAR(16) COMMENT '单位',
    result ENUM('PASS', 'FAIL', 'SPECIAL') COMMENT '单项结果',
    defect_code VARCHAR(32) COMMENT '缺陷代码',
    cause_code VARCHAR(32) COMMENT '原因代码',
    action_code VARCHAR(32) COMMENT '处置代码',
    remarks TEXT COMMENT '备注',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_insp (insp_id),
    INDEX idx_item_key (item_key),
    INDEX idx_result (result),
    INDEX idx_tenant (tenant_id)
) COMMENT '检验明细表';

-- 测试记录表
CREATE TABLE IF NOT EXISTS test_record (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sn VARCHAR(64) NOT NULL COMMENT '序列号',
    station VARCHAR(64) NOT NULL COMMENT '测试工位',
    test_type VARCHAR(32) COMMENT '测试类型',
    result ENUM('PASS', 'FAIL') NOT NULL COMMENT '测试结果',
    defect_code VARCHAR(32) COMMENT '缺陷代码',
    test_data JSON COMMENT '测试数据',
    operator VARCHAR(64) COMMENT '操作员',
    tested_at DATETIME NOT NULL COMMENT '测试时间',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_sn (sn),
    INDEX idx_station (station),
    INDEX idx_result (result),
    INDEX idx_tested_at (tested_at),
    INDEX idx_tenant (tenant_id)
) COMMENT '测试记录表';

-- ==============================================
-- 6. 库存管理
-- ==============================================

-- 库存表
CREATE TABLE IF NOT EXISTS stock (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    item_id VARCHAR(32) NOT NULL COMMENT '物料ID',
    lot_id VARCHAR(32) COMMENT '批次号',
    location_id VARCHAR(32) COMMENT '库位ID',
    quantity DECIMAL(18,4) NOT NULL DEFAULT 0 COMMENT '库存数量',
    available_quantity DECIMAL(18,4) NOT NULL DEFAULT 0 COMMENT '可用数量',
    reserved_quantity DECIMAL(18,4) NOT NULL DEFAULT 0 COMMENT '预留数量',
    unit_cost DECIMAL(18,4) COMMENT '单位成本',
    total_cost DECIMAL(18,2) COMMENT '总成本',
    status ENUM('AVAILABLE', 'RESERVED', 'QUARANTINE', 'REJECTED') DEFAULT 'AVAILABLE' COMMENT '状态',
    expiry_date DATE COMMENT '过期日期',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_item_lot_location (item_id, lot_id, location_id),
    INDEX idx_item (item_id),
    INDEX idx_lot (lot_id),
    INDEX idx_location (location_id),
    INDEX idx_status (status),
    INDEX idx_tenant (tenant_id)
) COMMENT '库存表';

-- 库存事务表
CREATE TABLE IF NOT EXISTS stock_transaction (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    transaction_id VARCHAR(32) NOT NULL COMMENT '事务ID',
    item_id VARCHAR(32) NOT NULL COMMENT '物料ID',
    lot_id VARCHAR(32) COMMENT '批次号',
    location_id VARCHAR(32) COMMENT '库位ID',
    transaction_type ENUM('IN', 'OUT', 'TRANSFER', 'ADJUST', 'RESERVE', 'UNRESERVE') NOT NULL COMMENT '事务类型',
    quantity DECIMAL(18,4) NOT NULL COMMENT '数量',
    unit_cost DECIMAL(18,4) COMMENT '单位成本',
    total_cost DECIMAL(18,2) COMMENT '总成本',
    reference_type VARCHAR(32) COMMENT '关联单据类型',
    reference_id VARCHAR(32) COMMENT '关联单据ID',
    remarks TEXT COMMENT '备注',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_transaction_id (transaction_id),
    INDEX idx_item (item_id),
    INDEX idx_lot (lot_id),
    INDEX idx_location (location_id),
    INDEX idx_type (transaction_type),
    INDEX idx_reference (reference_type, reference_id),
    INDEX idx_created_at (created_at),
    INDEX idx_tenant (tenant_id)
) COMMENT '库存事务表';

-- ==============================================
-- 7. 追溯系统核心表
-- ==============================================

-- 追溯事件表（事件溯源核心表）
CREATE TABLE IF NOT EXISTS trace_event (
    event_id VARCHAR(40) PRIMARY KEY COMMENT '事件ID',
    entity_type VARCHAR(32) NOT NULL COMMENT '实体类型 SN/LOT/WO/GRN/BOX/PLT/INSP',
    entity_id VARCHAR(64) NOT NULL COMMENT '实体ID',
    action VARCHAR(32) NOT NULL COMMENT '动作 START/END/PASS/FAIL/REWORK/MOVE/PACK/SHIP',
    occurred_at DATETIME NOT NULL COMMENT '发生时间',
    op_id VARCHAR(32) COMMENT '工序ID',
    op_name VARCHAR(64) COMMENT '工序名称',
    op_start_at DATETIME COMMENT '工序开始时间',
    op_end_at DATETIME COMMENT '工序结束时间',
    operator_id VARCHAR(64) COMMENT '操作员ID',
    result ENUM('PASS', 'FAIL', 'REWORK', 'HOLD') COMMENT '结果',
    station_id VARCHAR(64) COMMENT '工位ID',
    shift_code VARCHAR(16) COMMENT '班次代码',
    ref_id VARCHAR(64) COMMENT '关联单据ID',
    data JSON COMMENT '扩展数据',
    prev_event_id VARCHAR(40) COMMENT '前一个事件ID',
    correlation_id VARCHAR(64) COMMENT '关联ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    source_system VARCHAR(32) COMMENT '来源系统',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_entity (entity_type, entity_id, occurred_at),
    INDEX idx_action (action, occurred_at),
    INDEX idx_operator (operator_id),
    INDEX idx_station (station_id),
    INDEX idx_prev_event (prev_event_id),
    INDEX idx_correlation (correlation_id),
    INDEX idx_tenant_site (tenant_id, site_id)
) COMMENT '追溯事件表';

-- 序列号映射表
CREATE TABLE IF NOT EXISTS map_sn (
    sn VARCHAR(64) PRIMARY KEY COMMENT '序列号',
    lot_id VARCHAR(32) NOT NULL COMMENT '批次ID',
    wo_id VARCHAR(32) NOT NULL COMMENT '工单ID',
    box_no VARCHAR(64) COMMENT '箱号',
    pallet_no VARCHAR(64) COMMENT '托盘号',
    shipment_id VARCHAR(32) COMMENT '出货单ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(64) NOT NULL,
    INDEX idx_lot (lot_id),
    INDEX idx_wo (wo_id),
    INDEX idx_box (box_no),
    INDEX idx_pallet (pallet_no),
    INDEX idx_shipment (shipment_id),
    INDEX idx_tenant_site (tenant_id, site_id)
) COMMENT '序列号映射表';

-- 批次用料映射表
CREATE TABLE IF NOT EXISTS map_lot_material (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    lot_id VARCHAR(32) NOT NULL COMMENT '批次ID',
    item_id VARCHAR(32) NOT NULL COMMENT '物料ID',
    supplier_id VARCHAR(32) COMMENT '供应商ID',
    grn_id VARCHAR(32) COMMENT '收货单ID',
    mold_id VARCHAR(32) COMMENT '模具ID',
    qty_used DECIMAL(18,4) COMMENT '使用数量',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_lot (lot_id),
    INDEX idx_item (item_id),
    INDEX idx_supplier (supplier_id),
    INDEX idx_grn (grn_id),
    INDEX idx_mold (mold_id),
    INDEX idx_tenant (tenant_id)
) COMMENT '批次用料映射表';

-- ==============================================
-- 8. 系统配置与字典表
-- ==============================================

-- 品质代码表
CREATE TABLE IF NOT EXISTS qms_code (
    code_type VARCHAR(16) NOT NULL COMMENT '代码类型 DEFECT/CAUSE/ACTION',
    code VARCHAR(32) NOT NULL COMMENT '代码',
    description VARCHAR(255) NOT NULL COMMENT '描述',
    category VARCHAR(64) COMMENT '分类',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (code_type, code),
    INDEX idx_type (code_type),
    INDEX idx_category (category),
    INDEX idx_tenant (tenant_id)
) COMMENT '品质代码表';

-- 附件表
CREATE TABLE IF NOT EXISTS attachment (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    file_name VARCHAR(255) NOT NULL COMMENT '文件名',
    file_path VARCHAR(500) NOT NULL COMMENT '文件路径',
    file_size BIGINT COMMENT '文件大小',
    file_type VARCHAR(64) COMMENT '文件类型',
    biz_type VARCHAR(32) COMMENT '业务类型',
    biz_id VARCHAR(32) COMMENT '业务ID',
    checksum CHAR(64) COMMENT '文件校验和',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_biz (biz_type, biz_id),
    INDEX idx_tenant_site (tenant_id, site_id)
) COMMENT '附件表';

-- ==============================================
-- 9. BI数据聚合表
-- ==============================================

-- 良率聚合表（5分钟）
CREATE TABLE IF NOT EXISTS agg_yield_5m (
    bucket_start DATETIME PRIMARY KEY COMMENT '时间桶开始时间',
    pass_cnt INT DEFAULT 0 COMMENT '通过数量',
    fail_cnt INT DEFAULT 0 COMMENT '失败数量',
    yield DECIMAL(5,2) COMMENT '良率',
    station VARCHAR(64) COMMENT '工位',
    item_id VARCHAR(32) COMMENT '物料ID',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_station (station),
    INDEX idx_item (item_id),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '良率聚合表';

-- WIP状态聚合表
CREATE TABLE IF NOT EXISTS agg_wip_status (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    bucket_start DATETIME NOT NULL COMMENT '时间桶开始时间',
    wo_id VARCHAR(32) COMMENT '工单ID',
    item_id VARCHAR(32) COMMENT '物料ID',
    station VARCHAR(64) COMMENT '工位',
    status ENUM('PLANNED', 'IN_PROGRESS', 'COMPLETED', 'REJECTED', 'REWORK') COMMENT '状态',
    quantity DECIMAL(18,4) COMMENT '数量',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_bucket_wo (bucket_start, wo_id),
    INDEX idx_item (item_id),
    INDEX idx_station (station),
    INDEX idx_status (status)
) COMMENT 'WIP状态聚合表';
