-- ==============================================
-- BTC核心数据库 - 主数据管理表
-- ==============================================

USE btc_core;

-- 物料主数据表
CREATE TABLE item_master (
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
CREATE TABLE supplier_master (
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
    INDEX idx_status (status),
    INDEX idx_tenant (tenant_id)
) COMMENT '供应商主数据表';

-- 客户主数据表
CREATE TABLE customer_master (
    customer_id VARCHAR(32) PRIMARY KEY COMMENT '客户编码 CUS-XXXXX',
    customer_code VARCHAR(64) NOT NULL COMMENT '客户代码',
    customer_name VARCHAR(255) NOT NULL COMMENT '客户名称',
    customer_type ENUM('RETAIL', 'WHOLESALE', 'OEM', 'END_USER') DEFAULT 'END_USER' COMMENT '客户类型',
    contact_person VARCHAR(100) COMMENT '联系人',
    contact_phone VARCHAR(50) COMMENT '联系电话',
    contact_email VARCHAR(100) COMMENT '联系邮箱',
    address TEXT COMMENT '地址',
    status ENUM('ACTIVE', 'INACTIVE', 'BLACKLIST') DEFAULT 'ACTIVE' COMMENT '状态',
    credit_limit DECIMAL(18,2) DEFAULT 0 COMMENT '信用额度',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_customer_code (customer_code),
    INDEX idx_customer_type (customer_type),
    INDEX idx_status (status),
    INDEX idx_tenant (tenant_id)
) COMMENT '客户主数据表';

-- 库位主数据表
CREATE TABLE location_master (
    location_id VARCHAR(32) PRIMARY KEY COMMENT '库位编码 LOC-XXXXX',
    location_code VARCHAR(64) NOT NULL COMMENT '库位代码',
    location_name VARCHAR(255) NOT NULL COMMENT '库位名称',
    location_type ENUM('WAREHOUSE', 'PRODUCTION_LINE', 'QUALITY_AREA', 'SCRAP_AREA', 'RETURN_AREA') NOT NULL COMMENT '库位类型',
    warehouse_code VARCHAR(64) COMMENT '仓库代码',
    zone_code VARCHAR(64) COMMENT '区域代码',
    aisle_code VARCHAR(64) COMMENT '通道代码',
    rack_code VARCHAR(64) COMMENT '货架代码',
    shelf_code VARCHAR(64) COMMENT '层代码',
    position_code VARCHAR(64) COMMENT '位代码',
    capacity DECIMAL(18,4) DEFAULT 0 COMMENT '容量',
    capacity_uom VARCHAR(16) COMMENT '容量单位',
    status ENUM('ACTIVE', 'INACTIVE', 'MAINTENANCE') DEFAULT 'ACTIVE' COMMENT '状态',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_location_code (location_code),
    INDEX idx_location_type (location_type),
    INDEX idx_warehouse_code (warehouse_code),
    INDEX idx_status (status),
    INDEX idx_tenant_site (tenant_id, site_id)
) COMMENT '库位主数据表';

-- 缺陷代码主数据表
CREATE TABLE defect_code_master (
    defect_code_id VARCHAR(32) PRIMARY KEY COMMENT '缺陷代码ID',
    defect_code VARCHAR(32) NOT NULL COMMENT '缺陷代码',
    defect_name VARCHAR(128) NOT NULL COMMENT '缺陷名称',
    defect_category VARCHAR(64) COMMENT '缺陷类别',
    severity_level ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') DEFAULT 'MEDIUM' COMMENT '严重程度',
    description TEXT COMMENT '缺陷描述',
    root_cause_category VARCHAR(64) COMMENT '根本原因类别',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_defect_code (defect_code),
    INDEX idx_defect_category (defect_category),
    INDEX idx_severity_level (severity_level),
    INDEX idx_status (status),
    INDEX idx_tenant (tenant_id)
) COMMENT '缺陷代码主数据表';

-- 原因代码主数据表
CREATE TABLE cause_code_master (
    cause_code_id VARCHAR(32) PRIMARY KEY COMMENT '原因代码ID',
    cause_code VARCHAR(32) NOT NULL COMMENT '原因代码',
    cause_name VARCHAR(128) NOT NULL COMMENT '原因名称',
    cause_category VARCHAR(64) COMMENT '原因类别',
    description TEXT COMMENT '原因描述',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_cause_code (cause_code),
    INDEX idx_cause_category (cause_category),
    INDEX idx_status (status),
    INDEX idx_tenant (tenant_id)
) COMMENT '原因代码主数据表';

-- 添加外键约束
ALTER TABLE item_master ADD CONSTRAINT fk_item_supplier FOREIGN KEY (supplier_id) REFERENCES supplier_master(supplier_id);
