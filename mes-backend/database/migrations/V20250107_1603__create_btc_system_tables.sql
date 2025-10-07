-- V20250107_1603__add_system_tables.sql
-- 添加系统管理、用户权限、环境配置等基础表
-- 基于MES系统全局架构基础文档
-- 作者: MES开发团队
-- 日期: 2025-01-07

-- 使用MES核心数据库
USE mes_core;

-- ==============================================
-- 1. 系统管理表（用户、角色、权限）
-- ==============================================

-- 租户表
CREATE TABLE IF NOT EXISTS tenant (
    tenant_id VARCHAR(32) PRIMARY KEY COMMENT '租户ID',
    tenant_code VARCHAR(64) NOT NULL UNIQUE COMMENT '租户代码',
    tenant_name VARCHAR(255) NOT NULL COMMENT '租户名称',
    tenant_type ENUM('ENTERPRISE', 'SME', 'INDIVIDUAL') DEFAULT 'ENTERPRISE' COMMENT '租户类型',
    contact_person VARCHAR(100) COMMENT '联系人',
    contact_phone VARCHAR(50) COMMENT '联系电话',
    contact_email VARCHAR(100) COMMENT '联系邮箱',
    address TEXT COMMENT '地址',
    license_key VARCHAR(128) COMMENT '许可证密钥',
    license_expires DATE COMMENT '许可证到期日期',
    max_users INT DEFAULT 100 COMMENT '最大用户数',
    max_stations INT DEFAULT 50 COMMENT '最大工位数',
    status ENUM('ACTIVE', 'SUSPENDED', 'EXPIRED') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant_code (tenant_code),
    INDEX idx_status (status),
    INDEX idx_license_expires (license_expires)
) COMMENT '租户表';

-- 站点表
CREATE TABLE IF NOT EXISTS site (
    site_id VARCHAR(32) PRIMARY KEY COMMENT '站点ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_code VARCHAR(64) NOT NULL COMMENT '站点代码',
    site_name VARCHAR(255) NOT NULL COMMENT '站点名称',
    site_type ENUM('HEADQUARTERS', 'BRANCH', 'FACTORY', 'WAREHOUSE') DEFAULT 'FACTORY' COMMENT '站点类型',
    address TEXT COMMENT '地址',
    timezone VARCHAR(50) DEFAULT 'Asia/Shanghai' COMMENT '时区',
    currency VARCHAR(8) DEFAULT 'CNY' COMMENT '默认币种',
    language VARCHAR(8) DEFAULT 'zh-CN' COMMENT '默认语言',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    UNIQUE KEY uk_tenant_site_code (tenant_id, site_code),
    INDEX idx_tenant (tenant_id),
    INDEX idx_status (status)
) COMMENT '站点表';

-- 用户表
CREATE TABLE IF NOT EXISTS sys_user (
    user_id VARCHAR(32) PRIMARY KEY COMMENT '用户ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    username VARCHAR(64) NOT NULL COMMENT '用户名',
    password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希',
    email VARCHAR(100) COMMENT '邮箱',
    phone VARCHAR(20) COMMENT '手机号',
    real_name VARCHAR(100) COMMENT '真实姓名',
    employee_no VARCHAR(64) COMMENT '工号',
    avatar_url VARCHAR(500) COMMENT '头像URL',
    gender ENUM('MALE', 'FEMALE', 'OTHER') COMMENT '性别',
    birth_date DATE COMMENT '出生日期',
    department VARCHAR(100) COMMENT '部门',
    position VARCHAR(100) COMMENT '职位',
    status ENUM('ACTIVE', 'INACTIVE', 'LOCKED', 'EXPIRED') DEFAULT 'ACTIVE' COMMENT '状态',
    last_login_at DATETIME COMMENT '最后登录时间',
    last_login_ip VARCHAR(45) COMMENT '最后登录IP',
    login_failed_count INT DEFAULT 0 COMMENT '登录失败次数',
    password_changed_at DATETIME COMMENT '密码修改时间',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    FOREIGN KEY (site_id) REFERENCES site(site_id),
    UNIQUE KEY uk_tenant_username (tenant_id, username),
    UNIQUE KEY uk_email (email),
    UNIQUE KEY uk_phone (phone),
    INDEX idx_tenant (tenant_id),
    INDEX idx_site (site_id),
    INDEX idx_status (status),
    INDEX idx_last_login (last_login_at)
) COMMENT '用户表';

-- 角色表
CREATE TABLE IF NOT EXISTS sys_role (
    role_id VARCHAR(32) PRIMARY KEY COMMENT '角色ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    role_code VARCHAR(64) NOT NULL COMMENT '角色代码',
    role_name VARCHAR(100) NOT NULL COMMENT '角色名称',
    role_type ENUM('SYSTEM', 'CUSTOM') DEFAULT 'CUSTOM' COMMENT '角色类型',
    description TEXT COMMENT '角色描述',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    UNIQUE KEY uk_tenant_role_code (tenant_id, role_code),
    INDEX idx_tenant (tenant_id),
    INDEX idx_status (status)
) COMMENT '角色表';

-- 用户角色关联表
CREATE TABLE IF NOT EXISTS sys_user_role (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(32) NOT NULL COMMENT '用户ID',
    role_id VARCHAR(32) NOT NULL COMMENT '角色ID',
    assigned_by VARCHAR(64) COMMENT '分配人',
    assigned_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '分配时间',
    expires_at DATETIME COMMENT '过期时间',
    FOREIGN KEY (user_id) REFERENCES sys_user(user_id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES sys_role(role_id) ON DELETE CASCADE,
    UNIQUE KEY uk_user_role (user_id, role_id),
    INDEX idx_user (user_id),
    INDEX idx_role (role_id)
) COMMENT '用户角色关联表';

-- 权限表
CREATE TABLE IF NOT EXISTS sys_permission (
    permission_id VARCHAR(32) PRIMARY KEY COMMENT '权限ID',
    permission_code VARCHAR(100) NOT NULL UNIQUE COMMENT '权限代码',
    permission_name VARCHAR(100) NOT NULL COMMENT '权限名称',
    permission_type ENUM('MENU', 'BUTTON', 'API', 'DATA') DEFAULT 'MENU' COMMENT '权限类型',
    parent_id VARCHAR(32) COMMENT '父权限ID',
    menu_path VARCHAR(200) COMMENT '菜单路径',
    api_path VARCHAR(200) COMMENT 'API路径',
    http_method VARCHAR(10) COMMENT 'HTTP方法',
    sort_order INT DEFAULT 0 COMMENT '排序',
    icon VARCHAR(100) COMMENT '图标',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES sys_permission(permission_id),
    INDEX idx_parent (parent_id),
    INDEX idx_type (permission_type),
    INDEX idx_status (status)
) COMMENT '权限表';

-- 角色权限关联表
CREATE TABLE IF NOT EXISTS sys_role_permission (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    role_id VARCHAR(32) NOT NULL COMMENT '角色ID',
    permission_id VARCHAR(32) NOT NULL COMMENT '权限ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES sys_role(role_id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES sys_permission(permission_id) ON DELETE CASCADE,
    UNIQUE KEY uk_role_permission (role_id, permission_id),
    INDEX idx_role (role_id),
    INDEX idx_permission (permission_id)
) COMMENT '角色权限关联表';

-- 菜单表
CREATE TABLE IF NOT EXISTS sys_menu (
    menu_id VARCHAR(32) PRIMARY KEY COMMENT '菜单ID',
    parent_id VARCHAR(32) COMMENT '父菜单ID',
    menu_code VARCHAR(64) NOT NULL COMMENT '菜单代码',
    menu_name VARCHAR(100) NOT NULL COMMENT '菜单名称',
    menu_type ENUM('DIRECTORY', 'MENU', 'BUTTON') DEFAULT 'MENU' COMMENT '菜单类型',
    menu_path VARCHAR(200) COMMENT '菜单路径',
    component_path VARCHAR(200) COMMENT '组件路径',
    icon VARCHAR(100) COMMENT '图标',
    sort_order INT DEFAULT 0 COMMENT '排序',
    is_visible TINYINT(1) DEFAULT 1 COMMENT '是否可见',
    is_cache TINYINT(1) DEFAULT 0 COMMENT '是否缓存',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES sys_menu(menu_id),
    UNIQUE KEY uk_menu_code (menu_code),
    INDEX idx_parent (parent_id),
    INDEX idx_sort_order (sort_order),
    INDEX idx_status (status)
) COMMENT '菜单表';

-- ==============================================
-- 2. 环境配置表（工厂、产线、工位、设备等）
-- ==============================================

-- 工厂表
CREATE TABLE IF NOT EXISTS plant (
    plant_id VARCHAR(32) PRIMARY KEY COMMENT '工厂ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) NOT NULL COMMENT '站点ID',
    plant_code VARCHAR(64) NOT NULL COMMENT '工厂代码',
    plant_name VARCHAR(255) NOT NULL COMMENT '工厂名称',
    plant_type ENUM('MANUFACTURING', 'ASSEMBLY', 'TESTING', 'WAREHOUSE') DEFAULT 'MANUFACTURING' COMMENT '工厂类型',
    address TEXT COMMENT '地址',
    manager_id VARCHAR(32) COMMENT '厂长ID',
    status ENUM('ACTIVE', 'INACTIVE', 'MAINTENANCE') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    FOREIGN KEY (site_id) REFERENCES site(site_id),
    UNIQUE KEY uk_site_plant_code (site_id, plant_code),
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_status (status)
) COMMENT '工厂表';

-- 产线表
CREATE TABLE IF NOT EXISTS production_line (
    line_id VARCHAR(32) PRIMARY KEY COMMENT '产线ID',
    plant_id VARCHAR(32) NOT NULL COMMENT '工厂ID',
    line_code VARCHAR(64) NOT NULL COMMENT '产线代码',
    line_name VARCHAR(255) NOT NULL COMMENT '产线名称',
    line_type ENUM('ASSEMBLY', 'TESTING', 'PACKAGING', 'MIXED') DEFAULT 'ASSEMBLY' COMMENT '产线类型',
    capacity_per_hour DECIMAL(10,2) COMMENT '每小时产能',
    working_hours_per_day DECIMAL(4,2) DEFAULT 8.0 COMMENT '每日工作小时数',
    working_days_per_week INT DEFAULT 5 COMMENT '每周工作天数',
    supervisor_id VARCHAR(32) COMMENT '线长ID',
    status ENUM('ACTIVE', 'INACTIVE', 'MAINTENANCE', 'STOPPED') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (plant_id) REFERENCES plant(plant_id),
    UNIQUE KEY uk_plant_line_code (plant_id, line_code),
    INDEX idx_plant (plant_id),
    INDEX idx_status (status)
) COMMENT '产线表';

-- 工位表
CREATE TABLE IF NOT EXISTS workstation (
    station_id VARCHAR(32) PRIMARY KEY COMMENT '工位ID',
    line_id VARCHAR(32) NOT NULL COMMENT '产线ID',
    station_code VARCHAR(64) NOT NULL COMMENT '工位代码',
    station_name VARCHAR(255) NOT NULL COMMENT '工位名称',
    station_type ENUM('MANUAL', 'SEMI_AUTO', 'AUTO', 'TESTING', 'INSPECTION') DEFAULT 'MANUAL' COMMENT '工位类型',
    sequence_no INT COMMENT '工位序号',
    cycle_time DECIMAL(8,2) COMMENT '节拍时间(秒)',
    capacity_per_hour DECIMAL(10,2) COMMENT '每小时产能',
    operator_count INT DEFAULT 1 COMMENT '操作员数量',
    skill_requirements JSON COMMENT '技能要求',
    status ENUM('ACTIVE', 'INACTIVE', 'MAINTENANCE', 'BREAKDOWN') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (line_id) REFERENCES production_line(line_id),
    UNIQUE KEY uk_line_station_code (line_id, station_code),
    INDEX idx_line (line_id),
    INDEX idx_sequence (sequence_no),
    INDEX idx_status (status)
) COMMENT '工位表';

-- 设备表
CREATE TABLE IF NOT EXISTS equipment (
    equipment_id VARCHAR(32) PRIMARY KEY COMMENT '设备ID',
    station_id VARCHAR(32) COMMENT '工位ID',
    equipment_code VARCHAR(64) NOT NULL COMMENT '设备代码',
    equipment_name VARCHAR(255) NOT NULL COMMENT '设备名称',
    equipment_type ENUM('MACHINE', 'TOOL', 'GAUGE', 'TESTER', 'CONVEYOR') DEFAULT 'MACHINE' COMMENT '设备类型',
    manufacturer VARCHAR(100) COMMENT '制造商',
    model VARCHAR(100) COMMENT '型号',
    serial_number VARCHAR(100) COMMENT '序列号',
    purchase_date DATE COMMENT '采购日期',
    warranty_expires DATE COMMENT '保修到期日期',
    maintenance_cycle INT COMMENT '维护周期(天)',
    last_maintenance_date DATE COMMENT '最后维护日期',
    next_maintenance_date DATE COMMENT '下次维护日期',
    status ENUM('RUNNING', 'STOPPED', 'MAINTENANCE', 'BREAKDOWN', 'RETIRED') DEFAULT 'RUNNING' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (station_id) REFERENCES workstation(station_id),
    UNIQUE KEY uk_equipment_code (equipment_code),
    INDEX idx_station (station_id),
    INDEX idx_type (equipment_type),
    INDEX idx_status (status),
    INDEX idx_next_maintenance (next_maintenance_date)
) COMMENT '设备表';

-- ==============================================
-- 3. 基础数据扩展表
-- ==============================================

-- 计量单位表
CREATE TABLE IF NOT EXISTS unit_of_measure (
    uom_id VARCHAR(32) PRIMARY KEY COMMENT '计量单位ID',
    uom_code VARCHAR(16) NOT NULL UNIQUE COMMENT '计量单位代码',
    uom_name VARCHAR(100) NOT NULL COMMENT '计量单位名称',
    uom_type ENUM('LENGTH', 'WEIGHT', 'VOLUME', 'COUNT', 'TIME', 'TEMPERATURE', 'OTHER') DEFAULT 'OTHER' COMMENT '单位类型',
    base_uom_id VARCHAR(32) COMMENT '基础单位ID',
    conversion_factor DECIMAL(18,8) DEFAULT 1.0 COMMENT '转换系数',
    precision DECIMAL(8,4) DEFAULT 4 COMMENT '精度',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (base_uom_id) REFERENCES unit_of_measure(uom_id),
    INDEX idx_type (uom_type),
    INDEX idx_status (status)
) COMMENT '计量单位表';

-- 库位表
CREATE TABLE IF NOT EXISTS location (
    location_id VARCHAR(32) PRIMARY KEY COMMENT '库位ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) NOT NULL COMMENT '站点ID',
    location_code VARCHAR(64) NOT NULL COMMENT '库位代码',
    location_name VARCHAR(255) NOT NULL COMMENT '库位名称',
    location_type ENUM('WAREHOUSE', 'PRODUCTION', 'QUALITY', 'SCRAP', 'IN_TRANSIT') DEFAULT 'WAREHOUSE' COMMENT '库位类型',
    warehouse_code VARCHAR(64) COMMENT '仓库代码',
    zone_code VARCHAR(64) COMMENT '区域代码',
    aisle VARCHAR(16) COMMENT '通道',
    shelf VARCHAR(16) COMMENT '货架',
    level VARCHAR(16) COMMENT '层',
    position VARCHAR(16) COMMENT '位置',
    capacity DECIMAL(18,4) COMMENT '容量',
    current_quantity DECIMAL(18,4) DEFAULT 0 COMMENT '当前数量',
    status ENUM('ACTIVE', 'INACTIVE', 'MAINTENANCE') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    FOREIGN KEY (site_id) REFERENCES site(site_id),
    UNIQUE KEY uk_site_location_code (site_id, location_code),
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_type (location_type),
    INDEX idx_warehouse (warehouse_code),
    INDEX idx_status (status)
) COMMENT '库位表';

-- 班次表
CREATE TABLE IF NOT EXISTS shift (
    shift_id VARCHAR(32) PRIMARY KEY COMMENT '班次ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    shift_code VARCHAR(16) NOT NULL COMMENT '班次代码',
    shift_name VARCHAR(100) NOT NULL COMMENT '班次名称',
    start_time TIME NOT NULL COMMENT '开始时间',
    end_time TIME NOT NULL COMMENT '结束时间',
    work_days JSON COMMENT '工作日期配置',
    is_night_shift TINYINT(1) DEFAULT 0 COMMENT '是否夜班',
    break_duration INT DEFAULT 60 COMMENT '休息时长(分钟)',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    UNIQUE KEY uk_tenant_shift_code (tenant_id, shift_code),
    INDEX idx_tenant (tenant_id),
    INDEX idx_status (status)
) COMMENT '班次表';

-- 日历表
CREATE TABLE IF NOT EXISTS calendar (
    calendar_id VARCHAR(32) PRIMARY KEY COMMENT '日历ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    calendar_name VARCHAR(100) NOT NULL COMMENT '日历名称',
    calendar_type ENUM('WORK', 'HOLIDAY', 'MAINTENANCE') DEFAULT 'WORK' COMMENT '日历类型',
    year INT NOT NULL COMMENT '年份',
    month INT NOT NULL COMMENT '月份',
    day INT NOT NULL COMMENT '日期',
    is_workday TINYINT(1) DEFAULT 1 COMMENT '是否工作日',
    work_start_time TIME COMMENT '工作开始时间',
    work_end_time TIME COMMENT '工作结束时间',
    description VARCHAR(255) COMMENT '描述',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    UNIQUE KEY uk_tenant_date (tenant_id, year, month, day),
    INDEX idx_tenant (tenant_id),
    INDEX idx_date (year, month, day),
    INDEX idx_type (calendar_type)
) COMMENT '日历表';

-- ==============================================
-- 4. 员工管理表
-- ==============================================

-- 员工表
CREATE TABLE IF NOT EXISTS employee (
    employee_id VARCHAR(32) PRIMARY KEY COMMENT '员工ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) NOT NULL COMMENT '站点ID',
    employee_no VARCHAR(64) NOT NULL COMMENT '工号',
    real_name VARCHAR(100) NOT NULL COMMENT '真实姓名',
    english_name VARCHAR(100) COMMENT '英文姓名',
    id_card VARCHAR(18) COMMENT '身份证号',
    phone VARCHAR(20) COMMENT '手机号',
    email VARCHAR(100) COMMENT '邮箱',
    gender ENUM('MALE', 'FEMALE', 'OTHER') COMMENT '性别',
    birth_date DATE COMMENT '出生日期',
    hire_date DATE COMMENT '入职日期',
    department VARCHAR(100) COMMENT '部门',
    position VARCHAR(100) COMMENT '职位',
    level VARCHAR(32) COMMENT '职级',
    supervisor_id VARCHAR(32) COMMENT '上级主管ID',
    work_location VARCHAR(100) COMMENT '工作地点',
    employment_type ENUM('FULL_TIME', 'PART_TIME', 'CONTRACT', 'INTERN') DEFAULT 'FULL_TIME' COMMENT '雇佣类型',
    status ENUM('ACTIVE', 'INACTIVE', 'RESIGNED', 'TERMINATED') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    FOREIGN KEY (site_id) REFERENCES site(site_id),
    UNIQUE KEY uk_tenant_employee_no (tenant_id, employee_no),
    UNIQUE KEY uk_id_card (id_card),
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_department (department),
    INDEX idx_status (status)
) COMMENT '员工表';

-- 技能表
CREATE TABLE IF NOT EXISTS skill (
    skill_id VARCHAR(32) PRIMARY KEY COMMENT '技能ID',
    skill_code VARCHAR(64) NOT NULL COMMENT '技能代码',
    skill_name VARCHAR(100) NOT NULL COMMENT '技能名称',
    skill_category VARCHAR(64) COMMENT '技能分类',
    skill_level ENUM('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT') DEFAULT 'BEGINNER' COMMENT '技能等级',
    description TEXT COMMENT '技能描述',
    certification_required TINYINT(1) DEFAULT 0 COMMENT '是否需要认证',
    validity_period INT COMMENT '有效期(月)',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_skill_code (skill_code),
    INDEX idx_category (skill_category),
    INDEX idx_status (status)
) COMMENT '技能表';

-- 员工技能关联表
CREATE TABLE IF NOT EXISTS employee_skill (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    employee_id VARCHAR(32) NOT NULL COMMENT '员工ID',
    skill_id VARCHAR(32) NOT NULL COMMENT '技能ID',
    skill_level ENUM('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT') DEFAULT 'BEGINNER' COMMENT '技能等级',
    certified_date DATE COMMENT '认证日期',
    expires_date DATE COMMENT '到期日期',
    certified_by VARCHAR(64) COMMENT '认证人',
    status ENUM('ACTIVE', 'EXPIRED', 'REVOKED') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skill(skill_id) ON DELETE CASCADE,
    UNIQUE KEY uk_employee_skill (employee_id, skill_id),
    INDEX idx_employee (employee_id),
    INDEX idx_skill (skill_id),
    INDEX idx_expires (expires_date)
) COMMENT '员工技能关联表';

-- ==============================================
-- 5. 系统配置表
-- ==============================================

-- 系统参数表
CREATE TABLE IF NOT EXISTS sys_config (
    config_id VARCHAR(32) PRIMARY KEY COMMENT '配置ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    config_key VARCHAR(100) NOT NULL COMMENT '配置键',
    config_value TEXT COMMENT '配置值',
    config_type ENUM('STRING', 'NUMBER', 'BOOLEAN', 'JSON', 'FILE') DEFAULT 'STRING' COMMENT '配置类型',
    config_group VARCHAR(64) COMMENT '配置分组',
    description TEXT COMMENT '配置描述',
    is_system TINYINT(1) DEFAULT 0 COMMENT '是否系统配置',
    is_encrypted TINYINT(1) DEFAULT 0 COMMENT '是否加密',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    UNIQUE KEY uk_tenant_config_key (tenant_id, config_key),
    INDEX idx_group (config_group),
    INDEX idx_status (status)
) COMMENT '系统参数表';

-- 数据字典表
CREATE TABLE IF NOT EXISTS sys_dict (
    dict_id VARCHAR(32) PRIMARY KEY COMMENT '字典ID',
    dict_type VARCHAR(64) NOT NULL COMMENT '字典类型',
    dict_key VARCHAR(64) NOT NULL COMMENT '字典键',
    dict_value VARCHAR(255) NOT NULL COMMENT '字典值',
    dict_label VARCHAR(255) NOT NULL COMMENT '字典标签',
    sort_order INT DEFAULT 0 COMMENT '排序',
    parent_id VARCHAR(32) COMMENT '父字典ID',
    css_class VARCHAR(100) COMMENT 'CSS类名',
    list_class VARCHAR(100) COMMENT '列表样式',
    is_default TINYINT(1) DEFAULT 0 COMMENT '是否默认',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    remark TEXT COMMENT '备注',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES sys_dict(dict_id),
    UNIQUE KEY uk_type_key (dict_type, dict_key),
    INDEX idx_type (dict_type),
    INDEX idx_parent (parent_id),
    INDEX idx_status (status)
) COMMENT '数据字典表';

-- 操作日志表
CREATE TABLE IF NOT EXISTS sys_operation_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id VARCHAR(32) COMMENT '租户ID',
    user_id VARCHAR(32) COMMENT '用户ID',
    username VARCHAR(64) COMMENT '用户名',
    operation_type VARCHAR(32) NOT NULL COMMENT '操作类型',
    operation_desc VARCHAR(500) COMMENT '操作描述',
    request_method VARCHAR(10) COMMENT '请求方法',
    request_url VARCHAR(500) COMMENT '请求URL',
    request_ip VARCHAR(45) COMMENT '请求IP',
    request_location VARCHAR(100) COMMENT '请求地点',
    request_params TEXT COMMENT '请求参数',
    response_result TEXT COMMENT '响应结果',
    execution_time BIGINT COMMENT '执行时间(ms)',
    status ENUM('SUCCESS', 'FAILURE') DEFAULT 'SUCCESS' COMMENT '操作状态',
    error_msg TEXT COMMENT '错误信息',
    user_agent VARCHAR(500) COMMENT '用户代理',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_tenant (tenant_id),
    INDEX idx_user (user_id),
    INDEX idx_operation_type (operation_type),
    INDEX idx_created_at (created_at),
    INDEX idx_status (status)
) COMMENT '操作日志表';

-- 登录日志表
CREATE TABLE IF NOT EXISTS sys_login_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id VARCHAR(32) COMMENT '租户ID',
    user_id VARCHAR(32) COMMENT '用户ID',
    username VARCHAR(64) COMMENT '用户名',
    login_ip VARCHAR(45) COMMENT '登录IP',
    login_location VARCHAR(100) COMMENT '登录地点',
    browser VARCHAR(100) COMMENT '浏览器',
    os VARCHAR(100) COMMENT '操作系统',
    login_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登录时间',
    logout_time DATETIME COMMENT '登出时间',
    session_duration BIGINT COMMENT '会话时长(秒)',
    status ENUM('SUCCESS', 'FAILURE') DEFAULT 'SUCCESS' COMMENT '登录状态',
    failure_reason VARCHAR(255) COMMENT '失败原因',
    INDEX idx_tenant (tenant_id),
    INDEX idx_user (user_id),
    INDEX idx_login_time (login_time),
    INDEX idx_status (status)
) COMMENT '登录日志表';
