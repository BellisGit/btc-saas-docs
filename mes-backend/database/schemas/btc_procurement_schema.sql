-- ==============================================
-- BTC采购管理数据�?- 扩展数据库示�?
-- 独立数据库，通过API与核心数据库集成
-- ==============================================

-- 创建BTC采购管理数据�?
CREATE DATABASE IF NOT EXISTS btc_procurement CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE btc_procurement;

-- ==============================================
-- 1. 采购基础�?
-- ==============================================

-- 采购订单�?
CREATE TABLE purchase_order (
    po_id VARCHAR(32) PRIMARY KEY COMMENT '采购订单ID',
    po_number VARCHAR(64) NOT NULL UNIQUE COMMENT '采购订单�?,
    supplier_id VARCHAR(32) NOT NULL COMMENT '供应商ID（来自核心数据库�?,
    supplier_code VARCHAR(64) COMMENT '供应商代码（冗余字段�?,
    supplier_name VARCHAR(255) COMMENT '供应商名称（冗余字段�?,
    po_type ENUM('STANDARD', 'URGENT', 'BLANKET', 'CONTRACT') DEFAULT 'STANDARD' COMMENT '采购类型',
    po_status ENUM('DRAFT', 'SUBMITTED', 'APPROVED', 'REJECTED', 'ORDERED', 'PARTIAL_RECEIVED', 'RECEIVED', 'CLOSED', 'CANCELLED') DEFAULT 'DRAFT' COMMENT '订单状�?,
    order_date DATE NOT NULL COMMENT '订单日期',
    required_date DATE COMMENT '要求到货日期',
    promised_date DATE COMMENT '承诺到货日期',
    total_amount DECIMAL(18,2) DEFAULT 0 COMMENT '订单总金�?,
    currency VARCHAR(8) DEFAULT 'CNY' COMMENT '货币',
    payment_terms VARCHAR(128) COMMENT '付款条件',
    delivery_terms VARCHAR(128) COMMENT '交货条件',
    remarks TEXT COMMENT '备注',
    approver VARCHAR(64) COMMENT '审批�?,
    approval_date DATETIME COMMENT '审批日期',
    buyer VARCHAR(64) COMMENT '采购�?,
    tenant_id VARCHAR(32) COMMENT '租户ID（来自核心数据库�?,
    site_id VARCHAR(32) COMMENT '站点ID（来自核心数据库�?,
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_po_number (po_number),
    INDEX idx_supplier_id (supplier_id),
    INDEX idx_po_type (po_type),
    INDEX idx_po_status (po_status),
    INDEX idx_order_date (order_date),
    INDEX idx_required_date (required_date),
    INDEX idx_tenant_site (tenant_id, site_id)
) COMMENT '采购订单�?;

-- 采购订单明细�?
CREATE TABLE purchase_order_detail (
    detail_id VARCHAR(32) PRIMARY KEY COMMENT '明细ID',
    po_id VARCHAR(32) NOT NULL COMMENT '采购订单ID',
    line_number INT NOT NULL COMMENT '行号',
    item_id VARCHAR(32) NOT NULL COMMENT '物料ID（来自核心数据库�?,
    item_code VARCHAR(64) COMMENT '物料代码（冗余字段）',
    item_name VARCHAR(255) COMMENT '物料名称（冗余字段）',
    item_specification TEXT COMMENT '物料规格（冗余字段）',
    uom VARCHAR(16) COMMENT '计量单位（冗余字段）',
    ordered_qty DECIMAL(18,4) NOT NULL COMMENT '订购数量',
    received_qty DECIMAL(18,4) DEFAULT 0 COMMENT '已收数量',
    pending_qty DECIMAL(18,4) DEFAULT 0 COMMENT '待收数量',
    unit_price DECIMAL(18,4) NOT NULL COMMENT '单价',
    line_amount DECIMAL(18,2) NOT NULL COMMENT '行金�?,
    required_date DATE COMMENT '要求到货日期',
    promised_date DATE COMMENT '承诺到货日期',
    remarks TEXT COMMENT '备注',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_po (po_id),
    INDEX idx_item_id (item_id),
    INDEX idx_line_number (line_number),
    INDEX idx_tenant (tenant_id),
    FOREIGN KEY (po_id) REFERENCES purchase_order(po_id)
) COMMENT '采购订单明细�?;

-- 采购收货�?
CREATE TABLE purchase_receipt (
    receipt_id VARCHAR(32) PRIMARY KEY COMMENT '收货单ID',
    receipt_number VARCHAR(64) NOT NULL UNIQUE COMMENT '收货单号',
    po_id VARCHAR(32) NOT NULL COMMENT '采购订单ID',
    po_number VARCHAR(64) COMMENT '采购订单号（冗余字段�?,
    supplier_id VARCHAR(32) NOT NULL COMMENT '供应商ID',
    supplier_code VARCHAR(64) COMMENT '供应商代码（冗余字段�?,
    supplier_name VARCHAR(255) COMMENT '供应商名称（冗余字段�?,
    receipt_date DATE NOT NULL COMMENT '收货日期',
    receipt_status ENUM('DRAFT', 'RECEIVED', 'INSPECTED', 'ACCEPTED', 'REJECTED', 'PARTIAL_ACCEPTED') DEFAULT 'DRAFT' COMMENT '收货状�?,
    total_qty DECIMAL(18,4) DEFAULT 0 COMMENT '总收货数�?,
    total_amount DECIMAL(18,2) DEFAULT 0 COMMENT '总收货金�?,
    warehouse_code VARCHAR(64) COMMENT '仓库代码',
    location_code VARCHAR(64) COMMENT '库位代码',
    delivery_note VARCHAR(128) COMMENT '送货单号',
    truck_number VARCHAR(32) COMMENT '车牌�?,
    driver_name VARCHAR(64) COMMENT '司机姓名',
    driver_phone VARCHAR(32) COMMENT '司机电话',
    remarks TEXT COMMENT '备注',
    receiver VARCHAR(64) COMMENT '收货�?,
    inspector VARCHAR(64) COMMENT '检验员',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_receipt_number (receipt_number),
    INDEX idx_po (po_id),
    INDEX idx_supplier_id (supplier_id),
    INDEX idx_receipt_date (receipt_date),
    INDEX idx_receipt_status (receipt_status),
    INDEX idx_tenant_site (tenant_id, site_id),
    FOREIGN KEY (po_id) REFERENCES purchase_order(po_id)
) COMMENT '采购收货�?;

-- 采购收货明细�?
CREATE TABLE purchase_receipt_detail (
    detail_id VARCHAR(32) PRIMARY KEY COMMENT '明细ID',
    receipt_id VARCHAR(32) NOT NULL COMMENT '收货单ID',
    po_detail_id VARCHAR(32) NOT NULL COMMENT '采购订单明细ID',
    line_number INT NOT NULL COMMENT '行号',
    item_id VARCHAR(32) NOT NULL COMMENT '物料ID',
    item_code VARCHAR(64) COMMENT '物料代码（冗余字段）',
    item_name VARCHAR(255) COMMENT '物料名称（冗余字段）',
    batch_no VARCHAR(64) COMMENT '批次�?,
    serial_no VARCHAR(64) COMMENT '序列�?,
    received_qty DECIMAL(18,4) NOT NULL COMMENT '收货数量',
    accepted_qty DECIMAL(18,4) DEFAULT 0 COMMENT '接受数量',
    rejected_qty DECIMAL(18,4) DEFAULT 0 COMMENT '拒收数量',
    unit_price DECIMAL(18,4) NOT NULL COMMENT '单价',
    line_amount DECIMAL(18,2) NOT NULL COMMENT '行金�?,
    quality_status ENUM('PENDING', 'PASS', 'FAIL', 'SPECIAL') DEFAULT 'PENDING' COMMENT '质量状�?,
    inspection_result TEXT COMMENT '检验结�?,
    remarks TEXT COMMENT '备注',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_receipt (receipt_id),
    INDEX idx_po_detail (po_detail_id),
    INDEX idx_item_id (item_id),
    INDEX idx_batch_no (batch_no),
    INDEX idx_serial_no (serial_no),
    INDEX idx_quality_status (quality_status),
    INDEX idx_tenant (tenant_id),
    FOREIGN KEY (receipt_id) REFERENCES purchase_receipt(receipt_id),
    FOREIGN KEY (po_detail_id) REFERENCES purchase_order_detail(detail_id)
) COMMENT '采购收货明细�?;

-- 供应商评估表
CREATE TABLE supplier_evaluation (
    evaluation_id VARCHAR(32) PRIMARY KEY COMMENT '评估ID',
    supplier_id VARCHAR(32) NOT NULL COMMENT '供应商ID',
    supplier_code VARCHAR(64) COMMENT '供应商代码（冗余字段�?,
    supplier_name VARCHAR(255) COMMENT '供应商名称（冗余字段�?,
    evaluation_period VARCHAR(32) NOT NULL COMMENT '评估期间',
    evaluation_date DATE NOT NULL COMMENT '评估日期',
    evaluator VARCHAR(64) NOT NULL COMMENT '评估�?,
    quality_score DECIMAL(5,2) DEFAULT 0 COMMENT '质量评分',
    delivery_score DECIMAL(5,2) DEFAULT 0 COMMENT '交付评分',
    service_score DECIMAL(5,2) DEFAULT 0 COMMENT '服务评分',
    cost_score DECIMAL(5,2) DEFAULT 0 COMMENT '成本评分',
    overall_score DECIMAL(5,2) DEFAULT 0 COMMENT '综合评分',
    evaluation_level ENUM('EXCELLENT', 'GOOD', 'AVERAGE', 'POOR', 'UNACCEPTABLE') DEFAULT 'AVERAGE' COMMENT '评估等级',
    strengths TEXT COMMENT '优势',
    weaknesses TEXT COMMENT '劣势',
    improvement_suggestions TEXT COMMENT '改进建议',
    next_evaluation_date DATE COMMENT '下次评估日期',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状�?,
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_supplier_id (supplier_id),
    INDEX idx_evaluation_period (evaluation_period),
    INDEX idx_evaluation_date (evaluation_date),
    INDEX idx_evaluation_level (evaluation_level),
    INDEX idx_tenant (tenant_id)
) COMMENT '供应商评估表';

-- 采购合同�?
CREATE TABLE purchase_contract (
    contract_id VARCHAR(32) PRIMARY KEY COMMENT '合同ID',
    contract_number VARCHAR(64) NOT NULL UNIQUE COMMENT '合同编号',
    supplier_id VARCHAR(32) NOT NULL COMMENT '供应商ID',
    supplier_code VARCHAR(64) COMMENT '供应商代码（冗余字段�?,
    supplier_name VARCHAR(255) COMMENT '供应商名称（冗余字段�?,
    contract_type ENUM('FRAMEWORK', 'SPECIFIC', 'BLANKET') DEFAULT 'SPECIFIC' COMMENT '合同类型',
    contract_status ENUM('DRAFT', 'ACTIVE', 'EXPIRED', 'TERMINATED', 'CANCELLED') DEFAULT 'DRAFT' COMMENT '合同状�?,
    start_date DATE NOT NULL COMMENT '开始日�?,
    end_date DATE NOT NULL COMMENT '结束日期',
    total_amount DECIMAL(18,2) DEFAULT 0 COMMENT '合同总金�?,
    currency VARCHAR(8) DEFAULT 'CNY' COMMENT '货币',
    payment_terms VARCHAR(128) COMMENT '付款条件',
    delivery_terms VARCHAR(128) COMMENT '交货条件',
    warranty_period INT COMMENT '保修期（月）',
    contract_content TEXT COMMENT '合同内容',
    attachments JSON COMMENT '附件列表',
    approver VARCHAR(64) COMMENT '审批�?,
    approval_date DATETIME COMMENT '审批日期',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_contract_number (contract_number),
    INDEX idx_supplier_id (supplier_id),
    INDEX idx_contract_type (contract_type),
    INDEX idx_contract_status (contract_status),
    INDEX idx_start_date (start_date),
    INDEX idx_end_date (end_date),
    INDEX idx_tenant_site (tenant_id, site_id)
) COMMENT '采购合同�?;

-- 采购合同明细�?
CREATE TABLE purchase_contract_detail (
    detail_id VARCHAR(32) PRIMARY KEY COMMENT '明细ID',
    contract_id VARCHAR(32) NOT NULL COMMENT '合同ID',
    line_number INT NOT NULL COMMENT '行号',
    item_id VARCHAR(32) NOT NULL COMMENT '物料ID',
    item_code VARCHAR(64) COMMENT '物料代码（冗余字段）',
    item_name VARCHAR(255) COMMENT '物料名称（冗余字段）',
    item_specification TEXT COMMENT '物料规格（冗余字段）',
    uom VARCHAR(16) COMMENT '计量单位（冗余字段）',
    contract_qty DECIMAL(18,4) NOT NULL COMMENT '合同数量',
    unit_price DECIMAL(18,4) NOT NULL COMMENT '单价',
    line_amount DECIMAL(18,2) NOT NULL COMMENT '行金�?,
    delivery_schedule JSON COMMENT '交货计划',
    quality_requirements TEXT COMMENT '质量要求',
    remarks TEXT COMMENT '备注',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_contract (contract_id),
    INDEX idx_item_id (item_id),
    INDEX idx_line_number (line_number),
    INDEX idx_tenant (tenant_id),
    FOREIGN KEY (contract_id) REFERENCES purchase_contract(contract_id)
) COMMENT '采购合同明细�?;

-- ==============================================
-- 2. 采购BI聚合�?
-- ==============================================

-- 采购绩效聚合表（日级别）
CREATE TABLE agg_procurement_performance_1d (
    bucket_start DATE PRIMARY KEY COMMENT '统计日期',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    supplier_id VARCHAR(32) COMMENT '供应商ID',
    total_orders INT DEFAULT 0 COMMENT '总订单数',
    total_amount DECIMAL(18,2) DEFAULT 0 COMMENT '总采购金�?,
    on_time_delivery_rate DECIMAL(5,2) DEFAULT 0 COMMENT '准时交付�?,
    quality_pass_rate DECIMAL(5,2) DEFAULT 0 COMMENT '质量通过�?,
    cost_savings DECIMAL(18,2) DEFAULT 0 COMMENT '成本节约',
    avg_lead_time DECIMAL(8,2) DEFAULT 0 COMMENT '平均交期（天�?,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_supplier_id (supplier_id),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '采购绩效聚合�?�?';

-- ==============================================
-- 3. 数据同步配置�?
-- ==============================================

-- 核心数据同步�?
CREATE TABLE core_data_sync (
    sync_id VARCHAR(32) PRIMARY KEY COMMENT '同步ID',
    entity_type VARCHAR(32) NOT NULL COMMENT '实体类型',
    entity_id VARCHAR(32) NOT NULL COMMENT '实体ID',
    sync_action ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL COMMENT '同步动作',
    sync_status ENUM('PENDING', 'SUCCESS', 'FAILED') DEFAULT 'PENDING' COMMENT '同步状�?,
    sync_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '同步时间',
    error_message TEXT COMMENT '错误信息',
    retry_count INT DEFAULT 0 COMMENT '重试次数',
    INDEX idx_entity (entity_type, entity_id),
    INDEX idx_sync_status (sync_status),
    INDEX idx_sync_time (sync_time)
) COMMENT '核心数据同步�?;

