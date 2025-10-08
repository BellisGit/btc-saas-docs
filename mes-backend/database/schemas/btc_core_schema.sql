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

-- 内网用户四个核心部门
('DEPT_INERT_ENGINEERING', 'TENANT_INERT', 'ENGINEERING', '工程部门', 'DEPARTMENT', 1, 'SYSTEM'),
('DEPT_INERT_QUALITY', 'TENANT_INERT', 'QUALITY', '品质部门', 'DEPARTMENT', 2, 'SYSTEM'),
('DEPT_INERT_PRODUCTION', 'TENANT_INERT', 'PRODUCTION', '生产部门', 'DEPARTMENT', 3, 'SYSTEM'),
('DEPT_INERT_LOGISTICS', 'TENANT_INERT', 'LOGISTICS', '物流部门', 'DEPARTMENT', 4, 'SYSTEM'),

-- 供应商群体部门
('DEPT_SUPPLIER_MOLD', 'TENANT_SUPPLIER', 'MOLD_SUPPLIER', '模具供应商', 'DEPARTMENT', 1, 'SYSTEM'),
('DEPT_SUPPLIER_RAW', 'TENANT_SUPPLIER', 'RAW_MATERIAL', '原材料供应商', 'DEPARTMENT', 2, 'SYSTEM');

-- 为每个租户插入管理员用户
INSERT INTO sys_user (user_id, tenant_id, dept_id, username, password_hash, real_name, user_type, status, created_by)
VALUES 
-- 英国总公司管理员
('USER_UK_ADMIN', 'TENANT_UK_HEAD', 'DEPT_UK_HEAD', 'uk_admin', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '英国IT管理员', 'SYSTEM', 'ACTIVE', 'SYSTEM'),
('USER_UK_LEADER', 'TENANT_UK_HEAD', 'DEPT_UK_LEADERSHIP', 'uk_leader', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '英国领导', 'READONLY', 'ACTIVE', 'SYSTEM'),

-- 内网用户 - 按四个核心部门分配
-- 工程部门
('USER_INERT_ENGINEER', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'inert_engineer', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '工程工程师', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_INERT_ENGINEER_LEADER', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'inert_eng_leader', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '工程部门主管', 'MANAGER', 'ACTIVE', 'SYSTEM'),

-- 品质部门
('USER_INERT_QC_INSPECTOR', 'TENANT_INERT', 'DEPT_INERT_QUALITY', 'inert_qc_inspector', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '品质检验员', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_INERT_QC_MANAGER', 'TENANT_INERT', 'DEPT_INERT_QUALITY', 'inert_qc_manager', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '品质经理', 'MANAGER', 'ACTIVE', 'SYSTEM'),

-- 生产部门
('USER_INERT_PRODUCTION_OPERATOR', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'inert_prod_operator', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '生产操作员', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_INERT_PRODUCTION_MANAGER', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'inert_prod_manager', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '生产经理', 'MANAGER', 'ACTIVE', 'SYSTEM'),

-- 物流部门
('USER_INERT_LOGISTICS_OPERATOR', 'TENANT_INERT', 'DEPT_INERT_LOGISTICS', 'inert_log_operator', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '物流操作员', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_INERT_LOGISTICS_MANAGER', 'TENANT_INERT', 'DEPT_INERT_LOGISTICS', 'inert_log_manager', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '物流经理', 'MANAGER', 'ACTIVE', 'SYSTEM'),

-- 内网系统管理员
('USER_INERT_ADMIN', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'inert_admin', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '内网系统管理员', 'SYSTEM', 'ACTIVE', 'SYSTEM'),

-- 供应商管理员
('USER_SUPPLIER_ADMIN', 'TENANT_SUPPLIER', 'DEPT_SUPPLIER_MOLD', 'supplier_admin', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '供应商管理员', 'SUPPLIER', 'ACTIVE', 'SYSTEM');

-- 插入基于流程树的角色数据
INSERT INTO sys_role (role_id, tenant_id, parent_role_id, role_code, role_name, role_type, role_level, data_scope, inherit_permissions, inherit_data_scope, created_by) VALUES
-- ===== 英国总公司角色体系 =====
-- 战略决策层
('ROLE_UK_EXECUTIVE', 'TENANT_UK_HEAD', NULL, 'UK_EXECUTIVE', '英国执行层', 'SYSTEM', 1, 'ALL', FALSE, FALSE, 'SYSTEM'),
('ROLE_UK_DIRECTOR', 'TENANT_UK_HEAD', 'ROLE_UK_EXECUTIVE', 'UK_DIRECTOR', '英国总监层', 'SYSTEM', 2, 'ALL', TRUE, TRUE, 'SYSTEM'),

-- 运营管理层
('ROLE_UK_OPERATIONS_MANAGER', 'TENANT_UK_HEAD', 'ROLE_UK_DIRECTOR', 'UK_OPERATIONS_MANAGER', '英国运营经理', 'NORMAL', 3, 'ALL', TRUE, TRUE, 'SYSTEM'),
('ROLE_UK_BI_ANALYST', 'TENANT_UK_HEAD', 'ROLE_UK_OPERATIONS_MANAGER', 'UK_BI_ANALYST', '英国BI分析师', 'NORMAL', 4, 'ALL', TRUE, TRUE, 'SYSTEM'),

-- 技术支持层
('ROLE_UK_IT_ADMIN', 'TENANT_UK_HEAD', 'ROLE_UK_OPERATIONS_MANAGER', 'UK_IT_ADMIN', '英国IT管理员', 'SYSTEM', 4, 'ALL', TRUE, TRUE, 'SYSTEM'),
('ROLE_UK_VIEWER', 'TENANT_UK_HEAD', 'ROLE_UK_BI_ANALYST', 'UK_VIEWER', '英国查看者', 'READONLY', 5, 'ALL', TRUE, TRUE, 'SYSTEM'),

-- ===== 内网用户角色体系 =====
-- 生产管理层
('ROLE_INERT_PRODUCTION_MANAGER', 'TENANT_INERT', NULL, 'INERT_PRODUCTION_MANAGER', '生产经理', 'NORMAL', 1, 'DEPT_AND_CHILD', FALSE, FALSE, 'SYSTEM'),
('ROLE_INERT_PLANNING_ENGINEER', 'TENANT_INERT', 'ROLE_INERT_PRODUCTION_MANAGER', 'INERT_PLANNING_ENGINEER', '计划工程师', 'NORMAL', 2, 'DEPT', TRUE, TRUE, 'SYSTEM'),
('ROLE_INERT_WORK_ORDER_CONTROLLER', 'TENANT_INERT', 'ROLE_INERT_PLANNING_ENGINEER', 'INERT_WORK_ORDER_CONTROLLER', '工单控制员', 'NORMAL', 3, 'DEPT', TRUE, TRUE, 'SYSTEM'),

-- 质量管理层
('ROLE_INERT_QUALITY_MANAGER', 'TENANT_INERT', NULL, 'INERT_QUALITY_MANAGER', '质量经理', 'NORMAL', 1, 'DEPT_AND_CHILD', FALSE, FALSE, 'SYSTEM'),
('ROLE_INERT_IQC_INSPECTOR', 'TENANT_INERT', 'ROLE_INERT_QUALITY_MANAGER', 'INERT_IQC_INSPECTOR', 'IQC检验员', 'NORMAL', 2, 'DEPT', TRUE, TRUE, 'SYSTEM'),
('ROLE_INERT_IPQC_INSPECTOR', 'TENANT_INERT', 'ROLE_INERT_QUALITY_MANAGER', 'INERT_IPQC_INSPECTOR', 'IPQC巡检员', 'NORMAL', 2, 'DEPT', TRUE, TRUE, 'SYSTEM'),
('ROLE_INERT_OQC_INSPECTOR', 'TENANT_INERT', 'ROLE_INERT_QUALITY_MANAGER', 'INERT_OQC_INSPECTOR', 'OQC检验员', 'NORMAL', 2, 'DEPT', TRUE, TRUE, 'SYSTEM'),

-- 仓储物流层
('ROLE_INERT_WAREHOUSE_MANAGER', 'TENANT_INERT', NULL, 'INERT_WAREHOUSE_MANAGER', '仓库经理', 'NORMAL', 1, 'DEPT_AND_CHILD', FALSE, FALSE, 'SYSTEM'),
('ROLE_INERT_MATERIAL_HANDLER', 'TENANT_INERT', 'ROLE_INERT_WAREHOUSE_MANAGER', 'INERT_MATERIAL_HANDLER', '物料管理员', 'NORMAL', 2, 'DEPT', TRUE, TRUE, 'SYSTEM'),
('ROLE_INERT_INVENTORY_CONTROLLER', 'TENANT_INERT', 'ROLE_INERT_WAREHOUSE_MANAGER', 'INERT_INVENTORY_CONTROLLER', '盘点员', 'NORMAL', 2, 'DEPT', TRUE, TRUE, 'SYSTEM'),

-- 生产执行层
('ROLE_INERT_PRODUCTION_OPERATOR', 'TENANT_INERT', 'ROLE_INERT_PRODUCTION_MANAGER', 'INERT_PRODUCTION_OPERATOR', '生产操作员', 'NORMAL', 2, 'DEPT', TRUE, TRUE, 'SYSTEM'),
('ROLE_INERT_FAI_OPERATOR', 'TENANT_INERT', 'ROLE_INERT_PRODUCTION_OPERATOR', 'INERT_FAI_OPERATOR', '首件验证员', 'NORMAL', 3, 'DEPT', TRUE, TRUE, 'SYSTEM'),
('ROLE_INERT_TEST_OPERATOR', 'TENANT_INERT', 'ROLE_INERT_PRODUCTION_OPERATOR', 'INERT_TEST_OPERATOR', '测试操作员', 'NORMAL', 3, 'DEPT', TRUE, TRUE, 'SYSTEM'),

-- 维护支持层
('ROLE_INERT_MAINTENANCE_MANAGER', 'TENANT_INERT', NULL, 'INERT_MAINTENANCE_MANAGER', '维护经理', 'NORMAL', 1, 'DEPT_AND_CHILD', FALSE, FALSE, 'SYSTEM'),
('ROLE_INERT_MAINTENANCE_TECHNICIAN', 'TENANT_INERT', 'ROLE_INERT_MAINTENANCE_MANAGER', 'INERT_MAINTENANCE_TECHNICIAN', '维护技师', 'NORMAL', 2, 'DEPT', TRUE, TRUE, 'SYSTEM'),

-- 追溯分析层
('ROLE_INERT_TRACE_ANALYST', 'TENANT_INERT', 'ROLE_INERT_QUALITY_MANAGER', 'INERT_TRACE_ANALYST', '追溯分析师', 'NORMAL', 2, 'ALL', TRUE, TRUE, 'SYSTEM'),

-- 工程部门角色
('ROLE_INERT_ENGINEER', 'TENANT_INERT', NULL, 'INERT_ENGINEER', '工程工程师', 'NORMAL', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),
('ROLE_INERT_ENGINEER_LEADER', 'TENANT_INERT', 'ROLE_INERT_ENGINEER', 'INERT_ENGINEER_LEADER', '工程部门主管', 'MANAGER', 2, 'DEPT_AND_CHILD', TRUE, TRUE, 'SYSTEM'),

-- 品质部门角色
('ROLE_INERT_QC_INSPECTOR', 'TENANT_INERT', NULL, 'INERT_QC_INSPECTOR', '品质检验员', 'NORMAL', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),
('ROLE_INERT_QC_MANAGER', 'TENANT_INERT', 'ROLE_INERT_QC_INSPECTOR', 'INERT_QC_MANAGER', '品质经理', 'MANAGER', 2, 'DEPT_AND_CHILD', TRUE, TRUE, 'SYSTEM'),

-- 生产部门角色
('ROLE_INERT_PRODUCTION_OPERATOR', 'TENANT_INERT', NULL, 'INERT_PRODUCTION_OPERATOR', '生产操作员', 'NORMAL', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),
('ROLE_INERT_PRODUCTION_MANAGER', 'TENANT_INERT', 'ROLE_INERT_PRODUCTION_OPERATOR', 'INERT_PRODUCTION_MANAGER', '生产经理', 'MANAGER', 2, 'DEPT_AND_CHILD', TRUE, TRUE, 'SYSTEM'),

-- 物流部门角色
('ROLE_INERT_LOGISTICS_OPERATOR', 'TENANT_INERT', NULL, 'INERT_LOGISTICS_OPERATOR', '物流操作员', 'NORMAL', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),
('ROLE_INERT_LOGISTICS_MANAGER', 'TENANT_INERT', 'ROLE_INERT_LOGISTICS_OPERATOR', 'INERT_LOGISTICS_MANAGER', '物流经理', 'MANAGER', 2, 'DEPT_AND_CHILD', TRUE, TRUE, 'SYSTEM'),

-- 系统管理层
('ROLE_INERT_SYSTEM_ADMIN', 'TENANT_INERT', NULL, 'INERT_SYSTEM_ADMIN', '内网系统管理员', 'SYSTEM', 1, 'ALL', FALSE, FALSE, 'SYSTEM'),

-- ===== 供应商群体角色体系 =====
-- 模具供应商
('ROLE_SUPPLIER_MOLD_MANAGER', 'TENANT_SUPPLIER', NULL, 'SUPPLIER_MOLD_MANAGER', '模具供应商经理', 'SUPPLIER', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),
('ROLE_SUPPLIER_MOLD_OPERATOR', 'TENANT_SUPPLIER', 'ROLE_SUPPLIER_MOLD_MANAGER', 'SUPPLIER_MOLD_OPERATOR', '模具操作员', 'SUPPLIER', 2, 'DEPT', TRUE, TRUE, 'SYSTEM'),

-- 原材料供应商
('ROLE_SUPPLIER_RAW_MANAGER', 'TENANT_SUPPLIER', NULL, 'SUPPLIER_RAW_MANAGER', '原材料供应商经理', 'SUPPLIER', 1, 'DEPT', FALSE, FALSE, 'SYSTEM'),
('ROLE_SUPPLIER_RAW_OPERATOR', 'TENANT_SUPPLIER', 'ROLE_SUPPLIER_RAW_MANAGER', 'SUPPLIER_RAW_OPERATOR', '原材料操作员', 'SUPPLIER', 2, 'DEPT', TRUE, TRUE, 'SYSTEM');

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
-- 英国总公司用户角色
('USER_UK_ADMIN', 'ROLE_UK_EXECUTIVE', 'SYSTEM'),
('USER_UK_LEADER', 'ROLE_UK_DIRECTOR', 'SYSTEM'),

-- 内网用户角色 - 按四个核心部门分配
-- 工程部门角色
('USER_INERT_ENGINEER', 'ROLE_INERT_ENGINEER', 'SYSTEM'),
('USER_INERT_ENGINEER_LEADER', 'ROLE_INERT_ENGINEER_LEADER', 'SYSTEM'),

-- 品质部门角色
('USER_INERT_QC_INSPECTOR', 'ROLE_INERT_QC_INSPECTOR', 'SYSTEM'),
('USER_INERT_QC_MANAGER', 'ROLE_INERT_QC_MANAGER', 'SYSTEM'),

-- 生产部门角色
('USER_INERT_PRODUCTION_OPERATOR', 'ROLE_INERT_PRODUCTION_OPERATOR', 'SYSTEM'),
('USER_INERT_PRODUCTION_MANAGER', 'ROLE_INERT_PRODUCTION_MANAGER', 'SYSTEM'),

-- 物流部门角色
('USER_INERT_LOGISTICS_OPERATOR', 'ROLE_INERT_LOGISTICS_OPERATOR', 'SYSTEM'),
('USER_INERT_LOGISTICS_MANAGER', 'ROLE_INERT_LOGISTICS_MANAGER', 'SYSTEM'),

-- 系统管理员角色
('USER_INERT_ADMIN', 'ROLE_INERT_SYSTEM_ADMIN', 'SYSTEM'),

-- 多对多关系示例 - 跨部门角色分配
-- 工程部门主管同时具有系统管理权限
('USER_INERT_ENGINEER_LEADER', 'ROLE_INERT_SYSTEM_ADMIN', 'SYSTEM'),

-- 品质经理同时具有追溯分析权限
('USER_INERT_QC_MANAGER', 'ROLE_INERT_TRACE_ANALYST', 'SYSTEM'),

-- 生产经理同时具有质量管控权限
('USER_INERT_PRODUCTION_MANAGER', 'ROLE_INERT_QC_MANAGER', 'SYSTEM'),

-- 物流经理同时具有维护管理权限
('USER_INERT_LOGISTICS_MANAGER', 'ROLE_INERT_MAINTENANCE_MANAGER', 'SYSTEM');

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