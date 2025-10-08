-- ==============================================
-- BTC核心数据库 - 租户和部门表
-- ==============================================

USE btc_core;

CREATE TABLE tenant (
    tenant_id VARCHAR(32) PRIMARY KEY COMMENT '租户ID',
    tenant_code VARCHAR(64) NOT NULL UNIQUE COMMENT '租户代码',
    tenant_name VARCHAR(128) NOT NULL COMMENT '租户名称',
    tenant_type ENUM('ENTERPRISE', 'SMALL_MEDIUM', 'INDIVIDUAL') DEFAULT 'ENTERPRISE' COMMENT '租户类型',
    status ENUM('ACTIVE', 'INACTIVE', 'SUSPENDED') DEFAULT 'ACTIVE' COMMENT '状态',
    contact_person VARCHAR(64) COMMENT '联系人',
    contact_phone VARCHAR(32) COMMENT '联系电话',
    contact_email VARCHAR(128) COMMENT '联系邮箱',
    address TEXT COMMENT '地址',
    industry VARCHAR(64) COMMENT '行业',
    scale VARCHAR(32) COMMENT '规模',
    logo_url VARCHAR(255) COMMENT 'Logo URL',
    settings JSON COMMENT '租户配置',
    subscription_plan VARCHAR(32) COMMENT '订阅计划',
    subscription_expire DATETIME COMMENT '订阅过期时间',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant_code (tenant_code),
    INDEX idx_tenant_name (tenant_name),
    INDEX idx_status (status),
    INDEX idx_subscription_expire (subscription_expire)
) COMMENT '租户管理表';

-- ==============================================
-- 2. 部门表
-- ==============================================

CREATE TABLE sys_dept (
    dept_id VARCHAR(32) PRIMARY KEY COMMENT '部门ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    dept_code VARCHAR(64) NOT NULL COMMENT '部门代码',
    dept_name VARCHAR(128) NOT NULL COMMENT '部门名称',
    parent_id VARCHAR(32) COMMENT '父部门ID',
    dept_type ENUM('COMPANY', 'DEPARTMENT', 'TEAM', 'GROUP') DEFAULT 'DEPARTMENT' COMMENT '部门类型',
    manager_id VARCHAR(32) COMMENT '部门负责人ID',
    sort_order INT DEFAULT 0 COMMENT '排序',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant (tenant_id),
    INDEX idx_parent_id (parent_id),
    INDEX idx_status (status),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    FOREIGN KEY (parent_id) REFERENCES sys_dept(dept_id)
) COMMENT '部门表';
