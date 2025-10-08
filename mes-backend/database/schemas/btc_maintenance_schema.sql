-- ==============================================
-- BTC设备维护数据库 - 扩展数据库示例
-- 独立数据库，通过API与核心数据库集成
-- ==============================================

-- 创建BTC设备维护数据库
CREATE DATABASE IF NOT EXISTS btc_maintenance CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE btc_maintenance;

-- ==============================================
-- 1. 维护基础表
-- ==============================================

-- 维护计划表
CREATE TABLE maintenance_plan (
    plan_id VARCHAR(32) PRIMARY KEY COMMENT '维护计划ID',
    plan_code VARCHAR(64) NOT NULL UNIQUE COMMENT '维护计划代码',
    plan_name VARCHAR(128) NOT NULL COMMENT '维护计划名称',
    equipment_id VARCHAR(32) NOT NULL COMMENT '设备ID（来自核心数据库）',
    equipment_code VARCHAR(64) COMMENT '设备代码（冗余字段）',
    equipment_name VARCHAR(128) COMMENT '设备名称（冗余字段）',
    plan_type ENUM('PREVENTIVE', 'PREDICTIVE', 'CORRECTIVE', 'EMERGENCY') DEFAULT 'PREVENTIVE' COMMENT '维护类型',
    maintenance_category VARCHAR(64) COMMENT '维护类别',
    frequency_type ENUM('DAILY', 'WEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY', 'USAGE_BASED', 'TIME_BASED') DEFAULT 'MONTHLY' COMMENT '频率类型',
    frequency_value INT DEFAULT 1 COMMENT '频率值',
    frequency_unit VARCHAR(16) COMMENT '频率单位',
    estimated_duration INT DEFAULT 60 COMMENT '预计耗时（分钟）',
    estimated_cost DECIMAL(18,2) DEFAULT 0 COMMENT '预计成本',
    priority ENUM('LOW', 'NORMAL', 'HIGH', 'URGENT') DEFAULT 'NORMAL' COMMENT '优先级',
    status ENUM('ACTIVE', 'INACTIVE', 'SUSPENDED') DEFAULT 'ACTIVE' COMMENT '状态',
    description TEXT COMMENT '描述',
    maintenance_procedures TEXT COMMENT '维护程序',
    required_skills JSON COMMENT '所需技能',
    required_tools JSON COMMENT '所需工具',
    required_parts JSON COMMENT '所需备件',
    safety_requirements TEXT COMMENT '安全要求',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_plan_code (plan_code),
    INDEX idx_equipment_id (equipment_id),
    INDEX idx_plan_type (plan_type),
    INDEX idx_frequency_type (frequency_type),
    INDEX idx_priority (priority),
    INDEX idx_status (status),
    INDEX idx_tenant_site (tenant_id, site_id)
) COMMENT '维护计划表';

-- 维护工单表
CREATE TABLE maintenance_workorder (
    wo_id VARCHAR(32) PRIMARY KEY COMMENT '工单ID',
    wo_number VARCHAR(64) NOT NULL UNIQUE COMMENT '工单号',
    plan_id VARCHAR(32) COMMENT '维护计划ID',
    equipment_id VARCHAR(32) NOT NULL COMMENT '设备ID',
    equipment_code VARCHAR(64) COMMENT '设备代码',
    equipment_name VARCHAR(128) COMMENT '设备名称',
    wo_type ENUM('PREVENTIVE', 'PREDICTIVE', 'CORRECTIVE', 'EMERGENCY') DEFAULT 'PREVENTIVE' COMMENT '工单类型',
    priority ENUM('LOW', 'NORMAL', 'HIGH', 'URGENT') DEFAULT 'NORMAL' COMMENT '优先级',
    wo_status ENUM('DRAFT', 'PLANNED', 'ASSIGNED', 'IN_PROGRESS', 'ON_HOLD', 'COMPLETED', 'CANCELLED') DEFAULT 'DRAFT' COMMENT '工单状态',
    title VARCHAR(255) NOT NULL COMMENT '标题',
    description TEXT COMMENT '描述',
    work_description TEXT COMMENT '工作描述',
    safety_requirements TEXT COMMENT '安全要求',
    estimated_duration INT DEFAULT 60 COMMENT '预计耗时（分钟）',
    actual_duration INT COMMENT '实际耗时（分钟）',
    estimated_cost DECIMAL(18,2) DEFAULT 0 COMMENT '预计成本',
    actual_cost DECIMAL(18,2) COMMENT '实际成本',
    scheduled_start DATETIME COMMENT '计划开始时间',
    scheduled_end DATETIME COMMENT '计划结束时间',
    actual_start DATETIME COMMENT '实际开始时间',
    actual_end DATETIME COMMENT '实际结束时间',
    assigned_to VARCHAR(64) COMMENT '分配给',
    assigned_by VARCHAR(64) COMMENT '分配人',
    assigned_date DATETIME COMMENT '分配日期',
    completed_by VARCHAR(64) COMMENT '完成人',
    completed_date DATETIME COMMENT '完成日期',
    approval_required BOOLEAN DEFAULT FALSE COMMENT '是否需要审批',
    approved_by VARCHAR(64) COMMENT '审批人',
    approved_date DATETIME COMMENT '审批日期',
    failure_code VARCHAR(32) COMMENT '故障代码',
    failure_description TEXT COMMENT '故障描述',
    root_cause TEXT COMMENT '根本原因',
    corrective_actions TEXT COMMENT '纠正措施',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_wo_number (wo_number),
    INDEX idx_plan_id (plan_id),
    INDEX idx_equipment_id (equipment_id),
    INDEX idx_wo_type (wo_type),
    INDEX idx_wo_status (wo_status),
    INDEX idx_priority (priority),
    INDEX idx_assigned_to (assigned_to),
    INDEX idx_scheduled_start (scheduled_start),
    INDEX idx_tenant_site (tenant_id, site_id),
    FOREIGN KEY (plan_id) REFERENCES maintenance_plan(plan_id)
) COMMENT '维护工单表';

-- 维护任务表
CREATE TABLE maintenance_task (
    task_id VARCHAR(32) PRIMARY KEY COMMENT '任务ID',
    wo_id VARCHAR(32) NOT NULL COMMENT '工单ID',
    task_code VARCHAR(64) NOT NULL COMMENT '任务代码',
    task_name VARCHAR(128) NOT NULL COMMENT '任务名称',
    task_type ENUM('INSPECTION', 'CLEANING', 'LUBRICATION', 'REPLACEMENT', 'CALIBRATION', 'REPAIR', 'TESTING') DEFAULT 'INSPECTION' COMMENT '任务类型',
    task_sequence INT DEFAULT 1 COMMENT '任务顺序',
    task_status ENUM('PENDING', 'IN_PROGRESS', 'COMPLETED', 'SKIPPED') DEFAULT 'PENDING' COMMENT '任务状态',
    description TEXT COMMENT '任务描述',
    instructions TEXT COMMENT '操作说明',
    estimated_duration INT DEFAULT 30 COMMENT '预计耗时（分钟）',
    actual_duration INT COMMENT '实际耗时（分钟）',
    assigned_to VARCHAR(64) COMMENT '分配给',
    started_by VARCHAR(64) COMMENT '开始人',
    completed_by VARCHAR(64) COMMENT '完成人',
    started_at DATETIME COMMENT '开始时间',
    completed_at DATETIME COMMENT '完成时间',
    result ENUM('PASS', 'FAIL', 'SKIP') COMMENT '结果',
    result_description TEXT COMMENT '结果描述',
    observations TEXT COMMENT '观察记录',
    measurements JSON COMMENT '测量数据',
    photos JSON COMMENT '照片列表',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_wo_id (wo_id),
    INDEX idx_task_code (task_code),
    INDEX idx_task_type (task_type),
    INDEX idx_task_status (task_status),
    INDEX idx_assigned_to (assigned_to),
    INDEX idx_tenant_site (tenant_id, site_id),
    FOREIGN KEY (wo_id) REFERENCES maintenance_workorder(wo_id)
) COMMENT '维护任务表';

-- 备件使用记录表
CREATE TABLE spare_part_usage (
    usage_id VARCHAR(32) PRIMARY KEY COMMENT '使用记录ID',
    wo_id VARCHAR(32) NOT NULL COMMENT '工单ID',
    part_id VARCHAR(32) NOT NULL COMMENT '备件ID',
    part_code VARCHAR(64) COMMENT '备件代码',
    part_name VARCHAR(128) COMMENT '备件名称',
    part_category VARCHAR(64) COMMENT '备件类别',
    quantity_used DECIMAL(18,4) NOT NULL COMMENT '使用数量',
    unit_cost DECIMAL(18,2) COMMENT '单价',
    total_cost DECIMAL(18,2) COMMENT '总成本',
    supplier VARCHAR(128) COMMENT '供应商',
    batch_number VARCHAR(64) COMMENT '批次号',
    expiry_date DATE COMMENT '过期日期',
    usage_date DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '使用日期',
    used_by VARCHAR(64) COMMENT '使用人',
    notes TEXT COMMENT '备注',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_wo_id (wo_id),
    INDEX idx_part_id (part_id),
    INDEX idx_part_code (part_code),
    INDEX idx_usage_date (usage_date),
    INDEX idx_tenant_site (tenant_id, site_id),
    FOREIGN KEY (wo_id) REFERENCES maintenance_workorder(wo_id)
) COMMENT '备件使用记录表';

-- 维护成本表
CREATE TABLE maintenance_cost (
    cost_id VARCHAR(32) PRIMARY KEY COMMENT '成本ID',
    wo_id VARCHAR(32) NOT NULL COMMENT '工单ID',
    cost_type ENUM('LABOR', 'PARTS', 'TOOLS', 'EXTERNAL', 'OTHER') DEFAULT 'LABOR' COMMENT '成本类型',
    cost_category VARCHAR(64) COMMENT '成本类别',
    description TEXT COMMENT '成本描述',
    quantity DECIMAL(18,4) DEFAULT 1 COMMENT '数量',
    unit_cost DECIMAL(18,2) NOT NULL COMMENT '单价',
    total_cost DECIMAL(18,2) NOT NULL COMMENT '总成本',
    currency VARCHAR(8) DEFAULT 'CNY' COMMENT '货币',
    cost_date DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '成本日期',
    supplier VARCHAR(128) COMMENT '供应商',
    invoice_number VARCHAR(64) COMMENT '发票号',
    approval_required BOOLEAN DEFAULT FALSE COMMENT '是否需要审批',
    approved_by VARCHAR(64) COMMENT '审批人',
    approved_date DATETIME COMMENT '审批日期',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_wo_id (wo_id),
    INDEX idx_cost_type (cost_type),
    INDEX idx_cost_category (cost_category),
    INDEX idx_cost_date (cost_date),
    INDEX idx_tenant_site (tenant_id, site_id),
    FOREIGN KEY (wo_id) REFERENCES maintenance_workorder(wo_id)
) COMMENT '维护成本表';

-- 维护文档表
CREATE TABLE maintenance_document (
    doc_id VARCHAR(32) PRIMARY KEY COMMENT '文档ID',
    wo_id VARCHAR(32) COMMENT '工单ID',
    plan_id VARCHAR(32) COMMENT '维护计划ID',
    doc_type ENUM('PROCEDURE', 'MANUAL', 'CHECKLIST', 'REPORT', 'PHOTO', 'VIDEO', 'OTHER') DEFAULT 'REPORT' COMMENT '文档类型',
    doc_name VARCHAR(255) NOT NULL COMMENT '文档名称',
    doc_description TEXT COMMENT '文档描述',
    file_path VARCHAR(500) NOT NULL COMMENT '文件路径',
    file_size BIGINT COMMENT '文件大小（字节）',
    file_type VARCHAR(64) COMMENT '文件类型',
    upload_date DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '上传日期',
    uploaded_by VARCHAR(64) COMMENT '上传人',
    version VARCHAR(16) COMMENT '版本号',
    is_template BOOLEAN DEFAULT FALSE COMMENT '是否模板',
    template_type VARCHAR(64) COMMENT '模板类型',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_wo_id (wo_id),
    INDEX idx_plan_id (plan_id),
    INDEX idx_doc_type (doc_type),
    INDEX idx_upload_date (upload_date),
    INDEX idx_tenant_site (tenant_id, site_id),
    FOREIGN KEY (wo_id) REFERENCES maintenance_workorder(wo_id),
    FOREIGN KEY (plan_id) REFERENCES maintenance_plan(plan_id)
) COMMENT '维护文档表';

-- 维护历史记录表
CREATE TABLE maintenance_history (
    history_id VARCHAR(32) PRIMARY KEY COMMENT '历史记录ID',
    equipment_id VARCHAR(32) NOT NULL COMMENT '设备ID',
    equipment_code VARCHAR(64) COMMENT '设备代码',
    equipment_name VARCHAR(128) COMMENT '设备名称',
    wo_id VARCHAR(32) COMMENT '工单ID',
    wo_number VARCHAR(64) COMMENT '工单号',
    maintenance_type ENUM('PREVENTIVE', 'PREDICTIVE', 'CORRECTIVE', 'EMERGENCY') COMMENT '维护类型',
    maintenance_date DATETIME NOT NULL COMMENT '维护日期',
    maintenance_duration INT COMMENT '维护耗时（分钟）',
    maintenance_cost DECIMAL(18,2) COMMENT '维护成本',
    maintenance_personnel VARCHAR(255) COMMENT '维护人员',
    work_description TEXT COMMENT '工作描述',
    failure_code VARCHAR(32) COMMENT '故障代码',
    failure_description TEXT COMMENT '故障描述',
    root_cause TEXT COMMENT '根本原因',
    corrective_actions TEXT COMMENT '纠正措施',
    preventive_actions TEXT COMMENT '预防措施',
    parts_replaced JSON COMMENT '更换备件',
    measurements_before JSON COMMENT '维护前测量值',
    measurements_after JSON COMMENT '维护后测量值',
    maintenance_result ENUM('SUCCESS', 'PARTIAL', 'FAILED') COMMENT '维护结果',
    next_maintenance_date DATETIME COMMENT '下次维护日期',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_equipment_id (equipment_id),
    INDEX idx_wo_id (wo_id),
    INDEX idx_maintenance_type (maintenance_type),
    INDEX idx_maintenance_date (maintenance_date),
    INDEX idx_tenant_site (tenant_id, site_id),
    FOREIGN KEY (wo_id) REFERENCES maintenance_workorder(wo_id)
) COMMENT '维护历史记录表';

-- 维护计划执行统计表
CREATE TABLE maintenance_plan_stats (
    stats_id VARCHAR(32) PRIMARY KEY COMMENT '统计ID',
    plan_id VARCHAR(32) NOT NULL COMMENT '维护计划ID',
    equipment_id VARCHAR(32) NOT NULL COMMENT '设备ID',
    stats_period DATE NOT NULL COMMENT '统计周期',
    planned_count INT DEFAULT 0 COMMENT '计划次数',
    executed_count INT DEFAULT 0 COMMENT '执行次数',
    completed_count INT DEFAULT 0 COMMENT '完成次数',
    overdue_count INT DEFAULT 0 COMMENT '逾期次数',
    cancelled_count INT DEFAULT 0 COMMENT '取消次数',
    avg_duration DECIMAL(8,2) COMMENT '平均耗时（分钟）',
    avg_cost DECIMAL(18,2) COMMENT '平均成本',
    total_cost DECIMAL(18,2) DEFAULT 0 COMMENT '总成本',
    completion_rate DECIMAL(5,2) COMMENT '完成率',
    on_time_rate DECIMAL(5,2) COMMENT '准时率',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_plan_id (plan_id),
    INDEX idx_equipment_id (equipment_id),
    INDEX idx_stats_period (stats_period),
    INDEX idx_tenant_site (tenant_id, site_id),
    UNIQUE KEY uk_plan_equipment_period (plan_id, equipment_id, stats_period),
    FOREIGN KEY (plan_id) REFERENCES maintenance_plan(plan_id)
) COMMENT '维护计划执行统计表';


-- ==============================================
-- 2. 初始化数据
-- ==============================================

-- 插入示例维护计划
INSERT INTO maintenance_plan (
    plan_id, plan_code, plan_name, equipment_id, equipment_code, equipment_name,
    plan_type, maintenance_category, frequency_type, frequency_value,
    estimated_duration, estimated_cost, priority, status, description,
    tenant_id, site_id, created_by
) VALUES (
    'PLAN_001', 'PM_001', '设备日常保养', 'EQ_001', 'EQ001', '生产线设备001',
    'PREVENTIVE', 'ROUTINE', 'DAILY', 1,
    30, 50.00, 'NORMAL', 'ACTIVE', '日常清洁和润滑保养',
    'TENANT_001', 'SITE_001', 'SYSTEM'
);

-- 插入示例维护工单
INSERT INTO maintenance_workorder (
    wo_id, wo_number, plan_id, equipment_id, equipment_code, equipment_name,
    wo_type, priority, wo_status, title, description,
    estimated_duration, estimated_cost, scheduled_start, scheduled_end,
    assigned_to, tenant_id, site_id, created_by
) VALUES (
    'WO_001', 'WO20250107001', 'PLAN_001', 'EQ_001', 'EQ001', '生产线设备001',
    'PREVENTIVE', 'NORMAL', 'PLANNED', '设备日常保养工单',
    '按照维护计划执行日常保养工作',
    30, 50.00, '2025-01-07 09:00:00', '2025-01-07 09:30:00',
    'TECH_001', 'TENANT_001', 'SITE_001', 'SYSTEM'
);