-- ==============================================
-- BTC采购管理数据库 - 扩展数据库示例
-- 独立数据库，通过API与核心数据库集成
-- ==============================================

-- 创建BTC采购管理数据库
CREATE DATABASE IF NOT EXISTS btc_procurement CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE btc_procurement;

-- ==============================================
-- 1. 采购基础表
-- ==============================================

-- 采购订单表
CREATE TABLE purchase_order (
    po_id VARCHAR(32) PRIMARY KEY COMMENT '采购订单ID',
    po_number VARCHAR(64) NOT NULL UNIQUE COMMENT '采购订单号',
    supplier_id VARCHAR(32) NOT NULL COMMENT '供应商ID（来自核心数据库）',
    supplier_code VARCHAR(64) COMMENT '供应商代码（冗余字段）',
    supplier_name VARCHAR(255) COMMENT '供应商名称（冗余字段）',
    po_type ENUM('STANDARD', 'URGENT', 'BLANKET', 'CONTRACT') DEFAULT 'STANDARD' COMMENT '采购类型',
    po_status ENUM('DRAFT', 'SUBMITTED', 'APPROVED', 'REJECTED', 'ORDERED', 'PARTIAL_RECEIVED', 'RECEIVED', 'CLOSED', 'CANCELLED') DEFAULT 'DRAFT' COMMENT '订单状态',
    order_date DATE NOT NULL COMMENT '订单日期',
    required_date DATE COMMENT '要求到货日期',
    promised_date DATE COMMENT '承诺到货日期',
    total_amount DECIMAL(18,2) DEFAULT 0 COMMENT '订单总金额',
    currency VARCHAR(8) DEFAULT 'CNY' COMMENT '货币',
    payment_terms VARCHAR(128) COMMENT '付款条件',
    delivery_terms VARCHAR(128) COMMENT '交货条件',
    remarks TEXT COMMENT '备注',
    approver VARCHAR(64) COMMENT '审批人',
    approval_date DATETIME COMMENT '审批日期',
    buyer VARCHAR(64) COMMENT '采购员',
    tenant_id VARCHAR(32) COMMENT '租户ID（来自核心数据库）',
    site_id VARCHAR(32) COMMENT '站点ID（来自核心数据库）',
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
) COMMENT '采购订单表';

-- 采购订单明细表
CREATE TABLE purchase_order_item (
    item_id VARCHAR(32) PRIMARY KEY COMMENT '明细ID',
    po_id VARCHAR(32) NOT NULL COMMENT '采购订单ID',
    line_number INT NOT NULL COMMENT '行号',
    item_code VARCHAR(64) NOT NULL COMMENT '物料代码',
    item_name VARCHAR(255) NOT NULL COMMENT '物料名称',
    item_description TEXT COMMENT '物料描述',
    item_category VARCHAR(64) COMMENT '物料类别',
    specification VARCHAR(255) COMMENT '规格',
    unit VARCHAR(16) NOT NULL COMMENT '单位',
    quantity DECIMAL(18,4) NOT NULL COMMENT '数量',
    unit_price DECIMAL(18,4) NOT NULL COMMENT '单价',
    total_price DECIMAL(18,2) NOT NULL COMMENT '总价',
    received_quantity DECIMAL(18,4) DEFAULT 0 COMMENT '已收货数量',
    pending_quantity DECIMAL(18,4) COMMENT '待收货数量',
    required_date DATE COMMENT '要求到货日期',
    promised_date DATE COMMENT '承诺到货日期',
    warehouse_location VARCHAR(128) COMMENT '仓库位置',
    remarks TEXT COMMENT '备注',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_po_id (po_id),
    INDEX idx_item_code (item_code),
    INDEX idx_line_number (line_number),
    INDEX idx_tenant_site (tenant_id, site_id),
    FOREIGN KEY (po_id) REFERENCES purchase_order(po_id)
) COMMENT '采购订单明细表';

-- 供应商管理表
CREATE TABLE supplier (
    supplier_id VARCHAR(32) PRIMARY KEY COMMENT '供应商ID',
    supplier_code VARCHAR(64) NOT NULL UNIQUE COMMENT '供应商代码',
    supplier_name VARCHAR(255) NOT NULL COMMENT '供应商名称',
    supplier_type ENUM('MANUFACTURER', 'DISTRIBUTOR', 'TRADER', 'SERVICE') DEFAULT 'MANUFACTURER' COMMENT '供应商类型',
    business_license VARCHAR(128) COMMENT '营业执照号',
    tax_number VARCHAR(128) COMMENT '税号',
    contact_person VARCHAR(64) COMMENT '联系人',
    contact_phone VARCHAR(32) COMMENT '联系电话',
    contact_email VARCHAR(128) COMMENT '联系邮箱',
    address TEXT COMMENT '地址',
    payment_terms VARCHAR(128) COMMENT '付款条件',
    delivery_terms VARCHAR(128) COMMENT '交货条件',
    credit_limit DECIMAL(18,2) COMMENT '信用额度',
    payment_method ENUM('CASH', 'CREDIT', 'LETTER_OF_CREDIT', 'OTHER') DEFAULT 'CREDIT' COMMENT '付款方式',
    bank_name VARCHAR(128) COMMENT '开户银行',
    bank_account VARCHAR(128) COMMENT '银行账号',
    rating ENUM('A', 'B', 'C', 'D', 'E') DEFAULT 'B' COMMENT '供应商评级',
    status ENUM('ACTIVE', 'INACTIVE', 'BLACKLISTED') DEFAULT 'ACTIVE' COMMENT '状态',
    certification_info JSON COMMENT '认证信息',
    quality_score DECIMAL(3,2) COMMENT '质量评分',
    delivery_score DECIMAL(3,2) COMMENT '交付评分',
    service_score DECIMAL(3,2) COMMENT '服务评分',
    overall_score DECIMAL(3,2) COMMENT '综合评分',
    last_evaluation_date DATE COMMENT '最后评估日期',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_supplier_code (supplier_code),
    INDEX idx_supplier_name (supplier_name),
    INDEX idx_supplier_type (supplier_type),
    INDEX idx_rating (rating),
    INDEX idx_status (status),
    INDEX idx_tenant_site (tenant_id, site_id)
) COMMENT '供应商管理表';

-- 收货单表
CREATE TABLE goods_receipt (
    receipt_id VARCHAR(32) PRIMARY KEY COMMENT '收货单ID',
    receipt_number VARCHAR(64) NOT NULL UNIQUE COMMENT '收货单号',
    po_id VARCHAR(32) COMMENT '采购订单ID',
    supplier_id VARCHAR(32) NOT NULL COMMENT '供应商ID',
    supplier_code VARCHAR(64) COMMENT '供应商代码',
    supplier_name VARCHAR(255) COMMENT '供应商名称',
    receipt_type ENUM('PURCHASE', 'RETURN', 'TRANSFER', 'OTHER') DEFAULT 'PURCHASE' COMMENT '收货类型',
    receipt_status ENUM('DRAFT', 'RECEIVED', 'PARTIAL_RECEIVED', 'VERIFIED', 'ACCEPTED', 'REJECTED') DEFAULT 'DRAFT' COMMENT '收货状态',
    receipt_date DATE NOT NULL COMMENT '收货日期',
    warehouse_id VARCHAR(32) COMMENT '仓库ID',
    warehouse_code VARCHAR(64) COMMENT '仓库代码',
    warehouse_name VARCHAR(128) COMMENT '仓库名称',
    receiving_person VARCHAR(64) COMMENT '收货人',
    inspector VARCHAR(64) COMMENT '检验员',
    inspection_date DATETIME COMMENT '检验日期',
    inspection_result ENUM('PASS', 'FAIL', 'PENDING') COMMENT '检验结果',
    total_quantity DECIMAL(18,4) DEFAULT 0 COMMENT '总数量',
    accepted_quantity DECIMAL(18,4) DEFAULT 0 COMMENT '验收数量',
    rejected_quantity DECIMAL(18,4) DEFAULT 0 COMMENT '拒收数量',
    remarks TEXT COMMENT '备注',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_receipt_number (receipt_number),
    INDEX idx_po_id (po_id),
    INDEX idx_supplier_id (supplier_id),
    INDEX idx_receipt_type (receipt_type),
    INDEX idx_receipt_status (receipt_status),
    INDEX idx_receipt_date (receipt_date),
    INDEX idx_warehouse_id (warehouse_id),
    INDEX idx_tenant_site (tenant_id, site_id),
    FOREIGN KEY (po_id) REFERENCES purchase_order(po_id),
    FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id)
) COMMENT '收货单表';

-- 收货明细表
CREATE TABLE goods_receipt_item (
    item_id VARCHAR(32) PRIMARY KEY COMMENT '明细ID',
    receipt_id VARCHAR(32) NOT NULL COMMENT '收货单ID',
    po_item_id VARCHAR(32) COMMENT '采购订单明细ID',
    line_number INT NOT NULL COMMENT '行号',
    item_code VARCHAR(64) NOT NULL COMMENT '物料代码',
    item_name VARCHAR(255) NOT NULL COMMENT '物料名称',
    specification VARCHAR(255) COMMENT '规格',
    unit VARCHAR(16) NOT NULL COMMENT '单位',
    ordered_quantity DECIMAL(18,4) COMMENT '订购数量',
    received_quantity DECIMAL(18,4) NOT NULL COMMENT '收货数量',
    accepted_quantity DECIMAL(18,4) DEFAULT 0 COMMENT '验收数量',
    rejected_quantity DECIMAL(18,4) DEFAULT 0 COMMENT '拒收数量',
    unit_price DECIMAL(18,4) COMMENT '单价',
    total_price DECIMAL(18,2) COMMENT '总价',
    batch_number VARCHAR(64) COMMENT '批次号',
    expiry_date DATE COMMENT '过期日期',
    location_code VARCHAR(64) COMMENT '库位代码',
    quality_status ENUM('PASS', 'FAIL', 'PENDING') COMMENT '质量状态',
    inspection_notes TEXT COMMENT '检验备注',
    remarks TEXT COMMENT '备注',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_receipt_id (receipt_id),
    INDEX idx_po_item_id (po_item_id),
    INDEX idx_item_code (item_code),
    INDEX idx_line_number (line_number),
    INDEX idx_batch_number (batch_number),
    INDEX idx_tenant_site (tenant_id, site_id),
    FOREIGN KEY (receipt_id) REFERENCES goods_receipt(receipt_id),
    FOREIGN KEY (po_item_id) REFERENCES purchase_order_item(item_id)
) COMMENT '收货明细表';

-- 采购申请表
CREATE TABLE purchase_requisition (
    req_id VARCHAR(32) PRIMARY KEY COMMENT '申请ID',
    req_number VARCHAR(64) NOT NULL UNIQUE COMMENT '申请单号',
    req_type ENUM('MATERIAL', 'EQUIPMENT', 'SERVICE', 'OTHER') DEFAULT 'MATERIAL' COMMENT '申请类型',
    req_status ENUM('DRAFT', 'SUBMITTED', 'APPROVED', 'REJECTED', 'PURCHASED', 'CLOSED') DEFAULT 'DRAFT' COMMENT '申请状态',
    priority ENUM('LOW', 'NORMAL', 'HIGH', 'URGENT') DEFAULT 'NORMAL' COMMENT '优先级',
    title VARCHAR(255) NOT NULL COMMENT '标题',
    description TEXT COMMENT '描述',
    required_date DATE COMMENT '需求日期',
    budget_amount DECIMAL(18,2) COMMENT '预算金额',
    actual_amount DECIMAL(18,2) DEFAULT 0 COMMENT '实际金额',
    requester VARCHAR(64) NOT NULL COMMENT '申请人',
    department VARCHAR(128) COMMENT '申请部门',
    approver VARCHAR(64) COMMENT '审批人',
    approval_date DATETIME COMMENT '审批日期',
    approval_notes TEXT COMMENT '审批备注',
    buyer VARCHAR(64) COMMENT '采购员',
    po_id VARCHAR(32) COMMENT '关联采购订单ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_req_number (req_number),
    INDEX idx_req_type (req_type),
    INDEX idx_req_status (req_status),
    INDEX idx_priority (priority),
    INDEX idx_requester (requester),
    INDEX idx_approver (approver),
    INDEX idx_required_date (required_date),
    INDEX idx_tenant_site (tenant_id, site_id),
    FOREIGN KEY (po_id) REFERENCES purchase_order(po_id)
) COMMENT '采购申请表';

-- 采购申请明细表
CREATE TABLE purchase_requisition_item (
    item_id VARCHAR(32) PRIMARY KEY COMMENT '明细ID',
    req_id VARCHAR(32) NOT NULL COMMENT '申请ID',
    line_number INT NOT NULL COMMENT '行号',
    item_code VARCHAR(64) NOT NULL COMMENT '物料代码',
    item_name VARCHAR(255) NOT NULL COMMENT '物料名称',
    item_description TEXT COMMENT '物料描述',
    specification VARCHAR(255) COMMENT '规格',
    unit VARCHAR(16) NOT NULL COMMENT '单位',
    quantity DECIMAL(18,4) NOT NULL COMMENT '数量',
    unit_price DECIMAL(18,4) COMMENT '单价',
    total_price DECIMAL(18,2) COMMENT '总价',
    required_date DATE COMMENT '需求日期',
    purpose TEXT COMMENT '用途说明',
    remarks TEXT COMMENT '备注',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_req_id (req_id),
    INDEX idx_item_code (item_code),
    INDEX idx_line_number (line_number),
    INDEX idx_required_date (required_date),
    INDEX idx_tenant_site (tenant_id, site_id),
    FOREIGN KEY (req_id) REFERENCES purchase_requisition(req_id)
) COMMENT '采购申请明细表';

-- 采购合同表
CREATE TABLE purchase_contract (
    contract_id VARCHAR(32) PRIMARY KEY COMMENT '合同ID',
    contract_number VARCHAR(64) NOT NULL UNIQUE COMMENT '合同编号',
    supplier_id VARCHAR(32) NOT NULL COMMENT '供应商ID',
    supplier_code VARCHAR(64) COMMENT '供应商代码',
    supplier_name VARCHAR(255) COMMENT '供应商名称',
    contract_type ENUM('FRAMEWORK', 'PURCHASE', 'SERVICE', 'OTHER') DEFAULT 'PURCHASE' COMMENT '合同类型',
    contract_status ENUM('DRAFT', 'NEGOTIATING', 'APPROVED', 'SIGNED', 'ACTIVE', 'EXPIRED', 'TERMINATED') DEFAULT 'DRAFT' COMMENT '合同状态',
    title VARCHAR(255) NOT NULL COMMENT '合同标题',
    description TEXT COMMENT '合同描述',
    contract_amount DECIMAL(18,2) NOT NULL COMMENT '合同金额',
    currency VARCHAR(8) DEFAULT 'CNY' COMMENT '货币',
    start_date DATE COMMENT '开始日期',
    end_date DATE COMMENT '结束日期',
    payment_terms TEXT COMMENT '付款条件',
    delivery_terms TEXT COMMENT '交货条件',
    quality_terms TEXT COMMENT '质量条件',
    warranty_terms TEXT COMMENT '保修条件',
    penalty_terms TEXT COMMENT '违约条款',
    sign_date DATE COMMENT '签署日期',
    signer VARCHAR(64) COMMENT '签署人',
    approver VARCHAR(64) COMMENT '审批人',
    approval_date DATETIME COMMENT '审批日期',
    contract_file_path VARCHAR(500) COMMENT '合同文件路径',
    remarks TEXT COMMENT '备注',
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
    INDEX idx_tenant_site (tenant_id, site_id),
    FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id)
) COMMENT '采购合同表';

-- 采购合同明细表
CREATE TABLE purchase_contract_item (
    item_id VARCHAR(32) PRIMARY KEY COMMENT '明细ID',
    contract_id VARCHAR(32) NOT NULL COMMENT '合同ID',
    line_number INT NOT NULL COMMENT '行号',
    item_code VARCHAR(64) NOT NULL COMMENT '物料代码',
    item_name VARCHAR(255) NOT NULL COMMENT '物料名称',
    item_description TEXT COMMENT '物料描述',
    specification VARCHAR(255) COMMENT '规格',
    unit VARCHAR(16) NOT NULL COMMENT '单位',
    quantity DECIMAL(18,4) NOT NULL COMMENT '数量',
    unit_price DECIMAL(18,4) NOT NULL COMMENT '单价',
    total_price DECIMAL(18,2) NOT NULL COMMENT '总价',
    delivery_schedule JSON COMMENT '交付计划',
    quality_requirements TEXT COMMENT '质量要求',
    remarks TEXT COMMENT '备注',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_contract_id (contract_id),
    INDEX idx_item_code (item_code),
    INDEX idx_line_number (line_number),
    INDEX idx_tenant_site (tenant_id, site_id),
    FOREIGN KEY (contract_id) REFERENCES purchase_contract(contract_id)
) COMMENT '采购合同明细表';

-- 采购统计表
CREATE TABLE procurement_stats (
    stats_id VARCHAR(32) PRIMARY KEY COMMENT '统计ID',
    stats_period DATE NOT NULL COMMENT '统计周期',
    supplier_id VARCHAR(32) COMMENT '供应商ID',
    item_category VARCHAR(64) COMMENT '物料类别',
    total_orders INT DEFAULT 0 COMMENT '总订单数',
    total_amount DECIMAL(18,2) DEFAULT 0 COMMENT '总金额',
    avg_order_amount DECIMAL(18,2) DEFAULT 0 COMMENT '平均订单金额',
    on_time_delivery_rate DECIMAL(5,2) COMMENT '准时交付率',
    quality_pass_rate DECIMAL(5,2) COMMENT '质量合格率',
    cost_savings DECIMAL(18,2) DEFAULT 0 COMMENT '成本节约',
    supplier_rating DECIMAL(3,2) COMMENT '供应商评分',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_stats_period (stats_period),
    INDEX idx_supplier_id (supplier_id),
    INDEX idx_item_category (item_category),
    INDEX idx_tenant_site (tenant_id, site_id),
    UNIQUE KEY uk_period_supplier_category (stats_period, supplier_id, item_category)
) COMMENT '采购统计表';

-- ==============================================
-- 2. 初始化数据
-- ==============================================

-- 插入示例供应商
INSERT INTO supplier (
    supplier_id, supplier_code, supplier_name, supplier_type,
    contact_person, contact_phone, contact_email, address,
    payment_terms, delivery_terms, rating, status,
    tenant_id, site_id, created_by
) VALUES (
    'SUP_001', 'SUP001', '示例供应商A', 'MANUFACTURER',
    '张三', '13800138000', 'zhangsan@supplier.com', '北京市朝阳区xxx路xxx号',
    '月结30天', 'FOB', 'A', 'ACTIVE',
    'TENANT_001', 'SITE_001', 'SYSTEM'
);

-- 插入示例采购订单
INSERT INTO purchase_order (
    po_id, po_number, supplier_id, supplier_code, supplier_name,
    po_type, po_status, order_date, required_date,
    total_amount, buyer, tenant_id, site_id, created_by
) VALUES (
    'PO_001', 'PO20250107001', 'SUP_001', 'SUP001', '示例供应商A',
    'STANDARD', 'APPROVED', '2025-01-07', '2025-01-14',
    10000.00, 'BUYER_001', 'TENANT_001', 'SITE_001', 'SYSTEM'
);

-- 插入示例采购订单明细
INSERT INTO purchase_order_item (
    item_id, po_id, line_number, item_code, item_name,
    specification, unit, quantity, unit_price, total_price,
    tenant_id, site_id, created_by
) VALUES (
    'POI_001', 'PO_001', 1, 'ITEM_001', '示例物料A',
    '规格A', 'PCS', 100, 50.00, 5000.00,
    'TENANT_001', 'SITE_001', 'SYSTEM'
);