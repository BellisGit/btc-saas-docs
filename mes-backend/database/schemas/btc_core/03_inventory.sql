-- ==============================================
-- BTC核心数据库 - 库存管理表
-- ==============================================

USE btc_core;

-- 库存表
CREATE TABLE stock (
    stock_id VARCHAR(32) PRIMARY KEY COMMENT '库存ID',
    item_id VARCHAR(32) NOT NULL COMMENT '物料ID',
    location_id VARCHAR(32) NOT NULL COMMENT '库位ID',
    batch_no VARCHAR(64) COMMENT '批次号',
    serial_no VARCHAR(64) COMMENT '序列号',
    quantity DECIMAL(18,4) NOT NULL DEFAULT 0 COMMENT '数量',
    reserved_qty DECIMAL(18,4) DEFAULT 0 COMMENT '预留数量',
    available_qty DECIMAL(18,4) DEFAULT 0 COMMENT '可用数量',
    unit_cost DECIMAL(18,4) DEFAULT 0 COMMENT '单位成本',
    total_cost DECIMAL(18,2) DEFAULT 0 COMMENT '总成本',
    status ENUM('AVAILABLE', 'RESERVED', 'QUARANTINE', 'BLOCKED') DEFAULT 'AVAILABLE' COMMENT '状态',
    expiry_date DATE COMMENT '过期日期',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_item (item_id),
    INDEX idx_location (location_id),
    INDEX idx_batch_no (batch_no),
    INDEX idx_serial_no (serial_no),
    INDEX idx_status (status),
    INDEX idx_expiry_date (expiry_date),
    INDEX idx_tenant_site (tenant_id, site_id)
) COMMENT '库存表';

-- 库存事务表
CREATE TABLE stock_transaction (
    transaction_id VARCHAR(32) PRIMARY KEY COMMENT '事务ID',
    transaction_no VARCHAR(64) NOT NULL UNIQUE COMMENT '事务号',
    transaction_type ENUM('IN', 'OUT', 'TRANSFER', 'ADJUST', 'RESERVE', 'UNRESERVE', 'COUNT') NOT NULL COMMENT '事务类型',
    item_id VARCHAR(32) NOT NULL COMMENT '物料ID',
    from_location_id VARCHAR(32) COMMENT '源库位ID',
    to_location_id VARCHAR(32) COMMENT '目标库位ID',
    quantity DECIMAL(18,4) NOT NULL COMMENT '数量',
    unit_cost DECIMAL(18,4) DEFAULT 0 COMMENT '单位成本',
    total_cost DECIMAL(18,2) DEFAULT 0 COMMENT '总成本',
    batch_no VARCHAR(64) COMMENT '批次号',
    serial_no VARCHAR(64) COMMENT '序列号',
    reference_type VARCHAR(32) COMMENT '参考类型',
    reference_id VARCHAR(32) COMMENT '参考ID',
    reference_no VARCHAR(64) COMMENT '参考单号',
    transaction_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '事务日期',
    reason_code VARCHAR(32) COMMENT '原因代码',
    description TEXT COMMENT '描述',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_transaction_no (transaction_no),
    INDEX idx_transaction_type (transaction_type),
    INDEX idx_item (item_id),
    INDEX idx_from_location (from_location_id),
    INDEX idx_to_location (to_location_id),
    INDEX idx_batch_no (batch_no),
    INDEX idx_serial_no (serial_no),
    INDEX idx_reference (reference_type, reference_id),
    INDEX idx_transaction_date (transaction_date),
    INDEX idx_tenant_site (tenant_id, site_id)
) COMMENT '库存事务表';

-- 库存预留表
CREATE TABLE stock_reservation (
    reservation_id VARCHAR(32) PRIMARY KEY COMMENT '预留ID',
    reservation_no VARCHAR(64) NOT NULL UNIQUE COMMENT '预留单号',
    item_id VARCHAR(32) NOT NULL COMMENT '物料ID',
    location_id VARCHAR(32) NOT NULL COMMENT '库位ID',
    batch_no VARCHAR(64) COMMENT '批次号',
    serial_no VARCHAR(64) COMMENT '序列号',
    reserved_qty DECIMAL(18,4) NOT NULL COMMENT '预留数量',
    consumed_qty DECIMAL(18,4) DEFAULT 0 COMMENT '消耗数量',
    remaining_qty DECIMAL(18,4) DEFAULT 0 COMMENT '剩余数量',
    reservation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '预留日期',
    expiry_date DATETIME COMMENT '过期日期',
    reference_type VARCHAR(32) COMMENT '参考类型',
    reference_id VARCHAR(32) COMMENT '参考ID',
    reference_no VARCHAR(64) COMMENT '参考单号',
    status ENUM('ACTIVE', 'PARTIAL', 'COMPLETED', 'CANCELLED', 'EXPIRED') DEFAULT 'ACTIVE' COMMENT '状态',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_reservation_no (reservation_no),
    INDEX idx_item (item_id),
    INDEX idx_location (location_id),
    INDEX idx_batch_no (batch_no),
    INDEX idx_serial_no (serial_no),
    INDEX idx_reference (reference_type, reference_id),
    INDEX idx_reservation_date (reservation_date),
    INDEX idx_status (status),
    INDEX idx_tenant_site (tenant_id, site_id)
) COMMENT '库存预留表';

-- 库存盘点表
CREATE TABLE stock_count (
    count_id VARCHAR(32) PRIMARY KEY COMMENT '盘点ID',
    count_no VARCHAR(64) NOT NULL UNIQUE COMMENT '盘点单号',
    count_type ENUM('CYCLE', 'PHYSICAL', 'SPOT', 'ADJUSTMENT') NOT NULL COMMENT '盘点类型',
    location_id VARCHAR(32) NOT NULL COMMENT '库位ID',
    count_date DATE NOT NULL COMMENT '盘点日期',
    status ENUM('PLANNED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED') DEFAULT 'PLANNED' COMMENT '状态',
    description TEXT COMMENT '描述',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_count_no (count_no),
    INDEX idx_count_type (count_type),
    INDEX idx_location (location_id),
    INDEX idx_count_date (count_date),
    INDEX idx_status (status),
    INDEX idx_tenant_site (tenant_id, site_id)
) COMMENT '库存盘点表';

-- 库存盘点明细表
CREATE TABLE stock_count_detail (
    count_detail_id VARCHAR(32) PRIMARY KEY COMMENT '盘点明细ID',
    count_id VARCHAR(32) NOT NULL COMMENT '盘点ID',
    item_id VARCHAR(32) NOT NULL COMMENT '物料ID',
    batch_no VARCHAR(64) COMMENT '批次号',
    serial_no VARCHAR(64) COMMENT '序列号',
    system_qty DECIMAL(18,4) NOT NULL DEFAULT 0 COMMENT '系统数量',
    counted_qty DECIMAL(18,4) DEFAULT 0 COMMENT '盘点数量',
    variance_qty DECIMAL(18,4) DEFAULT 0 COMMENT '差异数量',
    variance_cost DECIMAL(18,2) DEFAULT 0 COMMENT '差异成本',
    unit_cost DECIMAL(18,4) DEFAULT 0 COMMENT '单位成本',
    count_status ENUM('PENDING', 'COUNTED', 'VERIFIED', 'ADJUSTED') DEFAULT 'PENDING' COMMENT '盘点状态',
    counted_by VARCHAR(64) COMMENT '盘点人',
    counted_date DATETIME COMMENT '盘点时间',
    verified_by VARCHAR(64) COMMENT '复核人',
    verified_date DATETIME COMMENT '复核时间',
    remarks TEXT COMMENT '备注',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_count (count_id),
    INDEX idx_item (item_id),
    INDEX idx_batch_no (batch_no),
    INDEX idx_serial_no (serial_no),
    INDEX idx_count_status (count_status),
    INDEX idx_tenant (tenant_id),
    FOREIGN KEY (count_id) REFERENCES stock_count(count_id)
) COMMENT '库存盘点明细表';

-- 添加外键约束
ALTER TABLE stock ADD CONSTRAINT fk_stock_item FOREIGN KEY (item_id) REFERENCES item_master(item_id);
ALTER TABLE stock ADD CONSTRAINT fk_stock_location FOREIGN KEY (location_id) REFERENCES location_master(location_id);
ALTER TABLE stock_transaction ADD CONSTRAINT fk_stock_trans_item FOREIGN KEY (item_id) REFERENCES item_master(item_id);
ALTER TABLE stock_transaction ADD CONSTRAINT fk_stock_trans_from_location FOREIGN KEY (from_location_id) REFERENCES location_master(location_id);
ALTER TABLE stock_transaction ADD CONSTRAINT fk_stock_trans_to_location FOREIGN KEY (to_location_id) REFERENCES location_master(location_id);
ALTER TABLE stock_reservation ADD CONSTRAINT fk_stock_res_item FOREIGN KEY (item_id) REFERENCES item_master(item_id);
ALTER TABLE stock_reservation ADD CONSTRAINT fk_stock_res_location FOREIGN KEY (location_id) REFERENCES location_master(location_id);
ALTER TABLE stock_count ADD CONSTRAINT fk_stock_count_location FOREIGN KEY (location_id) REFERENCES location_master(location_id);
ALTER TABLE stock_count_detail ADD CONSTRAINT fk_stock_count_detail_item FOREIGN KEY (item_id) REFERENCES item_master(item_id);
