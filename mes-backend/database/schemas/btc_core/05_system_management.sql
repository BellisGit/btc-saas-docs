-- ==============================================
-- BTC核心数据库 - 系统管理表
-- ==============================================

USE btc_core;

-- 租户管理表
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

-- 站点管理表
CREATE TABLE site (
    site_id VARCHAR(32) PRIMARY KEY COMMENT '站点ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_code VARCHAR(64) NOT NULL COMMENT '站点代码',
    site_name VARCHAR(128) NOT NULL COMMENT '站点名称',
    site_type ENUM('HEADQUARTERS', 'BRANCH', 'FACTORY', 'WAREHOUSE', 'RETAIL') DEFAULT 'FACTORY' COMMENT '站点类型',
    status ENUM('ACTIVE', 'INACTIVE', 'MAINTENANCE') DEFAULT 'ACTIVE' COMMENT '状态',
    timezone VARCHAR(32) DEFAULT 'Asia/Shanghai' COMMENT '时区',
    currency VARCHAR(8) DEFAULT 'CNY' COMMENT '货币',
    language VARCHAR(8) DEFAULT 'zh-CN' COMMENT '语言',
    address TEXT COMMENT '地址',
    contact_person VARCHAR(64) COMMENT '联系人',
    contact_phone VARCHAR(32) COMMENT '联系电话',
    contact_email VARCHAR(128) COMMENT '联系邮箱',
    settings JSON COMMENT '站点配置',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant (tenant_id),
    INDEX idx_site_code (site_code),
    INDEX idx_site_name (site_name),
    INDEX idx_status (status),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id)
) COMMENT '站点管理表';

-- 系统用户表
CREATE TABLE sys_user (
    user_id VARCHAR(32) PRIMARY KEY COMMENT '用户ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    username VARCHAR(64) NOT NULL UNIQUE COMMENT '用户名',
    password VARCHAR(255) NOT NULL COMMENT '密码',
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
    INDEX idx_site (site_id),
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_phone (phone),
    INDEX idx_status (status),
    INDEX idx_user_type (user_type),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    FOREIGN KEY (site_id) REFERENCES site(site_id)
) COMMENT '系统用户表';

-- 系统角色表
CREATE TABLE sys_role (
    role_id VARCHAR(32) PRIMARY KEY COMMENT '角色ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    role_code VARCHAR(64) NOT NULL COMMENT '角色代码',
    role_name VARCHAR(128) NOT NULL COMMENT '角色名称',
    role_type ENUM('SYSTEM', 'TENANT', 'CUSTOM') DEFAULT 'TENANT' COMMENT '角色类型',
    description TEXT COMMENT '角色描述',
    data_scope ENUM('ALL', 'CUSTOM', 'DEPT', 'DEPT_AND_CHILD', 'SELF') DEFAULT 'SELF' COMMENT '数据权限范围',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    sort_order INT DEFAULT 0 COMMENT '排序',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant (tenant_id),
    INDEX idx_role_code (role_code),
    INDEX idx_role_name (role_name),
    INDEX idx_status (status),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id)
) COMMENT '系统角色表';

-- 系统权限表
CREATE TABLE sys_permission (
    permission_id VARCHAR(32) PRIMARY KEY COMMENT '权限ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    permission_code VARCHAR(128) NOT NULL COMMENT '权限代码',
    permission_name VARCHAR(128) NOT NULL COMMENT '权限名称',
    permission_type ENUM('MENU', 'BUTTON', 'API', 'DATA') DEFAULT 'MENU' COMMENT '权限类型',
    parent_id VARCHAR(32) COMMENT '父权限ID',
    path VARCHAR(255) COMMENT '路径',
    component VARCHAR(255) COMMENT '组件',
    icon VARCHAR(64) COMMENT '图标',
    sort_order INT DEFAULT 0 COMMENT '排序',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant (tenant_id),
    INDEX idx_permission_code (permission_code),
    INDEX idx_parent_id (parent_id),
    INDEX idx_status (status),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    FOREIGN KEY (parent_id) REFERENCES sys_permission(permission_id)
) COMMENT '系统权限表';

-- 系统菜单表
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
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant (tenant_id),
    INDEX idx_menu_code (menu_code),
    INDEX idx_parent_id (parent_id),
    INDEX idx_status (status),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    FOREIGN KEY (parent_id) REFERENCES sys_menu(menu_id)
) COMMENT '系统菜单表';

-- 用户角色关联表
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

-- 角色权限关联表
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

-- 员工管理表
CREATE TABLE employee (
    employee_id VARCHAR(32) PRIMARY KEY COMMENT '员工ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) NOT NULL COMMENT '站点ID',
    employee_code VARCHAR(64) NOT NULL COMMENT '员工工号',
    employee_name VARCHAR(128) NOT NULL COMMENT '员工姓名',
    employee_type ENUM('FULL_TIME', 'PART_TIME', 'CONTRACT', 'INTERN', 'CONSULTANT') DEFAULT 'FULL_TIME' COMMENT '员工类型',
    department VARCHAR(64) COMMENT '部门',
    position VARCHAR(64) COMMENT '职位',
    job_title VARCHAR(128) COMMENT '职称',
    level VARCHAR(32) COMMENT '级别',
    status ENUM('ACTIVE', 'INACTIVE', 'ON_LEAVE', 'TERMINATED') DEFAULT 'ACTIVE' COMMENT '状态',
    gender ENUM('MALE', 'FEMALE', 'UNKNOWN') DEFAULT 'UNKNOWN' COMMENT '性别',
    birth_date DATE COMMENT '出生日期',
    hire_date DATE COMMENT '入职日期',
    termination_date DATE COMMENT '离职日期',
    phone VARCHAR(32) COMMENT '电话',
    email VARCHAR(128) COMMENT '邮箱',
    address TEXT COMMENT '地址',
    emergency_contact VARCHAR(128) COMMENT '紧急联系人',
    emergency_phone VARCHAR(32) COMMENT '紧急联系电话',
    id_card VARCHAR(32) COMMENT '身份证号',
    education VARCHAR(64) COMMENT '学历',
    major VARCHAR(128) COMMENT '专业',
    graduation_school VARCHAR(128) COMMENT '毕业院校',
    graduation_date DATE COMMENT '毕业日期',
    description TEXT COMMENT '描述',
    settings JSON COMMENT '员工配置',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_employee_code (employee_code),
    INDEX idx_employee_name (employee_name),
    INDEX idx_employee_type (employee_type),
    INDEX idx_department (department),
    INDEX idx_position (position),
    INDEX idx_status (status),
    INDEX idx_hire_date (hire_date),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    FOREIGN KEY (site_id) REFERENCES site(site_id)
) COMMENT '员工管理表';

-- 技能管理表
CREATE TABLE skill (
    skill_id VARCHAR(32) PRIMARY KEY COMMENT '技能ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    skill_code VARCHAR(64) NOT NULL COMMENT '技能代码',
    skill_name VARCHAR(128) NOT NULL COMMENT '技能名称',
    skill_category VARCHAR(64) COMMENT '技能分类',
    skill_type ENUM('TECHNICAL', 'SOFT', 'CERTIFICATION', 'LANGUAGE', 'EQUIPMENT') DEFAULT 'TECHNICAL' COMMENT '技能类型',
    description TEXT COMMENT '技能描述',
    level_count INT DEFAULT 5 COMMENT '等级数量',
    level_names JSON COMMENT '等级名称列表',
    assessment_method TEXT COMMENT '评估方法',
    validity_period INT COMMENT '有效期(月)',
    is_required BOOLEAN DEFAULT FALSE COMMENT '是否必需',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant (tenant_id),
    INDEX idx_skill_code (skill_code),
    INDEX idx_skill_name (skill_name),
    INDEX idx_skill_category (skill_category),
    INDEX idx_skill_type (skill_type),
    INDEX idx_status (status),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id)
) COMMENT '技能管理表';

-- 员工技能关联表
CREATE TABLE employee_skill (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    employee_id VARCHAR(32) NOT NULL COMMENT '员工ID',
    skill_id VARCHAR(32) NOT NULL COMMENT '技能ID',
    skill_level INT DEFAULT 1 COMMENT '技能等级',
    certification_no VARCHAR(128) COMMENT '证书编号',
    certification_date DATE COMMENT '认证日期',
    certification_expire_date DATE COMMENT '证书过期日期',
    assessment_score DECIMAL(5,2) COMMENT '评估分数',
    assessor VARCHAR(64) COMMENT '评估人',
    assessment_date DATE COMMENT '评估日期',
    notes TEXT COMMENT '备注',
    status ENUM('ACTIVE', 'INACTIVE', 'EXPIRED') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_employee (employee_id),
    INDEX idx_skill (skill_id),
    INDEX idx_skill_level (skill_level),
    INDEX idx_certification_date (certification_date),
    INDEX idx_certification_expire_date (certification_expire_date),
    INDEX idx_status (status),
    UNIQUE KEY uk_employee_skill (employee_id, skill_id),
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id),
    FOREIGN KEY (skill_id) REFERENCES skill(skill_id)
) COMMENT '员工技能关联表';
