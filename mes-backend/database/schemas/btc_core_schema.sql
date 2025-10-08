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