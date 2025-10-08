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
    position_id VARCHAR(32) COMMENT '职位ID',
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
    FOREIGN KEY (dept_id) REFERENCES sys_dept(dept_id),
    FOREIGN KEY (position_id) REFERENCES sys_position(position_id)
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
    parent_id VARCHAR(32) COMMENT '父菜单ID',
    
    -- 基础属性
    menu_code VARCHAR(64) NOT NULL COMMENT '菜单代码',
    menu_name VARCHAR(128) NOT NULL COMMENT '菜单名称',
    menu_type ENUM('DIRECTORY', 'MENU', 'BUTTON', 'PLUGIN') DEFAULT 'MENU' COMMENT '菜单类型',
    icon VARCHAR(64) COMMENT '菜单图标',
    sort_order INT DEFAULT 0 COMMENT '排序号',
    
    -- 模块化属性
    module_code VARCHAR(32) NOT NULL COMMENT '模块代码',
    plugin_code VARCHAR(32) COMMENT '插件代码',
    deploy_url VARCHAR(255) COMMENT '部署地址',
    route_path VARCHAR(255) COMMENT '路由路径',
    component_path VARCHAR(255) COMMENT '组件路径',
    
    -- 权限属性
    permission_code VARCHAR(64) COMMENT '权限标识',
    access_level ENUM('PUBLIC', 'AUTHENTICATED', 'AUTHORIZED') DEFAULT 'AUTHORIZED' COMMENT '访问级别',
    data_scope ENUM('ALL', 'TENANT', 'DEPT', 'SELF') DEFAULT 'TENANT' COMMENT '数据权限',
    operation_type ENUM('READ', 'WRITE', 'ADMIN') DEFAULT 'READ' COMMENT '操作权限',
    
    -- 租户属性
    tenant_visible BOOLEAN DEFAULT TRUE COMMENT '租户可见性',
    tenant_config JSON COMMENT '租户配置',
    
    -- 状态属性
    visible BOOLEAN DEFAULT TRUE COMMENT '是否可见',
    keep_alive BOOLEAN DEFAULT FALSE COMMENT '是否缓存',
    external_link BOOLEAN DEFAULT FALSE COMMENT '是否外链',
    external_url VARCHAR(500) COMMENT '外链地址',
    status ENUM('ACTIVE', 'INACTIVE', 'MAINTENANCE') DEFAULT 'ACTIVE' COMMENT '状态',
    is_deleted BOOLEAN DEFAULT FALSE COMMENT '是否删除',
    
    -- 审计字段
    created_by VARCHAR(64) NOT NULL COMMENT '创建人',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by VARCHAR(64) COMMENT '更新人',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    INDEX idx_tenant (tenant_id),
    INDEX idx_parent (parent_id),
    INDEX idx_module (module_code),
    INDEX idx_plugin (plugin_code),
    INDEX idx_menu_code (menu_code),
    INDEX idx_visible (visible),
    INDEX idx_status (status),
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(tenant_id),
    FOREIGN KEY (parent_id) REFERENCES sys_menu(menu_id),
    UNIQUE KEY uk_menu_code (menu_code, tenant_id)
) COMMENT '系统菜单表(基于cool-admin多模块架构)';

-- ==============================================
-- 7. 模块表 (支持多模块架构)
-- ==============================================

CREATE TABLE sys_module (
    module_id VARCHAR(32) PRIMARY KEY COMMENT '模块ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    
    -- 基础属性
    module_code VARCHAR(32) NOT NULL UNIQUE COMMENT '模块代码',
    module_name VARCHAR(64) NOT NULL COMMENT '模块名称',
    module_type ENUM('SYSTEM', 'BUSINESS', 'PLUGIN') NOT NULL COMMENT '模块类型',
    description TEXT COMMENT '模块描述',
    
    -- 部署属性
    deploy_url VARCHAR(255) COMMENT '部署地址',
    api_base_url VARCHAR(255) COMMENT 'API基础地址',
    version VARCHAR(16) COMMENT '版本号',
    build_version VARCHAR(32) COMMENT '构建版本',
    
    -- 配置属性
    config JSON COMMENT '模块配置',
    dependencies JSON COMMENT '依赖关系',
    plugins JSON COMMENT '插件列表',
    
    -- 状态属性
    status ENUM('ACTIVE', 'INACTIVE', 'MAINTENANCE', 'DEPRECATED') DEFAULT 'ACTIVE' COMMENT '状态',
    is_deleted BOOLEAN DEFAULT FALSE COMMENT '是否删除',
    
    -- 审计字段
    created_by VARCHAR(64) NOT NULL COMMENT '创建人',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by VARCHAR(64) COMMENT '更新人',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    INDEX idx_tenant (tenant_id),
    INDEX idx_module_code (module_code),
    INDEX idx_module_type (module_type),
    INDEX idx_status (status),
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(tenant_id)
) COMMENT '模块表';

-- ==============================================
-- 8. 插件表 (支持插件化扩展)
-- ==============================================

CREATE TABLE sys_plugin (
    plugin_id VARCHAR(32) PRIMARY KEY COMMENT '插件ID',
    module_id VARCHAR(32) NOT NULL COMMENT '所属模块ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    
    -- 基础属性
    plugin_code VARCHAR(32) NOT NULL COMMENT '插件代码',
    plugin_name VARCHAR(64) NOT NULL COMMENT '插件名称',
    plugin_type ENUM('FUNCTION', 'WIDGET', 'INTEGRATION') NOT NULL COMMENT '插件类型',
    description TEXT COMMENT '插件描述',
    
    -- 部署属性
    plugin_url VARCHAR(255) COMMENT '插件地址',
    api_endpoint VARCHAR(255) COMMENT 'API端点',
    version VARCHAR(16) COMMENT '版本号',
    
    -- 配置属性
    config JSON COMMENT '插件配置',
    permissions JSON COMMENT '权限配置',
    menu_config JSON COMMENT '菜单配置',
    
    -- 状态属性
    status ENUM('ACTIVE', 'INACTIVE', 'LOADING', 'ERROR') DEFAULT 'INACTIVE' COMMENT '状态',
    is_deleted BOOLEAN DEFAULT FALSE COMMENT '是否删除',
    
    -- 审计字段
    created_by VARCHAR(64) NOT NULL COMMENT '创建人',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by VARCHAR(64) COMMENT '更新人',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    INDEX idx_module (module_id),
    INDEX idx_tenant (tenant_id),
    INDEX idx_plugin_code (plugin_code),
    INDEX idx_plugin_type (plugin_type),
    INDEX idx_status (status),
    FOREIGN KEY (module_id) REFERENCES sys_module(module_id),
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(tenant_id)
) COMMENT '插件表';

-- ==============================================
-- 9. 用户模块关联表 (支持模块跳转)
-- ==============================================

CREATE TABLE sys_user_module (
    user_module_id VARCHAR(32) PRIMARY KEY COMMENT '用户模块关联ID',
    user_id VARCHAR(32) NOT NULL COMMENT '用户ID',
    module_id VARCHAR(32) NOT NULL COMMENT '模块ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    
    -- 权限属性
    access_level ENUM('READ', 'WRITE', 'ADMIN') DEFAULT 'READ' COMMENT '访问级别',
    is_default BOOLEAN DEFAULT FALSE COMMENT '是否默认模块',
    auto_redirect BOOLEAN DEFAULT TRUE COMMENT '是否自动跳转',
    
    -- 状态属性
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    
    -- 审计字段
    created_by VARCHAR(64) NOT NULL COMMENT '创建人',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by VARCHAR(64) COMMENT '更新人',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    UNIQUE KEY uk_user_module (user_id, module_id),
    INDEX idx_user (user_id),
    INDEX idx_module (module_id),
    INDEX idx_tenant (tenant_id),
    INDEX idx_status (status),
    FOREIGN KEY (user_id) REFERENCES sys_user(user_id),
    FOREIGN KEY (module_id) REFERENCES sys_module(module_id),
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(tenant_id)
) COMMENT '用户模块关联表';

-- ==============================================
-- 10. 菜单权限关联表（关联菜单和权限）
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
-- 8. 职位表（组织学概念）
-- ==============================================

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

-- ==============================================
-- 10. 用户角色关联表
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
-- 11. 流程管理表
-- ==============================================

-- 流程定义表
CREATE TABLE workflow_definition (
    workflow_id VARCHAR(32) PRIMARY KEY COMMENT '流程ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    workflow_code VARCHAR(64) NOT NULL COMMENT '流程代码',
    workflow_name VARCHAR(128) NOT NULL COMMENT '流程名称',
    workflow_type ENUM('PRODUCTION', 'QUALITY', 'LOGISTICS', 'MAINTENANCE', 'CUSTOM') DEFAULT 'PRODUCTION' COMMENT '流程类型',
    description TEXT COMMENT '流程描述',
    version INT DEFAULT 1 COMMENT '版本号',
    status ENUM('ACTIVE', 'INACTIVE', 'DRAFT') DEFAULT 'DRAFT' COMMENT '状态',
    is_template BOOLEAN DEFAULT FALSE COMMENT '是否模板',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant (tenant_id),
    INDEX idx_workflow_code (workflow_code),
    INDEX idx_workflow_type (workflow_type),
    INDEX idx_status (status),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id)
) COMMENT '流程定义表';

-- 流程节点表
CREATE TABLE workflow_node (
    node_id VARCHAR(32) PRIMARY KEY COMMENT '节点ID',
    workflow_id VARCHAR(32) NOT NULL COMMENT '流程ID',
    node_code VARCHAR(64) NOT NULL COMMENT '节点代码',
    node_name VARCHAR(128) NOT NULL COMMENT '节点名称',
    node_type ENUM('START', 'END', 'TASK', 'GATEWAY', 'SUB_PROCESS') DEFAULT 'TASK' COMMENT '节点类型',
    sequence_order INT NOT NULL COMMENT '执行顺序',
    parent_node_id VARCHAR(32) COMMENT '父节点ID',
    is_parallel BOOLEAN DEFAULT FALSE COMMENT '是否并行执行',
    timeout_minutes INT COMMENT '超时时间(分钟)',
    retry_count INT DEFAULT 0 COMMENT '重试次数',
    node_config JSON COMMENT '节点配置',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_workflow_id (workflow_id),
    INDEX idx_node_code (node_code),
    INDEX idx_sequence_order (sequence_order),
    INDEX idx_parent_node (parent_node_id),
    FOREIGN KEY (workflow_id) REFERENCES workflow_definition(workflow_id),
    FOREIGN KEY (parent_node_id) REFERENCES workflow_node(node_id)
) COMMENT '流程节点表';

-- 流程连接表
CREATE TABLE workflow_connection (
    connection_id VARCHAR(32) PRIMARY KEY COMMENT '连接ID',
    workflow_id VARCHAR(32) NOT NULL COMMENT '流程ID',
    from_node_id VARCHAR(32) NOT NULL COMMENT '源节点ID',
    to_node_id VARCHAR(32) NOT NULL COMMENT '目标节点ID',
    connection_type ENUM('NORMAL', 'CONDITIONAL', 'EXCEPTION') DEFAULT 'NORMAL' COMMENT '连接类型',
    condition_expression TEXT COMMENT '条件表达式',
    connection_label VARCHAR(128) COMMENT '连接标签',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_workflow_id (workflow_id),
    INDEX idx_from_node (from_node_id),
    INDEX idx_to_node (to_node_id),
    FOREIGN KEY (workflow_id) REFERENCES workflow_definition(workflow_id),
    FOREIGN KEY (from_node_id) REFERENCES workflow_node(node_id),
    FOREIGN KEY (to_node_id) REFERENCES workflow_node(node_id)
) COMMENT '流程连接表';

-- 流程实例表
CREATE TABLE workflow_instance (
    instance_id VARCHAR(32) PRIMARY KEY COMMENT '实例ID',
    workflow_id VARCHAR(32) NOT NULL COMMENT '流程ID',
    instance_name VARCHAR(128) COMMENT '实例名称',
    business_key VARCHAR(128) COMMENT '业务键',
    business_type VARCHAR(64) COMMENT '业务类型',
    current_node_id VARCHAR(32) COMMENT '当前节点ID',
    instance_status ENUM('RUNNING', 'COMPLETED', 'SUSPENDED', 'TERMINATED', 'FAILED') DEFAULT 'RUNNING' COMMENT '实例状态',
    start_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '开始时间',
    end_time DATETIME COMMENT '结束时间',
    started_by VARCHAR(64) NOT NULL COMMENT '启动人',
    variables JSON COMMENT '流程变量',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_workflow_id (workflow_id),
    INDEX idx_business_key (business_key),
    INDEX idx_business_type (business_type),
    INDEX idx_current_node (current_node_id),
    INDEX idx_instance_status (instance_status),
    INDEX idx_start_time (start_time),
    INDEX idx_tenant_site (tenant_id, site_id),
    FOREIGN KEY (workflow_id) REFERENCES workflow_definition(workflow_id),
    FOREIGN KEY (current_node_id) REFERENCES workflow_node(node_id)
) COMMENT '流程实例表';

-- 流程任务表
CREATE TABLE workflow_task (
    task_id VARCHAR(32) PRIMARY KEY COMMENT '任务ID',
    instance_id VARCHAR(32) NOT NULL COMMENT '实例ID',
    node_id VARCHAR(32) NOT NULL COMMENT '节点ID',
    task_name VARCHAR(128) NOT NULL COMMENT '任务名称',
    task_type ENUM('MANUAL', 'AUTOMATIC', 'SERVICE') DEFAULT 'MANUAL' COMMENT '任务类型',
    assignee_type ENUM('USER', 'ROLE', 'GROUP') DEFAULT 'USER' COMMENT '分配类型',
    assignee_id VARCHAR(64) COMMENT '分配人ID',
    task_status ENUM('PENDING', 'IN_PROGRESS', 'COMPLETED', 'SKIPPED', 'FAILED') DEFAULT 'PENDING' COMMENT '任务状态',
    priority ENUM('LOW', 'NORMAL', 'HIGH', 'URGENT') DEFAULT 'NORMAL' COMMENT '优先级',
    due_date DATETIME COMMENT '截止时间',
    start_time DATETIME COMMENT '开始时间',
    end_time DATETIME COMMENT '结束时间',
    completion_notes TEXT COMMENT '完成备注',
    form_data JSON COMMENT '表单数据',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_instance_id (instance_id),
    INDEX idx_node_id (node_id),
    INDEX idx_assignee (assignee_type, assignee_id),
    INDEX idx_task_status (task_status),
    INDEX idx_due_date (due_date),
    INDEX idx_tenant_site (tenant_id, site_id),
    FOREIGN KEY (instance_id) REFERENCES workflow_instance(instance_id),
    FOREIGN KEY (node_id) REFERENCES workflow_node(node_id)
) COMMENT '流程任务表';

-- 流程历史表
CREATE TABLE workflow_history (
    history_id VARCHAR(32) PRIMARY KEY COMMENT '历史ID',
    instance_id VARCHAR(32) NOT NULL COMMENT '实例ID',
    node_id VARCHAR(32) NOT NULL COMMENT '节点ID',
    task_id VARCHAR(32) COMMENT '任务ID',
    action_type ENUM('START', 'COMPLETE', 'SKIP', 'FAIL', 'SUSPEND', 'RESUME', 'TERMINATE') NOT NULL COMMENT '动作类型',
    action_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '动作时间',
    operator_id VARCHAR(64) COMMENT '操作人ID',
    operator_name VARCHAR(64) COMMENT '操作人姓名',
    action_notes TEXT COMMENT '动作备注',
    form_data JSON COMMENT '表单数据快照',
    variables JSON COMMENT '变量快照',
    execution_time BIGINT COMMENT '执行时间(毫秒)',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_instance_id (instance_id),
    INDEX idx_node_id (node_id),
    INDEX idx_task_id (task_id),
    INDEX idx_action_type (action_type),
    INDEX idx_action_time (action_time),
    INDEX idx_operator (operator_id),
    INDEX idx_tenant_site (tenant_id, site_id),
    FOREIGN KEY (instance_id) REFERENCES workflow_instance(instance_id),
    FOREIGN KEY (node_id) REFERENCES workflow_node(node_id),
    FOREIGN KEY (task_id) REFERENCES workflow_task(task_id)
) COMMENT '流程历史表';

-- ==============================================
-- 12. 追溯映射表（基于MES架构文档要求）
-- ==============================================

-- SN → 批次/工单/箱号/托盘映射
CREATE TABLE map_sn (
    sn VARCHAR(64) PRIMARY KEY COMMENT '序列号',
    lot_id VARCHAR(32) NOT NULL COMMENT '批次ID',
    wo_id VARCHAR(32) NOT NULL COMMENT '工单ID',
    box_no VARCHAR(64) COMMENT '箱号',
    pallet_no VARCHAR(64) COMMENT '托盘号',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(64) NOT NULL,
    INDEX idx_map_sn_lot (lot_id),
    INDEX idx_map_sn_box (box_no),
    INDEX idx_map_sn_pallet (pallet_no),
    INDEX idx_map_sn_wo (wo_id),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id)
) COMMENT 'SN映射表';

-- 箱号 → SN映射
CREATE TABLE map_box_sn (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    box_no VARCHAR(64) NOT NULL COMMENT '箱号',
    sn VARCHAR(64) NOT NULL COMMENT '序列号',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_box_sn_box (box_no),
    INDEX idx_box_sn_sn (sn),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id)
) COMMENT '箱号SN映射表';

-- 托盘 → 箱号映射
CREATE TABLE map_pallet_box (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    pallet_no VARCHAR(64) NOT NULL COMMENT '托盘号',
    box_no VARCHAR(64) NOT NULL COMMENT '箱号',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_pallet_box_pallet (pallet_no),
    INDEX idx_pallet_box_box (box_no),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id)
) COMMENT '托盘箱号映射表';

-- 批次 → 用料来源映射
CREATE TABLE map_lot_material (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    lot_id VARCHAR(32) NOT NULL COMMENT '批次ID',
    item_id VARCHAR(32) NOT NULL COMMENT '物料ID',
    supplier_id VARCHAR(32) COMMENT '供应商ID',
    grn_id VARCHAR(32) COMMENT '收货单ID',
    mold_id VARCHAR(32) COMMENT '模具ID',
    qty_used DECIMAL(18,4) COMMENT '用量',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_lot_material_lot (lot_id),
    INDEX idx_lot_material_item (item_id),
    INDEX idx_lot_material_supplier (supplier_id),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id)
) COMMENT '批次用料映射表';

-- ==============================================
-- 13. 事件溯源表（基于MES架构文档要求）
-- ==============================================

-- 所有可追节点抽象为不可变事件
CREATE TABLE trace_event (
    event_id VARCHAR(40) PRIMARY KEY COMMENT '事件ID',
    entity_type VARCHAR(32) NOT NULL COMMENT '实体类型(SN/LOT/WO/GRN/BOX/PLT/INSP)',
    entity_id VARCHAR(64) NOT NULL COMMENT '实体ID',
    action VARCHAR(32) NOT NULL COMMENT '动作(START/END/PASS/FAIL/REWORK/MOVE/PACK/SHIP)',
    occurred_at DATETIME NOT NULL COMMENT '发生时间',
    op_id VARCHAR(32) COMMENT '对应工序ID',
    op_name VARCHAR(64) COMMENT '工序名称',
    op_start_at DATETIME COMMENT '工序开始时间',
    op_end_at DATETIME COMMENT '工序结束时间',
    operator_id VARCHAR(64) COMMENT '操作人ID',
    result VARCHAR(16) COMMENT '结果(PASS/FAIL/REWORK/HOLD)',
    station_id VARCHAR(64) COMMENT '工位ID',
    shift_code VARCHAR(16) COMMENT '班次代码',
    ref_id VARCHAR(64) COMMENT '业务单据ID',
    data JSON COMMENT '测量值/参数/附件key等',
    prev_event_id VARCHAR(40) COMMENT '链式追溯-前一个事件ID',
    correlation_id VARCHAR(64) COMMENT '同事务/同工序相关性ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    source_system VARCHAR(32) COMMENT '来源系统',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_event_entity (entity_type, entity_id, occurred_at),
    INDEX idx_event_action (action, occurred_at),
    INDEX idx_event_operator (operator_id, occurred_at),
    INDEX idx_event_station (station_id, occurred_at),
    INDEX idx_event_correlation (correlation_id),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id)
) COMMENT '追溯事件表';

-- 链路快照（三层：原材料/组件/成品）
CREATE TABLE trace_link (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    level ENUM('RAW', 'COMPONENT', 'FINISHED') NOT NULL COMMENT '层级',
    sn VARCHAR(64) COMMENT '序列号',
    lot_id VARCHAR(32) COMMENT '批次ID',
    wo_id VARCHAR(32) COMMENT '工单ID',
    op_id VARCHAR(32) COMMENT '工序ID',
    op_name VARCHAR(64) COMMENT '工序名称',
    op_start_at DATETIME COMMENT '工序开始时间',
    op_end_at DATETIME COMMENT '工序结束时间',
    operator_id VARCHAR(64) COMMENT '操作人ID',
    result ENUM('PASS', 'FAIL', 'REWORK', 'HOLD') COMMENT '结果',
    station_id VARCHAR(64) COMMENT '工位ID',
    next_sn VARCHAR(64) COMMENT '指向上层的SN',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_trace_link_sn (sn),
    INDEX idx_trace_link_lot (lot_id),
    INDEX idx_trace_link_wo (wo_id),
    INDEX idx_trace_link_next (next_sn),
    INDEX idx_trace_link_level (level),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id)
) COMMENT '追溯链路快照表';

-- ==============================================
-- 14. 测试和测量记录表（基于MES架构文档要求）
-- ==============================================

-- 测试记录表
CREATE TABLE test_record (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID',
    sn VARCHAR(64) NOT NULL COMMENT '序列号',
    lot_id VARCHAR(32) COMMENT '批次ID',
    wo_id VARCHAR(32) COMMENT '工单ID',
    station VARCHAR(64) NOT NULL COMMENT '测试工位',
    test_type VARCHAR(32) COMMENT '测试类型',
    result VARCHAR(8) NOT NULL COMMENT '结果(PASS/FAIL)',
    code VARCHAR(32) COMMENT '失败代码',
    test_data JSON COMMENT '测试数据',
    tested_at DATETIME NOT NULL COMMENT '测试时间',
    operator_id VARCHAR(64) COMMENT '测试员ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_sn (sn),
    INDEX idx_lot_id (lot_id),
    INDEX idx_wo_id (wo_id),
    INDEX idx_station (station),
    INDEX idx_tested_at (tested_at),
    INDEX idx_result (result),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id)
) COMMENT '测试记录表';

-- 测量记录表
CREATE TABLE measure_record (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID',
    insp_id VARCHAR(32) COMMENT '检验单ID',
    test_record_id BIGINT COMMENT '测试记录ID',
    item_key VARCHAR(64) NOT NULL COMMENT '测量项目',
    value_num DECIMAL(18,6) COMMENT '数值',
    unit VARCHAR(16) COMMENT '单位',
    standard_value DECIMAL(18,6) COMMENT '标准值',
    upper_limit DECIMAL(18,6) COMMENT '上限',
    lower_limit DECIMAL(18,6) COMMENT '下限',
    measured_at DATETIME NOT NULL COMMENT '测量时间',
    operator_id VARCHAR(64) COMMENT '测量员ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_insp_id (insp_id),
    INDEX idx_test_record_id (test_record_id),
    INDEX idx_item_key (item_key),
    INDEX idx_measured_at (measured_at),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id)
) COMMENT '测量记录表';

-- ==============================================
-- 15. 初始化数据
-- ==============================================

-- 插入三个租户数据
INSERT INTO tenant (
    tenant_id, 
    tenant_code, 
    tenant_name, 
    tenant_type, 
    status, 
    contact_person,
    contact_email,
    industry,
    scale,
    subscription_plan,
    description,
    created_by
) VALUES 
-- 英国总公司 - 只读用户，主要供英国领导和IT查看
('TENANT_UK_HEAD', 'UK_HEAD', '英国总公司', 'ENTERPRISE', 'ACTIVE', 'IT Administrator', 'it@ukhead.com', 'Manufacturing', 'Large', 'ENTERPRISE', '英国总公司，大部分用户为只读用户，主要供英国领导和IT部门进行数据查看和分析', 'SYSTEM'),

-- 内网用户 - MES系统主要用户群体，100-300人规模
('TENANT_INERT', 'INERT', '内网用户', 'ENTERPRISE', 'ACTIVE', 'MES Administrator', 'admin@inert.com', 'Manufacturing', 'Medium', 'STANDARD', '内网用户群体，MES系统的主要用户，当前规模约100人，未来可扩展至300人', 'SYSTEM'),

-- 供应商群体 - 包括模具供应商、原材料供应商等
('TENANT_SUPPLIER', 'SUPPLIER', '供应商群体', 'SMALL_MEDIUM', 'ACTIVE', 'Supplier Manager', 'supplier@company.com', 'Supply Chain', 'Medium', 'BASIC', '供应商群体，包括模具供应商、原材料供应商等外部合作伙伴', 'SYSTEM');

-- 为每个租户插入默认部门
INSERT INTO sys_dept (dept_id, tenant_id, dept_code, dept_name, dept_type, sort_order, created_by)
VALUES 
-- 英国总公司部门
('DEPT_UK_HEAD', 'TENANT_UK_HEAD', 'UK_IT', 'IT部门', 'DEPARTMENT', 1, 'SYSTEM'),
('DEPT_UK_LEADERSHIP', 'TENANT_UK_HEAD', 'UK_LEADERSHIP', '领导层', 'DEPARTMENT', 2, 'SYSTEM'),

-- 内网用户部门（基于真实组织架构）
('DEPT_INERT_MANAGEMENT', 'TENANT_INERT', 'MANAGEMENT', '管理层', 'COMPANY', 1, 'SYSTEM'),
('DEPT_INERT_FINANCE', 'TENANT_INERT', 'FINANCE', '财务部门', 'DEPARTMENT', 2, 'SYSTEM'),
('DEPT_INERT_HR', 'TENANT_INERT', 'HR', '人事部门', 'DEPARTMENT', 3, 'SYSTEM'),
('DEPT_INERT_LOGISTICS', 'TENANT_INERT', 'LOGISTICS', '物流部门', 'DEPARTMENT', 4, 'SYSTEM'),
('DEPT_INERT_PROCUREMENT', 'TENANT_INERT', 'PROCUREMENT', '采购部门', 'DEPARTMENT', 5, 'SYSTEM'),
('DEPT_INERT_PRODUCTION', 'TENANT_INERT', 'PRODUCTION', '生产部门', 'DEPARTMENT', 6, 'SYSTEM'),
('DEPT_INERT_ENGINEERING', 'TENANT_INERT', 'ENGINEERING', '工程部门', 'DEPARTMENT', 7, 'SYSTEM'),
('DEPT_INERT_QUALITY', 'TENANT_INERT', 'QUALITY', '品质部门', 'DEPARTMENT', 8, 'SYSTEM'),
('DEPT_INERT_MAINTENANCE', 'TENANT_INERT', 'MAINTENANCE', '维修部门', 'DEPARTMENT', 9, 'SYSTEM'),
('DEPT_INERT_IT', 'TENANT_INERT', 'IT', 'IT部门', 'DEPARTMENT', 10, 'SYSTEM'),

-- 供应商群体部门
('DEPT_SUPPLIER_MOLD', 'TENANT_SUPPLIER', 'MOLD_SUPPLIER', '模具供应商', 'DEPARTMENT', 1, 'SYSTEM'),
('DEPT_SUPPLIER_RAW', 'TENANT_SUPPLIER', 'RAW_MATERIAL', '原材料供应商', 'DEPARTMENT', 2, 'SYSTEM');

-- 插入基于user_profile的真实用户数据
INSERT INTO sys_user (user_id, tenant_id, dept_id, position_id, username, password_hash, real_name, email, user_type, status, created_by)
VALUES 
-- === 英国总公司用户 ===
('USER_58', 'TENANT_UK_HEAD', 'DEPT_UK_HEAD', 'POS_UK_READONLY', 'uk', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'UK', 'btcinformation@bellis-technology.cn', 'READONLY', 'ACTIVE', 'SYSTEM'),

-- === 内网用户 (TENANT_INERT) - 57人 ===
-- 管理层 (1人)
('USER_1', 'TENANT_INERT', 'DEPT_INERT_MANAGEMENT', 'POS_INERT_CEO', 'iji', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '季小波', 'iji@bellis-technology.cn', 'EXECUTIVE', 'ACTIVE', 'SYSTEM'),

-- 财务部门 (4人)
('USER_11', 'TENANT_INERT', 'DEPT_INERT_FINANCE', 'POS_INERT_FINANCE_MGR', 'lcai', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '蔡亮', 'lcai@bellis-technology.cn', 'MANAGER', 'ACTIVE', 'SYSTEM'),
('USER_12', 'TENANT_INERT', 'DEPT_INERT_FINANCE', 'POS_INERT_FINANCE_SUPER', 'mhong', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '洪梅', 'mhong@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_13', 'TENANT_INERT', 'DEPT_INERT_FINANCE', 'POS_INERT_FINANCE', 'ezhang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '张慧玲', 'ezhang@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_14', 'TENANT_INERT', 'DEPT_INERT_FINANCE', 'POS_INERT_FINANCE', 'dali', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '黎秋怡', 'dali@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),

-- 人事部门 (2人)
('USER_15', 'TENANT_INERT', 'DEPT_INERT_HR', 'POS_INERT_HR_SUPER', 'tding', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '丁婷', 'tding@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_16', 'TENANT_INERT', 'DEPT_INERT_HR', 'POS_INERT_HR', 'mhuang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '黄美艳', 'mhuang@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),

-- 物流部门 (4人)
('USER_2', 'TENANT_INERT', 'DEPT_INERT_LOGISTICS', 'POS_INERT_LOGISTICS_MGR', 'fxiong', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '熊匀', 'fxiong@bellis-technology.cn', 'MANAGER', 'ACTIVE', 'SYSTEM'),
('USER_3', 'TENANT_INERT', 'DEPT_INERT_LOGISTICS', 'POS_INERT_CUSTOMS', 'mliu', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '刘振飞', 'mliu@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_4', 'TENANT_INERT', 'DEPT_INERT_LOGISTICS', 'POS_INERT_CUSTOMS', 'azhang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '张米花', 'azhang@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_10', 'TENANT_INERT', 'DEPT_INERT_LOGISTICS', 'POS_INERT_WAREHOUSE_LEADER', 'hxiao', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '肖荤莲', 'hxiao@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),

-- 采购部门 (5人)
('USER_5', 'TENANT_INERT', 'DEPT_INERT_PROCUREMENT', 'POS_INERT_PROCUREMENT_MGR', 'ayang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '杨志叶', 'ayang@bellis-technology.cn', 'MANAGER', 'ACTIVE', 'SYSTEM'),
('USER_6', 'TENANT_INERT', 'DEPT_INERT_PROCUREMENT', 'POS_INERT_PROCUREMENT_ECN', 'kgao', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '高广玉', 'kgao@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_7', 'TENANT_INERT', 'DEPT_INERT_PROCUREMENT', 'POS_INERT_PROCUREMENT', 'kbao', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '鲍文林', 'kbao@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_8', 'TENANT_INERT', 'DEPT_INERT_PROCUREMENT', 'POS_INERT_PROCUREMENT_AUXMAT', 'aguo', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '郭凤英', 'aguo@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_9', 'TENANT_INERT', 'DEPT_INERT_PROCUREMENT', 'POS_INERT_PROCUREMENT_PKG', 'lwang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '王观丽', 'lwang@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),

-- 生产部门 (11人)
('USER_17', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'POS_INERT_PRODUCTION_MGR', 'azhou', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '周海涛', 'azhou@bellis-technology.cn', 'MANAGER', 'ACTIVE', 'SYSTEM'),
('USER_18', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'POS_INERT_PRODUCTION_SHIP', 'lli', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '黎艳均', 'lli@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_19', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'POS_INERT_PRODUCTION_WORKSHOP', 'jiangli', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '蒋丽', 'jiangli@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_20', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'POS_INERT_PRODUCTION_LEADER', 'pliu', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '刘培', 'pliu@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_21', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'POS_INERT_PRODUCTION_GROUP', 'cwang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '王翠平', 'cwang@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_22', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'POS_INERT_PRODUCTION_GROUP', 'cyuying', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '蔡玉颖', 'cyuying@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_23', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'POS_INERT_PRODUCTION_GROUP', 'czhu', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '朱长坤', 'czhu@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_24', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'POS_INERT_PRODUCTION_ENG', 'jguo', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '郭建强', 'jguo@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_25', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'POS_INERT_PRODUCTION_AUTO', 'sshang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '尚思丰', 'sshang@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_26', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'POS_INERT_PRODUCTION_AUTO', 'syang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '杨升', 'syang@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_27', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'POS_INERT_PRODUCTION_CLERK', 'ayi', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '易兴平', 'ayi@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_28', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'POS_INERT_PRODUCTION_CLERK', 'xxiao', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '肖丽', 'xxiao@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_29', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'POS_INERT_PRODUCTION_CLERK', 'dxu', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '徐德琴', 'dxu@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),

-- 工程部门 (10人)
('USER_30', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'POS_INERT_ENGINEERING_MGR', 'dwei', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '韦占光', 'dwei@bellis-technology.cn', 'MANAGER', 'ACTIVE', 'SYSTEM'),
('USER_31', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'POS_INERT_ENGINEERING_SUPER', 'dlee', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '李海林', 'dlee@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_32', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'POS_INERT_NPD_ENG', 'hhuang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '黄海辉', 'hhuang@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_33', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'POS_INERT_NPD_ENG', 'lxiao', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '肖星宇', 'lxiao@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_34', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'POS_INERT_NPD_ENG', 'kjii', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '季晨阳', 'kjii@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_35', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'POS_INERT_NPD_ENG', 'vchen', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '陈蔓', 'vchen@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_36', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'POS_INERT_NPD_ENG', 'jhu', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '胡锦伦', 'jhu@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_37', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'POS_INERT_NPD_ENG', 'sshu', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '舒恒', 'sshu@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_38', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'POS_INERT_MOLD_ENG', 'jchen', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '陈强', 'jchen@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_39', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'POS_INERT_MOLD_ENG', 'zliao', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '廖凯臻', 'zliao@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),

-- 工程部门 - 生产工程师 (3人)
('USER_40', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'POS_INERT_PROCESS_ENG', 'jxaing', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '向枕毅', 'jxaing@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_41', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'POS_INERT_PROCESS_ENG', 'ejiang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '江勤', 'ejiang@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_42', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'POS_INERT_PROCESS_ENG', 'hqingchuan', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '黄清传', 'hqingchuan@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),

-- 品质部门 (14人)
('USER_43', 'TENANT_INERT', 'DEPT_INERT_QUALITY', 'POS_INERT_QUALITY_MGR', 'sli', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '黎厚利', 'sli@bellis-technology.cn', 'MANAGER', 'ACTIVE', 'SYSTEM'),
('USER_50', 'TENANT_INERT', 'DEPT_INERT_QUALITY', 'POS_INERT_QUALITY_SUPER', 'nwang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '王艳', 'nwang@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_46', 'TENANT_INERT', 'DEPT_INERT_QUALITY', 'POS_INERT_FAI', 'faliu', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '刘芳', 'faliu@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_51', 'TENANT_INERT', 'DEPT_INERT_QUALITY', 'POS_INERT_IQC', 'kzhang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '张枭', 'kzhang@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_53', 'TENANT_INERT', 'DEPT_INERT_QUALITY', 'POS_INERT_IQC', 'xtan', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '谭学琼', 'xtan@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_54', 'TENANT_INERT', 'DEPT_INERT_QUALITY', 'POS_INERT_IQC', 'sjiang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '江三秀', 'sjiang@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_55', 'TENANT_INERT', 'DEPT_INERT_QUALITY', 'POS_INERT_IQC', 'hgu', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '顾红雷', 'hgu@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_56', 'TENANT_INERT', 'DEPT_INERT_QUALITY', 'POS_INERT_IPQC', 'fzhang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '张凤云', 'fzhang@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_52', 'TENANT_INERT', 'DEPT_INERT_QUALITY', 'POS_INERT_QUALITY_EXTERNAL', 'iliu', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '刘志林', 'iliu@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_49', 'TENANT_INERT', 'DEPT_INERT_QUALITY', 'POS_INERT_QUALITY_REPAIR', 'jili', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '李建强', 'jili@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_57', 'TENANT_INERT', 'DEPT_INERT_QUALITY', 'POS_INERT_QUALITY_CLERK', 'jhao', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '郝娟', 'jhao@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),

-- 维修部门 (1人)
('USER_48', 'TENANT_INERT', 'DEPT_INERT_MAINTENANCE', 'POS_INERT_MAINTENANCE', 'ami', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '米红刚', 'ami@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),

-- IT部门 (3人)
('USER_44', 'TENANT_INERT', 'DEPT_INERT_IT', 'POS_INERT_IT_ENG', 'mlu', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '卢澳华', 'mlu@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_45', 'TENANT_INERT', 'DEPT_INERT_IT', 'POS_INERT_IT_DEV', 'jqi', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '覃思创', 'jqi@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_47', 'TENANT_INERT', 'DEPT_INERT_IT', 'POS_INERT_IT_OPS', 'xmei', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '梅细根', 'xmei@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),

-- === 供应商用户 (TENANT_SUPPLIER) - 52人 ===
('USER_59', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'POS_SUPPLIER_MATERIAL', 'ctliu', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'ctliu', 'ct.liu@suga.com.cn', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_60', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'POS_SUPPLIER_MATERIAL', 'elmerliu', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'elmerliu', 'elmer.liu@suga.com.cn', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_61', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'luckyluo', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'luckyluo', 'lucky.luo@suga.com.cn', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_62', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'tomey', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'tomey', 'tomey@peirestech.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_63', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'pg008', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'pg008', 'pg008@dgkrljq.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_64', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'sales003', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'sales003', 'sales003@konnra.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_65', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'szit00', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'szit00', 'szit00@163.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_66', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'cowin66', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'cowin66', 'cowin66@163.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_67', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'hflpaper', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'hflpaper', 'hfl_paper@163.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_68', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'optqc', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'optqc', 'optqc@cn.greatlink.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_69', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'marywang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'marywang', 'mary.wang@greatlink.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_70', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'ambertang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'ambertang', 'amber.tang@fennerprecision.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_71', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'mike', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'mike', 'mike@aco-mfg.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_72', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'feiluo', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'feiluo', 'fei.luo@johnsonelectric.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_73', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'jackli', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'jackli', 'jack.li@kaiyangfm.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_74', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'quality', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'quality', 'quality@powerspring.cn', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_75', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'qc02', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'qc02', 'qc02@hongshengintl.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_76', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'om', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'om', 'om@hongshengintl.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_77', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'coral', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'coral', 'coral@jmsdg.cn', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_78', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'skyy', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'skyy', 'skyy@zgyangkang.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_79', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'qualitykoyo', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'qualitykoyo', 'quality@dgkoyo.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_80', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'ltpqa', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'ltpqa', 'ltp-qa@ltihk.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_81', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'zhangzhihui', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'zhangzhihui', 'zhangzhihui@cn-poeder.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_82', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'susan', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'susan', 'susan@cn-powder.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_83', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'quality01', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'quality01', 'quality01@jbrsz.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_84', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'pd', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'pd', 'pd@jbrsz.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_85', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'sales', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'sales', 'sales@bearings-china.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_86', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'jojo', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'jojo', 'jojo@gtktaiwan.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_87', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'sales4', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'sales4', 'sales4@nichibo-motor.com.cn', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_88', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'salesyaxin', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'salesyaxin', 'sales@solenoidschina.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_89', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'twn7pros', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'twn7pros', 'twn7pros@ms17.hinet.net', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_90', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'jg640', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'jg640', 'jg640@hzjinggong.cn', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_91', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'qc', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'qc', 'QC@kamon.com.cn', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_92', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'yluo', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'yluo', 'y.luo@magtop.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_93', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'huizhou', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'huizhou', 'huizhou@kamon.com.cn', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_94', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'rubyyan', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'rubyyan', 'rubyyan@sbgxbl.com.cn', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_95', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'cqe', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'cqe', 'cqe@dgchenyuan.com.cn', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_96', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'qa', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'qa', 'qa@dgchenyuan.com.cn', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_97', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'sale5', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'sale5', 'sale5@tobon.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_98', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'sale2', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'sale2', 'sale2@tobon.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_99', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'szhyx168', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'szhyx168', 'szhyx168@163.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_100', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'tonywu', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'tonywu', 'tonywu@axes-ind.com.hk', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_101', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'cqecht', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'cqecht', 'cqe@sz-changhong.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_102', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'cqe2', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'cqe2', 'cqe2@sz-changhong.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_103', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'qchyy', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'qchyy', 'qc_hyy@163.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_104', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'saleshyy', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'saleshyy', 'sales_hyy02@163.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_105', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'yuanhaitao', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'yuanhaitao', 'yuanhaitao@sz-baohui.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_106', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'qe', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'qe', 'qe@suga.com.cn', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_107', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'pyleung', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'pyleung', 'pyleung@kamon.com.cn', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_108', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'hqingchuan_s', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '黄清传', 'hqingchuan@bellis-technology.cn', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_109', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'hou', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'hou', 'diles.hou@mingrun.work', 'SUPPLIER', 'ACTIVE', 'SYSTEM'),
('USER_110', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_RAW', 'wu', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'wu', 'annie.wu@jinnfeng.com', 'SUPPLIER', 'ACTIVE', 'SYSTEM');

-- 插入基于业务行为的RBAC角色数据
INSERT INTO sys_role (role_id, tenant_id, parent_role_id, role_code, role_name, role_type, role_level, data_scope, inherit_permissions, inherit_data_scope, created_by) VALUES
-- ===== 通用角色（跨租户） =====

-- 1. 数据查看类角色
('ROLE_DATA_VIEWER_ALL', 'TENANT_INERT', NULL, 'DATA_VIEWER_ALL', '全局数据查看', 'NORMAL', 1, 'ALL', FALSE, FALSE, 'SYSTEM'),
('ROLE_DATA_VIEWER_DEPT', 'TENANT_INERT', 'ROLE_DATA_VIEWER_ALL', 'DATA_VIEWER_DEPT', '部门数据查看', 'NORMAL', 2, 'DEPT', TRUE, FALSE, 'SYSTEM'),
('ROLE_BI_ANALYST', 'TENANT_INERT', 'ROLE_DATA_VIEWER_ALL', 'BI_ANALYST', 'BI数据分析', 'NORMAL', 2, 'ALL', TRUE, TRUE, 'SYSTEM'),

-- 2. 采购域角色
('ROLE_PROCUREMENT_ORDER_CREATE', 'TENANT_INERT', NULL, 'PROCUREMENT_ORDER_CREATE', '创建采购订单', 'NORMAL', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),
('ROLE_PROCUREMENT_ORDER_APPROVE', 'TENANT_INERT', 'ROLE_PROCUREMENT_ORDER_CREATE', 'PROCUREMENT_ORDER_APPROVE', '审批采购订单', 'NORMAL', 2, 'DEPT_AND_CHILD', TRUE, TRUE, 'SYSTEM'),
('ROLE_PROCUREMENT_ECN_MANAGE', 'TENANT_INERT', NULL, 'PROCUREMENT_ECN_MANAGE', 'ECN变更管理', 'NORMAL', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),
('ROLE_SUPPLIER_MANAGE', 'TENANT_INERT', NULL, 'SUPPLIER_MANAGE', '供应商管理', 'NORMAL', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),

-- 3. 物流域角色
('ROLE_CUSTOMS_DECLARE', 'TENANT_INERT', NULL, 'CUSTOMS_DECLARE', '海关报备', 'NORMAL', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),
('ROLE_WAREHOUSE_RECEIVE', 'TENANT_INERT', NULL, 'WAREHOUSE_RECEIVE', '收货入库', 'NORMAL', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),
('ROLE_WAREHOUSE_ISSUE', 'TENANT_INERT', NULL, 'WAREHOUSE_ISSUE', '备料出库', 'NORMAL', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),
('ROLE_INVENTORY_COUNT', 'TENANT_INERT', NULL, 'INVENTORY_COUNT', '库存盘点', 'NORMAL', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),
('ROLE_INVENTORY_APPROVE', 'TENANT_INERT', 'ROLE_INVENTORY_COUNT', 'INVENTORY_APPROVE', '库存审批', 'NORMAL', 2, 'DEPT_AND_CHILD', TRUE, TRUE, 'SYSTEM'),

-- 4. 品质域角色
('ROLE_IQC_INSPECT', 'TENANT_INERT', NULL, 'IQC_INSPECT', 'IQC进料检验', 'NORMAL', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),
('ROLE_IQC_APPROVE', 'TENANT_INERT', 'ROLE_IQC_INSPECT', 'IQC_APPROVE', 'IQC结果审批', 'NORMAL', 2, 'DEPT_AND_CHILD', TRUE, TRUE, 'SYSTEM'),
('ROLE_IPQC_INSPECT', 'TENANT_INERT', NULL, 'IPQC_INSPECT', 'IPQC过程巡检', 'NORMAL', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),
('ROLE_OQC_INSPECT', 'TENANT_INERT', NULL, 'OQC_INSPECT', 'OQC出货检验', 'NORMAL', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),
('ROLE_FAI_VERIFY', 'TENANT_INERT', NULL, 'FAI_VERIFY', '首件验证', 'NORMAL', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),
('ROLE_QUALITY_NCR_CREATE', 'TENANT_INERT', NULL, 'QUALITY_NCR_CREATE', '创建NCR/SCAR', 'NORMAL', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),
('ROLE_QUALITY_NCR_HANDLE', 'TENANT_INERT', 'ROLE_QUALITY_NCR_CREATE', 'QUALITY_NCR_HANDLE', '处理NCR/SCAR', 'NORMAL', 2, 'DEPT', TRUE, TRUE, 'SYSTEM'),
('ROLE_QUALITY_APPROVE', 'TENANT_INERT', 'ROLE_IQC_APPROVE', 'QUALITY_APPROVE', '品质审批', 'NORMAL', 3, 'DEPT_AND_CHILD', TRUE, TRUE, 'SYSTEM'),

-- 5. 生产域角色
('ROLE_PRODUCTION_PLAN_CREATE', 'TENANT_INERT', NULL, 'PRODUCTION_PLAN_CREATE', '创建生产计划', 'NORMAL', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),
('ROLE_PRODUCTION_PLAN_APPROVE', 'TENANT_INERT', 'ROLE_PRODUCTION_PLAN_CREATE', 'PRODUCTION_PLAN_APPROVE', '审批生产计划', 'NORMAL', 2, 'DEPT_AND_CHILD', TRUE, TRUE, 'SYSTEM'),
('ROLE_WORK_ORDER_CREATE', 'TENANT_INERT', NULL, 'WORK_ORDER_CREATE', '创建工单', 'NORMAL', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),
('ROLE_WORK_ORDER_EXECUTE', 'TENANT_INERT', NULL, 'WORK_ORDER_EXECUTE', '执行工单', 'NORMAL', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),
('ROLE_PRODUCTION_TEST', 'TENANT_INERT', NULL, 'PRODUCTION_TEST', '生产测试', 'NORMAL', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),
('ROLE_PRODUCTION_REPAIR', 'TENANT_INERT', NULL, 'PRODUCTION_REPAIR', '返修操作', 'NORMAL', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),
('ROLE_PRODUCTION_PACK', 'TENANT_INERT', NULL, 'PRODUCTION_PACK', '打包出货', 'NORMAL', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),

-- 6. 工程域角色
('ROLE_ENGINEERING_NPD', 'TENANT_INERT', NULL, 'ENGINEERING_NPD', '新产品开发', 'NORMAL', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),
('ROLE_ENGINEERING_PROCESS', 'TENANT_INERT', NULL, 'ENGINEERING_PROCESS', '工艺管理', 'NORMAL', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),
('ROLE_ENGINEERING_MOLD', 'TENANT_INERT', NULL, 'ENGINEERING_MOLD', '模具管理', 'NORMAL', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),
('ROLE_ENGINEERING_APPROVE', 'TENANT_INERT', 'ROLE_ENGINEERING_NPD', 'ENGINEERING_APPROVE', '工程审批', 'NORMAL', 2, 'DEPT_AND_CHILD', TRUE, TRUE, 'SYSTEM'),

-- 7. 追溯与分析角色
('ROLE_TRACE_QUERY', 'TENANT_INERT', NULL, 'TRACE_QUERY', '追溯查询', 'NORMAL', 1, 'ALL', FALSE, FALSE, 'SYSTEM'),
('ROLE_TRACE_ANALYST', 'TENANT_INERT', 'ROLE_TRACE_QUERY', 'TRACE_ANALYST', '追溯分析', 'NORMAL', 2, 'ALL', TRUE, TRUE, 'SYSTEM'),

-- 8. 系统管理角色
('ROLE_SYSTEM_ADMIN', 'TENANT_INERT', NULL, 'SYSTEM_ADMIN', '系统管理', 'SYSTEM', 1, 'ALL', FALSE, FALSE, 'SYSTEM'),
('ROLE_USER_MANAGE', 'TENANT_INERT', NULL, 'USER_MANAGE', '用户管理', 'NORMAL', 1, 'DEPT_AND_CHILD', FALSE, FALSE, 'SYSTEM'),
('ROLE_TENANT_ADMIN', 'TENANT_INERT', 'ROLE_SYSTEM_ADMIN', 'TENANT_ADMIN', '租户管理', 'SYSTEM', 2, 'ALL', TRUE, TRUE, 'SYSTEM'),
('ROLE_MODULE_ADMIN', 'TENANT_INERT', NULL, 'MODULE_ADMIN', '模块管理', 'NORMAL', 1, 'DEPT_AND_CHILD', FALSE, FALSE, 'SYSTEM'),

-- 9. 财务与HR角色
('ROLE_FINANCE_VIEW', 'TENANT_INERT', NULL, 'FINANCE_VIEW', '财务数据查看', 'NORMAL', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),
('ROLE_FINANCE_APPROVE', 'TENANT_INERT', 'ROLE_FINANCE_VIEW', 'FINANCE_APPROVE', '财务审批', 'NORMAL', 2, 'DEPT_AND_CHILD', TRUE, TRUE, 'SYSTEM'),
('ROLE_HR_MANAGE', 'TENANT_INERT', NULL, 'HR_MANAGE', '人事管理', 'NORMAL', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),

-- ===== 供应商协同角色 =====
('ROLE_SUPPLIER_ORDER_VIEW', 'TENANT_SUPPLIER', NULL, 'SUPPLIER_ORDER_VIEW', '查看采购订单', 'SUPPLIER', 1, 'SELF', FALSE, FALSE, 'SYSTEM'),
('ROLE_SUPPLIER_IQC_COLLABORATE', 'TENANT_SUPPLIER', NULL, 'SUPPLIER_IQC_COLLABORATE', 'IQC协同', 'SUPPLIER', 1, 'SELF', FALSE, FALSE, 'SYSTEM'),
('ROLE_SUPPLIER_DELIVERY_MANAGE', 'TENANT_SUPPLIER', NULL, 'SUPPLIER_DELIVERY_MANAGE', '发货管理', 'SUPPLIER', 1, 'SELF', FALSE, FALSE, 'SYSTEM'),
('ROLE_SUPPLIER_MOLD_UPDATE', 'TENANT_SUPPLIER', NULL, 'SUPPLIER_MOLD_UPDATE', '模具状态更新', 'SUPPLIER', 1, 'SELF', FALSE, FALSE, 'SYSTEM');

-- 插入职位数据（基于user_profile真实职位）
INSERT INTO sys_position (position_id, tenant_id, position_code, position_name, dept_id, position_level, created_by) VALUES
-- INERT内网职位
('POS_INERT_CEO', 'TENANT_INERT', 'CEO', '总经理', 'DEPT_INERT_MANAGEMENT', 1, 'SYSTEM'),
('POS_INERT_LOGISTICS_MGR', 'TENANT_INERT', 'LOGISTICS_MGR', '物流经理', 'DEPT_INERT_LOGISTICS', 2, 'SYSTEM'),
('POS_INERT_CUSTOMS', 'TENANT_INERT', 'CUSTOMS', '海关专员', 'DEPT_INERT_LOGISTICS', 4, 'SYSTEM'),
('POS_INERT_WAREHOUSE_LEADER', 'TENANT_INERT', 'WAREHOUSE_LEADER', '仓管大组长', 'DEPT_INERT_LOGISTICS', 3, 'SYSTEM'),
('POS_INERT_PROCUREMENT_MGR', 'TENANT_INERT', 'PROCUREMENT_MGR', '采购经理', 'DEPT_INERT_PROCUREMENT', 2, 'SYSTEM'),
('POS_INERT_PROCUREMENT_ECN', 'TENANT_INERT', 'PROCUREMENT_ECN', '采购ECN变更专员', 'DEPT_INERT_PROCUREMENT', 4, 'SYSTEM'),
('POS_INERT_PROCUREMENT', 'TENANT_INERT', 'PROCUREMENT', '采购专员', 'DEPT_INERT_PROCUREMENT', 4, 'SYSTEM'),
('POS_INERT_PROCUREMENT_AUXMAT', 'TENANT_INERT', 'PROCUREMENT_AUXMAT', '采购辅料专员', 'DEPT_INERT_PROCUREMENT', 4, 'SYSTEM'),
('POS_INERT_PROCUREMENT_PKG', 'TENANT_INERT', 'PROCUREMENT_PKG', '采购包材专员', 'DEPT_INERT_PROCUREMENT', 4, 'SYSTEM'),
('POS_INERT_FINANCE_MGR', 'TENANT_INERT', 'FINANCE_MGR', '财务经理', 'DEPT_INERT_FINANCE', 2, 'SYSTEM'),
('POS_INERT_FINANCE_SUPER', 'TENANT_INERT', 'FINANCE_SUPER', '财务主管', 'DEPT_INERT_FINANCE', 3, 'SYSTEM'),
('POS_INERT_FINANCE', 'TENANT_INERT', 'FINANCE', '财务专员', 'DEPT_INERT_FINANCE', 4, 'SYSTEM'),
('POS_INERT_HR_SUPER', 'TENANT_INERT', 'HR_SUPER', '人事主管', 'DEPT_INERT_HR', 3, 'SYSTEM'),
('POS_INERT_HR', 'TENANT_INERT', 'HR', '人事专员', 'DEPT_INERT_HR', 4, 'SYSTEM'),
('POS_INERT_PRODUCTION_MGR', 'TENANT_INERT', 'PRODUCTION_MGR', '生产经理', 'DEPT_INERT_PRODUCTION', 2, 'SYSTEM'),
('POS_INERT_PRODUCTION_SHIP', 'TENANT_INERT', 'PRODUCTION_SHIP', '生产出货主管', 'DEPT_INERT_PRODUCTION', 3, 'SYSTEM'),
('POS_INERT_PRODUCTION_WORKSHOP', 'TENANT_INERT', 'PRODUCTION_WORKSHOP', '生产车间主管', 'DEPT_INERT_PRODUCTION', 3, 'SYSTEM'),
('POS_INERT_PRODUCTION_LEADER', 'TENANT_INERT', 'PRODUCTION_LEADER', '生产大组长', 'DEPT_INERT_PRODUCTION', 4, 'SYSTEM'),
('POS_INERT_PRODUCTION_GROUP', 'TENANT_INERT', 'PRODUCTION_GROUP', '生产组长', 'DEPT_INERT_PRODUCTION', 5, 'SYSTEM'),
('POS_INERT_PRODUCTION_ENG', 'TENANT_INERT', 'PRODUCTION_ENG', '生产工程师', 'DEPT_INERT_PRODUCTION', 4, 'SYSTEM'),
('POS_INERT_PRODUCTION_AUTO', 'TENANT_INERT', 'PRODUCTION_AUTO', '生产自动化工程师', 'DEPT_INERT_PRODUCTION', 4, 'SYSTEM'),
('POS_INERT_PRODUCTION_CLERK', 'TENANT_INERT', 'PRODUCTION_CLERK', '生产文员', 'DEPT_INERT_PRODUCTION', 5, 'SYSTEM'),
('POS_INERT_ENGINEERING_MGR', 'TENANT_INERT', 'ENGINEERING_MGR', '工程经理', 'DEPT_INERT_ENGINEERING', 2, 'SYSTEM'),
('POS_INERT_ENGINEERING_SUPER', 'TENANT_INERT', 'ENGINEERING_SUPER', '工程主管', 'DEPT_INERT_ENGINEERING', 3, 'SYSTEM'),
('POS_INERT_NPD_ENG', 'TENANT_INERT', 'NPD_ENG', 'NPD工程师', 'DEPT_INERT_ENGINEERING', 4, 'SYSTEM'),
('POS_INERT_MOLD_ENG', 'TENANT_INERT', 'MOLD_ENG', '模具工程师', 'DEPT_INERT_ENGINEERING', 4, 'SYSTEM'),
('POS_INERT_PROCESS_ENG', 'TENANT_INERT', 'PROCESS_ENG', '生产工程师', 'DEPT_INERT_ENGINEERING', 4, 'SYSTEM'),
('POS_INERT_QUALITY_MGR', 'TENANT_INERT', 'QUALITY_MGR', '品质经理', 'DEPT_INERT_QUALITY', 2, 'SYSTEM'),
('POS_INERT_QUALITY_SUPER', 'TENANT_INERT', 'QUALITY_SUPER', '品质主管', 'DEPT_INERT_QUALITY', 3, 'SYSTEM'),
('POS_INERT_FAI', 'TENANT_INERT', 'FAI', '首件核对专员', 'DEPT_INERT_QUALITY', 4, 'SYSTEM'),
('POS_INERT_IQC', 'TENANT_INERT', 'IQC', 'IQC专员', 'DEPT_INERT_QUALITY', 4, 'SYSTEM'),
('POS_INERT_IPQC', 'TENANT_INERT', 'IPQC', 'IPQC专员', 'DEPT_INERT_QUALITY', 4, 'SYSTEM'),
('POS_INERT_QUALITY_EXTERNAL', 'TENANT_INERT', 'QUALITY_EXTERNAL', '品质外派专员', 'DEPT_INERT_QUALITY', 4, 'SYSTEM'),
('POS_INERT_QUALITY_REPAIR', 'TENANT_INERT', 'QUALITY_REPAIR', '品质维修专员', 'DEPT_INERT_QUALITY', 4, 'SYSTEM'),
('POS_INERT_QUALITY_CLERK', 'TENANT_INERT', 'QUALITY_CLERK', '品质文员', 'DEPT_INERT_QUALITY', 5, 'SYSTEM'),
('POS_INERT_MAINTENANCE', 'TENANT_INERT', 'MAINTENANCE', '维修主管', 'DEPT_INERT_MAINTENANCE', 3, 'SYSTEM'),
('POS_INERT_IT_ENG', 'TENANT_INERT', 'IT_ENG', 'IT工程师', 'DEPT_INERT_IT', 4, 'SYSTEM'),
('POS_INERT_IT_DEV', 'TENANT_INERT', 'IT_DEV', 'IT开发', 'DEPT_INERT_IT', 4, 'SYSTEM'),
('POS_INERT_IT_OPS', 'TENANT_INERT', 'IT_OPS', 'IT运维专员', 'DEPT_INERT_IT', 4, 'SYSTEM'),

-- UK_HEAD职位
('POS_UK_READONLY', 'TENANT_UK_HEAD', 'READONLY', '只读用户', 'DEPT_UK_HEAD', 4, 'SYSTEM'),

-- SUPPLIER职位
('POS_SUPPLIER_MATERIAL', 'TENANT_SUPPLIER', 'SUPPLIER_MATERIAL', '原材料供应商', 'DEPT_SUPPLIER_RAW', 4, 'SYSTEM');

-- 插入职位-角色映射数据（职位与权限角色的解耦）
INSERT INTO sys_position_role (position_id, role_id, is_default, created_by) VALUES
-- 总经理职位映射
('POS_INERT_CEO', 'ROLE_DATA_VIEWER_ALL', TRUE, 'SYSTEM'),
('POS_INERT_CEO', 'ROLE_BI_ANALYST', TRUE, 'SYSTEM'),
('POS_INERT_CEO', 'ROLE_PRODUCTION_PLAN_APPROVE', TRUE, 'SYSTEM'),
('POS_INERT_CEO', 'ROLE_PROCUREMENT_ORDER_APPROVE', TRUE, 'SYSTEM'),
('POS_INERT_CEO', 'ROLE_FINANCE_APPROVE', TRUE, 'SYSTEM'),

-- 物流经理职位映射
('POS_INERT_LOGISTICS_MGR', 'ROLE_WAREHOUSE_RECEIVE', TRUE, 'SYSTEM'),
('POS_INERT_LOGISTICS_MGR', 'ROLE_WAREHOUSE_ISSUE', TRUE, 'SYSTEM'),
('POS_INERT_LOGISTICS_MGR', 'ROLE_INVENTORY_APPROVE', TRUE, 'SYSTEM'),
('POS_INERT_LOGISTICS_MGR', 'ROLE_CUSTOMS_DECLARE', TRUE, 'SYSTEM'),
('POS_INERT_LOGISTICS_MGR', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- 海关专员职位映射
('POS_INERT_CUSTOMS', 'ROLE_CUSTOMS_DECLARE', TRUE, 'SYSTEM'),
('POS_INERT_CUSTOMS', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- 仓管大组长职位映射
('POS_INERT_WAREHOUSE_LEADER', 'ROLE_WAREHOUSE_RECEIVE', TRUE, 'SYSTEM'),
('POS_INERT_WAREHOUSE_LEADER', 'ROLE_WAREHOUSE_ISSUE', TRUE, 'SYSTEM'),
('POS_INERT_WAREHOUSE_LEADER', 'ROLE_INVENTORY_COUNT', TRUE, 'SYSTEM'),
('POS_INERT_WAREHOUSE_LEADER', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- 采购经理职位映射
('POS_INERT_PROCUREMENT_MGR', 'ROLE_PROCUREMENT_ORDER_CREATE', TRUE, 'SYSTEM'),
('POS_INERT_PROCUREMENT_MGR', 'ROLE_PROCUREMENT_ORDER_APPROVE', TRUE, 'SYSTEM'),
('POS_INERT_PROCUREMENT_MGR', 'ROLE_SUPPLIER_MANAGE', TRUE, 'SYSTEM'),
('POS_INERT_PROCUREMENT_MGR', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- 采购ECN专员职位映射
('POS_INERT_PROCUREMENT_ECN', 'ROLE_PROCUREMENT_ECN_MANAGE', TRUE, 'SYSTEM'),
('POS_INERT_PROCUREMENT_ECN', 'ROLE_PROCUREMENT_ORDER_CREATE', TRUE, 'SYSTEM'),
('POS_INERT_PROCUREMENT_ECN', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- 采购专员职位映射
('POS_INERT_PROCUREMENT', 'ROLE_PROCUREMENT_ORDER_CREATE', TRUE, 'SYSTEM'),
('POS_INERT_PROCUREMENT', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- 采购辅料专员职位映射
('POS_INERT_PROCUREMENT_AUXMAT', 'ROLE_PROCUREMENT_ORDER_CREATE', TRUE, 'SYSTEM'),
('POS_INERT_PROCUREMENT_AUXMAT', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- 采购包材专员职位映射
('POS_INERT_PROCUREMENT_PKG', 'ROLE_PROCUREMENT_ORDER_CREATE', TRUE, 'SYSTEM'),
('POS_INERT_PROCUREMENT_PKG', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- 财务经理职位映射
('POS_INERT_FINANCE_MGR', 'ROLE_FINANCE_VIEW', TRUE, 'SYSTEM'),
('POS_INERT_FINANCE_MGR', 'ROLE_FINANCE_APPROVE', TRUE, 'SYSTEM'),
('POS_INERT_FINANCE_MGR', 'ROLE_PROCUREMENT_ORDER_APPROVE', TRUE, 'SYSTEM'),
('POS_INERT_FINANCE_MGR', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- 财务主管职位映射
('POS_INERT_FINANCE_SUPER', 'ROLE_FINANCE_VIEW', TRUE, 'SYSTEM'),
('POS_INERT_FINANCE_SUPER', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- 财务专员职位映射
('POS_INERT_FINANCE', 'ROLE_FINANCE_VIEW', TRUE, 'SYSTEM'),

-- 人事主管职位映射
('POS_INERT_HR_SUPER', 'ROLE_HR_MANAGE', TRUE, 'SYSTEM'),
('POS_INERT_HR_SUPER', 'ROLE_USER_MANAGE', TRUE, 'SYSTEM'),
('POS_INERT_HR_SUPER', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- 人事专员职位映射
('POS_INERT_HR', 'ROLE_HR_MANAGE', TRUE, 'SYSTEM'),

-- 生产经理职位映射
('POS_INERT_PRODUCTION_MGR', 'ROLE_PRODUCTION_PLAN_CREATE', TRUE, 'SYSTEM'),
('POS_INERT_PRODUCTION_MGR', 'ROLE_PRODUCTION_PLAN_APPROVE', TRUE, 'SYSTEM'),
('POS_INERT_PRODUCTION_MGR', 'ROLE_WORK_ORDER_CREATE', TRUE, 'SYSTEM'),
('POS_INERT_PRODUCTION_MGR', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- 生产出货主管职位映射
('POS_INERT_PRODUCTION_SHIP', 'ROLE_PRODUCTION_PACK', TRUE, 'SYSTEM'),
('POS_INERT_PRODUCTION_SHIP', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- 生产车间主管职位映射
('POS_INERT_PRODUCTION_WORKSHOP', 'ROLE_WORK_ORDER_EXECUTE', TRUE, 'SYSTEM'),
('POS_INERT_PRODUCTION_WORKSHOP', 'ROLE_WORK_ORDER_CREATE', TRUE, 'SYSTEM'),
('POS_INERT_PRODUCTION_WORKSHOP', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- 生产大组长职位映射
('POS_INERT_PRODUCTION_LEADER', 'ROLE_WORK_ORDER_EXECUTE', TRUE, 'SYSTEM'),
('POS_INERT_PRODUCTION_LEADER', 'ROLE_PRODUCTION_TEST', TRUE, 'SYSTEM'),
('POS_INERT_PRODUCTION_LEADER', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- 生产组长职位映射
('POS_INERT_PRODUCTION_GROUP', 'ROLE_WORK_ORDER_EXECUTE', TRUE, 'SYSTEM'),
('POS_INERT_PRODUCTION_GROUP', 'ROLE_PRODUCTION_TEST', TRUE, 'SYSTEM'),
('POS_INERT_PRODUCTION_GROUP', 'ROLE_PRODUCTION_REPAIR', TRUE, 'SYSTEM'),

-- 生产工程师职位映射
('POS_INERT_PRODUCTION_ENG', 'ROLE_ENGINEERING_PROCESS', TRUE, 'SYSTEM'),
('POS_INERT_PRODUCTION_ENG', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- 生产自动化工程师职位映射
('POS_INERT_PRODUCTION_AUTO', 'ROLE_ENGINEERING_PROCESS', TRUE, 'SYSTEM'),
('POS_INERT_PRODUCTION_AUTO', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- 生产文员职位映射
('POS_INERT_PRODUCTION_CLERK', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- 工程经理职位映射
('POS_INERT_ENGINEERING_MGR', 'ROLE_ENGINEERING_NPD', TRUE, 'SYSTEM'),
('POS_INERT_ENGINEERING_MGR', 'ROLE_ENGINEERING_APPROVE', TRUE, 'SYSTEM'),
('POS_INERT_ENGINEERING_MGR', 'ROLE_PRODUCTION_PLAN_APPROVE', TRUE, 'SYSTEM'),
('POS_INERT_ENGINEERING_MGR', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- 工程主管职位映射
('POS_INERT_ENGINEERING_SUPER', 'ROLE_ENGINEERING_NPD', TRUE, 'SYSTEM'),
('POS_INERT_ENGINEERING_SUPER', 'ROLE_ENGINEERING_PROCESS', TRUE, 'SYSTEM'),
('POS_INERT_ENGINEERING_SUPER', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- NPD工程师职位映射
('POS_INERT_NPD_ENG', 'ROLE_ENGINEERING_NPD', TRUE, 'SYSTEM'),
('POS_INERT_NPD_ENG', 'ROLE_FAI_VERIFY', TRUE, 'SYSTEM'),
('POS_INERT_NPD_ENG', 'ROLE_ENGINEERING_PROCESS', TRUE, 'SYSTEM'),
('POS_INERT_NPD_ENG', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- 模具工程师职位映射
('POS_INERT_MOLD_ENG', 'ROLE_ENGINEERING_MOLD', TRUE, 'SYSTEM'),
('POS_INERT_MOLD_ENG', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- 生产工程师职位映射
('POS_INERT_PROCESS_ENG', 'ROLE_ENGINEERING_PROCESS', TRUE, 'SYSTEM'),
('POS_INERT_PROCESS_ENG', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- 品质经理职位映射
('POS_INERT_QUALITY_MGR', 'ROLE_QUALITY_APPROVE', TRUE, 'SYSTEM'),
('POS_INERT_QUALITY_MGR', 'ROLE_IQC_APPROVE', TRUE, 'SYSTEM'),
('POS_INERT_QUALITY_MGR', 'ROLE_TRACE_ANALYST', TRUE, 'SYSTEM'),
('POS_INERT_QUALITY_MGR', 'ROLE_QUALITY_NCR_HANDLE', TRUE, 'SYSTEM'),
('POS_INERT_QUALITY_MGR', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- 品质主管职位映射
('POS_INERT_QUALITY_SUPER', 'ROLE_IQC_APPROVE', TRUE, 'SYSTEM'),
('POS_INERT_QUALITY_SUPER', 'ROLE_QUALITY_NCR_HANDLE', TRUE, 'SYSTEM'),
('POS_INERT_QUALITY_SUPER', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- FAI专员职位映射
('POS_INERT_FAI', 'ROLE_FAI_VERIFY', TRUE, 'SYSTEM'),
('POS_INERT_FAI', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- IQC专员职位映射
('POS_INERT_IQC', 'ROLE_IQC_INSPECT', TRUE, 'SYSTEM'),
('POS_INERT_IQC', 'ROLE_QUALITY_NCR_CREATE', TRUE, 'SYSTEM'),
('POS_INERT_IQC', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- IPQC专员职位映射
('POS_INERT_IPQC', 'ROLE_IPQC_INSPECT', TRUE, 'SYSTEM'),
('POS_INERT_IPQC', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- 品质外派专员职位映射
('POS_INERT_QUALITY_EXTERNAL', 'ROLE_IQC_INSPECT', TRUE, 'SYSTEM'),
('POS_INERT_QUALITY_EXTERNAL', 'ROLE_SUPPLIER_MANAGE', TRUE, 'SYSTEM'),
('POS_INERT_QUALITY_EXTERNAL', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- 品质维修专员职位映射
('POS_INERT_QUALITY_REPAIR', 'ROLE_PRODUCTION_REPAIR', TRUE, 'SYSTEM'),
('POS_INERT_QUALITY_REPAIR', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- 品质文员职位映射
('POS_INERT_QUALITY_CLERK', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- 维修主管职位映射
('POS_INERT_MAINTENANCE', 'ROLE_PRODUCTION_REPAIR', TRUE, 'SYSTEM'),
('POS_INERT_MAINTENANCE', 'ROLE_DATA_VIEWER_DEPT', TRUE, 'SYSTEM'),

-- IT工程师职位映射
('POS_INERT_IT_ENG', 'ROLE_SYSTEM_ADMIN', TRUE, 'SYSTEM'),
('POS_INERT_IT_ENG', 'ROLE_USER_MANAGE', TRUE, 'SYSTEM'),

-- IT开发职位映射
('POS_INERT_IT_DEV', 'ROLE_SYSTEM_ADMIN', TRUE, 'SYSTEM'),
('POS_INERT_IT_DEV', 'ROLE_MODULE_ADMIN', TRUE, 'SYSTEM'),

-- IT运维专员职位映射
('POS_INERT_IT_OPS', 'ROLE_SYSTEM_ADMIN', TRUE, 'SYSTEM'),

-- 英国只读用户职位映射
('POS_UK_READONLY', 'ROLE_DATA_VIEWER_ALL', TRUE, 'SYSTEM'),
('POS_UK_READONLY', 'ROLE_BI_ANALYST', TRUE, 'SYSTEM'),

-- 供应商职位映射
('POS_SUPPLIER_MATERIAL', 'ROLE_SUPPLIER_ORDER_VIEW', TRUE, 'SYSTEM'),
('POS_SUPPLIER_MATERIAL', 'ROLE_SUPPLIER_IQC_COLLABORATE', TRUE, 'SYSTEM'),
('POS_SUPPLIER_MATERIAL', 'ROLE_SUPPLIER_DELIVERY_MANAGE', TRUE, 'SYSTEM');

-- 插入基于流程树的权限数据
INSERT INTO sys_permission (permission_id, tenant_id, permission_code, permission_name, permission_type, resource_type, resource_id, action, created_by) VALUES
-- ===== 英国总公司权限 =====
-- 数据查看权限
('PERM_UK_DATA_VIEW', 'TENANT_UK_HEAD', 'uk:data:view', '英国数据查看', 'MENU_ACCESS', 'MENU', 'UK_DASHBOARD', 'READ', 'SYSTEM'),
('PERM_UK_REPORT_VIEW', 'TENANT_UK_HEAD', 'uk:report:view', '英国报表查看', 'MENU_ACCESS', 'MENU', 'UK_REPORTS', 'READ', 'SYSTEM'),
('PERM_UK_BI_ANALYSIS', 'TENANT_UK_HEAD', 'uk:bi:analysis', '英国BI分析', 'MENU_ACCESS', 'MENU', 'UK_BI_ANALYSIS', 'WRITE', 'SYSTEM'),
('PERM_UK_SYSTEM_MANAGE', 'TENANT_UK_HEAD', 'uk:system:manage', '英国系统管理', 'MENU_ACCESS', 'MENU', 'UK_SYSTEM_MANAGE', 'ADMIN', 'SYSTEM'),

-- ===== 内网用户权限 =====
-- 生产管理权限
('PERM_INERT_PRODUCTION_PLAN', 'TENANT_INERT', 'inert:production:plan', '生产计划管理', 'MENU_ACCESS', 'MENU', 'PRODUCTION_PLAN', 'WRITE', 'SYSTEM'),
('PERM_INERT_WORK_ORDER', 'TENANT_INERT', 'inert:workorder:manage', '工单管理', 'MENU_ACCESS', 'MENU', 'WORK_ORDER_MANAGE', 'WRITE', 'SYSTEM'),
('PERM_INERT_PRODUCTION_EXECUTE', 'TENANT_INERT', 'inert:production:execute', '生产执行', 'MENU_ACCESS', 'MENU', 'PRODUCTION_EXECUTE', 'WRITE', 'SYSTEM'),
('PERM_INERT_FAI_MANAGE', 'TENANT_INERT', 'inert:fai:manage', '首件验证管理', 'MENU_ACCESS', 'MENU', 'FAI_MANAGE', 'WRITE', 'SYSTEM'),
('PERM_INERT_TEST_MANAGE', 'TENANT_INERT', 'inert:test:manage', '测试管理', 'MENU_ACCESS', 'MENU', 'TEST_MANAGE', 'WRITE', 'SYSTEM'),

-- 质量管理权限
('PERM_INERT_IQC_MANAGE', 'TENANT_INERT', 'inert:iqc:manage', 'IQC检验管理', 'MENU_ACCESS', 'MENU', 'IQC_MANAGE', 'WRITE', 'SYSTEM'),
('PERM_INERT_IPQC_MANAGE', 'TENANT_INERT', 'inert:ipqc:manage', 'IPQC巡检管理', 'MENU_ACCESS', 'MENU', 'IPQC_MANAGE', 'WRITE', 'SYSTEM'),
('PERM_INERT_OQC_MANAGE', 'TENANT_INERT', 'inert:oqc:manage', 'OQC出货管理', 'MENU_ACCESS', 'MENU', 'OQC_MANAGE', 'WRITE', 'SYSTEM'),
('PERM_INERT_QUALITY_MANAGE', 'TENANT_INERT', 'inert:quality:manage', '质量管理', 'MENU_ACCESS', 'MENU', 'QUALITY_MANAGE', 'ADMIN', 'SYSTEM'),

-- 仓储物流权限
('PERM_INERT_WAREHOUSE_MANAGE', 'TENANT_INERT', 'inert:warehouse:manage', '仓库管理', 'MENU_ACCESS', 'MENU', 'WAREHOUSE_MANAGE', 'ADMIN', 'SYSTEM'),
('PERM_INERT_MATERIAL_MANAGE', 'TENANT_INERT', 'inert:material:manage', '物料管理', 'MENU_ACCESS', 'MENU', 'MATERIAL_MANAGE', 'WRITE', 'SYSTEM'),
('PERM_INERT_INVENTORY_MANAGE', 'TENANT_INERT', 'inert:inventory:manage', '库存管理', 'MENU_ACCESS', 'MENU', 'INVENTORY_MANAGE', 'WRITE', 'SYSTEM'),

-- 维护管理权限
('PERM_INERT_MAINTENANCE_MANAGE', 'TENANT_INERT', 'inert:maintenance:manage', '维护管理', 'MENU_ACCESS', 'MENU', 'MAINTENANCE_MANAGE', 'ADMIN', 'SYSTEM'),
('PERM_INERT_MAINTENANCE_EXECUTE', 'TENANT_INERT', 'inert:maintenance:execute', '维护执行', 'MENU_ACCESS', 'MENU', 'MAINTENANCE_EXECUTE', 'WRITE', 'SYSTEM'),

-- 追溯分析权限
('PERM_INERT_TRACE_ANALYSIS', 'TENANT_INERT', 'inert:trace:analysis', '追溯分析', 'MENU_ACCESS', 'MENU', 'TRACE_ANALYSIS', 'WRITE', 'SYSTEM'),

-- 系统管理权限
('PERM_INERT_SYSTEM_MANAGE', 'TENANT_INERT', 'inert:system:manage', '内网系统管理', 'MENU_ACCESS', 'MENU', 'INERT_SYSTEM_MANAGE', 'ADMIN', 'SYSTEM'),

-- ===== 供应商群体权限 =====
-- 模具管理权限
('PERM_SUPPLIER_MOLD_MANAGE', 'TENANT_SUPPLIER', 'supplier:mold:manage', '模具管理', 'MENU_ACCESS', 'MENU', 'MOLD_MANAGE', 'WRITE', 'SYSTEM'),
('PERM_SUPPLIER_MOLD_UPDATE', 'TENANT_SUPPLIER', 'supplier:mold:update', '模具状态更新', 'MENU_ACCESS', 'MENU', 'MOLD_STATUS_UPDATE', 'WRITE', 'SYSTEM'),

-- 原材料管理权限
('PERM_SUPPLIER_RAW_MANAGE', 'TENANT_SUPPLIER', 'supplier:raw:manage', '原材料管理', 'MENU_ACCESS', 'MENU', 'RAW_MATERIAL_MANAGE', 'WRITE', 'SYSTEM'),
('PERM_SUPPLIER_RAW_IQC', 'TENANT_SUPPLIER', 'supplier:raw:iqc', '原材料IQC协同', 'MENU_ACCESS', 'MENU', 'RAW_IQC_COORDINATE', 'WRITE', 'SYSTEM');

-- 插入模块数据
INSERT INTO sys_module (module_id, tenant_id, module_code, module_name, module_type, description, deploy_url, api_base_url, version, status, created_by) VALUES
-- 系统管理模块
('MODULE_SYSTEM', 'TENANT_UK_HEAD', 'SYSTEM', '系统管理', 'SYSTEM', '系统级管理模块，包含租户管理、模块管理、插件管理等', 'https://system.btc-saas.com', 'https://api.btc-saas.com/system', '1.0.0', 'ACTIVE', 'SYSTEM'),
('MODULE_SYSTEM', 'TENANT_INERT', 'SYSTEM', '系统管理', 'SYSTEM', '系统级管理模块，包含租户管理、模块管理、插件管理等', 'https://system.btc-saas.com', 'https://api.btc-saas.com/system', '1.0.0', 'ACTIVE', 'SYSTEM'),
('MODULE_SYSTEM', 'TENANT_SUPPLIER', 'SYSTEM', '系统管理', 'SYSTEM', '系统级管理模块，包含租户管理、模块管理、插件管理等', 'https://system.btc-saas.com', 'https://api.btc-saas.com/system', '1.0.0', 'ACTIVE', 'SYSTEM'),

-- 采购域模块
('MODULE_PROCUREMENT', 'TENANT_INERT', 'PROCUREMENT', '采购域', 'BUSINESS', '采购业务模块，包含供应商管理、采购计划、采购执行等', 'https://procurement.btc-saas.com', 'https://api.btc-saas.com/procurement', '1.0.0', 'ACTIVE', 'SYSTEM'),
('MODULE_PROCUREMENT', 'TENANT_SUPPLIER', 'PROCUREMENT', '采购域', 'BUSINESS', '采购业务模块，包含供应商管理、采购计划、采购执行等', 'https://procurement.btc-saas.com', 'https://api.btc-saas.com/procurement', '1.0.0', 'ACTIVE', 'SYSTEM'),

-- 生产域模块
('MODULE_PRODUCTION', 'TENANT_INERT', 'PRODUCTION', '生产域', 'BUSINESS', '生产业务模块，包含生产计划、工单管理、生产执行等', 'https://production.btc-saas.com', 'https://api.btc-saas.com/production', '1.0.0', 'ACTIVE', 'SYSTEM'),

-- 物流域模块
('MODULE_LOGISTICS', 'TENANT_INERT', 'LOGISTICS', '物流域', 'BUSINESS', '物流业务模块，包含仓库管理、库存管理、配送管理等', 'https://logistics.btc-saas.com', 'https://api.btc-saas.com/logistics', '1.0.0', 'ACTIVE', 'SYSTEM'),

-- 质量域模块
('MODULE_QUALITY', 'TENANT_INERT', 'QUALITY', '质量域', 'BUSINESS', '质量业务模块，包含IQC检验、IPQC巡检、OQC出货等', 'https://quality.btc-saas.com', 'https://api.btc-saas.com/quality', '1.0.0', 'ACTIVE', 'SYSTEM'),

-- 维护域模块
('MODULE_MAINTENANCE', 'TENANT_INERT', 'MAINTENANCE', '维护域', 'BUSINESS', '维护业务模块，包含设备管理、维护计划、故障处理等', 'https://maintenance.btc-saas.com', 'https://api.btc-saas.com/maintenance', '1.0.0', 'ACTIVE', 'SYSTEM'),

-- BI分析模块
('MODULE_BI', 'TENANT_UK_HEAD', 'BI', 'BI分析', 'BUSINESS', 'BI分析模块，包含数据看板、报表分析、实时监控等', 'https://bi.btc-saas.com', 'https://api.btc-saas.com/bi', '1.0.0', 'ACTIVE', 'SYSTEM'),
('MODULE_BI', 'TENANT_INERT', 'BI', 'BI分析', 'BUSINESS', 'BI分析模块，包含数据看板、报表分析、实时监控等', 'https://bi.btc-saas.com', 'https://api.btc-saas.com/bi', '1.0.0', 'ACTIVE', 'SYSTEM');

-- 插入插件数据
INSERT INTO sys_plugin (plugin_id, module_id, tenant_id, plugin_code, plugin_name, plugin_type, description, version, status, created_by) VALUES
-- 采购域插件
('PLUGIN_SUPPLIER', 'MODULE_PROCUREMENT', 'TENANT_INERT', 'SUPPLIER', '供应商管理插件', 'FUNCTION', '供应商信息管理、评价、协同等功能', '1.0.0', 'ACTIVE', 'SYSTEM'),
('PLUGIN_PURCHASE', 'MODULE_PROCUREMENT', 'TENANT_INERT', 'PURCHASE', '采购管理插件', 'FUNCTION', '采购计划、采购执行、合同管理等功能', '1.0.0', 'ACTIVE', 'SYSTEM'),
('PLUGIN_CONTRACT', 'MODULE_PROCUREMENT', 'TENANT_INERT', 'CONTRACT', '合同管理插件', 'FUNCTION', '采购合同管理、审批、执行等功能', '1.0.0', 'ACTIVE', 'SYSTEM'),

-- 生产域插件
('PLUGIN_WORKORDER', 'MODULE_PRODUCTION', 'TENANT_INERT', 'WORKORDER', '工单管理插件', 'FUNCTION', '工单创建、下发、执行、跟踪等功能', '1.0.0', 'ACTIVE', 'SYSTEM'),
('PLUGIN_SCHEDULING', 'MODULE_PRODUCTION', 'TENANT_INERT', 'SCHEDULING', '生产调度插件', 'FUNCTION', '生产计划、资源调度、进度控制等功能', '1.0.0', 'ACTIVE', 'SYSTEM'),
('PLUGIN_MONITORING', 'MODULE_PRODUCTION', 'TENANT_INERT', 'MONITORING', '生产监控插件', 'FUNCTION', '生产状态监控、异常告警、性能分析等功能', '1.0.0', 'ACTIVE', 'SYSTEM'),

-- 质量域插件
('PLUGIN_IQC', 'MODULE_QUALITY', 'TENANT_INERT', 'IQC', 'IQC检验插件', 'FUNCTION', '进料检验、AQL抽样、不合格处理等功能', '1.0.0', 'ACTIVE', 'SYSTEM'),
('PLUGIN_IPQC', 'MODULE_QUALITY', 'TENANT_INERT', 'IPQC', 'IPQC巡检插件', 'FUNCTION', '过程检验、抽检记录、质量问题发现等功能', '1.0.0', 'ACTIVE', 'SYSTEM'),
('PLUGIN_OQC', 'MODULE_QUALITY', 'TENANT_INERT', 'OQC', 'OQC出货插件', 'FUNCTION', '出货检验、AQL抽检、出货放行等功能', '1.0.0', 'ACTIVE', 'SYSTEM'),

-- BI分析插件
('PLUGIN_DASHBOARD', 'MODULE_BI', 'TENANT_UK_HEAD', 'DASHBOARD', '数据看板插件', 'WIDGET', '实时数据看板、关键指标展示、趋势分析等功能', '1.0.0', 'ACTIVE', 'SYSTEM'),
('PLUGIN_REPORT', 'MODULE_BI', 'TENANT_UK_HEAD', 'REPORT', '报表分析插件', 'FUNCTION', '报表生成、数据分析、导出等功能', '1.0.0', 'ACTIVE', 'SYSTEM'),
('PLUGIN_ALERT', 'MODULE_BI', 'TENANT_UK_HEAD', 'ALERT', '告警监控插件', 'FUNCTION', '异常告警、监控配置、通知推送等功能', '1.0.0', 'ACTIVE', 'SYSTEM');

-- 插入基于cool-admin多模块架构的菜单数据
INSERT INTO sys_menu (menu_id, tenant_id, menu_code, menu_name, menu_type, module_code, route_path, component_path, icon, sort_order, access_level, data_scope, operation_type, created_by) VALUES
-- ===== 英国总公司菜单 (BI模块) =====
('MENU_UK_DASHBOARD', 'TENANT_UK_HEAD', 'uk:dashboard', '数据看板', 'MENU', 'BI', '/bi/dashboard', 'bi/dashboard/index', 'dashboard', 1, 'AUTHORIZED', 'ALL', 'READ', 'SYSTEM'),
('MENU_UK_REPORTS', 'TENANT_UK_HEAD', 'uk:reports', '报表中心', 'MENU', 'BI', '/bi/reports', 'bi/reports/index', 'chart', 2, 'AUTHORIZED', 'ALL', 'READ', 'SYSTEM'),
('MENU_UK_BI_ANALYSIS', 'TENANT_UK_HEAD', 'uk:bi:analysis', 'BI分析', 'MENU', 'BI', '/bi/analysis', 'bi/analysis/index', 'analysis', 3, 'AUTHORIZED', 'ALL', 'READ', 'SYSTEM'),
('MENU_UK_SYSTEM_MANAGE', 'TENANT_UK_HEAD', 'uk:system:manage', '系统管理', 'MENU', 'SYSTEM', '/system/manage', 'system/manage/index', 'system', 4, 'AUTHORIZED', 'ALL', 'ADMIN', 'SYSTEM'),

-- ===== 内网用户菜单 =====
-- 系统管理模块菜单
('MENU_INERT_SYSTEM', 'TENANT_INERT', 'inert:system', '系统管理', 'DIRECTORY', 'SYSTEM', '/system', 'Layout', 'system', 1, 'AUTHORIZED', 'TENANT', 'ADMIN', 'SYSTEM'),
('MENU_INERT_SYSTEM_MANAGE', 'TENANT_INERT', 'inert:system:manage', '系统配置', 'MENU', 'SYSTEM', '/system/config', 'system/config/index', 'setting', 1, 'AUTHORIZED', 'TENANT', 'ADMIN', 'SYSTEM'),

-- 采购域模块菜单
('MENU_INERT_PROCUREMENT', 'TENANT_INERT', 'inert:procurement', '采购域', 'DIRECTORY', 'PROCUREMENT', '/procurement', 'Layout', 'shopping', 2, 'AUTHORIZED', 'TENANT', 'WRITE', 'SYSTEM'),
('MENU_INERT_SUPPLIER_MANAGE', 'TENANT_INERT', 'inert:procurement:supplier', '供应商管理', 'MENU', 'PROCUREMENT', '/procurement/supplier', 'procurement/supplier/index', 'team', 1, 'AUTHORIZED', 'TENANT', 'WRITE', 'SYSTEM'),
('MENU_INERT_PURCHASE_PLAN', 'TENANT_INERT', 'inert:procurement:purchase', '采购计划', 'MENU', 'PROCUREMENT', '/procurement/purchase', 'procurement/purchase/index', 'calendar', 2, 'AUTHORIZED', 'TENANT', 'WRITE', 'SYSTEM'),
('MENU_INERT_CONTRACT_MANAGE', 'TENANT_INERT', 'inert:procurement:contract', '合同管理', 'MENU', 'PROCUREMENT', '/procurement/contract', 'procurement/contract/index', 'file-text', 3, 'AUTHORIZED', 'TENANT', 'WRITE', 'SYSTEM'),

-- 生产域模块菜单
('MENU_INERT_PRODUCTION', 'TENANT_INERT', 'inert:production', '生产域', 'DIRECTORY', 'PRODUCTION', '/production', 'Layout', 'production', 3, 'AUTHORIZED', 'TENANT', 'WRITE', 'SYSTEM'),
('MENU_INERT_PRODUCTION_PLAN', 'TENANT_INERT', 'inert:production:plan', '生产计划', 'MENU', 'PRODUCTION', '/production/plan', 'production/plan/index', 'calendar', 1, 'AUTHORIZED', 'TENANT', 'WRITE', 'SYSTEM'),
('MENU_INERT_WORK_ORDER', 'TENANT_INERT', 'inert:production:workorder', '工单管理', 'MENU', 'PRODUCTION', '/production/workorder', 'production/workorder/index', 'document', 2, 'AUTHORIZED', 'TENANT', 'WRITE', 'SYSTEM'),
('MENU_INERT_PRODUCTION_EXECUTE', 'TENANT_INERT', 'inert:production:execute', '生产执行', 'MENU', 'PRODUCTION', '/production/execute', 'production/execute/index', 'play', 3, 'AUTHORIZED', 'TENANT', 'WRITE', 'SYSTEM'),
('MENU_INERT_FAI_MANAGE', 'TENANT_INERT', 'inert:production:fai', '首件验证', 'MENU', 'PRODUCTION', '/production/fai', 'production/fai/index', 'check-circle', 4, 'AUTHORIZED', 'TENANT', 'WRITE', 'SYSTEM'),
('MENU_INERT_TEST_MANAGE', 'TENANT_INERT', 'inert:production:test', '测试管理', 'MENU', 'PRODUCTION', '/production/test', 'production/test/index', 'experiment', 5, 'AUTHORIZED', 'TENANT', 'WRITE', 'SYSTEM'),

-- 物流域模块菜单
('MENU_INERT_LOGISTICS', 'TENANT_INERT', 'inert:logistics', '物流域', 'DIRECTORY', 'LOGISTICS', '/logistics', 'Layout', 'truck', 4, 'AUTHORIZED', 'TENANT', 'WRITE', 'SYSTEM'),
('MENU_INERT_WAREHOUSE_MANAGE', 'TENANT_INERT', 'inert:logistics:warehouse', '仓库管理', 'MENU', 'LOGISTICS', '/logistics/warehouse', 'logistics/warehouse/index', 'warehouse', 1, 'AUTHORIZED', 'TENANT', 'WRITE', 'SYSTEM'),
('MENU_INERT_INVENTORY_MANAGE', 'TENANT_INERT', 'inert:logistics:inventory', '库存管理', 'MENU', 'LOGISTICS', '/logistics/inventory', 'logistics/inventory/index', 'database', 2, 'AUTHORIZED', 'TENANT', 'WRITE', 'SYSTEM'),
('MENU_INERT_DELIVERY_MANAGE', 'TENANT_INERT', 'inert:logistics:delivery', '配送管理', 'MENU', 'LOGISTICS', '/logistics/delivery', 'logistics/delivery/index', 'truck', 3, 'AUTHORIZED', 'TENANT', 'WRITE', 'SYSTEM'),

-- 质量域模块菜单
('MENU_INERT_QUALITY', 'TENANT_INERT', 'inert:quality', '质量域', 'DIRECTORY', 'QUALITY', '/quality', 'Layout', 'quality', 5, 'AUTHORIZED', 'TENANT', 'WRITE', 'SYSTEM'),
('MENU_INERT_IQC_MANAGE', 'TENANT_INERT', 'inert:quality:iqc', 'IQC检验', 'MENU', 'QUALITY', '/quality/iqc', 'quality/iqc/index', 'inbox', 1, 'AUTHORIZED', 'TENANT', 'WRITE', 'SYSTEM'),
('MENU_INERT_IPQC_MANAGE', 'TENANT_INERT', 'inert:quality:ipqc', 'IPQC巡检', 'MENU', 'QUALITY', '/quality/ipqc', 'quality/ipqc/index', 'eye', 2, 'AUTHORIZED', 'TENANT', 'WRITE', 'SYSTEM'),
('MENU_INERT_OQC_MANAGE', 'TENANT_INERT', 'inert:quality:oqc', 'OQC出货', 'MENU', 'QUALITY', '/quality/oqc', 'quality/oqc/index', 'export', 3, 'AUTHORIZED', 'TENANT', 'WRITE', 'SYSTEM'),
('MENU_INERT_QUALITY_ANALYSIS', 'TENANT_INERT', 'inert:quality:analysis', '质量分析', 'MENU', 'QUALITY', '/quality/analysis', 'quality/analysis/index', 'chart', 4, 'AUTHORIZED', 'TENANT', 'READ', 'SYSTEM'),

-- 维护域模块菜单
('MENU_INERT_MAINTENANCE', 'TENANT_INERT', 'inert:maintenance', '维护域', 'DIRECTORY', 'MAINTENANCE', '/maintenance', 'Layout', 'tool', 6, 'AUTHORIZED', 'TENANT', 'WRITE', 'SYSTEM'),
('MENU_INERT_EQUIPMENT_MANAGE', 'TENANT_INERT', 'inert:maintenance:equipment', '设备管理', 'MENU', 'MAINTENANCE', '/maintenance/equipment', 'maintenance/equipment/index', 'setting', 1, 'AUTHORIZED', 'TENANT', 'WRITE', 'SYSTEM'),
('MENU_INERT_MAINTENANCE_PLAN', 'TENANT_INERT', 'inert:maintenance:plan', '维护计划', 'MENU', 'MAINTENANCE', '/maintenance/plan', 'maintenance/plan/index', 'calendar', 2, 'AUTHORIZED', 'TENANT', 'WRITE', 'SYSTEM'),
('MENU_INERT_FAULT_HANDLE', 'TENANT_INERT', 'inert:maintenance:fault', '故障处理', 'MENU', 'MAINTENANCE', '/maintenance/fault', 'maintenance/fault/index', 'warning', 3, 'AUTHORIZED', 'TENANT', 'WRITE', 'SYSTEM'),

-- 追溯分析菜单
('MENU_INERT_TRACE_ANALYSIS', 'TENANT_INERT', 'inert:trace:analysis', '追溯分析', 'MENU', 'BI', '/trace/analysis', 'trace/analysis/index', 'search', 7, 'AUTHORIZED', 'ALL', 'READ', 'SYSTEM'),

-- ===== 供应商群体菜单 =====
-- 采购域模块菜单 (供应商视角)
('MENU_SUPPLIER_PROCUREMENT', 'TENANT_SUPPLIER', 'supplier:procurement', '采购域', 'DIRECTORY', 'PROCUREMENT', '/procurement', 'Layout', 'shopping', 1, 'AUTHORIZED', 'TENANT', 'WRITE', 'SYSTEM'),
('MENU_SUPPLIER_INFO_MANAGE', 'TENANT_SUPPLIER', 'supplier:procurement:info', '信息管理', 'MENU', 'PROCUREMENT', '/procurement/info', 'procurement/info/index', 'user', 1, 'AUTHORIZED', 'TENANT', 'WRITE', 'SYSTEM'),
('MENU_SUPPLIER_ORDER_MANAGE', 'TENANT_SUPPLIER', 'supplier:procurement:order', '订单管理', 'MENU', 'PROCUREMENT', '/procurement/order', 'procurement/order/index', 'file', 2, 'AUTHORIZED', 'TENANT', 'WRITE', 'SYSTEM'),
('MENU_SUPPLIER_DELIVERY_MANAGE', 'TENANT_SUPPLIER', 'supplier:procurement:delivery', '交付管理', 'MENU', 'PROCUREMENT', '/procurement/delivery', 'procurement/delivery/index', 'truck', 3, 'AUTHORIZED', 'TENANT', 'WRITE', 'SYSTEM'),

-- 系统管理菜单
('MENU_SUPPLIER_SYSTEM', 'TENANT_SUPPLIER', 'supplier:system', '系统管理', 'MENU', 'SYSTEM', '/system', 'system/index', 'system', 2, 'AUTHORIZED', 'TENANT', 'READ', 'SYSTEM');

-- 插入用户模块关联数据
INSERT INTO sys_user_module (user_module_id, user_id, module_id, tenant_id, access_level, is_default, auto_redirect, status, created_by) VALUES
-- 英国总公司用户模块关联
('USER_MODULE_UK_001', 'USER_UK_ADMIN', 'MODULE_SYSTEM', 'TENANT_UK_HEAD', 'ADMIN', FALSE, TRUE, 'ACTIVE', 'SYSTEM'),
('USER_MODULE_UK_002', 'USER_UK_ADMIN', 'MODULE_BI', 'TENANT_UK_HEAD', 'ADMIN', TRUE, TRUE, 'ACTIVE', 'SYSTEM'),
('USER_MODULE_UK_003', 'USER_UK_LEADER', 'MODULE_BI', 'TENANT_UK_HEAD', 'READ', TRUE, TRUE, 'ACTIVE', 'SYSTEM'),

-- 内网用户模块关联
('USER_MODULE_INERT_001', 'USER_INERT_ADMIN', 'MODULE_SYSTEM', 'TENANT_INERT', 'ADMIN', FALSE, TRUE, 'ACTIVE', 'SYSTEM'),
('USER_MODULE_INERT_002', 'USER_INERT_ADMIN', 'MODULE_PROCUREMENT', 'TENANT_INERT', 'ADMIN', FALSE, TRUE, 'ACTIVE', 'SYSTEM'),
('USER_MODULE_INERT_003', 'USER_INERT_ADMIN', 'MODULE_PRODUCTION', 'TENANT_INERT', 'ADMIN', FALSE, TRUE, 'ACTIVE', 'SYSTEM'),
('USER_MODULE_INERT_004', 'USER_INERT_ADMIN', 'MODULE_LOGISTICS', 'TENANT_INERT', 'ADMIN', FALSE, TRUE, 'ACTIVE', 'SYSTEM'),
('USER_MODULE_INERT_005', 'USER_INERT_ADMIN', 'MODULE_QUALITY', 'TENANT_INERT', 'ADMIN', FALSE, TRUE, 'ACTIVE', 'SYSTEM'),
('USER_MODULE_INERT_006', 'USER_INERT_ADMIN', 'MODULE_MAINTENANCE', 'TENANT_INERT', 'ADMIN', FALSE, TRUE, 'ACTIVE', 'SYSTEM'),
('USER_MODULE_INERT_007', 'USER_INERT_ADMIN', 'MODULE_BI', 'TENANT_INERT', 'ADMIN', TRUE, TRUE, 'ACTIVE', 'SYSTEM'),
-- 工程部门用户模块关联
('USER_MODULE_INERT_009', 'USER_INERT_ENGINEER', 'MODULE_PRODUCTION', 'TENANT_INERT', 'WRITE', TRUE, TRUE, 'ACTIVE', 'SYSTEM'),
('USER_MODULE_INERT_010', 'USER_INERT_ENGINEER_LEADER', 'MODULE_PRODUCTION', 'TENANT_INERT', 'ADMIN', FALSE, TRUE, 'ACTIVE', 'SYSTEM'),

-- 品质部门用户模块关联
('USER_MODULE_INERT_011', 'USER_INERT_QC_INSPECTOR', 'MODULE_QUALITY', 'TENANT_INERT', 'WRITE', TRUE, TRUE, 'ACTIVE', 'SYSTEM'),
('USER_MODULE_INERT_012', 'USER_INERT_QC_MANAGER', 'MODULE_QUALITY', 'TENANT_INERT', 'ADMIN', FALSE, TRUE, 'ACTIVE', 'SYSTEM'),

-- 生产部门用户模块关联
('USER_MODULE_INERT_013', 'USER_INERT_PRODUCTION_OPERATOR', 'MODULE_PRODUCTION', 'TENANT_INERT', 'WRITE', TRUE, TRUE, 'ACTIVE', 'SYSTEM'),
('USER_MODULE_INERT_014', 'USER_INERT_PRODUCTION_MANAGER', 'MODULE_PRODUCTION', 'TENANT_INERT', 'ADMIN', FALSE, TRUE, 'ACTIVE', 'SYSTEM'),

-- 物流部门用户模块关联
('USER_MODULE_INERT_015', 'USER_INERT_LOGISTICS_OPERATOR', 'MODULE_LOGISTICS', 'TENANT_INERT', 'WRITE', TRUE, TRUE, 'ACTIVE', 'SYSTEM'),
('USER_MODULE_INERT_016', 'USER_INERT_LOGISTICS_MANAGER', 'MODULE_LOGISTICS', 'TENANT_INERT', 'ADMIN', FALSE, TRUE, 'ACTIVE', 'SYSTEM'),

-- 供应商用户模块关联
('USER_MODULE_SUPPLIER_001', 'USER_SUPPLIER_ADMIN', 'MODULE_SYSTEM', 'TENANT_SUPPLIER', 'READ', FALSE, TRUE, 'ACTIVE', 'SYSTEM'),
('USER_MODULE_SUPPLIER_002', 'USER_SUPPLIER_ADMIN', 'MODULE_PROCUREMENT', 'TENANT_SUPPLIER', 'WRITE', TRUE, TRUE, 'ACTIVE', 'SYSTEM');

-- 设置基于cool-admin多模块架构的菜单层级关系
-- 内网用户系统管理菜单层级
UPDATE sys_menu SET parent_id = 'MENU_INERT_SYSTEM' WHERE menu_id = 'MENU_INERT_SYSTEM_MANAGE';

-- 内网用户采购域菜单层级
UPDATE sys_menu SET parent_id = 'MENU_INERT_PROCUREMENT' WHERE menu_id IN ('MENU_INERT_SUPPLIER_MANAGE', 'MENU_INERT_PURCHASE_PLAN', 'MENU_INERT_CONTRACT_MANAGE');

-- 内网用户生产域菜单层级
UPDATE sys_menu SET parent_id = 'MENU_INERT_PRODUCTION' WHERE menu_id IN ('MENU_INERT_PRODUCTION_PLAN', 'MENU_INERT_WORK_ORDER', 'MENU_INERT_PRODUCTION_EXECUTE', 'MENU_INERT_FAI_MANAGE', 'MENU_INERT_TEST_MANAGE');

-- 内网用户物流域菜单层级
UPDATE sys_menu SET parent_id = 'MENU_INERT_LOGISTICS' WHERE menu_id IN ('MENU_INERT_WAREHOUSE_MANAGE', 'MENU_INERT_INVENTORY_MANAGE', 'MENU_INERT_DELIVERY_MANAGE');

-- 内网用户质量域菜单层级
UPDATE sys_menu SET parent_id = 'MENU_INERT_QUALITY' WHERE menu_id IN ('MENU_INERT_IQC_MANAGE', 'MENU_INERT_IPQC_MANAGE', 'MENU_INERT_OQC_MANAGE', 'MENU_INERT_QUALITY_ANALYSIS');

-- 内网用户维护域菜单层级
UPDATE sys_menu SET parent_id = 'MENU_INERT_MAINTENANCE' WHERE menu_id IN ('MENU_INERT_EQUIPMENT_MANAGE', 'MENU_INERT_MAINTENANCE_PLAN', 'MENU_INERT_FAULT_HANDLE');

-- 供应商采购域菜单层级
UPDATE sys_menu SET parent_id = 'MENU_SUPPLIER_PROCUREMENT' WHERE menu_id IN ('MENU_SUPPLIER_INFO_MANAGE', 'MENU_SUPPLIER_ORDER_MANAGE', 'MENU_SUPPLIER_DELIVERY_MANAGE');
('MENU_INERT_WORK_ORDER', 'PERM_INERT_WORK_ORDER', 'REQUIRED', 'SYSTEM'),
('MENU_INERT_PRODUCTION_EXECUTE', 'PERM_INERT_PRODUCTION_EXECUTE', 'REQUIRED', 'SYSTEM'),
('MENU_INERT_FAI_MANAGE', 'PERM_INERT_FAI_MANAGE', 'REQUIRED', 'SYSTEM'),
('MENU_INERT_TEST_MANAGE', 'PERM_INERT_TEST_MANAGE', 'REQUIRED', 'SYSTEM'),

-- 质量管理菜单权限
('MENU_INERT_QUALITY', 'PERM_INERT_QUALITY_MANAGE', 'REQUIRED', 'SYSTEM'),
('MENU_INERT_IQC_MANAGE', 'PERM_INERT_IQC_MANAGE', 'REQUIRED', 'SYSTEM'),
('MENU_INERT_IPQC_MANAGE', 'PERM_INERT_IPQC_MANAGE', 'REQUIRED', 'SYSTEM'),
('MENU_INERT_OQC_MANAGE', 'PERM_INERT_OQC_MANAGE', 'REQUIRED', 'SYSTEM'),
('MENU_INERT_QUALITY_MANAGE', 'PERM_INERT_QUALITY_MANAGE', 'REQUIRED', 'SYSTEM'),

-- 仓储物流菜单权限
('MENU_INERT_WAREHOUSE', 'PERM_INERT_WAREHOUSE_MANAGE', 'REQUIRED', 'SYSTEM'),
('MENU_INERT_MATERIAL_MANAGE', 'PERM_INERT_MATERIAL_MANAGE', 'REQUIRED', 'SYSTEM'),
('MENU_INERT_INVENTORY_MANAGE', 'PERM_INERT_INVENTORY_MANAGE', 'REQUIRED', 'SYSTEM'),
('MENU_INERT_WAREHOUSE_MANAGE', 'PERM_INERT_WAREHOUSE_MANAGE', 'REQUIRED', 'SYSTEM'),

-- 维护管理菜单权限
('MENU_INERT_MAINTENANCE', 'PERM_INERT_MAINTENANCE_MANAGE', 'REQUIRED', 'SYSTEM'),
('MENU_INERT_MAINTENANCE_MANAGE', 'PERM_INERT_MAINTENANCE_MANAGE', 'REQUIRED', 'SYSTEM'),
('MENU_INERT_MAINTENANCE_EXECUTE', 'PERM_INERT_MAINTENANCE_EXECUTE', 'REQUIRED', 'SYSTEM'),

-- 追溯分析菜单权限
('MENU_INERT_TRACE_ANALYSIS', 'PERM_INERT_TRACE_ANALYSIS', 'REQUIRED', 'SYSTEM'),

-- 系统管理菜单权限
('MENU_INERT_SYSTEM_MANAGE', 'PERM_INERT_SYSTEM_MANAGE', 'REQUIRED', 'SYSTEM'),

-- ===== 供应商群体菜单权限 =====
-- 模具管理菜单权限
('MENU_SUPPLIER_MOLD', 'PERM_SUPPLIER_MOLD_MANAGE', 'REQUIRED', 'SYSTEM'),
('MENU_SUPPLIER_MOLD_MANAGE', 'PERM_SUPPLIER_MOLD_MANAGE', 'REQUIRED', 'SYSTEM'),
('MENU_SUPPLIER_MOLD_UPDATE', 'PERM_SUPPLIER_MOLD_UPDATE', 'REQUIRED', 'SYSTEM'),

-- 原材料管理菜单权限
('MENU_SUPPLIER_RAW', 'PERM_SUPPLIER_RAW_MANAGE', 'REQUIRED', 'SYSTEM'),
('MENU_SUPPLIER_RAW_MANAGE', 'PERM_SUPPLIER_RAW_MANAGE', 'REQUIRED', 'SYSTEM'),
('MENU_SUPPLIER_RAW_IQC', 'PERM_SUPPLIER_RAW_IQC', 'REQUIRED', 'SYSTEM');

-- 关联基于流程树的用户角色
INSERT INTO sys_user_role (user_id, role_id, created_by)
VALUES 
-- === 英国总公司用户角色 ===
('USER_58', 'ROLE_UK_READONLY_USER', 'SYSTEM'),

-- === 内网用户角色 (TENANT_INERT) ===
-- 管理层
('USER_1', 'ROLE_INERT_CEO', 'SYSTEM'),

-- 财务部门
('USER_11', 'ROLE_INERT_FINANCE_MANAGER', 'SYSTEM'),
('USER_12', 'ROLE_INERT_FINANCE_SUPERVISOR', 'SYSTEM'),
('USER_13', 'ROLE_INERT_FINANCE_SPECIALIST', 'SYSTEM'),
('USER_14', 'ROLE_INERT_FINANCE_SPECIALIST', 'SYSTEM'),

-- 人事部门
('USER_15', 'ROLE_INERT_HR_SUPERVISOR', 'SYSTEM'),
('USER_16', 'ROLE_INERT_HR_SPECIALIST', 'SYSTEM'),

-- 物流部门
('USER_2', 'ROLE_INERT_LOGISTICS_MANAGER', 'SYSTEM'),
('USER_3', 'ROLE_INERT_CUSTOMS_SPECIALIST', 'SYSTEM'),
('USER_4', 'ROLE_INERT_CUSTOMS_SPECIALIST', 'SYSTEM'),
('USER_10', 'ROLE_INERT_WAREHOUSE_SUPERVISOR', 'SYSTEM'),

-- 采购部门
('USER_5', 'ROLE_INERT_PROCUREMENT_MANAGER', 'SYSTEM'),
('USER_6', 'ROLE_INERT_PROCUREMENT_ECN_SPECIALIST', 'SYSTEM'),
('USER_7', 'ROLE_INERT_PROCUREMENT_SPECIALIST', 'SYSTEM'),
('USER_8', 'ROLE_INERT_PROCUREMENT_AUXMAT_SPECIALIST', 'SYSTEM'),
('USER_9', 'ROLE_INERT_PROCUREMENT_PACKAGE_SPECIALIST', 'SYSTEM'),

-- 生产部门
('USER_17', 'ROLE_INERT_PRODUCTION_MANAGER', 'SYSTEM'),
('USER_18', 'ROLE_INERT_PRODUCTION_SHIPPING_SUPERVISOR', 'SYSTEM'),
('USER_19', 'ROLE_INERT_PRODUCTION_WORKSHOP_SUPERVISOR', 'SYSTEM'),
('USER_20', 'ROLE_INERT_PRODUCTION_LEADER', 'SYSTEM'),
('USER_21', 'ROLE_INERT_PRODUCTION_GROUP_LEADER', 'SYSTEM'),
('USER_22', 'ROLE_INERT_PRODUCTION_GROUP_LEADER', 'SYSTEM'),
('USER_23', 'ROLE_INERT_PRODUCTION_GROUP_LEADER', 'SYSTEM'),
('USER_24', 'ROLE_INERT_PRODUCTION_ENGINEER', 'SYSTEM'),
('USER_25', 'ROLE_INERT_PRODUCTION_AUTOMATION_ENGINEER', 'SYSTEM'),
('USER_26', 'ROLE_INERT_PRODUCTION_AUTOMATION_ENGINEER', 'SYSTEM'),
('USER_27', 'ROLE_INERT_PRODUCTION_CLERK', 'SYSTEM'),
('USER_28', 'ROLE_INERT_PRODUCTION_CLERK', 'SYSTEM'),
('USER_29', 'ROLE_INERT_PRODUCTION_CLERK', 'SYSTEM'),

-- 工程部门
('USER_30', 'ROLE_INERT_ENGINEERING_MANAGER', 'SYSTEM'),
('USER_31', 'ROLE_INERT_ENGINEERING_SUPERVISOR', 'SYSTEM'),
('USER_32', 'ROLE_INERT_NPD_ENGINEER', 'SYSTEM'),
('USER_33', 'ROLE_INERT_NPD_ENGINEER', 'SYSTEM'),
('USER_34', 'ROLE_INERT_NPD_ENGINEER', 'SYSTEM'),
('USER_35', 'ROLE_INERT_NPD_ENGINEER', 'SYSTEM'),
('USER_36', 'ROLE_INERT_NPD_ENGINEER', 'SYSTEM'),
('USER_37', 'ROLE_INERT_NPD_ENGINEER', 'SYSTEM'),
('USER_38', 'ROLE_INERT_MOLD_ENGINEER', 'SYSTEM'),
('USER_39', 'ROLE_INERT_MOLD_ENGINEER', 'SYSTEM'),
('USER_40', 'ROLE_INERT_PROCESS_ENGINEER', 'SYSTEM'),
('USER_41', 'ROLE_INERT_PROCESS_ENGINEER', 'SYSTEM'),
('USER_42', 'ROLE_INERT_PROCESS_ENGINEER', 'SYSTEM'),

-- 品质部门
('USER_43', 'ROLE_INERT_QUALITY_MANAGER', 'SYSTEM'),
('USER_50', 'ROLE_INERT_QUALITY_SUPERVISOR', 'SYSTEM'),
('USER_46', 'ROLE_INERT_FAI_SPECIALIST', 'SYSTEM'),
('USER_51', 'ROLE_INERT_IQC_SPECIALIST', 'SYSTEM'),
('USER_53', 'ROLE_INERT_IQC_SPECIALIST', 'SYSTEM'),
('USER_54', 'ROLE_INERT_IQC_SPECIALIST', 'SYSTEM'),
('USER_55', 'ROLE_INERT_IQC_SPECIALIST', 'SYSTEM'),
('USER_56', 'ROLE_INERT_IPQC_SPECIALIST', 'SYSTEM'),
('USER_52', 'ROLE_INERT_QUALITY_EXTERNAL_SPECIALIST', 'SYSTEM'),
('USER_49', 'ROLE_INERT_QUALITY_REPAIR_SPECIALIST', 'SYSTEM'),
('USER_57', 'ROLE_INERT_QUALITY_CLERK', 'SYSTEM'),

-- 维修部门
('USER_48', 'ROLE_INERT_MAINTENANCE_SUPERVISOR', 'SYSTEM'),

-- IT部门
('USER_44', 'ROLE_INERT_IT_ENGINEER', 'SYSTEM'),
('USER_45', 'ROLE_INERT_IT_DEVELOPER', 'SYSTEM'),
('USER_47', 'ROLE_INERT_IT_OPS_SPECIALIST', 'SYSTEM'),

-- 多对多关系 - 追溯分析师兼任
('USER_43', 'ROLE_INERT_TRACE_ANALYST', 'SYSTEM'),

-- 多对多关系 - IT经理兼任
('USER_44', 'ROLE_INERT_IT_MANAGER', 'SYSTEM'),

-- === 供应商用户角色 (TENANT_SUPPLIER) - 52人 ===
-- 所有供应商用户统一分配原材料查看者角色
('USER_59', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_60', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_61', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_62', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_63', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_64', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_65', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_66', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_67', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_68', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_69', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_70', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_71', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_72', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_73', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_74', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_75', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_76', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_77', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_78', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_79', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_80', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_81', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_82', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_83', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_84', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_85', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_86', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_87', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_88', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_89', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_90', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_91', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_92', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_93', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_94', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_95', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_96', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_97', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_98', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_99', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_100', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_101', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_102', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_103', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_104', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_105', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_106', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_107', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_108', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_109', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM'),
('USER_110', 'ROLE_SUPPLIER_MATERIAL_VIEWER', 'SYSTEM');

-- 为基于流程树的角色分配权限
INSERT INTO sys_role_permission (role_id, permission_id, created_by)
VALUES 
-- ===== 英国总公司角色权限 =====
-- 执行层权限
('ROLE_UK_EXECUTIVE', 'PERM_UK_DATA_VIEW', 'SYSTEM'),
('ROLE_UK_EXECUTIVE', 'PERM_UK_REPORT_VIEW', 'SYSTEM'),
('ROLE_UK_EXECUTIVE', 'PERM_UK_BI_ANALYSIS', 'SYSTEM'),

-- 总监层权限
('ROLE_UK_DIRECTOR', 'PERM_UK_DATA_VIEW', 'SYSTEM'),
('ROLE_UK_DIRECTOR', 'PERM_UK_REPORT_VIEW', 'SYSTEM'),

-- 运营经理权限
('ROLE_UK_OPERATIONS_MANAGER', 'PERM_UK_DATA_VIEW', 'SYSTEM'),
('ROLE_UK_OPERATIONS_MANAGER', 'PERM_UK_BI_ANALYSIS', 'SYSTEM'),

-- BI分析师权限
('ROLE_UK_BI_ANALYST', 'PERM_UK_DATA_VIEW', 'SYSTEM'),
('ROLE_UK_BI_ANALYST', 'PERM_UK_REPORT_VIEW', 'SYSTEM'),
('ROLE_UK_BI_ANALYST', 'PERM_UK_BI_ANALYSIS', 'SYSTEM'),

-- IT管理员权限
('ROLE_UK_IT_ADMIN', 'PERM_UK_SYSTEM_MANAGE', 'SYSTEM'),
('ROLE_UK_IT_ADMIN', 'PERM_UK_DATA_VIEW', 'SYSTEM'),

-- 查看者权限
('ROLE_UK_VIEWER', 'PERM_UK_DATA_VIEW', 'SYSTEM'),

-- ===== 内网用户角色权限 =====
-- 生产管理角色权限
('ROLE_INERT_PRODUCTION_MANAGER', 'PERM_INERT_PRODUCTION_PLAN', 'SYSTEM'),
('ROLE_INERT_PRODUCTION_MANAGER', 'PERM_INERT_WORK_ORDER', 'SYSTEM'),
('ROLE_INERT_PRODUCTION_MANAGER', 'PERM_INERT_PRODUCTION_EXECUTE', 'SYSTEM'),

('ROLE_INERT_PLANNING_ENGINEER', 'PERM_INERT_PRODUCTION_PLAN', 'SYSTEM'),
('ROLE_INERT_PLANNING_ENGINEER', 'PERM_INERT_WORK_ORDER', 'SYSTEM'),

('ROLE_INERT_WORK_ORDER_CONTROLLER', 'PERM_INERT_WORK_ORDER', 'SYSTEM'),

('ROLE_INERT_PRODUCTION_OPERATOR', 'PERM_INERT_PRODUCTION_EXECUTE', 'SYSTEM'),
('ROLE_INERT_PRODUCTION_OPERATOR', 'PERM_INERT_TEST_MANAGE', 'SYSTEM'),

('ROLE_INERT_FAI_OPERATOR', 'PERM_INERT_FAI_MANAGE', 'SYSTEM'),

('ROLE_INERT_TEST_OPERATOR', 'PERM_INERT_TEST_MANAGE', 'SYSTEM'),

-- 质量管理角色权限
('ROLE_INERT_QUALITY_MANAGER', 'PERM_INERT_QUALITY_MANAGE', 'SYSTEM'),
('ROLE_INERT_QUALITY_MANAGER', 'PERM_INERT_IQC_MANAGE', 'SYSTEM'),
('ROLE_INERT_QUALITY_MANAGER', 'PERM_INERT_IPQC_MANAGE', 'SYSTEM'),
('ROLE_INERT_QUALITY_MANAGER', 'PERM_INERT_OQC_MANAGE', 'SYSTEM'),

('ROLE_INERT_IQC_INSPECTOR', 'PERM_INERT_IQC_MANAGE', 'SYSTEM'),

('ROLE_INERT_IPQC_INSPECTOR', 'PERM_INERT_IPQC_MANAGE', 'SYSTEM'),

('ROLE_INERT_OQC_INSPECTOR', 'PERM_INERT_OQC_MANAGE', 'SYSTEM'),

-- 仓储物流角色权限
('ROLE_INERT_WAREHOUSE_MANAGER', 'PERM_INERT_WAREHOUSE_MANAGE', 'SYSTEM'),
('ROLE_INERT_WAREHOUSE_MANAGER', 'PERM_INERT_MATERIAL_MANAGE', 'SYSTEM'),
('ROLE_INERT_WAREHOUSE_MANAGER', 'PERM_INERT_INVENTORY_MANAGE', 'SYSTEM'),

('ROLE_INERT_MATERIAL_HANDLER', 'PERM_INERT_MATERIAL_MANAGE', 'SYSTEM'),

('ROLE_INERT_INVENTORY_CONTROLLER', 'PERM_INERT_INVENTORY_MANAGE', 'SYSTEM'),

-- 维护管理角色权限
('ROLE_INERT_MAINTENANCE_MANAGER', 'PERM_INERT_MAINTENANCE_MANAGE', 'SYSTEM'),

('ROLE_INERT_MAINTENANCE_TECHNICIAN', 'PERM_INERT_MAINTENANCE_EXECUTE', 'SYSTEM'),

-- 追溯分析角色权限
('ROLE_INERT_TRACE_ANALYST', 'PERM_INERT_TRACE_ANALYSIS', 'SYSTEM'),
('ROLE_INERT_TRACE_ANALYST', 'PERM_INERT_IQC_MANAGE', 'SYSTEM'),
('ROLE_INERT_TRACE_ANALYST', 'PERM_INERT_OQC_MANAGE', 'SYSTEM'),

-- 系统管理角色权限
('ROLE_INERT_SYSTEM_ADMIN', 'PERM_INERT_SYSTEM_MANAGE', 'SYSTEM'),

-- ===== 供应商群体角色权限 =====
-- 模具供应商角色权限
('ROLE_SUPPLIER_MOLD_MANAGER', 'PERM_SUPPLIER_MOLD_MANAGE', 'SYSTEM'),
('ROLE_SUPPLIER_MOLD_MANAGER', 'PERM_SUPPLIER_MOLD_UPDATE', 'SYSTEM'),

('ROLE_SUPPLIER_MOLD_OPERATOR', 'PERM_SUPPLIER_MOLD_UPDATE', 'SYSTEM'),

-- 原材料供应商角色权限
('ROLE_SUPPLIER_RAW_MANAGER', 'PERM_SUPPLIER_RAW_MANAGE', 'SYSTEM'),
('ROLE_SUPPLIER_RAW_MANAGER', 'PERM_SUPPLIER_RAW_IQC', 'SYSTEM'),

('ROLE_SUPPLIER_RAW_OPERATOR', 'PERM_SUPPLIER_RAW_IQC', 'SYSTEM');

-- 设置部门负责人
UPDATE sys_dept SET manager_id = 'USER_UK_ADMIN' WHERE dept_id = 'DEPT_UK_HEAD';
UPDATE sys_dept SET manager_id = 'USER_UK_LEADER' WHERE dept_id = 'DEPT_UK_LEADERSHIP';
UPDATE sys_dept SET manager_id = 'USER_INERT_ADMIN' WHERE dept_id = 'DEPT_INERT_PRODUCTION';
UPDATE sys_dept SET manager_id = 'USER_SUPPLIER_ADMIN' WHERE dept_id = 'DEPT_SUPPLIER_MOLD';
CALL UpdateRoleLevels();