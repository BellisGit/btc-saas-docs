-- ==============================================
-- BTC核心数据库 - 角色和权限表
-- ==============================================

USE btc_core;

CREATE TABLE sys_role (
    role_id VARCHAR(32) PRIMARY KEY COMMENT '角色ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    parent_role_id VARCHAR(32) COMMENT '父角色ID',
    role_code VARCHAR(64) NOT NULL COMMENT '角色代码',
    role_name VARCHAR(128) NOT NULL COMMENT '角色名称',
    role_type ENUM('SYSTEM', 'TENANT', 'CUSTOM') DEFAULT 'TENANT' COMMENT '角色类型',
    role_level INT DEFAULT 0 COMMENT '角色层级',
    description TEXT COMMENT '角色描述',
    data_scope ENUM('ALL', 'CUSTOM', 'DEPT', 'DEPT_AND_CHILD', 'SELF') DEFAULT 'SELF' COMMENT '数据权限范围',
    inherit_permissions BOOLEAN DEFAULT TRUE COMMENT '是否继承父角色权限',
    inherit_data_scope BOOLEAN DEFAULT FALSE COMMENT '是否继承父角色数据权限',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    sort_order INT DEFAULT 0 COMMENT '排序',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant (tenant_id),
    INDEX idx_parent_role (parent_role_id),
    INDEX idx_role_code (role_code),
    INDEX idx_role_name (role_name),
    INDEX idx_role_level (role_level),
    INDEX idx_status (status),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    FOREIGN KEY (parent_role_id) REFERENCES sys_role(role_id)
) COMMENT '系统角色表';

-- ==============================================
-- 5. 系统权限表（专注权限控制）
-- ==============================================

CREATE TABLE sys_permission (
    permission_id VARCHAR(32) PRIMARY KEY COMMENT '权限ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    permission_code VARCHAR(128) NOT NULL COMMENT '权限代码',
    permission_name VARCHAR(128) NOT NULL COMMENT '权限名称',
    permission_type ENUM('MENU_ACCESS', 'BUTTON_ACTION', 'API_CALL', 'DATA_ACCESS') DEFAULT 'MENU_ACCESS' COMMENT '权限类型',
    resource_type VARCHAR(64) COMMENT '资源类型',
    resource_id VARCHAR(128) COMMENT '资源标识',
    action VARCHAR(64) COMMENT '操作类型',
    scope ENUM('GLOBAL', 'TENANT', 'DEPT', 'SELF') DEFAULT 'TENANT' COMMENT '权限范围',
    parent_id VARCHAR(32) COMMENT '父权限ID',
    description TEXT COMMENT '权限描述',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant (tenant_id),
    INDEX idx_permission_code (permission_code),
    INDEX idx_permission_type (permission_type),
    INDEX idx_resource (resource_type, resource_id),
    INDEX idx_parent_id (parent_id),
    INDEX idx_status (status),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    FOREIGN KEY (parent_id) REFERENCES sys_permission(permission_id)
) COMMENT '系统权限表';
