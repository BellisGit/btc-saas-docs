-- 02_system_data.sql
-- 系统基础数据初始化
-- 基于MES系统全局架构基础文档
-- 作者: MES开发团队
-- 日期: 2025-01-07

USE mes_core;

-- ==============================================
-- 1. 初始化租户和站点数据
-- ==============================================

-- 插入默认租户
INSERT INTO tenant (tenant_id, tenant_code, tenant_name, tenant_type, contact_person, contact_phone, contact_email, status, created_by) VALUES
('TENANT001', 'DEFAULT', '默认租户', 'ENTERPRISE', '系统管理员', '13800138000', 'admin@company.com', 'ACTIVE', 'system');

-- 插入默认站点
INSERT INTO site (site_id, tenant_id, site_code, site_name, site_type, address, timezone, currency, language, status, created_by) VALUES
('SITE001', 'TENANT001', 'MAIN', '主工厂', 'FACTORY', '深圳市南山区科技园', 'Asia/Shanghai', 'CNY', 'zh-CN', 'ACTIVE', 'system');

-- ==============================================
-- 2. 初始化系统用户和角色
-- ==============================================

-- 插入系统角色
INSERT INTO sys_role (role_id, tenant_id, role_code, role_name, role_type, description, status, created_by) VALUES
('ROLE001', 'TENANT001', 'SUPER_ADMIN', '超级管理员', 'SYSTEM', '系统超级管理员，拥有所有权限', 'ACTIVE', 'system'),
('ROLE002', 'TENANT001', 'ADMIN', '系统管理员', 'SYSTEM', '系统管理员，拥有系统管理权限', 'ACTIVE', 'system'),
('ROLE003', 'TENANT001', 'PRODUCTION_MANAGER', '生产经理', 'CUSTOM', '生产经理，负责生产管理', 'ACTIVE', 'system'),
('ROLE004', 'TENANT001', 'QUALITY_MANAGER', '质量经理', 'CUSTOM', '质量经理，负责质量管理', 'ACTIVE', 'system'),
('ROLE005', 'TENANT001', 'WAREHOUSE_MANAGER', '仓库经理', 'CUSTOM', '仓库经理，负责库存管理', 'ACTIVE', 'system'),
('ROLE006', 'TENANT001', 'LINE_SUPERVISOR', '线长', 'CUSTOM', '产线线长，负责产线管理', 'ACTIVE', 'system'),
('ROLE007', 'TENANT001', 'OPERATOR', '操作员', 'CUSTOM', '生产操作员，负责具体操作', 'ACTIVE', 'system'),
('ROLE008', 'TENANT001', 'QC_INSPECTOR', '质检员', 'CUSTOM', '质检员，负责质量检验', 'ACTIVE', 'system');

-- 插入默认系统用户
INSERT INTO sys_user (user_id, tenant_id, site_id, username, password_hash, email, phone, real_name, employee_no, department, position, status, created_by) VALUES
('USER001', 'TENANT001', 'SITE001', 'admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iKyVqjQ9zO7j8vQ1HvJ9L8j8vQ1H', 'admin@company.com', '13800138000', '系统管理员', 'EMP001', 'IT部门', '系统管理员', 'ACTIVE', 'system');

-- 分配用户角色
INSERT INTO sys_user_role (user_id, role_id, assigned_by) VALUES
('USER001', 'ROLE001', 'system');

-- ==============================================
-- 3. 初始化权限数据
-- ==============================================

-- 插入系统权限
INSERT INTO sys_permission (permission_id, permission_code, permission_name, permission_type, parent_id, menu_path, api_path, http_method, sort_order, icon, status, created_by) VALUES
-- 系统管理
('PERM001', 'system', '系统管理', 'MENU', NULL, '/system', NULL, NULL, 1, 'system', 'ACTIVE', 'system'),
('PERM002', 'system:user', '用户管理', 'MENU', 'PERM001', '/system/user', '/api/users', 'GET', 1, 'user', 'ACTIVE', 'system'),
('PERM003', 'system:role', '角色管理', 'MENU', 'PERM001', '/system/role', '/api/roles', 'GET', 2, 'role', 'ACTIVE', 'system'),
('PERM004', 'system:menu', '菜单管理', 'MENU', 'PERM001', '/system/menu', '/api/menus', 'GET', 3, 'menu', 'ACTIVE', 'system'),
('PERM005', 'system:config', '系统配置', 'MENU', 'PERM001', '/system/config', '/api/configs', 'GET', 4, 'config', 'ACTIVE', 'system'),
('PERM006', 'system:log', '操作日志', 'MENU', 'PERM001', '/system/log', '/api/logs', 'GET', 5, 'log', 'ACTIVE', 'system'),

-- 生产管理
('PERM007', 'production', '生产管理', 'MENU', NULL, '/production', NULL, NULL, 2, 'production', 'ACTIVE', 'system'),
('PERM008', 'production:workorder', '工单管理', 'MENU', 'PERM007', '/production/workorder', '/api/work-orders', 'GET', 1, 'workorder', 'ACTIVE', 'system'),
('PERM009', 'production:lot', '批次管理', 'MENU', 'PERM007', '/production/lot', '/api/production-lots', 'GET', 2, 'lot', 'ACTIVE', 'system'),
('PERM010', 'production:line', '产线管理', 'MENU', 'PERM007', '/production/line', '/api/production-lines', 'GET', 3, 'line', 'ACTIVE', 'system'),

-- 质量管理
('PERM011', 'quality', '质量管理', 'MENU', NULL, '/quality', NULL, NULL, 3, 'quality', 'ACTIVE', 'system'),
('PERM012', 'quality:inspection', '检验管理', 'MENU', 'PERM011', '/quality/inspection', '/api/inspections', 'GET', 1, 'inspection', 'ACTIVE', 'system'),
('PERM013', 'quality:defect', '缺陷管理', 'MENU', 'PERM011', '/quality/defect', '/api/defects', 'GET', 2, 'defect', 'ACTIVE', 'system'),
('PERM014', 'quality:ncr', '不合格报告', 'MENU', 'PERM011', '/quality/ncr', '/api/ncrs', 'GET', 3, 'ncr', 'ACTIVE', 'system'),

-- 库存管理
('PERM015', 'inventory', '库存管理', 'MENU', NULL, '/inventory', NULL, NULL, 4, 'inventory', 'ACTIVE', 'system'),
('PERM016', 'inventory:stock', '库存查询', 'MENU', 'PERM015', '/inventory/stock', '/api/stock', 'GET', 1, 'stock', 'ACTIVE', 'system'),
('PERM017', 'inventory:transaction', '库存事务', 'MENU', 'PERM015', '/inventory/transaction', '/api/stock-transactions', 'GET', 2, 'transaction', 'ACTIVE', 'system'),
('PERM018', 'inventory:location', '库位管理', 'MENU', 'PERM015', '/inventory/location', '/api/locations', 'GET', 3, 'location', 'ACTIVE', 'system'),

-- 追溯管理
('PERM019', 'trace', '追溯管理', 'MENU', NULL, '/trace', NULL, NULL, 5, 'trace', 'ACTIVE', 'system'),
('PERM020', 'trace:forward', '正向追溯', 'MENU', 'PERM019', '/trace/forward', '/api/trace/forward', 'GET', 1, 'forward', 'ACTIVE', 'system'),
('PERM021', 'trace:reverse', '反向追溯', 'MENU', 'PERM019', '/trace/reverse', '/api/trace/reverse', 'GET', 2, 'reverse', 'ACTIVE', 'system'),

-- BI报表
('PERM022', 'bi', 'BI报表', 'MENU', NULL, '/bi', NULL, NULL, 6, 'bi', 'ACTIVE', 'system'),
('PERM023', 'bi:dashboard', '仪表板', 'MENU', 'PERM022', '/bi/dashboard', '/api/bi/dashboard', 'GET', 1, 'dashboard', 'ACTIVE', 'system'),
('PERM024', 'bi:report', '报表中心', 'MENU', 'PERM022', '/bi/report', '/api/bi/reports', 'GET', 2, 'report', 'ACTIVE', 'system');

-- 分配角色权限
INSERT INTO sys_role_permission (role_id, permission_id, created_by) VALUES
-- 超级管理员拥有所有权限
('ROLE001', 'PERM001', 'system'),
('ROLE001', 'PERM002', 'system'),
('ROLE001', 'PERM003', 'system'),
('ROLE001', 'PERM004', 'system'),
('ROLE001', 'PERM005', 'system'),
('ROLE001', 'PERM006', 'system'),
('ROLE001', 'PERM007', 'system'),
('ROLE001', 'PERM008', 'system'),
('ROLE001', 'PERM009', 'system'),
('ROLE001', 'PERM010', 'system'),
('ROLE001', 'PERM011', 'system'),
('ROLE001', 'PERM012', 'system'),
('ROLE001', 'PERM013', 'system'),
('ROLE001', 'PERM014', 'system'),
('ROLE001', 'PERM015', 'system'),
('ROLE001', 'PERM016', 'system'),
('ROLE001', 'PERM017', 'system'),
('ROLE001', 'PERM018', 'system'),
('ROLE001', 'PERM019', 'system'),
('ROLE001', 'PERM020', 'system'),
('ROLE001', 'PERM021', 'system'),
('ROLE001', 'PERM022', 'system'),
('ROLE001', 'PERM023', 'system'),
('ROLE001', 'PERM024', 'system');

-- ==============================================
-- 4. 初始化菜单数据
-- ==============================================

-- 插入系统菜单
INSERT INTO sys_menu (menu_id, parent_id, menu_code, menu_name, menu_type, menu_path, component_path, icon, sort_order, is_visible, is_cache, status, created_by) VALUES
-- 一级菜单
('MENU001', NULL, 'dashboard', '仪表板', 'MENU', '/dashboard', 'views/Dashboard/index', 'dashboard', 1, 1, 0, 'ACTIVE', 'system'),
('MENU002', NULL, 'system', '系统管理', 'DIRECTORY', '/system', NULL, 'system', 2, 1, 0, 'ACTIVE', 'system'),
('MENU003', NULL, 'production', '生产管理', 'DIRECTORY', '/production', NULL, 'production', 3, 1, 0, 'ACTIVE', 'system'),
('MENU004', NULL, 'quality', '质量管理', 'DIRECTORY', '/quality', NULL, 'quality', 4, 1, 0, 'ACTIVE', 'system'),
('MENU005', NULL, 'inventory', '库存管理', 'DIRECTORY', '/inventory', NULL, 'inventory', 5, 1, 0, 'ACTIVE', 'system'),
('MENU006', NULL, 'trace', '追溯管理', 'DIRECTORY', '/trace', NULL, 'trace', 6, 1, 0, 'ACTIVE', 'system'),
('MENU007', NULL, 'bi', 'BI报表', 'DIRECTORY', '/bi', NULL, 'bi', 7, 1, 0, 'ACTIVE', 'system'),

-- 系统管理子菜单
('MENU008', 'MENU002', 'user', '用户管理', 'MENU', '/system/user', 'views/System/User/index', 'user', 1, 1, 0, 'ACTIVE', 'system'),
('MENU009', 'MENU002', 'role', '角色管理', 'MENU', '/system/role', 'views/System/Role/index', 'role', 2, 1, 0, 'ACTIVE', 'system'),
('MENU010', 'MENU002', 'menu', '菜单管理', 'MENU', '/system/menu', 'views/System/Menu/index', 'menu', 3, 1, 0, 'ACTIVE', 'system'),
('MENU011', 'MENU002', 'config', '系统配置', 'MENU', '/system/config', 'views/System/Config/index', 'config', 4, 1, 0, 'ACTIVE', 'system'),
('MENU012', 'MENU002', 'log', '操作日志', 'MENU', '/system/log', 'views/System/Log/index', 'log', 5, 1, 0, 'ACTIVE', 'system'),

-- 生产管理子菜单
('MENU013', 'MENU003', 'workorder', '工单管理', 'MENU', '/production/workorder', 'views/Production/WorkOrder/index', 'workorder', 1, 1, 0, 'ACTIVE', 'system'),
('MENU014', 'MENU003', 'lot', '批次管理', 'MENU', '/production/lot', 'views/Production/Lot/index', 'lot', 2, 1, 0, 'ACTIVE', 'system'),
('MENU015', 'MENU003', 'line', '产线管理', 'MENU', '/production/line', 'views/Production/Line/index', 'line', 3, 1, 0, 'ACTIVE', 'system'),

-- 质量管理子菜单
('MENU016', 'MENU004', 'inspection', '检验管理', 'MENU', '/quality/inspection', 'views/Quality/Inspection/index', 'inspection', 1, 1, 0, 'ACTIVE', 'system'),
('MENU017', 'MENU004', 'defect', '缺陷管理', 'MENU', '/quality/defect', 'views/Quality/Defect/index', 'defect', 2, 1, 0, 'ACTIVE', 'system'),
('MENU018', 'MENU004', 'ncr', '不合格报告', 'MENU', '/quality/ncr', 'views/Quality/NCR/index', 'ncr', 3, 1, 0, 'ACTIVE', 'system'),

-- 库存管理子菜单
('MENU019', 'MENU005', 'stock', '库存查询', 'MENU', '/inventory/stock', 'views/Inventory/Stock/index', 'stock', 1, 1, 0, 'ACTIVE', 'system'),
('MENU020', 'MENU005', 'transaction', '库存事务', 'MENU', '/inventory/transaction', 'views/Inventory/Transaction/index', 'transaction', 2, 1, 0, 'ACTIVE', 'system'),
('MENU021', 'MENU005', 'location', '库位管理', 'MENU', '/inventory/location', 'views/Inventory/Location/index', 'location', 3, 1, 0, 'ACTIVE', 'system'),

-- 追溯管理子菜单
('MENU022', 'MENU006', 'forward', '正向追溯', 'MENU', '/trace/forward', 'views/Trace/Forward/index', 'forward', 1, 1, 0, 'ACTIVE', 'system'),
('MENU023', 'MENU006', 'reverse', '反向追溯', 'MENU', '/trace/reverse', 'views/Trace/Reverse/index', 'reverse', 2, 1, 0, 'ACTIVE', 'system'),

-- BI报表子菜单
('MENU024', 'MENU007', 'dashboard', '仪表板', 'MENU', '/bi/dashboard', 'views/BI/Dashboard/index', 'dashboard', 1, 1, 0, 'ACTIVE', 'system'),
('MENU025', 'MENU007', 'report', '报表中心', 'MENU', '/bi/report', 'views/BI/Report/index', 'report', 2, 1, 0, 'ACTIVE', 'system');

-- ==============================================
-- 5. 初始化环境配置数据
-- ==============================================

-- 插入工厂数据
INSERT INTO plant (plant_id, tenant_id, site_id, plant_code, plant_name, plant_type, address, status, created_by) VALUES
('PLANT001', 'TENANT001', 'SITE001', 'MAIN_PLANT', '主生产工厂', 'MANUFACTURING', '深圳市南山区科技园主厂房', 'ACTIVE', 'system');

-- 插入产线数据
INSERT INTO production_line (line_id, plant_id, line_code, line_name, line_type, capacity_per_hour, working_hours_per_day, working_days_per_week, status, created_by) VALUES
('LINE001', 'PLANT001', 'L1', '产线1', 'ASSEMBLY', 100.00, 8.0, 5, 'ACTIVE', 'system'),
('LINE002', 'PLANT001', 'L2', '产线2', 'ASSEMBLY', 120.00, 8.0, 5, 'ACTIVE', 'system'),
('LINE003', 'PLANT001', 'L3', '测试线', 'TESTING', 80.00, 8.0, 5, 'ACTIVE', 'system');

-- 插入工位数据
INSERT INTO workstation (station_id, line_id, station_code, station_name, station_type, sequence_no, cycle_time, capacity_per_hour, operator_count, status, created_by) VALUES
('STATION001', 'LINE001', 'S1', '工位1', 'MANUAL', 1, 30.0, 120.0, 1, 'ACTIVE', 'system'),
('STATION002', 'LINE001', 'S2', '工位2', 'SEMI_AUTO', 2, 25.0, 144.0, 1, 'ACTIVE', 'system'),
('STATION003', 'LINE001', 'S3', '工位3', 'AUTO', 3, 20.0, 180.0, 0, 'ACTIVE', 'system'),
('STATION004', 'LINE002', 'S4', '工位4', 'MANUAL', 1, 35.0, 102.9, 1, 'ACTIVE', 'system'),
('STATION005', 'LINE002', 'S5', '工位5', 'SEMI_AUTO', 2, 30.0, 120.0, 1, 'ACTIVE', 'system'),
('STATION006', 'LINE003', 'S6', '测试工位1', 'TESTING', 1, 45.0, 80.0, 1, 'ACTIVE', 'system'),
('STATION007', 'LINE003', 'S7', '测试工位2', 'TESTING', 2, 40.0, 90.0, 1, 'ACTIVE', 'system');

-- 插入设备数据
INSERT INTO equipment (equipment_id, station_id, equipment_code, equipment_name, equipment_type, manufacturer, model, serial_number, status, created_by) VALUES
('EQUIP001', 'STATION001', 'EQ001', '手动装配台', 'MACHINE', '国产厂商', 'MA-100', 'SN001', 'RUNNING', 'system'),
('EQUIP002', 'STATION002', 'EQ002', '半自动装配机', 'MACHINE', '进口厂商', 'SA-200', 'SN002', 'RUNNING', 'system'),
('EQUIP003', 'STATION003', 'EQ003', '全自动装配线', 'MACHINE', '进口厂商', 'AA-300', 'SN003', 'RUNNING', 'system'),
('EQUIP004', 'STATION006', 'EQ004', '功能测试仪', 'TESTER', '测试厂商', 'FT-100', 'SN004', 'RUNNING', 'system'),
('EQUIP005', 'STATION007', 'EQ005', '外观检测机', 'TESTER', '检测厂商', 'VI-200', 'SN005', 'RUNNING', 'system');

-- ==============================================
-- 6. 初始化基础数据
-- ==============================================

-- 插入计量单位数据
INSERT INTO unit_of_measure (uom_id, uom_code, uom_name, uom_type, precision, status, created_by) VALUES
('UOM001', 'PCS', '个', 'COUNT', 0, 'ACTIVE', 'system'),
('UOM002', 'SET', '套', 'COUNT', 0, 'ACTIVE', 'system'),
('UOM003', 'KG', '千克', 'WEIGHT', 2, 'ACTIVE', 'system'),
('UOM004', 'M', '米', 'LENGTH', 2, 'ACTIVE', 'system'),
('UOM005', 'MM', '毫米', 'LENGTH', 1, 'ACTIVE', 'system'),
('UOM006', 'HOUR', '小时', 'TIME', 1, 'ACTIVE', 'system'),
('UOM007', 'MINUTE', '分钟', 'TIME', 0, 'ACTIVE', 'system'),
('UOM008', 'LITER', '升', 'VOLUME', 2, 'ACTIVE', 'system');

-- 插入库位数据
INSERT INTO location (location_id, tenant_id, site_id, location_code, location_name, location_type, warehouse_code, zone_code, aisle, shelf, level, position, capacity, status, created_by) VALUES
('LOC001', 'TENANT001', 'SITE001', 'WH-A-01-01-01', '主仓库A区1号货架1层1位', 'WAREHOUSE', 'WH001', 'A', 'A01', 'S01', 'L01', 'P01', 1000.00, 'ACTIVE', 'system'),
('LOC002', 'TENANT001', 'SITE001', 'WH-A-01-01-02', '主仓库A区1号货架1层2位', 'WAREHOUSE', 'WH001', 'A', 'A01', 'S01', 'L01', 'P02', 1000.00, 'ACTIVE', 'system'),
('LOC003', 'TENANT001', 'SITE001', 'PROD-L1-01', '产线1工位1', 'PRODUCTION', 'PROD001', 'L1', NULL, NULL, NULL, NULL, 100.00, 'ACTIVE', 'system'),
('LOC004', 'TENANT001', 'SITE001', 'QC-01-01', '质检区1号位置', 'QUALITY', 'QC001', 'QC', NULL, NULL, NULL, NULL, 500.00, 'ACTIVE', 'system'),
('LOC005', 'TENANT001', 'SITE001', 'SCRAP-01', '废料区1号', 'SCRAP', 'SCRAP001', 'SCRAP', NULL, NULL, NULL, NULL, 200.00, 'ACTIVE', 'system');

-- 插入班次数据
INSERT INTO shift (shift_id, tenant_id, shift_code, shift_name, start_time, end_time, work_days, is_night_shift, break_duration, status, created_by) VALUES
('SHIFT001', 'TENANT001', 'DAY', '白班', '08:00:00', '17:00:00', '["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY"]', 0, 60, 'ACTIVE', 'system'),
('SHIFT002', 'TENANT001', 'NIGHT', '夜班', '20:00:00', '05:00:00', '["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY"]', 1, 60, 'ACTIVE', 'system'),
('SHIFT003', 'TENANT001', 'OVERTIME', '加班', '18:00:00', '22:00:00', '["SATURDAY", "SUNDAY"]', 0, 30, 'ACTIVE', 'system');

-- ==============================================
-- 7. 初始化员工数据
-- ==============================================

-- 插入员工数据
INSERT INTO employee (employee_id, tenant_id, site_id, employee_no, real_name, english_name, phone, email, gender, hire_date, department, position, employment_type, status, created_by) VALUES
('EMP001', 'TENANT001', 'SITE001', 'EMP001', '张三', 'Zhang San', '13800138001', 'zhangsan@company.com', 'MALE', '2024-01-01', 'IT部门', '系统管理员', 'FULL_TIME', 'ACTIVE', 'system'),
('EMP002', 'TENANT001', 'SITE001', 'EMP002', '李四', 'Li Si', '13800138002', 'lisi@company.com', 'MALE', '2024-01-15', '生产部', '生产经理', 'FULL_TIME', 'ACTIVE', 'system'),
('EMP003', 'TENANT001', 'SITE001', 'EMP003', '王五', 'Wang Wu', '13800138003', 'wangwu@company.com', 'MALE', '2024-02-01', '质量部', '质量经理', 'FULL_TIME', 'ACTIVE', 'system'),
('EMP004', 'TENANT001', 'SITE001', 'EMP004', '赵六', 'Zhao Liu', '13800138004', 'zhaoliu@company.com', 'MALE', '2024-02-15', '仓库部', '仓库经理', 'FULL_TIME', 'ACTIVE', 'system'),
('EMP005', 'TENANT001', 'SITE001', 'EMP005', '孙七', 'Sun Qi', '13800138005', 'sunqi@company.com', 'MALE', '2024-03-01', '生产部', '线长', 'FULL_TIME', 'ACTIVE', 'system'),
('EMP006', 'TENANT001', 'SITE001', 'EMP006', '周八', 'Zhou Ba', '13800138006', 'zhouba@company.com', 'MALE', '2024-03-15', '生产部', '操作员', 'FULL_TIME', 'ACTIVE', 'system'),
('EMP007', 'TENANT001', 'SITE001', 'EMP007', '吴九', 'Wu Jiu', '13800138007', 'wujiu@company.com', 'MALE', '2024-04-01', '质量部', '质检员', 'FULL_TIME', 'ACTIVE', 'system');

-- 插入技能数据
INSERT INTO skill (skill_id, skill_code, skill_name, skill_category, skill_level, description, certification_required, validity_period, status, created_by) VALUES
('SKILL001', 'ASSEMBLY', '装配技能', 'PRODUCTION', 'INTERMEDIATE', '电子产品装配技能', 1, 12, 'ACTIVE', 'system'),
('SKILL002', 'TESTING', '测试技能', 'QUALITY', 'ADVANCED', '产品功能测试技能', 1, 12, 'ACTIVE', 'system'),
('SKILL003', 'INSPECTION', '检验技能', 'QUALITY', 'INTERMEDIATE', '产品质量检验技能', 1, 12, 'ACTIVE', 'system'),
('SKILL004', 'OPERATION', '设备操作', 'PRODUCTION', 'BEGINNER', '生产设备操作技能', 0, 6, 'ACTIVE', 'system'),
('SKILL005', 'MAINTENANCE', '设备维护', 'MAINTENANCE', 'ADVANCED', '生产设备维护技能', 1, 24, 'ACTIVE', 'system');

-- 分配员工技能
INSERT INTO employee_skill (employee_id, skill_id, skill_level, certified_date, expires_date, certified_by, status, created_by) VALUES
('EMP005', 'SKILL001', 'ADVANCED', '2024-01-01', '2025-01-01', 'EMP002', 'ACTIVE', 'system'),
('EMP006', 'SKILL001', 'INTERMEDIATE', '2024-03-15', '2025-03-15', 'EMP005', 'ACTIVE', 'system'),
('EMP006', 'SKILL004', 'INTERMEDIATE', '2024-03-15', '2024-09-15', 'EMP005', 'ACTIVE', 'system'),
('EMP007', 'SKILL002', 'ADVANCED', '2024-04-01', '2025-04-01', 'EMP003', 'ACTIVE', 'system'),
('EMP007', 'SKILL003', 'ADVANCED', '2024-04-01', '2025-04-01', 'EMP003', 'ACTIVE', 'system');

-- ==============================================
-- 8. 初始化系统配置数据
-- ==============================================

-- 插入系统配置
INSERT INTO sys_config (config_id, tenant_id, config_key, config_value, config_type, config_group, description, is_system, status, created_by) VALUES
('CONFIG001', 'TENANT001', 'system.name', 'MES制造执行系统', 'STRING', 'system', '系统名称', 1, 'ACTIVE', 'system'),
('CONFIG002', 'TENANT001', 'system.version', '1.0.0', 'STRING', 'system', '系统版本', 1, 'ACTIVE', 'system'),
('CONFIG003', 'TENANT001', 'system.logo', '/assets/images/logo.png', 'STRING', 'system', '系统Logo', 1, 'ACTIVE', 'system'),
('CONFIG004', 'TENANT001', 'auth.jwt.secret', 'mes_jwt_secret_key_2025', 'STRING', 'auth', 'JWT密钥', 1, 'ACTIVE', 'system'),
('CONFIG005', 'TENANT001', 'auth.jwt.expires', '86400', 'NUMBER', 'auth', 'JWT过期时间(秒)', 1, 'ACTIVE', 'system'),
('CONFIG006', 'TENANT001', 'upload.max.size', '10485760', 'NUMBER', 'upload', '最大上传文件大小(字节)', 1, 'ACTIVE', 'system'),
('CONFIG007', 'TENANT001', 'upload.allowed.types', 'jpg,jpeg,png,pdf,doc,docx,xls,xlsx', 'STRING', 'upload', '允许上传的文件类型', 1, 'ACTIVE', 'system'),
('CONFIG008', 'TENANT001', 'quality.aql.level1', '0.65', 'NUMBER', 'quality', 'AQL等级1', 1, 'ACTIVE', 'system'),
('CONFIG009', 'TENANT001', 'quality.aql.level2', '2.5', 'NUMBER', 'quality', 'AQL等级2', 1, 'ACTIVE', 'system'),
('CONFIG010', 'TENANT001', 'quality.aql.level3', '4.0', 'NUMBER', 'quality', 'AQL等级3', 1, 'ACTIVE', 'system');

-- 插入数据字典
INSERT INTO sys_dict (dict_id, dict_type, dict_key, dict_value, dict_label, sort_order, status, created_by) VALUES
-- 物料类型字典
('DICT001', 'item_type', 'RAW', 'RAW', '原材料', 1, 'ACTIVE', 'system'),
('DICT002', 'item_type', 'COMPONENT', 'COMPONENT', '半成品', 2, 'ACTIVE', 'system'),
('DICT003', 'item_type', 'FINISHED', 'FINISHED', '成品', 3, 'ACTIVE', 'system'),
('DICT004', 'item_type', 'TOOL', 'TOOL', '工具', 4, 'ACTIVE', 'system'),
('DICT005', 'item_type', 'CONSUMABLE', 'CONSUMABLE', '消耗品', 5, 'ACTIVE', 'system'),

-- 工单状态字典
('DICT006', 'work_order_status', 'DRAFT', 'DRAFT', '草稿', 1, 'ACTIVE', 'system'),
('DICT007', 'work_order_status', 'RELEASED', 'RELEASED', '已发布', 2, 'ACTIVE', 'system'),
('DICT008', 'work_order_status', 'IN_PROGRESS', 'IN_PROGRESS', '进行中', 3, 'ACTIVE', 'system'),
('DICT009', 'work_order_status', 'COMPLETED', 'COMPLETED', '已完成', 4, 'ACTIVE', 'system'),
('DICT010', 'work_order_status', 'CANCELLED', 'CANCELLED', '已取消', 5, 'ACTIVE', 'system'),
('DICT011', 'work_order_status', 'ON_HOLD', 'ON_HOLD', '暂停', 6, 'ACTIVE', 'system'),

-- 检验类型字典
('DICT012', 'inspection_type', 'IQC', 'IQC', '来料检验', 1, 'ACTIVE', 'system'),
('DICT013', 'inspection_type', 'IPQC', 'IPQC', '过程检验', 2, 'ACTIVE', 'system'),
('DICT014', 'inspection_type', 'OQC', 'OQC', '出货检验', 3, 'ACTIVE', 'system'),
('DICT015', 'inspection_type', 'FAI', 'FAI', '首件检验', 4, 'ACTIVE', 'system'),

-- 检验结果字典
('DICT016', 'inspection_result', 'PASS', 'PASS', '通过', 1, 'ACTIVE', 'system'),
('DICT017', 'inspection_result', 'FAIL', 'FAIL', '不通过', 2, 'ACTIVE', 'system'),
('DICT018', 'inspection_result', 'SPECIAL', 'SPECIAL', '特采', 3, 'ACTIVE', 'system'),
('DICT019', 'inspection_result', 'PENDING', 'PENDING', '待检验', 4, 'ACTIVE', 'system');
