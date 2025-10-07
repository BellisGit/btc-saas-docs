-- ==============================================
-- BTC核心数据库 - 生产管理表
-- ==============================================

USE btc_core;

-- 工单主表
CREATE TABLE work_order (
    wo_id VARCHAR(32) PRIMARY KEY COMMENT '工单ID WO-YYYYMM-XXXX',
    wo_number VARCHAR(64) NOT NULL UNIQUE COMMENT '工单号',
    customer_id VARCHAR(32) COMMENT '客户ID',
    item_id VARCHAR(32) NOT NULL COMMENT '物料ID',
    planned_qty DECIMAL(18,4) NOT NULL COMMENT '计划数量',
    completed_qty DECIMAL(18,4) DEFAULT 0 COMMENT '完成数量',
    rejected_qty DECIMAL(18,4) DEFAULT 0 COMMENT '拒收数量',
    planned_start_date DATETIME COMMENT '计划开始时间',
    planned_end_date DATETIME COMMENT '计划结束时间',
    actual_start_date DATETIME COMMENT '实际开始时间',
    actual_end_date DATETIME COMMENT '实际结束时间',
    status ENUM('PLANNED', 'RELEASED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'ON_HOLD') DEFAULT 'PLANNED' COMMENT '工单状态',
    priority ENUM('LOW', 'NORMAL', 'HIGH', 'URGENT') DEFAULT 'NORMAL' COMMENT '优先级',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_wo_number (wo_number),
    INDEX idx_customer (customer_id),
    INDEX idx_item (item_id),
    INDEX idx_status (status),
    INDEX idx_priority (priority),
    INDEX idx_planned_start_date (planned_start_date),
    INDEX idx_tenant_site (tenant_id, site_id)
) COMMENT '工单主表';

-- 工艺路线表
CREATE TABLE routing (
    routing_id VARCHAR(32) PRIMARY KEY COMMENT '工艺路线ID',
    routing_code VARCHAR(64) NOT NULL COMMENT '工艺路线代码',
    routing_name VARCHAR(128) NOT NULL COMMENT '工艺路线名称',
    item_id VARCHAR(32) NOT NULL COMMENT '物料ID',
    version VARCHAR(16) DEFAULT '1.0' COMMENT '版本',
    status ENUM('ACTIVE', 'INACTIVE', 'DRAFT') DEFAULT 'ACTIVE' COMMENT '状态',
    description TEXT COMMENT '描述',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_routing_code (routing_code),
    INDEX idx_item (item_id),
    INDEX idx_status (status),
    INDEX idx_tenant (tenant_id)
) COMMENT '工艺路线表';

-- 工艺步骤表
CREATE TABLE routing_operation (
    operation_id VARCHAR(32) PRIMARY KEY COMMENT '工序ID',
    routing_id VARCHAR(32) NOT NULL COMMENT '工艺路线ID',
    operation_code VARCHAR(64) NOT NULL COMMENT '工序代码',
    operation_name VARCHAR(128) NOT NULL COMMENT '工序名称',
    operation_sequence INT NOT NULL COMMENT '工序顺序',
    work_center VARCHAR(64) COMMENT '工作中心',
    standard_time DECIMAL(8,2) COMMENT '标准时间(分钟)',
    setup_time DECIMAL(8,2) COMMENT '准备时间(分钟)',
    queue_time DECIMAL(8,2) COMMENT '排队时间(分钟)',
    move_time DECIMAL(8,2) COMMENT '移动时间(分钟)',
    description TEXT COMMENT '描述',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_routing (routing_id),
    INDEX idx_operation_code (operation_code),
    INDEX idx_operation_sequence (operation_sequence),
    INDEX idx_work_center (work_center),
    INDEX idx_tenant (tenant_id),
    FOREIGN KEY (routing_id) REFERENCES routing(routing_id)
) COMMENT '工艺步骤表';

-- BOM主表
CREATE TABLE bom_header (
    bom_id VARCHAR(32) PRIMARY KEY COMMENT 'BOM ID',
    bom_code VARCHAR(64) NOT NULL COMMENT 'BOM代码',
    bom_name VARCHAR(128) NOT NULL COMMENT 'BOM名称',
    parent_item_id VARCHAR(32) NOT NULL COMMENT '父物料ID',
    version VARCHAR(16) DEFAULT '1.0' COMMENT '版本',
    status ENUM('ACTIVE', 'INACTIVE', 'DRAFT') DEFAULT 'ACTIVE' COMMENT '状态',
    effective_date DATE COMMENT '生效日期',
    expiry_date DATE COMMENT '失效日期',
    description TEXT COMMENT '描述',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_bom_code (bom_code),
    INDEX idx_parent_item (parent_item_id),
    INDEX idx_status (status),
    INDEX idx_effective_date (effective_date),
    INDEX idx_tenant (tenant_id)
) COMMENT 'BOM主表';

-- BOM明细表
CREATE TABLE bom_detail (
    bom_detail_id VARCHAR(32) PRIMARY KEY COMMENT 'BOM明细ID',
    bom_id VARCHAR(32) NOT NULL COMMENT 'BOM ID',
    component_item_id VARCHAR(32) NOT NULL COMMENT '子物料ID',
    component_qty DECIMAL(18,4) NOT NULL COMMENT '用量',
    scrap_factor DECIMAL(5,2) DEFAULT 0 COMMENT '损耗率(%)',
    operation_id VARCHAR(32) COMMENT '工序ID',
    position VARCHAR(32) COMMENT '位置',
    description TEXT COMMENT '描述',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_bom (bom_id),
    INDEX idx_component_item (component_item_id),
    INDEX idx_operation (operation_id),
    INDEX idx_tenant (tenant_id),
    FOREIGN KEY (bom_id) REFERENCES bom_header(bom_id)
) COMMENT 'BOM明细表';

-- 工单工序表
CREATE TABLE wo_operation (
    wo_operation_id VARCHAR(32) PRIMARY KEY COMMENT '工单工序ID',
    wo_id VARCHAR(32) NOT NULL COMMENT '工单ID',
    operation_id VARCHAR(32) NOT NULL COMMENT '工序ID',
    operation_sequence INT NOT NULL COMMENT '工序顺序',
    planned_qty DECIMAL(18,4) NOT NULL COMMENT '计划数量',
    completed_qty DECIMAL(18,4) DEFAULT 0 COMMENT '完成数量',
    rejected_qty DECIMAL(18,4) DEFAULT 0 COMMENT '拒收数量',
    planned_start_date DATETIME COMMENT '计划开始时间',
    planned_end_date DATETIME COMMENT '计划结束时间',
    actual_start_date DATETIME COMMENT '实际开始时间',
    actual_end_date DATETIME COMMENT '实际结束时间',
    status ENUM('PENDING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED') DEFAULT 'PENDING' COMMENT '状态',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_wo (wo_id),
    INDEX idx_operation (operation_id),
    INDEX idx_operation_sequence (operation_sequence),
    INDEX idx_status (status),
    INDEX idx_tenant (tenant_id),
    FOREIGN KEY (wo_id) REFERENCES work_order(wo_id),
    FOREIGN KEY (operation_id) REFERENCES routing_operation(operation_id)
) COMMENT '工单工序表';

-- 添加外键约束
ALTER TABLE work_order ADD CONSTRAINT fk_wo_customer FOREIGN KEY (customer_id) REFERENCES customer_master(customer_id);
ALTER TABLE work_order ADD CONSTRAINT fk_wo_item FOREIGN KEY (item_id) REFERENCES item_master(item_id);
ALTER TABLE routing ADD CONSTRAINT fk_routing_item FOREIGN KEY (item_id) REFERENCES item_master(item_id);
ALTER TABLE bom_header ADD CONSTRAINT fk_bom_parent_item FOREIGN KEY (parent_item_id) REFERENCES item_master(item_id);
ALTER TABLE bom_detail ADD CONSTRAINT fk_bom_detail_component FOREIGN KEY (component_item_id) REFERENCES item_master(item_id);
ALTER TABLE bom_detail ADD CONSTRAINT fk_bom_detail_operation FOREIGN KEY (operation_id) REFERENCES routing_operation(operation_id);
