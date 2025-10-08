-- ==============================================
-- BTC核心数据库 - 职位表
-- ==============================================

USE btc_core;

CREATE TABLE sys_position (
    position_id VARCHAR(32) PRIMARY KEY COMMENT '职位ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    position_code VARCHAR(64) NOT NULL COMMENT '职位代码',
    position_name VARCHAR(128) NOT NULL COMMENT '职位名称',
    dept_id VARCHAR(32) COMMENT '所属部门',
    position_level INT COMMENT '职级',
    description TEXT COMMENT '职位描述',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL COMMENT '创建人',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by VARCHAR(64) COMMENT '更新人',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_tenant (tenant_id),
    INDEX idx_dept (dept_id),
    INDEX idx_position_code (position_code),
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(tenant_id),
    FOREIGN KEY (dept_id) REFERENCES sys_dept(dept_id),
    UNIQUE KEY uk_position_code (position_code, tenant_id)
) COMMENT '职位表';

-- ==============================================
-- 9. 职位角色映射表（职位与角色的多对多关系）
-- ==============================================

CREATE TABLE sys_position_role (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    position_id VARCHAR(32) NOT NULL COMMENT '职位ID',
    role_id VARCHAR(32) NOT NULL COMMENT '角色ID',
    is_default BOOLEAN DEFAULT TRUE COMMENT '是否默认角色',
    created_by VARCHAR(64) NOT NULL COMMENT '创建人',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    UNIQUE KEY uk_position_role (position_id, role_id),
    INDEX idx_position (position_id),
    INDEX idx_role (role_id),
    FOREIGN KEY (position_id) REFERENCES sys_position(position_id),
    FOREIGN KEY (role_id) REFERENCES sys_role(role_id)
) COMMENT '职位角色映射表';
