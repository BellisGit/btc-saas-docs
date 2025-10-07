-- V20250107_1605__create_bi_database.sql
-- 创建BTC BI数据库
-- 基于MES系统全局架构基础文档
-- 作者: MES开发团队
-- 日期: 2025-01-07

-- 创建BTC BI数据库
CREATE DATABASE IF NOT EXISTS btc_bi CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE btc_bi;

-- ==============================================
-- 1. 生产域聚合表
-- ==============================================

-- 生产进度聚合表（5分钟级别）
CREATE TABLE IF NOT EXISTS agg_production_progress_5m (
    bucket_start DATETIME PRIMARY KEY COMMENT '时间桶开始时间',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    wo_id VARCHAR(32) COMMENT '工单ID',
    item_id VARCHAR(32) COMMENT '物料ID',
    line_id VARCHAR(32) COMMENT '产线ID',
    station_id VARCHAR(32) COMMENT '工位ID',
    planned_qty DECIMAL(18,4) DEFAULT 0 COMMENT '计划数量',
    completed_qty DECIMAL(18,4) DEFAULT 0 COMMENT '完成数量',
    in_progress_qty DECIMAL(18,4) DEFAULT 0 COMMENT '在制数量',
    progress_rate DECIMAL(5,2) DEFAULT 0 COMMENT '进度百分比',
    efficiency DECIMAL(5,2) DEFAULT 0 COMMENT '效率百分比',
    cycle_time DECIMAL(8,2) DEFAULT 0 COMMENT '节拍时间(秒)',
    throughput DECIMAL(10,2) DEFAULT 0 COMMENT '吞吐量(件/小时)',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_wo (wo_id),
    INDEX idx_item (item_id),
    INDEX idx_line (line_id),
    INDEX idx_station (station_id),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '生产进度聚合表(5分钟)';

-- 良率聚合表（5分钟级别）
CREATE TABLE IF NOT EXISTS agg_yield_5m (
    bucket_start DATETIME PRIMARY KEY COMMENT '时间桶开始时间',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    wo_id VARCHAR(32) COMMENT '工单ID',
    item_id VARCHAR(32) COMMENT '物料ID',
    station_id VARCHAR(32) COMMENT '工位ID',
    pass_cnt INT DEFAULT 0 COMMENT '通过数量',
    fail_cnt INT DEFAULT 0 COMMENT '失败数量',
    rework_cnt INT DEFAULT 0 COMMENT '返工数量',
    yield DECIMAL(5,2) DEFAULT 0 COMMENT '良率百分比',
    ftt DECIMAL(5,2) DEFAULT 0 COMMENT '首次通过率',
    defect_rate DECIMAL(5,2) DEFAULT 0 COMMENT '缺陷率',
    top_defect_codes JSON COMMENT 'Top缺陷代码',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_wo (wo_id),
    INDEX idx_item (item_id),
    INDEX idx_station (station_id),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '良率聚合表(5分钟)';

-- WIP状态聚合表（5分钟级别）
CREATE TABLE IF NOT EXISTS agg_wip_status_5m (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    bucket_start DATETIME NOT NULL COMMENT '时间桶开始时间',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    wo_id VARCHAR(32) COMMENT '工单ID',
    item_id VARCHAR(32) COMMENT '物料ID',
    line_id VARCHAR(32) COMMENT '产线ID',
    station_id VARCHAR(32) COMMENT '工位ID',
    status ENUM('PLANNED', 'IN_PROGRESS', 'COMPLETED', 'REJECTED', 'REWORK', 'HOLD') COMMENT '状态',
    quantity DECIMAL(18,4) DEFAULT 0 COMMENT '数量',
    avg_wait_time BIGINT DEFAULT 0 COMMENT '平均等待时间(分钟)',
    max_wait_time BIGINT DEFAULT 0 COMMENT '最大等待时间(分钟)',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_wo (wo_id),
    INDEX idx_item (item_id),
    INDEX idx_line (line_id),
    INDEX idx_station (station_id),
    INDEX idx_status (status),
    INDEX idx_bucket_start (bucket_start)
) COMMENT 'WIP状态聚合表(5分钟)';

-- ==============================================
-- 2. 品质域聚合表
-- ==============================================

-- 品质统计聚合表（5分钟级别）
CREATE TABLE IF NOT EXISTS agg_quality_stats_5m (
    bucket_start DATETIME PRIMARY KEY COMMENT '时间桶开始时间',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    inspection_type ENUM('IQC', 'IPQC', 'OQC', 'FAI') COMMENT '检验类型',
    item_id VARCHAR(32) COMMENT '物料ID',
    station_id VARCHAR(32) COMMENT '工位ID',
    total_inspections INT DEFAULT 0 COMMENT '总检验数',
    pass_inspections INT DEFAULT 0 COMMENT '通过检验数',
    fail_inspections INT DEFAULT 0 COMMENT '失败检验数',
    special_inspections INT DEFAULT 0 COMMENT '特采检验数',
    pass_rate DECIMAL(5,2) DEFAULT 0 COMMENT '通过率',
    fail_rate DECIMAL(5,2) DEFAULT 0 COMMENT '失败率',
    special_rate DECIMAL(5,2) DEFAULT 0 COMMENT '特采率',
    avg_inspection_time DECIMAL(8,2) DEFAULT 0 COMMENT '平均检验时间(分钟)',
    defect_count INT DEFAULT 0 COMMENT '缺陷总数',
    defect_rate DECIMAL(5,2) DEFAULT 0 COMMENT '缺陷率',
    top_defects JSON COMMENT 'Top缺陷列表',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_inspection_type (inspection_type),
    INDEX idx_item (item_id),
    INDEX idx_station (station_id),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '品质统计聚合表(5分钟)';

-- 缺陷分析聚合表（小时级别）
CREATE TABLE IF NOT EXISTS agg_defect_analysis_1h (
    bucket_start DATETIME PRIMARY KEY COMMENT '时间桶开始时间',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    defect_code VARCHAR(32) COMMENT '缺陷代码',
    defect_name VARCHAR(128) COMMENT '缺陷名称',
    item_id VARCHAR(32) COMMENT '物料ID',
    station_id VARCHAR(32) COMMENT '工位ID',
    cause_code VARCHAR(32) COMMENT '原因代码',
    cause_name VARCHAR(128) COMMENT '原因名称',
    occurrence_count INT DEFAULT 0 COMMENT '发生次数',
    defect_rate DECIMAL(5,2) DEFAULT 0 COMMENT '缺陷率',
    cost_impact DECIMAL(18,2) DEFAULT 0 COMMENT '成本影响',
    avg_repair_time DECIMAL(8,2) DEFAULT 0 COMMENT '平均修复时间(分钟)',
    trend_direction ENUM('UP', 'DOWN', 'STABLE') DEFAULT 'STABLE' COMMENT '趋势方向',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_defect_code (defect_code),
    INDEX idx_item (item_id),
    INDEX idx_station (station_id),
    INDEX idx_cause_code (cause_code),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '缺陷分析聚合表(1小时)';

-- ==============================================
-- 3. 物流域聚合表
-- ==============================================

-- 库存周转聚合表（小时级别）
CREATE TABLE IF NOT EXISTS agg_inventory_turnover_1h (
    bucket_start DATETIME PRIMARY KEY COMMENT '时间桶开始时间',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    item_id VARCHAR(32) COMMENT '物料ID',
    location_id VARCHAR(32) COMMENT '库位ID',
    warehouse_code VARCHAR(64) COMMENT '仓库代码',
    beginning_stock DECIMAL(18,4) DEFAULT 0 COMMENT '期初库存',
    ending_stock DECIMAL(18,4) DEFAULT 0 COMMENT '期末库存',
    avg_stock DECIMAL(18,4) DEFAULT 0 COMMENT '平均库存',
    in_qty DECIMAL(18,4) DEFAULT 0 COMMENT '入库数量',
    out_qty DECIMAL(18,4) DEFAULT 0 COMMENT '出库数量',
    turnover_rate DECIMAL(8,4) DEFAULT 0 COMMENT '周转率',
    turnover_days DECIMAL(8,2) DEFAULT 0 COMMENT '周转天数',
    stock_value DECIMAL(18,2) DEFAULT 0 COMMENT '库存价值',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_item (item_id),
    INDEX idx_location (location_id),
    INDEX idx_warehouse (warehouse_code),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '库存周转聚合表(1小时)';

-- 库存事务聚合表（5分钟级别）
CREATE TABLE IF NOT EXISTS agg_stock_transaction_5m (
    bucket_start DATETIME PRIMARY KEY COMMENT '时间桶开始时间',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    transaction_type ENUM('IN', 'OUT', 'TRANSFER', 'ADJUST', 'RESERVE', 'UNRESERVE') COMMENT '事务类型',
    item_id VARCHAR(32) COMMENT '物料ID',
    location_id VARCHAR(32) COMMENT '库位ID',
    transaction_count INT DEFAULT 0 COMMENT '事务次数',
    total_quantity DECIMAL(18,4) DEFAULT 0 COMMENT '总数量',
    total_value DECIMAL(18,2) DEFAULT 0 COMMENT '总价值',
    avg_transaction_time DECIMAL(8,2) DEFAULT 0 COMMENT '平均事务时间(分钟)',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_transaction_type (transaction_type),
    INDEX idx_item (item_id),
    INDEX idx_location (location_id),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '库存事务聚合表(5分钟)';

-- ==============================================
-- 4. 设备域聚合表
-- ==============================================

-- 设备效率聚合表（5分钟级别）
CREATE TABLE IF NOT EXISTS agg_equipment_efficiency_5m (
    bucket_start DATETIME PRIMARY KEY COMMENT '时间桶开始时间',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    equipment_id VARCHAR(32) COMMENT '设备ID',
    equipment_code VARCHAR(64) COMMENT '设备代码',
    equipment_name VARCHAR(255) COMMENT '设备名称',
    station_id VARCHAR(32) COMMENT '工位ID',
    planned_time BIGINT DEFAULT 0 COMMENT '计划时间(分钟)',
    actual_time BIGINT DEFAULT 0 COMMENT '实际时间(分钟)',
    run_time BIGINT DEFAULT 0 COMMENT '运行时间(分钟)',
    down_time BIGINT DEFAULT 0 COMMENT '停机时间(分钟)',
    setup_time BIGINT DEFAULT 0 COMMENT '换型时间(分钟)',
    maintenance_time BIGINT DEFAULT 0 COMMENT '维护时间(分钟)',
    availability DECIMAL(5,2) DEFAULT 0 COMMENT '可用率',
    performance DECIMAL(5,2) DEFAULT 0 COMMENT '性能率',
    quality DECIMAL(5,2) DEFAULT 0 COMMENT '质量率',
    oee DECIMAL(5,2) DEFAULT 0 COMMENT 'OEE',
    throughput DECIMAL(10,2) DEFAULT 0 COMMENT '吞吐量(件/小时)',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_equipment (equipment_id),
    INDEX idx_station (station_id),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '设备效率聚合表(5分钟)';

-- 设备故障聚合表（小时级别）
CREATE TABLE IF NOT EXISTS agg_equipment_failure_1h (
    bucket_start DATETIME PRIMARY KEY COMMENT '时间桶开始时间',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    equipment_id VARCHAR(32) COMMENT '设备ID',
    failure_type VARCHAR(32) COMMENT '故障类型',
    failure_code VARCHAR(32) COMMENT '故障代码',
    failure_desc VARCHAR(255) COMMENT '故障描述',
    failure_count INT DEFAULT 0 COMMENT '故障次数',
    total_downtime BIGINT DEFAULT 0 COMMENT '总停机时间(分钟)',
    avg_repair_time BIGINT DEFAULT 0 COMMENT '平均修复时间(分钟)',
    mttr DECIMAL(8,2) DEFAULT 0 COMMENT '平均修复时间',
    mtbf DECIMAL(8,2) DEFAULT 0 COMMENT '平均故障间隔时间',
    cost_impact DECIMAL(18,2) DEFAULT 0 COMMENT '成本影响',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_equipment (equipment_id),
    INDEX idx_failure_type (failure_type),
    INDEX idx_failure_code (failure_code),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '设备故障聚合表(1小时)';

-- ==============================================
-- 5. 供应商域聚合表
-- ==============================================

-- 供应商绩效聚合表（日级别）
CREATE TABLE IF NOT EXISTS agg_supplier_performance_1d (
    bucket_start DATE PRIMARY KEY COMMENT '统计日期',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    supplier_id VARCHAR(32) COMMENT '供应商ID',
    supplier_code VARCHAR(64) COMMENT '供应商代码',
    supplier_name VARCHAR(255) COMMENT '供应商名称',
    delivery_score DECIMAL(5,2) DEFAULT 0 COMMENT '交付评分',
    quality_score DECIMAL(5,2) DEFAULT 0 COMMENT '质量评分',
    service_score DECIMAL(5,2) DEFAULT 0 COMMENT '服务评分',
    cost_score DECIMAL(5,2) DEFAULT 0 COMMENT '成本评分',
    overall_score DECIMAL(5,2) DEFAULT 0 COMMENT '综合评分',
    on_time_delivery_rate DECIMAL(5,2) DEFAULT 0 COMMENT '准时交付率',
    quality_pass_rate DECIMAL(5,2) DEFAULT 0 COMMENT '质量通过率',
    defect_rate DECIMAL(5,2) DEFAULT 0 COMMENT '缺陷率',
    complaint_count INT DEFAULT 0 COMMENT '投诉次数',
    ncr_count INT DEFAULT 0 COMMENT 'NCR次数',
    scar_count INT DEFAULT 0 COMMENT 'SCAR次数',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant (tenant_id),
    INDEX idx_supplier (supplier_id),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '供应商绩效聚合表(日)';

-- ==============================================
-- 6. 成本域聚合表
-- ==============================================

-- 成本分析聚合表（日级别）
CREATE TABLE IF NOT EXISTS agg_cost_analysis_1d (
    bucket_start DATE PRIMARY KEY COMMENT '统计日期',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    wo_id VARCHAR(32) COMMENT '工单ID',
    item_id VARCHAR(32) COMMENT '物料ID',
    planned_cost DECIMAL(18,2) DEFAULT 0 COMMENT '计划成本',
    actual_cost DECIMAL(18,2) DEFAULT 0 COMMENT '实际成本',
    material_cost DECIMAL(18,2) DEFAULT 0 COMMENT '物料成本',
    labor_cost DECIMAL(18,2) DEFAULT 0 COMMENT '人工成本',
    overhead_cost DECIMAL(18,2) DEFAULT 0 COMMENT '制造费用',
    quality_cost DECIMAL(18,2) DEFAULT 0 COMMENT '质量成本',
    cost_variance DECIMAL(18,2) DEFAULT 0 COMMENT '成本差异',
    cost_variance_rate DECIMAL(5,2) DEFAULT 0 COMMENT '成本差异率',
    unit_cost DECIMAL(18,4) DEFAULT 0 COMMENT '单位成本',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_wo (wo_id),
    INDEX idx_item (item_id),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '成本分析聚合表(日)';

-- ==============================================
-- 7. 告警统计聚合表
-- ==============================================

-- 告警统计聚合表（小时级别）
CREATE TABLE IF NOT EXISTS agg_alert_stats_1h (
    bucket_start DATETIME PRIMARY KEY COMMENT '时间桶开始时间',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    alert_type VARCHAR(32) COMMENT '告警类型',
    alert_level ENUM('INFO', 'WARNING', 'CRITICAL', 'FATAL') COMMENT '告警级别',
    alert_source VARCHAR(64) COMMENT '告警源',
    total_alerts INT DEFAULT 0 COMMENT '总告警数',
    resolved_alerts INT DEFAULT 0 COMMENT '已解决告警数',
    unresolved_alerts INT DEFAULT 0 COMMENT '未解决告警数',
    avg_resolution_time DECIMAL(8,2) DEFAULT 0 COMMENT '平均解决时间(分钟)',
    max_resolution_time DECIMAL(8,2) DEFAULT 0 COMMENT '最大解决时间(分钟)',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_alert_type (alert_type),
    INDEX idx_alert_level (alert_level),
    INDEX idx_alert_source (alert_source),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '告警统计聚合表(1小时)';

-- ==============================================
-- 8. BI数据质量监控表
-- ==============================================

-- BI数据质量监控表
CREATE TABLE IF NOT EXISTS bi_data_quality_monitor (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    data_source VARCHAR(64) NOT NULL COMMENT '数据源',
    table_name VARCHAR(64) NOT NULL COMMENT '表名',
    check_time DATETIME NOT NULL COMMENT '检查时间',
    record_count BIGINT DEFAULT 0 COMMENT '记录数',
    data_freshness_minutes INT DEFAULT 0 COMMENT '数据新鲜度(分钟)',
    completeness_rate DECIMAL(5,2) DEFAULT 0 COMMENT '完整性',
    accuracy_rate DECIMAL(5,2) DEFAULT 0 COMMENT '准确性',
    consistency_rate DECIMAL(5,2) DEFAULT 0 COMMENT '一致性',
    validity_rate DECIMAL(5,2) DEFAULT 0 COMMENT '有效性',
    uniqueness_rate DECIMAL(5,2) DEFAULT 0 COMMENT '唯一性',
    timeliness_score DECIMAL(5,2) DEFAULT 0 COMMENT '及时性评分',
    overall_quality_score DECIMAL(5,2) DEFAULT 0 COMMENT '总体质量评分',
    quality_issues JSON COMMENT '质量问题',
    check_status ENUM('SUCCESS', 'WARNING', 'ERROR') DEFAULT 'SUCCESS' COMMENT '检查状态',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_data_source (data_source),
    INDEX idx_table_name (table_name),
    INDEX idx_check_time (check_time),
    INDEX idx_check_status (check_status)
) COMMENT 'BI数据质量监控表';

-- BI聚合任务执行日志表
CREATE TABLE IF NOT EXISTS bi_aggregation_task_log (
    task_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id VARCHAR(32) COMMENT '租户ID',
    task_name VARCHAR(128) NOT NULL COMMENT '任务名称',
    table_name VARCHAR(64) NOT NULL COMMENT '目标表名',
    aggregation_type VARCHAR(32) NOT NULL COMMENT '聚合类型 5m/1h/1d',
    start_time DATETIME NOT NULL COMMENT '开始时间',
    end_time DATETIME COMMENT '结束时间',
    execution_time BIGINT COMMENT '执行时间(ms)',
    processed_records BIGINT DEFAULT 0 COMMENT '处理记录数',
    output_records BIGINT DEFAULT 0 COMMENT '输出记录数',
    status ENUM('RUNNING', 'SUCCESS', 'FAILED', 'CANCELLED') DEFAULT 'RUNNING' COMMENT '执行状态',
    error_message TEXT COMMENT '错误信息',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant (tenant_id),
    INDEX idx_task_name (task_name),
    INDEX idx_table_name (table_name),
    INDEX idx_start_time (start_time),
    INDEX idx_status (status)
) COMMENT 'BI聚合任务执行日志表';

-- ==============================================
-- 9. 实时指标缓存表
-- ==============================================

-- 实时指标缓存表
CREATE TABLE IF NOT EXISTS real_time_metrics_cache (
    cache_key VARCHAR(128) PRIMARY KEY COMMENT '缓存键',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    metric_type VARCHAR(32) NOT NULL COMMENT '指标类型',
    metric_name VARCHAR(64) NOT NULL COMMENT '指标名称',
    metric_value TEXT NOT NULL COMMENT '指标值(JSON)',
    ttl_seconds INT DEFAULT 300 COMMENT 'TTL秒数',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    expires_at DATETIME NOT NULL COMMENT '过期时间',
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_metric_type (metric_type),
    INDEX idx_metric_name (metric_name),
    INDEX idx_expires_at (expires_at)
) COMMENT '实时指标缓存表';
