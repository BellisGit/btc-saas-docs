-- ==============================================
-- BTC核心数据库架构 - 混合架构方案
-- 包含所有基础表和核心业务表，支持复杂事务
-- ==============================================

-- 创建BTC核心数据库
CREATE DATABASE IF NOT EXISTS btc_core CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE btc_core;

-- ==============================================
-- 1. 系统基础表（所有扩展数据库的基础）
-- ==============================================

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

-- ==============================================
-- 2. 主数据管理表
-- ==============================================

-- 物料主数据表
CREATE TABLE item_master (
    item_id VARCHAR(32) PRIMARY KEY COMMENT '物料编码 ITM-YYYYMM-XXXX',
    item_code VARCHAR(64) NOT NULL COMMENT 'ERP物料编码',
    item_name VARCHAR(255) NOT NULL COMMENT '物料名称',
    item_type ENUM('RAW', 'COMPONENT', 'FINISHED', 'TOOL', 'CONSUMABLE') NOT NULL COMMENT '物料类型',
    uom VARCHAR(16) NOT NULL COMMENT '计量单位',
    specification TEXT COMMENT '规格说明',
    supplier_id VARCHAR(32) COMMENT '默认供应商',
    status ENUM('ACTIVE', 'INACTIVE', 'OBSOLETE') DEFAULT 'ACTIVE' COMMENT '状态',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_item_code (item_code),
    INDEX idx_item_type (item_type),
    INDEX idx_supplier (supplier_id),
    INDEX idx_tenant_site (tenant_id, site_id),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    FOREIGN KEY (site_id) REFERENCES site(site_id)
) COMMENT '物料主数据表';

-- 供应商主数据表
CREATE TABLE supplier_master (
    supplier_id VARCHAR(32) PRIMARY KEY COMMENT '供应商编码 SUP-XXXXX',
    supplier_code VARCHAR(64) NOT NULL COMMENT '供应商代码',
    supplier_name VARCHAR(255) NOT NULL COMMENT '供应商名称',
    contact_person VARCHAR(100) COMMENT '联系人',
    contact_phone VARCHAR(50) COMMENT '联系电话',
    contact_email VARCHAR(100) COMMENT '联系邮箱',
    address TEXT COMMENT '地址',
    status ENUM('ACTIVE', 'INACTIVE', 'BLACKLIST') DEFAULT 'ACTIVE' COMMENT '状态',
    quality_rating DECIMAL(3,2) DEFAULT 5.00 COMMENT '质量评分',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_supplier_code (supplier_code),
    INDEX idx_status (status),
    INDEX idx_tenant (tenant_id),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id)
) COMMENT '供应商主数据表';

-- 客户主数据表
CREATE TABLE customer_master (
    customer_id VARCHAR(32) PRIMARY KEY COMMENT '客户编码 CUS-XXXXX',
    customer_code VARCHAR(64) NOT NULL COMMENT '客户代码',
    customer_name VARCHAR(255) NOT NULL COMMENT '客户名称',
    customer_type ENUM('RETAIL', 'WHOLESALE', 'OEM', 'END_USER') DEFAULT 'END_USER' COMMENT '客户类型',
    contact_person VARCHAR(100) COMMENT '联系人',
    contact_phone VARCHAR(50) COMMENT '联系电话',
    contact_email VARCHAR(100) COMMENT '联系邮箱',
    address TEXT COMMENT '地址',
    status ENUM('ACTIVE', 'INACTIVE', 'BLACKLIST') DEFAULT 'ACTIVE' COMMENT '状态',
    credit_limit DECIMAL(18,2) DEFAULT 0 COMMENT '信用额度',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_customer_code (customer_code),
    INDEX idx_customer_type (customer_type),
    INDEX idx_status (status),
    INDEX idx_tenant (tenant_id),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id)
) COMMENT '客户主数据表';

-- 库位主数据表
CREATE TABLE location_master (
    location_id VARCHAR(32) PRIMARY KEY COMMENT '库位编码 LOC-XXXXX',
    location_code VARCHAR(64) NOT NULL COMMENT '库位代码',
    location_name VARCHAR(255) NOT NULL COMMENT '库位名称',
    location_type ENUM('WAREHOUSE', 'PRODUCTION_LINE', 'QUALITY_AREA', 'SCRAP_AREA', 'RETURN_AREA') NOT NULL COMMENT '库位类型',
    warehouse_code VARCHAR(64) COMMENT '仓库代码',
    zone_code VARCHAR(64) COMMENT '区域代码',
    aisle_code VARCHAR(64) COMMENT '通道代码',
    rack_code VARCHAR(64) COMMENT '货架代码',
    shelf_code VARCHAR(64) COMMENT '层代码',
    position_code VARCHAR(64) COMMENT '位代码',
    capacity DECIMAL(18,4) DEFAULT 0 COMMENT '容量',
    capacity_uom VARCHAR(16) COMMENT '容量单位',
    status ENUM('ACTIVE', 'INACTIVE', 'MAINTENANCE') DEFAULT 'ACTIVE' COMMENT '状态',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_location_code (location_code),
    INDEX idx_location_type (location_type),
    INDEX idx_warehouse_code (warehouse_code),
    INDEX idx_status (status),
    INDEX idx_tenant_site (tenant_id, site_id),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    FOREIGN KEY (site_id) REFERENCES site(site_id)
) COMMENT '库位主数据表';

-- 缺陷代码主数据表
CREATE TABLE defect_code_master (
    defect_code_id VARCHAR(32) PRIMARY KEY COMMENT '缺陷代码ID',
    defect_code VARCHAR(32) NOT NULL COMMENT '缺陷代码',
    defect_name VARCHAR(128) NOT NULL COMMENT '缺陷名称',
    defect_category VARCHAR(64) COMMENT '缺陷类别',
    severity_level ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') DEFAULT 'MEDIUM' COMMENT '严重程度',
    description TEXT COMMENT '缺陷描述',
    root_cause_category VARCHAR(64) COMMENT '根本原因类别',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_defect_code (defect_code),
    INDEX idx_defect_category (defect_category),
    INDEX idx_severity_level (severity_level),
    INDEX idx_status (status),
    INDEX idx_tenant (tenant_id),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id)
) COMMENT '缺陷代码主数据表';

-- 原因代码主数据表
CREATE TABLE cause_code_master (
    cause_code_id VARCHAR(32) PRIMARY KEY COMMENT '原因代码ID',
    cause_code VARCHAR(32) NOT NULL COMMENT '原因代码',
    cause_name VARCHAR(128) NOT NULL COMMENT '原因名称',
    cause_category VARCHAR(64) COMMENT '原因类别',
    description TEXT COMMENT '原因描述',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_cause_code (cause_code),
    INDEX idx_cause_category (cause_category),
    INDEX idx_status (status),
    INDEX idx_tenant (tenant_id),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id)
) COMMENT '原因代码主数据表';

-- ==============================================
-- 3. 环境配置表
-- ==============================================

-- 工厂管理表
CREATE TABLE plant (
    plant_id VARCHAR(32) PRIMARY KEY COMMENT '工厂ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) NOT NULL COMMENT '站点ID',
    plant_code VARCHAR(64) NOT NULL COMMENT '工厂代码',
    plant_name VARCHAR(128) NOT NULL COMMENT '工厂名称',
    plant_type ENUM('MANUFACTURING', 'ASSEMBLY', 'WAREHOUSE', 'LABORATORY') DEFAULT 'MANUFACTURING' COMMENT '工厂类型',
    status ENUM('ACTIVE', 'INACTIVE', 'MAINTENANCE') DEFAULT 'ACTIVE' COMMENT '状态',
    address TEXT COMMENT '地址',
    timezone VARCHAR(32) DEFAULT 'Asia/Shanghai' COMMENT '时区',
    currency VARCHAR(8) DEFAULT 'CNY' COMMENT '货币',
    language VARCHAR(8) DEFAULT 'zh-CN' COMMENT '语言',
    contact_person VARCHAR(64) COMMENT '联系人',
    contact_phone VARCHAR(32) COMMENT '联系电话',
    contact_email VARCHAR(128) COMMENT '联系邮箱',
    description TEXT COMMENT '描述',
    settings JSON COMMENT '工厂配置',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_plant_code (plant_code),
    INDEX idx_plant_name (plant_name),
    INDEX idx_status (status),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    FOREIGN KEY (site_id) REFERENCES site(site_id)
) COMMENT '工厂管理表';

-- 产线管理表
CREATE TABLE production_line (
    line_id VARCHAR(32) PRIMARY KEY COMMENT '产线ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) NOT NULL COMMENT '站点ID',
    plant_id VARCHAR(32) NOT NULL COMMENT '工厂ID',
    line_code VARCHAR(64) NOT NULL COMMENT '产线代码',
    line_name VARCHAR(128) NOT NULL COMMENT '产线名称',
    line_type ENUM('ASSEMBLY', 'MANUFACTURING', 'PACKAGING', 'TESTING') DEFAULT 'ASSEMBLY' COMMENT '产线类型',
    status ENUM('ACTIVE', 'INACTIVE', 'MAINTENANCE', 'SHUTDOWN') DEFAULT 'ACTIVE' COMMENT '状态',
    capacity_per_hour DECIMAL(10,2) DEFAULT 0 COMMENT '每小时产能',
    cycle_time DECIMAL(8,2) DEFAULT 0 COMMENT '节拍时间(秒)',
    efficiency_target DECIMAL(5,2) DEFAULT 85.00 COMMENT '效率目标(%)',
    quality_target DECIMAL(5,2) DEFAULT 99.00 COMMENT '质量目标(%)',
    location VARCHAR(255) COMMENT '位置',
    description TEXT COMMENT '描述',
    settings JSON COMMENT '产线配置',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_plant (plant_id),
    INDEX idx_line_code (line_code),
    INDEX idx_line_name (line_name),
    INDEX idx_status (status),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    FOREIGN KEY (site_id) REFERENCES site(site_id),
    FOREIGN KEY (plant_id) REFERENCES plant(plant_id)
) COMMENT '产线管理表';

-- 工位管理表
CREATE TABLE workstation (
    station_id VARCHAR(32) PRIMARY KEY COMMENT '工位ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) NOT NULL COMMENT '站点ID',
    plant_id VARCHAR(32) NOT NULL COMMENT '工厂ID',
    line_id VARCHAR(32) NOT NULL COMMENT '产线ID',
    station_code VARCHAR(64) NOT NULL COMMENT '工位代码',
    station_name VARCHAR(128) NOT NULL COMMENT '工位名称',
    station_type ENUM('ASSEMBLY', 'TESTING', 'INSPECTION', 'PACKAGING', 'STORAGE') DEFAULT 'ASSEMBLY' COMMENT '工位类型',
    status ENUM('ACTIVE', 'INACTIVE', 'MAINTENANCE', 'BREAKDOWN') DEFAULT 'ACTIVE' COMMENT '状态',
    station_order INT DEFAULT 1 COMMENT '工位顺序',
    capacity_per_hour DECIMAL(10,2) DEFAULT 0 COMMENT '每小时产能',
    cycle_time DECIMAL(8,2) DEFAULT 0 COMMENT '节拍时间(秒)',
    setup_time DECIMAL(8,2) DEFAULT 0 COMMENT '换型时间(分钟)',
    location VARCHAR(255) COMMENT '位置',
    description TEXT COMMENT '描述',
    settings JSON COMMENT '工位配置',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_plant (plant_id),
    INDEX idx_line (line_id),
    INDEX idx_station_code (station_code),
    INDEX idx_station_name (station_name),
    INDEX idx_status (status),
    INDEX idx_station_order (station_order),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    FOREIGN KEY (site_id) REFERENCES site(site_id),
    FOREIGN KEY (plant_id) REFERENCES plant(plant_id),
    FOREIGN KEY (line_id) REFERENCES production_line(line_id)
) COMMENT '工位管理表';

-- 设备管理表
CREATE TABLE equipment (
    equipment_id VARCHAR(32) PRIMARY KEY COMMENT '设备ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) NOT NULL COMMENT '站点ID',
    plant_id VARCHAR(32) NOT NULL COMMENT '工厂ID',
    line_id VARCHAR(32) COMMENT '产线ID',
    station_id VARCHAR(32) COMMENT '工位ID',
    equipment_code VARCHAR(64) NOT NULL COMMENT '设备代码',
    equipment_name VARCHAR(128) NOT NULL COMMENT '设备名称',
    equipment_type ENUM('MACHINE', 'TOOL', 'INSTRUMENT', 'VEHICLE', 'COMPUTER', 'OTHER') DEFAULT 'MACHINE' COMMENT '设备类型',
    equipment_category VARCHAR(64) COMMENT '设备分类',
    manufacturer VARCHAR(128) COMMENT '制造商',
    model VARCHAR(128) COMMENT '型号',
    serial_number VARCHAR(128) COMMENT '序列号',
    status ENUM('ACTIVE', 'INACTIVE', 'MAINTENANCE', 'BREAKDOWN', 'RETIRED') DEFAULT 'ACTIVE' COMMENT '状态',
    purchase_date DATE COMMENT '采购日期',
    installation_date DATE COMMENT '安装日期',
    warranty_expire_date DATE COMMENT '保修过期日期',
    location VARCHAR(255) COMMENT '位置',
    description TEXT COMMENT '描述',
    specifications JSON COMMENT '技术规格',
    settings JSON COMMENT '设备配置',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_plant (plant_id),
    INDEX idx_line (line_id),
    INDEX idx_station (station_id),
    INDEX idx_equipment_code (equipment_code),
    INDEX idx_equipment_name (equipment_name),
    INDEX idx_equipment_type (equipment_type),
    INDEX idx_status (status),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    FOREIGN KEY (site_id) REFERENCES site(site_id),
    FOREIGN KEY (plant_id) REFERENCES plant(plant_id),
    FOREIGN KEY (line_id) REFERENCES production_line(line_id),
    FOREIGN KEY (station_id) REFERENCES workstation(station_id)
) COMMENT '设备管理表';

-- 传感器管理表
CREATE TABLE sensor (
    sensor_id VARCHAR(32) PRIMARY KEY COMMENT '传感器ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) NOT NULL COMMENT '站点ID',
    equipment_id VARCHAR(32) COMMENT '设备ID',
    sensor_code VARCHAR(64) NOT NULL COMMENT '传感器代码',
    sensor_name VARCHAR(128) NOT NULL COMMENT '传感器名称',
    sensor_type ENUM('TEMPERATURE', 'PRESSURE', 'VIBRATION', 'CURRENT', 'VOLTAGE', 'SPEED', 'POSITION', 'OTHER') DEFAULT 'OTHER' COMMENT '传感器类型',
    unit VARCHAR(16) COMMENT '单位',
    min_value DECIMAL(18,4) COMMENT '最小值',
    max_value DECIMAL(18,4) COMMENT '最大值',
    normal_min DECIMAL(18,4) COMMENT '正常范围最小值',
    normal_max DECIMAL(18,4) COMMENT '正常范围最大值',
    warning_min DECIMAL(18,4) COMMENT '警告范围最小值',
    warning_max DECIMAL(18,4) COMMENT '警告范围最大值',
    alarm_min DECIMAL(18,4) COMMENT '报警范围最小值',
    alarm_max DECIMAL(18,4) COMMENT '报警范围最大值',
    sampling_rate INT DEFAULT 1000 COMMENT '采样频率(Hz)',
    accuracy DECIMAL(8,4) COMMENT '精度',
    status ENUM('ACTIVE', 'INACTIVE', 'MAINTENANCE', 'FAULT') DEFAULT 'ACTIVE' COMMENT '状态',
    location VARCHAR(255) COMMENT '位置',
    description TEXT COMMENT '描述',
    calibration_date DATE COMMENT '校准日期',
    calibration_due_date DATE COMMENT '下次校准日期',
    settings JSON COMMENT '传感器配置',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_equipment (equipment_id),
    INDEX idx_sensor_code (sensor_code),
    INDEX idx_sensor_name (sensor_name),
    INDEX idx_sensor_type (sensor_type),
    INDEX idx_status (status),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    FOREIGN KEY (site_id) REFERENCES site(site_id),
    FOREIGN KEY (equipment_id) REFERENCES equipment(equipment_id)
) COMMENT '传感器管理表';

-- ==============================================
-- 4. 员工管理表
-- ==============================================

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

-- ==============================================
-- 5. 动态扩展表
-- ==============================================

-- 动态实体表
CREATE TABLE dynamic_entity (
    entity_id VARCHAR(40) PRIMARY KEY COMMENT '实体ID',
    entity_type VARCHAR(64) NOT NULL COMMENT '实体类型',
    entity_name VARCHAR(128) NOT NULL COMMENT '实体名称',
    entity_code VARCHAR(64) NOT NULL COMMENT '实体代码',
    description TEXT COMMENT '实体描述',
    schema_version VARCHAR(16) DEFAULT '1.0' COMMENT 'Schema版本',
    status ENUM('ACTIVE', 'INACTIVE', 'DRAFT') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_entity_type (entity_type),
    INDEX idx_entity_code (entity_code),
    INDEX idx_status (status)
) COMMENT '动态实体表';

-- 动态属性表
CREATE TABLE dynamic_attribute (
    attribute_id VARCHAR(40) PRIMARY KEY COMMENT '属性ID',
    entity_id VARCHAR(40) NOT NULL COMMENT '实体ID',
    attribute_name VARCHAR(64) NOT NULL COMMENT '属性名称',
    attribute_code VARCHAR(64) NOT NULL COMMENT '属性代码',
    attribute_type ENUM('STRING', 'INTEGER', 'DECIMAL', 'BOOLEAN', 'DATE', 'DATETIME', 'TEXT', 'JSON', 'FILE') NOT NULL COMMENT '属性类型',
    data_type VARCHAR(32) COMMENT '数据类型',
    length INT COMMENT '长度',
    precision INT COMMENT '精度',
    scale INT COMMENT '小数位',
    nullable BOOLEAN DEFAULT TRUE COMMENT '是否可空',
    default_value TEXT COMMENT '默认值',
    validation_rules JSON COMMENT '验证规则',
    display_order INT DEFAULT 0 COMMENT '显示顺序',
    is_searchable BOOLEAN DEFAULT FALSE COMMENT '是否可搜索',
    is_required BOOLEAN DEFAULT FALSE COMMENT '是否必填',
    description TEXT COMMENT '属性描述',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_entity (entity_id),
    INDEX idx_attribute_code (attribute_code),
    INDEX idx_attribute_name (attribute_name),
    UNIQUE KEY uk_entity_attribute (entity_id, attribute_code),
    FOREIGN KEY (entity_id) REFERENCES dynamic_entity(entity_id)
) COMMENT '动态属性表';

-- 动态属性值表
CREATE TABLE dynamic_attribute_value (
    value_id VARCHAR(40) PRIMARY KEY COMMENT '值ID',
    entity_id VARCHAR(40) NOT NULL COMMENT '实体ID',
    attribute_id VARCHAR(40) NOT NULL COMMENT '属性ID',
    record_id VARCHAR(64) NOT NULL COMMENT '记录ID',
    attribute_value TEXT COMMENT '属性值',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_entity (entity_id),
    INDEX idx_attribute (attribute_id),
    INDEX idx_record (record_id),
    UNIQUE KEY uk_entity_attribute_record (entity_id, attribute_id, record_id),
    FOREIGN KEY (entity_id) REFERENCES dynamic_entity(entity_id),
    FOREIGN KEY (attribute_id) REFERENCES dynamic_attribute(attribute_id)
) COMMENT '动态属性值表';

-- 通用事件类型定义表（元数据驱动）
CREATE TABLE trace_event_type (
    event_type_id VARCHAR(32) PRIMARY KEY COMMENT '事件类型ID',
    event_type_code VARCHAR(64) NOT NULL UNIQUE COMMENT '事件类型代码',
    category VARCHAR(32) NOT NULL COMMENT '事件类别',
    event_name VARCHAR(128) NOT NULL COMMENT '事件名称',
    description TEXT COMMENT '事件描述',
    schema_definition JSON NOT NULL COMMENT '动态Schema定义',
    business_rules JSON COMMENT '业务规则配置',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_event_type_code (event_type_code),
    INDEX idx_category (category),
    INDEX idx_status (status)
) COMMENT '通用事件类型定义表';

-- 通用事件记录表（支持任意业务事件）
CREATE TABLE universal_trace_event (
    event_id VARCHAR(40) PRIMARY KEY COMMENT '事件ID',
    event_type_id VARCHAR(32) NOT NULL COMMENT '事件类型ID',
    entity_type VARCHAR(32) NOT NULL COMMENT '实体类型',
    entity_id VARCHAR(64) NOT NULL COMMENT '实体ID',
    event_data JSON NOT NULL COMMENT '动态数据存储',
    event_time DATETIME NOT NULL COMMENT '事件时间',
    source_system VARCHAR(64) COMMENT '来源系统',
    source_user VARCHAR(64) COMMENT '操作用户',
    correlation_id VARCHAR(64) COMMENT '关联ID',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_event_type (event_type_id),
    INDEX idx_entity (entity_type, entity_id),
    INDEX idx_event_time (event_time),
    INDEX idx_source_system (source_system),
    INDEX idx_correlation_id (correlation_id),
    FOREIGN KEY (event_type_id) REFERENCES trace_event_type(event_type_id)
) COMMENT '通用事件记录表';

-- ==============================================
-- 6. 系统配置表
-- ==============================================

-- 系统配置表
CREATE TABLE sys_config (
    config_id VARCHAR(32) PRIMARY KEY COMMENT '配置ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    config_group VARCHAR(64) NOT NULL COMMENT '配置分组',
    config_key VARCHAR(128) NOT NULL COMMENT '配置键',
    config_value TEXT COMMENT '配置值',
    config_type ENUM('STRING', 'INTEGER', 'DECIMAL', 'BOOLEAN', 'JSON', 'TEXT') DEFAULT 'STRING' COMMENT '配置类型',
    description TEXT COMMENT '配置描述',
    is_system BOOLEAN DEFAULT FALSE COMMENT '是否系统配置',
    is_encrypted BOOLEAN DEFAULT FALSE COMMENT '是否加密',
    validation_rule VARCHAR(255) COMMENT '验证规则',
    default_value TEXT COMMENT '默认值',
    sort_order INT DEFAULT 0 COMMENT '排序',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_config_group (config_group),
    INDEX idx_config_key (config_key),
    INDEX idx_is_system (is_system),
    INDEX idx_status (status),
    UNIQUE KEY uk_tenant_site_group_key (tenant_id, site_id, config_group, config_key),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    FOREIGN KEY (site_id) REFERENCES site(site_id)
) COMMENT '系统配置表';

-- 系统字典表
CREATE TABLE sys_dict (
    dict_id VARCHAR(32) PRIMARY KEY COMMENT '字典ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    dict_type VARCHAR(64) NOT NULL COMMENT '字典类型',
    dict_code VARCHAR(64) NOT NULL COMMENT '字典代码',
    dict_label VARCHAR(128) NOT NULL COMMENT '字典标签',
    dict_value VARCHAR(255) COMMENT '字典值',
    parent_id VARCHAR(32) COMMENT '父字典ID',
    sort_order INT DEFAULT 0 COMMENT '排序',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    css_class VARCHAR(128) COMMENT 'CSS类名',
    list_class ENUM('DEFAULT', 'PRIMARY', 'SUCCESS', 'INFO', 'WARNING', 'DANGER') DEFAULT 'DEFAULT' COMMENT '列表样式',
    is_default BOOLEAN DEFAULT FALSE COMMENT '是否默认',
    description TEXT COMMENT '字典描述',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant (tenant_id),
    INDEX idx_dict_type (dict_type),
    INDEX idx_dict_code (dict_code),
    INDEX idx_parent_id (parent_id),
    INDEX idx_status (status),
    UNIQUE KEY uk_tenant_type_code (tenant_id, dict_type, dict_code),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    FOREIGN KEY (parent_id) REFERENCES sys_dict(dict_id)
) COMMENT '系统字典表';

-- 系统参数表
CREATE TABLE sys_parameter (
    parameter_id VARCHAR(32) PRIMARY KEY COMMENT '参数ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    parameter_group VARCHAR(64) NOT NULL COMMENT '参数分组',
    parameter_name VARCHAR(128) NOT NULL COMMENT '参数名称',
    parameter_code VARCHAR(128) NOT NULL COMMENT '参数代码',
    parameter_value TEXT COMMENT '参数值',
    parameter_type ENUM('STRING', 'INTEGER', 'DECIMAL', 'BOOLEAN', 'JSON', 'TEXT', 'FILE', 'URL') DEFAULT 'STRING' COMMENT '参数类型',
    description TEXT COMMENT '参数描述',
    is_system BOOLEAN DEFAULT FALSE COMMENT '是否系统参数',
    is_required BOOLEAN DEFAULT FALSE COMMENT '是否必需',
    is_readonly BOOLEAN DEFAULT FALSE COMMENT '是否只读',
    validation_rule VARCHAR(255) COMMENT '验证规则',
    default_value TEXT COMMENT '默认值',
    sort_order INT DEFAULT 0 COMMENT '排序',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_parameter_group (parameter_group),
    INDEX idx_parameter_code (parameter_code),
    INDEX idx_is_system (is_system),
    INDEX idx_status (status),
    UNIQUE KEY uk_tenant_site_group_code (tenant_id, site_id, parameter_group, parameter_code),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    FOREIGN KEY (site_id) REFERENCES site(site_id)
) COMMENT '系统参数表';

-- 系统通知表
CREATE TABLE sys_notification (
    notification_id VARCHAR(32) PRIMARY KEY COMMENT '通知ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    notification_type ENUM('SYSTEM', 'BUSINESS', 'ALERT', 'REMINDER', 'ANNOUNCEMENT') DEFAULT 'SYSTEM' COMMENT '通知类型',
    notification_level ENUM('INFO', 'WARNING', 'ERROR', 'CRITICAL') DEFAULT 'INFO' COMMENT '通知级别',
    title VARCHAR(255) NOT NULL COMMENT '通知标题',
    content TEXT NOT NULL COMMENT '通知内容',
    target_type ENUM('ALL', 'USER', 'ROLE', 'DEPARTMENT', 'CUSTOM') DEFAULT 'ALL' COMMENT '目标类型',
    target_ids JSON COMMENT '目标ID列表',
    sender_id VARCHAR(32) COMMENT '发送者ID',
    sender_name VARCHAR(128) COMMENT '发送者姓名',
    is_read BOOLEAN DEFAULT FALSE COMMENT '是否已读',
    read_time DATETIME COMMENT '阅读时间',
    expire_time DATETIME COMMENT '过期时间',
    status ENUM('DRAFT', 'SENT', 'READ', 'EXPIRED', 'CANCELLED') DEFAULT 'DRAFT' COMMENT '状态',
    attachments JSON COMMENT '附件列表',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_notification_type (notification_type),
    INDEX idx_notification_level (notification_level),
    INDEX idx_target_type (target_type),
    INDEX idx_sender_id (sender_id),
    INDEX idx_is_read (is_read),
    INDEX idx_expire_time (expire_time),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id),
    FOREIGN KEY (site_id) REFERENCES site(site_id)
) COMMENT '系统通知表';

-- 系统任务调度表
CREATE TABLE sys_job (
    job_id VARCHAR(32) PRIMARY KEY COMMENT '任务ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    job_name VARCHAR(128) NOT NULL COMMENT '任务名称',
    job_group VARCHAR(64) NOT NULL COMMENT '任务分组',
    job_class VARCHAR(255) NOT NULL COMMENT '任务类名',
    method_name VARCHAR(128) COMMENT '方法名',
    method_params VARCHAR(255) COMMENT '方法参数',
    cron_expression VARCHAR(128) COMMENT 'Cron表达式',
    misfire_policy ENUM('DO_NOTHING', 'FIRE_ONCE_NOW', 'IGNORE_MISFIRE') DEFAULT 'DO_NOTHING' COMMENT '错失执行策略',
    concurrent BOOLEAN DEFAULT FALSE COMMENT '是否并发执行',
    status ENUM('NORMAL', 'PAUSE', 'DELETE') DEFAULT 'NORMAL' COMMENT '状态',
    description TEXT COMMENT '任务描述',
    last_run_time DATETIME COMMENT '上次执行时间',
    next_run_time DATETIME COMMENT '下次执行时间',
    run_count INT DEFAULT 0 COMMENT '执行次数',
    success_count INT DEFAULT 0 COMMENT '成功次数',
    fail_count INT DEFAULT 0 COMMENT '失败次数',
    last_result TEXT COMMENT '上次执行结果',
    last_error TEXT COMMENT '上次执行错误',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant (tenant_id),
    INDEX idx_job_group (job_group),
    INDEX idx_status (status),
    INDEX idx_next_run_time (next_run_time),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id)
) COMMENT '系统任务调度表';

-- ==============================================
-- 7. 扩展数据库注册表
-- ==============================================

-- 扩展数据库注册表
CREATE TABLE extension_database (
    db_id VARCHAR(32) PRIMARY KEY COMMENT '数据库ID',
    db_name VARCHAR(64) NOT NULL UNIQUE COMMENT '数据库名称',
    db_type VARCHAR(32) NOT NULL COMMENT '数据库类型',
    db_description VARCHAR(255) COMMENT '数据库描述',
    business_module VARCHAR(64) NOT NULL COMMENT '业务模块',
    version VARCHAR(16) DEFAULT '1.0' COMMENT '版本',
    status ENUM('ACTIVE', 'INACTIVE', 'MAINTENANCE') DEFAULT 'ACTIVE' COMMENT '状态',
    connection_config JSON COMMENT '连接配置',
    api_endpoints JSON COMMENT 'API端点',
    dependencies JSON COMMENT '依赖关系',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_db_name (db_name),
    INDEX idx_db_type (db_type),
    INDEX idx_business_module (business_module),
    INDEX idx_status (status)
) COMMENT '扩展数据库注册表';

-- 跨数据库数据同步表
CREATE TABLE cross_db_sync (
    sync_id VARCHAR(32) PRIMARY KEY COMMENT '同步ID',
    source_db VARCHAR(64) NOT NULL COMMENT '源数据库',
    target_db VARCHAR(64) NOT NULL COMMENT '目标数据库',
    source_table VARCHAR(64) NOT NULL COMMENT '源表',
    target_table VARCHAR(64) NOT NULL COMMENT '目标表',
    sync_type ENUM('REAL_TIME', 'BATCH', 'EVENT_DRIVEN') DEFAULT 'BATCH' COMMENT '同步类型',
    sync_frequency VARCHAR(32) COMMENT '同步频率',
    last_sync_time DATETIME COMMENT '最后同步时间',
    sync_status ENUM('ACTIVE', 'PAUSED', 'ERROR') DEFAULT 'ACTIVE' COMMENT '同步状态',
    error_message TEXT COMMENT '错误信息',
    sync_config JSON COMMENT '同步配置',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_source_db (source_db),
    INDEX idx_target_db (target_db),
    INDEX idx_sync_type (sync_type),
    INDEX idx_sync_status (sync_status),
    INDEX idx_last_sync_time (last_sync_time)
) COMMENT '跨数据库数据同步表';

-- 添加外键约束
ALTER TABLE item_master ADD CONSTRAINT fk_item_supplier FOREIGN KEY (supplier_id) REFERENCES supplier_master(supplier_id);
