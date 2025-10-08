-- ==============================================
-- BTC核心数据库 - 系统基础表（支持角色继承）
-- 权限和菜单分离，角色支持继承
-- 作者: MES开发团队
-- 日期: 2025-01-07
-- ==============================================

USE btc_core;

-- ==============================================
-- 1. 租户管理表
-- ==============================================

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

-- ==============================================
-- 3. 系统用户表
-- ==============================================

CREATE TABLE sys_user (
    user_id VARCHAR(32) PRIMARY KEY COMMENT '用户ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    dept_id VARCHAR(32) COMMENT '部门ID',
    username VARCHAR(64) NOT NULL UNIQUE COMMENT '用户名',
    password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希',
    email VARCHAR(128) COMMENT '邮箱',
    phone VARCHAR(32) COMMENT '手机号',
    real_name VARCHAR(64) COMMENT '真实姓名',
    nickname VARCHAR(64) COMMENT '昵称',
    avatar_url VARCHAR(255) COMMENT '头像URL',
    gender ENUM('MALE', 'FEMALE', 'UNKNOWN') DEFAULT 'UNKNOWN' COMMENT '性别',
    birthday DATE COMMENT '生日',
    status ENUM('ACTIVE', 'INACTIVE', 'LOCKED', 'EXPIRED') DEFAULT 'ACTIVE' COMMENT '状态',
    user_type ENUM('SYSTEM', 'TENANT', 'EMPLOYEE', 'EXTERNAL') DEFAULT 'TENANT' COMMENT '用户类型',
    last_login_time DATETIME COMMENT '最后登录时间',
    last_login_ip VARCHAR(45) COMMENT '最后登录IP',
    login_count INT DEFAULT 0 COMMENT '登录次数',
    password_update_time DATETIME COMMENT '密码更新时间',
    account_expire_time DATETIME COMMENT '账户过期时间',
    password_expire_time DATETIME COMMENT '密码过期时间',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant (tenant_id),
    INDEX idx_dept (dept_id),
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_phone (phone),
    INDEX idx_status (status),
    INDEX idx_user_type (user_type),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    FOREIGN KEY (dept_id) REFERENCES sys_dept(dept_id)
) COMMENT '系统用户表';

-- ==============================================
-- 4. 系统角色表（支持继承）
-- ==============================================

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

-- ==============================================
-- 6. 系统菜单表（专注界面导航）
-- ==============================================

CREATE TABLE sys_menu (
    menu_id VARCHAR(32) PRIMARY KEY COMMENT '菜单ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    menu_code VARCHAR(64) NOT NULL COMMENT '菜单代码',
    menu_name VARCHAR(128) NOT NULL COMMENT '菜单名称',
    menu_type ENUM('DIRECTORY', 'MENU', 'BUTTON') DEFAULT 'MENU' COMMENT '菜单类型',
    parent_id VARCHAR(32) COMMENT '父菜单ID',
    path VARCHAR(255) COMMENT '路由路径',
    component VARCHAR(255) COMMENT '组件路径',
    icon VARCHAR(64) COMMENT '图标',
    sort_order INT DEFAULT 0 COMMENT '排序',
    visible BOOLEAN DEFAULT TRUE COMMENT '是否可见',
    keep_alive BOOLEAN DEFAULT FALSE COMMENT '是否缓存',
    external_link BOOLEAN DEFAULT FALSE COMMENT '是否外链',
    external_url VARCHAR(500) COMMENT '外链地址',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant (tenant_id),
    INDEX idx_menu_code (menu_code),
    INDEX idx_parent_id (parent_id),
    INDEX idx_visible (visible),
    INDEX idx_status (status),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    FOREIGN KEY (parent_id) REFERENCES sys_menu(menu_id)
) COMMENT '系统菜单表';

-- ==============================================
-- 7. 菜单权限关联表（关联菜单和权限）
-- ==============================================

CREATE TABLE sys_menu_permission (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    menu_id VARCHAR(32) NOT NULL COMMENT '菜单ID',
    permission_id VARCHAR(32) NOT NULL COMMENT '权限ID',
    relation_type ENUM('REQUIRED', 'OPTIONAL') DEFAULT 'REQUIRED' COMMENT '关联类型',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_menu (menu_id),
    INDEX idx_permission (permission_id),
    UNIQUE KEY uk_menu_permission (menu_id, permission_id),
    FOREIGN KEY (menu_id) REFERENCES sys_menu(menu_id),
    FOREIGN KEY (permission_id) REFERENCES sys_permission(permission_id)
) COMMENT '菜单权限关联表';

-- ==============================================
-- 8. 用户角色关联表
-- ==============================================

CREATE TABLE sys_user_role (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(32) NOT NULL COMMENT '用户ID',
    role_id VARCHAR(32) NOT NULL COMMENT '角色ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user (user_id),
    INDEX idx_role (role_id),
    UNIQUE KEY uk_user_role (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES sys_user(user_id),
    FOREIGN KEY (role_id) REFERENCES sys_role(role_id)
) COMMENT '用户角色关联表';

-- ==============================================
-- 9. 角色权限关联表
-- ==============================================

CREATE TABLE sys_role_permission (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    role_id VARCHAR(32) NOT NULL COMMENT '角色ID',
    permission_id VARCHAR(32) NOT NULL COMMENT '权限ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_role (role_id),
    INDEX idx_permission (permission_id),
    UNIQUE KEY uk_role_permission (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES sys_role(role_id),
    FOREIGN KEY (permission_id) REFERENCES sys_permission(permission_id)
) COMMENT '角色权限关联表';

-- ==============================================
-- 10. 角色继承管理存储过程
-- ==============================================

-- 检查角色继承循环
DELIMITER $$

CREATE PROCEDURE CheckRoleInheritanceCycle(IN p_role_id VARCHAR(32))
BEGIN
    DECLARE cycle_found BOOLEAN DEFAULT FALSE;
    
    WITH RECURSIVE role_hierarchy AS (
        SELECT role_id, parent_role_id, 1 as level
        FROM sys_role WHERE role_id = p_role_id
        
        UNION ALL
        
        SELECT r.role_id, r.parent_role_id, rh.level + 1
        FROM sys_role r
        JOIN role_hierarchy rh ON r.role_id = rh.parent_role_id
        WHERE rh.level < 10  -- 防止无限递归
    )
    SELECT COUNT(*) > 0 INTO cycle_found
    FROM role_hierarchy
    WHERE level > 1 AND role_id = p_role_id;
    
    IF cycle_found THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Role inheritance cycle detected';
    END IF;
END$$

-- 获取角色继承路径
CREATE PROCEDURE GetRoleInheritancePath(IN p_role_id VARCHAR(32))
BEGIN
    WITH RECURSIVE inheritance_path AS (
        SELECT 
            role_id,
            role_code,
            role_name,
            parent_role_id,
            1 as level,
            CAST(role_code AS CHAR(1000)) as path
        FROM sys_role 
        WHERE role_id = p_role_id
        
        UNION ALL
        
        SELECT 
            r.role_id,
            r.role_code,
            r.role_name,
            r.parent_role_id,
            ip.level + 1,
            CONCAT(r.role_code, ' -> ', ip.path)
        FROM sys_role r
        JOIN inheritance_path ip ON r.role_id = ip.parent_role_id
        WHERE ip.level < 10
    )
    SELECT * FROM inheritance_path ORDER BY level DESC;
END$$

-- 批量更新角色层级
CREATE PROCEDURE UpdateRoleLevels()
BEGIN
    WITH RECURSIVE role_levels AS (
        -- 根角色（没有父角色）
        SELECT 
            role_id,
            parent_role_id,
            0 as calculated_level
        FROM sys_role 
        WHERE parent_role_id IS NULL
        
        UNION ALL
        
        -- 子角色
        SELECT 
            r.role_id,
            r.parent_role_id,
            rl.calculated_level + 1
        FROM sys_role r
        JOIN role_levels rl ON r.parent_role_id = rl.role_id
    )
    UPDATE sys_role sr
    JOIN role_levels rl ON sr.role_id = rl.role_id
    SET sr.role_level = rl.calculated_level;
END$$

DELIMITER ;

-- ==============================================
-- 11. 初始化数据
-- ==============================================

-- 插入默认租户
INSERT INTO tenant (tenant_id, tenant_code, tenant_name, tenant_type, status, created_by) 
VALUES ('TENANT_001', 'DEFAULT', '默认租户', 'ENTERPRISE', 'ACTIVE', 'SYSTEM');

-- 插入默认部门
INSERT INTO sys_dept (dept_id, tenant_id, dept_code, dept_name, dept_type, created_by)
VALUES ('DEPT_001', 'TENANT_001', 'DEFAULT', '默认部门', 'DEPARTMENT', 'SYSTEM');

-- 插入系统管理员用户
INSERT INTO sys_user (user_id, tenant_id, dept_id, username, password_hash, real_name, user_type, status, created_by)
VALUES ('USER_001', 'TENANT_001', 'DEPT_001', 'admin', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '系统管理员', 'SYSTEM', 'ACTIVE', 'SYSTEM');

-- 插入层级角色数据
INSERT INTO sys_role (role_id, tenant_id, parent_role_id, role_code, role_name, role_type, role_level, data_scope, inherit_permissions, inherit_data_scope, created_by) VALUES
-- 系统级角色
('ROLE_SYS_ADMIN', 'TENANT_001', NULL, 'SYSTEM_ADMIN', '系统管理员', 'SYSTEM', 1, 'ALL', FALSE, FALSE, 'SYSTEM'),

-- 租户级角色
('ROLE_TENANT_ADMIN', 'TENANT_001', 'ROLE_SYS_ADMIN', 'TENANT_ADMIN', '租户管理员', 'TENANT', 2, 'ALL', TRUE, FALSE, 'SYSTEM'),
('ROLE_DEPT_MANAGER', 'TENANT_001', 'ROLE_TENANT_ADMIN', 'DEPT_MANAGER', '部门经理', 'TENANT', 3, 'DEPT_AND_CHILD', TRUE, TRUE, 'SYSTEM'),
('ROLE_TEAM_LEADER', 'TENANT_001', 'ROLE_DEPT_MANAGER', 'TEAM_LEADER', '团队负责人', 'TENANT', 4, 'DEPT', TRUE, TRUE, 'SYSTEM'),
('ROLE_EMPLOYEE', 'TENANT_001', 'ROLE_TEAM_LEADER', 'EMPLOYEE', '普通员工', 'TENANT', 5, 'SELF', TRUE, TRUE, 'SYSTEM'),

-- 功能角色
('ROLE_HR_ADMIN', 'TENANT_001', 'ROLE_TENANT_ADMIN', 'HR_ADMIN', 'HR管理员', 'CUSTOM', 2, 'DEPT_AND_CHILD', TRUE, FALSE, 'SYSTEM'),
('ROLE_HR_SPECIALIST', 'TENANT_001', 'ROLE_HR_ADMIN', 'HR_SPECIALIST', 'HR专员', 'CUSTOM', 3, 'DEPT', TRUE, TRUE, 'SYSTEM');

-- 插入权限数据
INSERT INTO sys_permission (permission_id, tenant_id, permission_code, permission_name, permission_type, resource_type, resource_id, action, created_by) VALUES
('PERM_001', 'TENANT_001', 'system:user:read', '用户查看权限', 'MENU_ACCESS', 'MENU', 'USER_MANAGE', 'READ', 'SYSTEM'),
('PERM_002', 'TENANT_001', 'system:user:add', '用户新增权限', 'BUTTON_ACTION', 'BUTTON', 'USER_ADD', 'CREATE', 'SYSTEM'),
('PERM_003', 'TENANT_001', 'system:user:edit', '用户编辑权限', 'BUTTON_ACTION', 'BUTTON', 'USER_EDIT', 'UPDATE', 'SYSTEM'),
('PERM_004', 'TENANT_001', 'system:user:delete', '用户删除权限', 'BUTTON_ACTION', 'BUTTON', 'USER_DELETE', 'DELETE', 'SYSTEM'),
('PERM_005', 'TENANT_001', 'api:user:create', '用户创建API权限', 'API_CALL', 'API', '/api/users', 'POST', 'SYSTEM'),
('PERM_006', 'TENANT_001', 'api:user:update', '用户更新API权限', 'API_CALL', 'API', '/api/users', 'PUT', 'SYSTEM'),
('PERM_007', 'TENANT_001', 'data:user:access', '用户数据访问权限', 'DATA_ACCESS', 'TABLE', 'sys_user', 'SELECT', 'SYSTEM'),
('PERM_008', 'TENANT_001', 'system:manage', '系统管理权限', 'MENU_ACCESS', 'MENU', 'SYSTEM_MANAGE', 'ACCESS', 'SYSTEM'),
('PERM_009', 'TENANT_001', 'tenant:manage', '租户管理权限', 'MENU_ACCESS', 'MENU', 'TENANT_MANAGE', 'ACCESS', 'SYSTEM'),
('PERM_010', 'TENANT_001', 'dept:manage', '部门管理权限', 'MENU_ACCESS', 'MENU', 'DEPT_MANAGE', 'ACCESS', 'SYSTEM');

-- 插入菜单数据
INSERT INTO sys_menu (menu_id, tenant_id, menu_code, menu_name, menu_type, path, component, icon, sort_order, created_by) VALUES
('MENU_001', 'TENANT_001', 'system', '系统管理', 'DIRECTORY', '/system', 'Layout', 'system', 1, 'SYSTEM'),
('MENU_002', 'TENANT_001', 'system:user', '用户管理', 'MENU', '/system/user', 'system/user/index', 'user', 1, 'SYSTEM'),
('MENU_003', 'TENANT_001', 'system:user:add', '新增用户', 'BUTTON', NULL, NULL, 'plus', 1, 'SYSTEM'),
('MENU_004', 'TENANT_001', 'system:user:edit', '编辑用户', 'BUTTON', NULL, NULL, 'edit', 2, 'SYSTEM'),
('MENU_005', 'TENANT_001', 'system:user:delete', '删除用户', 'BUTTON', NULL, NULL, 'delete', 3, 'SYSTEM'),
('MENU_006', 'TENANT_001', 'system:role', '角色管理', 'MENU', '/system/role', 'system/role/index', 'role', 2, 'SYSTEM'),
('MENU_007', 'TENANT_001', 'system:dept', '部门管理', 'MENU', '/system/dept', 'system/dept/index', 'dept', 3, 'SYSTEM'),
('MENU_008', 'TENANT_001', 'tenant', '租户管理', 'MENU', '/tenant', 'tenant/index', 'tenant', 2, 'SYSTEM');

-- 设置菜单层级关系
UPDATE sys_menu SET parent_id = 'MENU_001' WHERE menu_id IN ('MENU_002', 'MENU_006', 'MENU_007');
UPDATE sys_menu SET parent_id = 'MENU_002' WHERE menu_id IN ('MENU_003', 'MENU_004', 'MENU_005');

-- 插入菜单权限关联
INSERT INTO sys_menu_permission (menu_id, permission_id, relation_type, created_by) VALUES
('MENU_001', 'PERM_008', 'REQUIRED', 'SYSTEM'),  -- 系统管理菜单需要系统管理权限
('MENU_002', 'PERM_001', 'REQUIRED', 'SYSTEM'),  -- 用户管理菜单需要用户查看权限
('MENU_003', 'PERM_002', 'REQUIRED', 'SYSTEM'),  -- 新增用户按钮需要用户新增权限
('MENU_004', 'PERM_003', 'REQUIRED', 'SYSTEM'),  -- 编辑用户按钮需要用户编辑权限
('MENU_005', 'PERM_004', 'REQUIRED', 'SYSTEM'),  -- 删除用户按钮需要用户删除权限
('MENU_007', 'PERM_010', 'REQUIRED', 'SYSTEM'),  -- 部门管理菜单需要部门管理权限
('MENU_008', 'PERM_009', 'REQUIRED', 'SYSTEM');  -- 租户管理菜单需要租户管理权限

-- 关联用户角色
INSERT INTO sys_user_role (user_id, role_id, created_by)
VALUES ('USER_001', 'ROLE_SYS_ADMIN', 'SYSTEM');

-- 为系统管理员分配所有权限
INSERT INTO sys_role_permission (role_id, permission_id, created_by)
VALUES 
('ROLE_SYS_ADMIN', 'PERM_001', 'SYSTEM'),
('ROLE_SYS_ADMIN', 'PERM_002', 'SYSTEM'),
('ROLE_SYS_ADMIN', 'PERM_003', 'SYSTEM'),
('ROLE_SYS_ADMIN', 'PERM_004', 'SYSTEM'),
('ROLE_SYS_ADMIN', 'PERM_005', 'SYSTEM'),
('ROLE_SYS_ADMIN', 'PERM_006', 'SYSTEM'),
('ROLE_SYS_ADMIN', 'PERM_007', 'SYSTEM'),
('ROLE_SYS_ADMIN', 'PERM_008', 'SYSTEM'),
('ROLE_SYS_ADMIN', 'PERM_009', 'SYSTEM'),
('ROLE_SYS_ADMIN', 'PERM_010', 'SYSTEM');

-- 为租户管理员分配租户级权限
INSERT INTO sys_role_permission (role_id, permission_id, created_by)
VALUES 
('ROLE_TENANT_ADMIN', 'PERM_009', 'SYSTEM'),  -- 租户管理权限
('ROLE_TENANT_ADMIN', 'PERM_010', 'SYSTEM');  -- 部门管理权限

-- 为部门经理分配部门级权限
INSERT INTO sys_role_permission (role_id, permission_id, created_by)
VALUES 
('ROLE_DEPT_MANAGER', 'PERM_001', 'SYSTEM');  -- 用户查看权限

-- 设置部门负责人
UPDATE sys_dept SET manager_id = 'USER_001' WHERE dept_id = 'DEPT_001';

-- 更新角色层级
CALL UpdateRoleLevels();