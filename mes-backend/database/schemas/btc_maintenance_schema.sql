-- ==============================================
-- BTC设备维护数据�?- 扩展数据库示�?
-- 独立数据库，通过API与核心数据库集成
-- ==============================================

-- 创建BTC设备维护数据�?
CREATE DATABASE IF NOT EXISTS btc_maintenance CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE btc_maintenance;

-- ==============================================
-- 1. 维护基础�?
-- ==============================================

-- 维护计划�?
CREATE TABLE maintenance_plan (
    plan_id VARCHAR(32) PRIMARY KEY COMMENT '维护计划ID',
    plan_code VARCHAR(64) NOT NULL UNIQUE COMMENT '维护计划代码',
    plan_name VARCHAR(128) NOT NULL COMMENT '维护计划名称',
    equipment_id VARCHAR(32) NOT NULL COMMENT '设备ID（来自核心数据库�?,
    equipment_code VARCHAR(64) COMMENT '设备代码（冗余字段）',
    equipment_name VARCHAR(128) COMMENT '设备名称（冗余字段）',
    plan_type ENUM('PREVENTIVE', 'PREDICTIVE', 'CORRECTIVE', 'EMERGENCY') DEFAULT 'PREVENTIVE' COMMENT '维护类型',
    maintenance_category VARCHAR(64) COMMENT '维护类别',
    frequency_type ENUM('DAILY', 'WEEKLY', 'MONTHLY', 'QUARTERLY', 'YEARLY', 'USAGE_BASED', 'TIME_BASED') DEFAULT 'MONTHLY' COMMENT '频率类型',
    frequency_value INT DEFAULT 1 COMMENT '频率�?,
    frequency_unit VARCHAR(16) COMMENT '频率单位',
    estimated_duration INT DEFAULT 60 COMMENT '预计耗时（分钟）',
    estimated_cost DECIMAL(18,2) DEFAULT 0 COMMENT '预计成本',
    priority ENUM('LOW', 'NORMAL', 'HIGH', 'URGENT') DEFAULT 'NORMAL' COMMENT '优先�?,
    status ENUM('ACTIVE', 'INACTIVE', 'SUSPENDED') DEFAULT 'ACTIVE' COMMENT '状�?,
    description TEXT COMMENT '描述',
    maintenance_procedures TEXT COMMENT '维护程序',
    required_skills JSON COMMENT '所需技�?,
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
) COMMENT '维护计划�?;

-- 维护工单�?
CREATE TABLE maintenance_work_order (
    wo_id VARCHAR(32) PRIMARY KEY COMMENT '工单ID',
    wo_number VARCHAR(64) NOT NULL UNIQUE COMMENT '工单�?,
    plan_id VARCHAR(32) COMMENT '维护计划ID',
    equipment_id VARCHAR(32) NOT NULL COMMENT '设备ID',
    equipment_code VARCHAR(64) COMMENT '设备代码（冗余字段）',
    equipment_name VARCHAR(128) COMMENT '设备名称（冗余字段）',
    wo_type ENUM('PLANNED', 'UNPLANNED', 'EMERGENCY', 'BREAKDOWN') DEFAULT 'PLANNED' COMMENT '工单类型',
    priority ENUM('LOW', 'NORMAL', 'HIGH', 'URGENT', 'CRITICAL') DEFAULT 'NORMAL' COMMENT '优先�?,
    wo_status ENUM('DRAFT', 'ASSIGNED', 'IN_PROGRESS', 'ON_HOLD', 'COMPLETED', 'CANCELLED', 'CLOSED') DEFAULT 'DRAFT' COMMENT '工单状�?,
    title VARCHAR(255) NOT NULL COMMENT '工单标题',
    description TEXT COMMENT '问题描述',
    root_cause TEXT COMMENT '根本原因',
    work_performed TEXT COMMENT '执行工作',
    assigned_to VARCHAR(64) COMMENT '分配�?,
    assigned_date DATETIME COMMENT '分配日期',
    scheduled_start DATETIME COMMENT '计划开始时�?,
    scheduled_end DATETIME COMMENT '计划结束时间',
    actual_start DATETIME COMMENT '实际开始时�?,
    actual_end DATETIME COMMENT '实际结束时间',
    estimated_duration INT COMMENT '预计耗时（分钟）',
    actual_duration INT COMMENT '实际耗时（分钟）',
    estimated_cost DECIMAL(18,2) DEFAULT 0 COMMENT '预计成本',
    actual_cost DECIMAL(18,2) DEFAULT 0 COMMENT '实际成本',
    downtime_start DATETIME COMMENT '停机开始时�?,
    downtime_end DATETIME COMMENT '停机结束时间',
    downtime_duration INT COMMENT '停机时长（分钟）',
    completion_notes TEXT COMMENT '完成说明',
    quality_check BOOLEAN DEFAULT FALSE COMMENT '质量检�?,
    quality_checker VARCHAR(64) COMMENT '质量检查员',
    quality_check_date DATETIME COMMENT '质量检查日�?,
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
    INDEX idx_priority (priority),
    INDEX idx_wo_status (wo_status),
    INDEX idx_assigned_to (assigned_to),
    INDEX idx_scheduled_start (scheduled_start),
    INDEX idx_actual_start (actual_start),
    INDEX idx_tenant_site (tenant_id, site_id),
    FOREIGN KEY (plan_id) REFERENCES maintenance_plan(plan_id)
) COMMENT '维护工单�?;

-- 维护工单明细�?
CREATE TABLE maintenance_work_order_detail (
    detail_id VARCHAR(32) PRIMARY KEY COMMENT '明细ID',
    wo_id VARCHAR(32) NOT NULL COMMENT '工单ID',
    line_number INT NOT NULL COMMENT '行号',
    task_description TEXT NOT NULL COMMENT '任务描述',
    task_type ENUM('INSPECTION', 'CLEANING', 'LUBRICATION', 'ADJUSTMENT', 'REPLACEMENT', 'REPAIR', 'CALIBRATION', 'TESTING') DEFAULT 'INSPECTION' COMMENT '任务类型',
    status ENUM('PENDING', 'IN_PROGRESS', 'COMPLETED', 'SKIPPED') DEFAULT 'PENDING' COMMENT '状�?,
    assigned_to VARCHAR(64) COMMENT '分配�?,
    estimated_duration INT COMMENT '预计耗时（分钟）',
    actual_duration INT COMMENT '实际耗时（分钟）',
    start_time DATETIME COMMENT '开始时�?,
    end_time DATETIME COMMENT '结束时间',
    result TEXT COMMENT '执行结果',
    notes TEXT COMMENT '备注',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_wo (wo_id),
    INDEX idx_line_number (line_number),
    INDEX idx_task_type (task_type),
    INDEX idx_status (status),
    INDEX idx_assigned_to (assigned_to),
    INDEX idx_tenant (tenant_id),
    FOREIGN KEY (wo_id) REFERENCES maintenance_work_order(wo_id)
) COMMENT '维护工单明细�?;

-- 备件使用记录�?
CREATE TABLE spare_part_usage (
    usage_id VARCHAR(32) PRIMARY KEY COMMENT '使用记录ID',
    wo_id VARCHAR(32) NOT NULL COMMENT '工单ID',
    part_id VARCHAR(32) NOT NULL COMMENT '备件ID（来自核心数据库�?,
    part_code VARCHAR(64) COMMENT '备件代码（冗余字段）',
    part_name VARCHAR(128) COMMENT '备件名称（冗余字段）',
    part_specification TEXT COMMENT '备件规格（冗余字段）',
    used_qty DECIMAL(18,4) NOT NULL COMMENT '使用数量',
    unit_cost DECIMAL(18,4) NOT NULL COMMENT '单位成本',
    total_cost DECIMAL(18,2) NOT NULL COMMENT '总成�?,
    batch_no VARCHAR(64) COMMENT '批次�?,
    serial_no VARCHAR(64) COMMENT '序列�?,
    usage_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '使用日期',
    usage_reason TEXT COMMENT '使用原因',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_wo (wo_id),
    INDEX idx_part_id (part_id),
    INDEX idx_usage_date (usage_date),
    INDEX idx_tenant (tenant_id),
    FOREIGN KEY (wo_id) REFERENCES maintenance_work_order(wo_id)
) COMMENT '备件使用记录�?;

-- 维护检查表
CREATE TABLE maintenance_checklist (
    checklist_id VARCHAR(32) PRIMARY KEY COMMENT '检查表ID',
    checklist_code VARCHAR(64) NOT NULL UNIQUE COMMENT '检查表代码',
    checklist_name VARCHAR(128) NOT NULL COMMENT '检查表名称',
    equipment_type VARCHAR(64) COMMENT '设备类型',
    maintenance_type ENUM('PREVENTIVE', 'PREDICTIVE', 'CORRECTIVE', 'EMERGENCY') DEFAULT 'PREVENTIVE' COMMENT '维护类型',
    version VARCHAR(16) DEFAULT '1.0' COMMENT '版本',
    status ENUM('ACTIVE', 'INACTIVE', 'DRAFT') DEFAULT 'ACTIVE' COMMENT '状�?,
    description TEXT COMMENT '描述',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_checklist_code (checklist_code),
    INDEX idx_equipment_type (equipment_type),
    INDEX idx_maintenance_type (maintenance_type),
    INDEX idx_status (status),
    INDEX idx_tenant (tenant_id)
) COMMENT '维护检查表';

-- 维护检查项�?
CREATE TABLE maintenance_checklist_item (
    item_id VARCHAR(32) PRIMARY KEY COMMENT '检查项ID',
    checklist_id VARCHAR(32) NOT NULL COMMENT '检查表ID',
    item_code VARCHAR(64) NOT NULL COMMENT '检查项代码',
    item_name VARCHAR(128) NOT NULL COMMENT '检查项名称',
    item_type ENUM('INSPECTION', 'MEASUREMENT', 'TEST', 'CLEANING', 'LUBRICATION', 'ADJUSTMENT') DEFAULT 'INSPECTION' COMMENT '检查项类型',
    item_description TEXT COMMENT '检查项描述',
    measurement_unit VARCHAR(16) COMMENT '测量单位',
    normal_min_value DECIMAL(18,4) COMMENT '正常范围最小�?,
    normal_max_value DECIMAL(18,4) COMMENT '正常范围最大�?,
    warning_min_value DECIMAL(18,4) COMMENT '警告范围最小�?,
    warning_max_value DECIMAL(18,4) COMMENT '警告范围最大�?,
    alarm_min_value DECIMAL(18,4) COMMENT '报警范围最小�?,
    alarm_max_value DECIMAL(18,4) COMMENT '报警范围最大�?,
    is_required BOOLEAN DEFAULT TRUE COMMENT '是否必需',
    sort_order INT DEFAULT 0 COMMENT '排序',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状�?,
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_checklist (checklist_id),
    INDEX idx_item_code (item_code),
    INDEX idx_item_type (item_type),
    INDEX idx_sort_order (sort_order),
    INDEX idx_status (status),
    INDEX idx_tenant (tenant_id),
    FOREIGN KEY (checklist_id) REFERENCES maintenance_checklist(checklist_id)
) COMMENT '维护检查项�?;

-- 维护检查记录表
CREATE TABLE maintenance_check_record (
    record_id VARCHAR(32) PRIMARY KEY COMMENT '检查记录ID',
    wo_id VARCHAR(32) NOT NULL COMMENT '工单ID',
    checklist_id VARCHAR(32) NOT NULL COMMENT '检查表ID',
    item_id VARCHAR(32) NOT NULL COMMENT '检查项ID',
    item_code VARCHAR(64) COMMENT '检查项代码（冗余字段）',
    item_name VARCHAR(128) COMMENT '检查项名称（冗余字段）',
    measured_value DECIMAL(18,4) COMMENT '测量�?,
    check_result ENUM('PASS', 'FAIL', 'WARNING', 'N/A') DEFAULT 'PASS' COMMENT '检查结�?,
    check_notes TEXT COMMENT '检查说�?,
    checker VARCHAR(64) COMMENT '检查员',
    check_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '检查时�?,
    photos JSON COMMENT '照片列表',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_wo (wo_id),
    INDEX idx_checklist (checklist_id),
    INDEX idx_item (item_id),
    INDEX idx_check_result (check_result),
    INDEX idx_checker (checker),
    INDEX idx_check_time (check_time),
    INDEX idx_tenant (tenant_id),
    FOREIGN KEY (wo_id) REFERENCES maintenance_work_order(wo_id),
    FOREIGN KEY (checklist_id) REFERENCES maintenance_checklist(checklist_id),
    FOREIGN KEY (item_id) REFERENCES maintenance_checklist_item(item_id)
) COMMENT '维护检查记录表';

-- 故障记录�?
CREATE TABLE failure_record (
    failure_id VARCHAR(32) PRIMARY KEY COMMENT '故障记录ID',
    wo_id VARCHAR(32) COMMENT '工单ID',
    equipment_id VARCHAR(32) NOT NULL COMMENT '设备ID',
    equipment_code VARCHAR(64) COMMENT '设备代码（冗余字段）',
    equipment_name VARCHAR(128) COMMENT '设备名称（冗余字段）',
    failure_code VARCHAR(32) COMMENT '故障代码',
    failure_type ENUM('MECHANICAL', 'ELECTRICAL', 'HYDRAULIC', 'PNEUMATIC', 'SOFTWARE', 'HUMAN_ERROR', 'ENVIRONMENTAL', 'OTHER') DEFAULT 'MECHANICAL' COMMENT '故障类型',
    failure_severity ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') DEFAULT 'MEDIUM' COMMENT '故障严重程度',
    failure_description TEXT NOT NULL COMMENT '故障描述',
    failure_symptoms TEXT COMMENT '故障症状',
    root_cause TEXT COMMENT '根本原因',
    immediate_action TEXT COMMENT '立即行动',
    corrective_action TEXT COMMENT '纠正措施',
    preventive_action TEXT COMMENT '预防措施',
    failure_start_time DATETIME NOT NULL COMMENT '故障开始时�?,
    failure_end_time DATETIME COMMENT '故障结束时间',
    downtime_duration INT COMMENT '停机时长（分钟）',
    impact_description TEXT COMMENT '影响描述',
    reported_by VARCHAR(64) COMMENT '报告�?,
    reported_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '报告时间',
    resolved_by VARCHAR(64) COMMENT '解决�?,
    resolved_time DATETIME COMMENT '解决时间',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_wo (wo_id),
    INDEX idx_equipment_id (equipment_id),
    INDEX idx_failure_code (failure_code),
    INDEX idx_failure_type (failure_type),
    INDEX idx_failure_severity (failure_severity),
    INDEX idx_failure_start_time (failure_start_time),
    INDEX idx_reported_by (reported_by),
    INDEX idx_reported_time (reported_time),
    INDEX idx_tenant_site (tenant_id, site_id),
    FOREIGN KEY (wo_id) REFERENCES maintenance_work_order(wo_id)
) COMMENT '故障记录�?;

-- ==============================================
-- 2. 维护BI聚合�?
-- ==============================================

-- 维护绩效聚合表（日级别）
CREATE TABLE agg_maintenance_performance_1d (
    bucket_start DATE PRIMARY KEY COMMENT '统计日期',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    equipment_id VARCHAR(32) COMMENT '设备ID',
    total_work_orders INT DEFAULT 0 COMMENT '总工单数',
    completed_work_orders INT DEFAULT 0 COMMENT '完成工单�?,
    on_time_completion_rate DECIMAL(5,2) DEFAULT 0 COMMENT '按时完成�?,
    total_downtime INT DEFAULT 0 COMMENT '总停机时间（分钟�?,
    mean_time_to_repair DECIMAL(8,2) DEFAULT 0 COMMENT '平均修复时间（分钟）',
    mean_time_between_failures DECIMAL(8,2) DEFAULT 0 COMMENT '平均故障间隔时间（小时）',
    maintenance_cost DECIMAL(18,2) DEFAULT 0 COMMENT '维护成本',
    spare_part_cost DECIMAL(18,2) DEFAULT 0 COMMENT '备件成本',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_equipment_id (equipment_id),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '维护绩效聚合�?�?';

-- 设备可靠性聚合表（周级别�?
CREATE TABLE agg_equipment_reliability_1w (
    bucket_start DATE PRIMARY KEY COMMENT '统计周开始日�?,
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    equipment_id VARCHAR(32) COMMENT '设备ID',
    total_operating_time INT DEFAULT 0 COMMENT '总运行时间（小时�?,
    total_downtime INT DEFAULT 0 COMMENT '总停机时间（小时�?,
    availability_rate DECIMAL(5,2) DEFAULT 0 COMMENT '可用�?,
    reliability_rate DECIMAL(5,2) DEFAULT 0 COMMENT '可靠�?,
    failure_count INT DEFAULT 0 COMMENT '故障次数',
    maintenance_count INT DEFAULT 0 COMMENT '维护次数',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_equipment_id (equipment_id),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '设备可靠性聚合表(�?';

-- ==============================================
-- 3. 数据同步配置�?
-- ==============================================

-- 核心数据同步�?
CREATE TABLE core_data_sync (
    sync_id VARCHAR(32) PRIMARY KEY COMMENT '同步ID',
    entity_type VARCHAR(32) NOT NULL COMMENT '实体类型',
    entity_id VARCHAR(32) NOT NULL COMMENT '实体ID',
    sync_action ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL COMMENT '同步动作',
    sync_status ENUM('PENDING', 'SUCCESS', 'FAILED') DEFAULT 'PENDING' COMMENT '同步状�?,
    sync_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '同步时间',
    error_message TEXT COMMENT '错误信息',
    retry_count INT DEFAULT 0 COMMENT '重试次数',
    INDEX idx_entity (entity_type, entity_id),
    INDEX idx_sync_status (sync_status),
    INDEX idx_sync_time (sync_time)
) COMMENT '核心数据同步�?;

