-- ==============================================
-- BTC BI数据库 - 系统和设备BI表
-- ==============================================

USE btc_bi;

-- 设备效率聚合表（5分钟级别）
CREATE TABLE agg_equipment_efficiency_5m (
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
) COMMENT '设备效率聚合表(5分钟)'
PARTITION BY RANGE (TO_DAYS(bucket_start)) (
    PARTITION p202501 VALUES LESS THAN (TO_DAYS('2025-02-01')),
    PARTITION p202502 VALUES LESS THAN (TO_DAYS('2025-03-01')),
    PARTITION p202503 VALUES LESS THAN (TO_DAYS('2025-04-01')),
    PARTITION p202504 VALUES LESS THAN (TO_DAYS('2025-05-01')),
    PARTITION p202505 VALUES LESS THAN (TO_DAYS('2025-06-01')),
    PARTITION p202506 VALUES LESS THAN (TO_DAYS('2025-07-01')),
    PARTITION p202507 VALUES LESS THAN (TO_DAYS('2025-08-01')),
    PARTITION p202508 VALUES LESS THAN (TO_DAYS('2025-09-01')),
    PARTITION p202509 VALUES LESS THAN (TO_DAYS('2025-10-01')),
    PARTITION p202510 VALUES LESS THAN (TO_DAYS('2025-11-01')),
    PARTITION p202511 VALUES LESS THAN (TO_DAYS('2025-12-01')),
    PARTITION p202512 VALUES LESS THAN (TO_DAYS('2026-01-01')),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- 设备故障聚合表（小时级别）
CREATE TABLE agg_equipment_failure_1h (
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
) COMMENT '设备故障聚合表(1小时)'
PARTITION BY RANGE (TO_DAYS(bucket_start)) (
    PARTITION p202501 VALUES LESS THAN (TO_DAYS('2025-02-01')),
    PARTITION p202502 VALUES LESS THAN (TO_DAYS('2025-03-01')),
    PARTITION p202503 VALUES LESS THAN (TO_DAYS('2025-04-01')),
    PARTITION p202504 VALUES LESS THAN (TO_DAYS('2025-05-01')),
    PARTITION p202505 VALUES LESS THAN (TO_DAYS('2025-06-01')),
    PARTITION p202506 VALUES LESS THAN (TO_DAYS('2025-07-01')),
    PARTITION p202507 VALUES LESS THAN (TO_DAYS('2025-08-01')),
    PARTITION p202508 VALUES LESS THAN (TO_DAYS('2025-09-01')),
    PARTITION p202509 VALUES LESS THAN (TO_DAYS('2025-10-01')),
    PARTITION p202510 VALUES LESS THAN (TO_DAYS('2025-11-01')),
    PARTITION p202511 VALUES LESS THAN (TO_DAYS('2025-12-01')),
    PARTITION p202512 VALUES LESS THAN (TO_DAYS('2026-01-01')),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- 告警统计聚合表（小时级别）
CREATE TABLE agg_alert_stats_1h (
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
) COMMENT '告警统计聚合表(1小时)'
PARTITION BY RANGE (TO_DAYS(bucket_start)) (
    PARTITION p202501 VALUES LESS THAN (TO_DAYS('2025-02-01')),
    PARTITION p202502 VALUES LESS THAN (TO_DAYS('2025-03-01')),
    PARTITION p202503 VALUES LESS THAN (TO_DAYS('2025-04-01')),
    PARTITION p202504 VALUES LESS THAN (TO_DAYS('2025-05-01')),
    PARTITION p202505 VALUES LESS THAN (TO_DAYS('2025-06-01')),
    PARTITION p202506 VALUES LESS THAN (TO_DAYS('2025-07-01')),
    PARTITION p202507 VALUES LESS THAN (TO_DAYS('2025-08-01')),
    PARTITION p202508 VALUES LESS THAN (TO_DAYS('2025-09-01')),
    PARTITION p202509 VALUES LESS THAN (TO_DAYS('2025-10-01')),
    PARTITION p202510 VALUES LESS THAN (TO_DAYS('2025-11-01')),
    PARTITION p202511 VALUES LESS THAN (TO_DAYS('2025-12-01')),
    PARTITION p202512 VALUES LESS THAN (TO_DAYS('2026-01-01')),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- 传感器数据聚合表（5分钟级别）
CREATE TABLE agg_sensor_data_5m (
    bucket_start DATETIME PRIMARY KEY COMMENT '时间桶开始时间',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    sensor_id VARCHAR(32) COMMENT '传感器ID',
    sensor_code VARCHAR(64) COMMENT '传感器代码',
    sensor_type VARCHAR(32) COMMENT '传感器类型',
    equipment_id VARCHAR(32) COMMENT '设备ID',
    avg_value DECIMAL(18,4) DEFAULT 0 COMMENT '平均值',
    min_value DECIMAL(18,4) DEFAULT 0 COMMENT '最小值',
    max_value DECIMAL(18,4) DEFAULT 0 COMMENT '最大值',
    std_deviation DECIMAL(18,4) DEFAULT 0 COMMENT '标准差',
    sample_count INT DEFAULT 0 COMMENT '采样数量',
    alert_count INT DEFAULT 0 COMMENT '告警次数',
    normal_count INT DEFAULT 0 COMMENT '正常次数',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_sensor_id (sensor_id),
    INDEX idx_sensor_type (sensor_type),
    INDEX idx_equipment_id (equipment_id),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '传感器数据聚合表(5分钟)'
PARTITION BY RANGE (TO_DAYS(bucket_start)) (
    PARTITION p202501 VALUES LESS THAN (TO_DAYS('2025-02-01')),
    PARTITION p202502 VALUES LESS THAN (TO_DAYS('2025-03-01')),
    PARTITION p202503 VALUES LESS THAN (TO_DAYS('2025-04-01')),
    PARTITION p202504 VALUES LESS THAN (TO_DAYS('2025-05-01')),
    PARTITION p202505 VALUES LESS THAN (TO_DAYS('2025-06-01')),
    PARTITION p202506 VALUES LESS THAN (TO_DAYS('2025-07-01')),
    PARTITION p202507 VALUES LESS THAN (TO_DAYS('2025-08-01')),
    PARTITION p202508 VALUES LESS THAN (TO_DAYS('2025-09-01')),
    PARTITION p202509 VALUES LESS THAN (TO_DAYS('2025-10-01')),
    PARTITION p202510 VALUES LESS THAN (TO_DAYS('2025-11-01')),
    PARTITION p202511 VALUES LESS THAN (TO_DAYS('2025-12-01')),
    PARTITION p202512 VALUES LESS THAN (TO_DAYS('2026-01-01')),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- 用户活跃度聚合表（小时级别）
CREATE TABLE agg_user_activity_1h (
    bucket_start DATETIME PRIMARY KEY COMMENT '时间桶开始时间',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    user_id VARCHAR(32) COMMENT '用户ID',
    username VARCHAR(64) COMMENT '用户名',
    login_count INT DEFAULT 0 COMMENT '登录次数',
    operation_count INT DEFAULT 0 COMMENT '操作次数',
    page_views INT DEFAULT 0 COMMENT '页面访问次数',
    session_duration BIGINT DEFAULT 0 COMMENT '会话时长(分钟)',
    last_activity_time DATETIME COMMENT '最后活动时间',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_user_id (user_id),
    INDEX idx_username (username),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '用户活跃度聚合表(1小时)'
PARTITION BY RANGE (TO_DAYS(bucket_start)) (
    PARTITION p202501 VALUES LESS THAN (TO_DAYS('2025-02-01')),
    PARTITION p202502 VALUES LESS THAN (TO_DAYS('2025-03-01')),
    PARTITION p202503 VALUES LESS THAN (TO_DAYS('2025-04-01')),
    PARTITION p202504 VALUES LESS THAN (TO_DAYS('2025-05-01')),
    PARTITION p202505 VALUES LESS THAN (TO_DAYS('2025-06-01')),
    PARTITION p202506 VALUES LESS THAN (TO_DAYS('2025-07-01')),
    PARTITION p202507 VALUES LESS THAN (TO_DAYS('2025-08-01')),
    PARTITION p202508 VALUES LESS THAN (TO_DAYS('2025-09-01')),
    PARTITION p202509 VALUES LESS THAN (TO_DAYS('2025-10-01')),
    PARTITION p202510 VALUES LESS THAN (TO_DAYS('2025-11-01')),
    PARTITION p202511 VALUES LESS THAN (TO_DAYS('2025-12-01')),
    PARTITION p202512 VALUES LESS THAN (TO_DAYS('2026-01-01')),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- 系统性能聚合表（5分钟级别）
CREATE TABLE agg_system_performance_5m (
    bucket_start DATETIME PRIMARY KEY COMMENT '时间桶开始时间',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    server_name VARCHAR(128) COMMENT '服务器名称',
    cpu_usage DECIMAL(5,2) DEFAULT 0 COMMENT 'CPU使用率',
    memory_usage DECIMAL(5,2) DEFAULT 0 COMMENT '内存使用率',
    disk_usage DECIMAL(5,2) DEFAULT 0 COMMENT '磁盘使用率',
    network_io BIGINT DEFAULT 0 COMMENT '网络IO',
    disk_io BIGINT DEFAULT 0 COMMENT '磁盘IO',
    active_connections INT DEFAULT 0 COMMENT '活跃连接数',
    request_count INT DEFAULT 0 COMMENT '请求数',
    avg_response_time DECIMAL(8,2) DEFAULT 0 COMMENT '平均响应时间(ms)',
    error_rate DECIMAL(5,2) DEFAULT 0 COMMENT '错误率',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_server_name (server_name),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '系统性能聚合表(5分钟)'
PARTITION BY RANGE (TO_DAYS(bucket_start)) (
    PARTITION p202501 VALUES LESS THAN (TO_DAYS('2025-02-01')),
    PARTITION p202502 VALUES LESS THAN (TO_DAYS('2025-03-01')),
    PARTITION p202503 VALUES LESS THAN (TO_DAYS('2025-04-01')),
    PARTITION p202504 VALUES LESS THAN (TO_DAYS('2025-05-01')),
    PARTITION p202505 VALUES LESS THAN (TO_DAYS('2025-06-01')),
    PARTITION p202506 VALUES LESS THAN (TO_DAYS('2025-07-01')),
    PARTITION p202507 VALUES LESS THAN (TO_DAYS('2025-08-01')),
    PARTITION p202508 VALUES LESS THAN (TO_DAYS('2025-09-01')),
    PARTITION p202509 VALUES LESS THAN (TO_DAYS('2025-10-01')),
    PARTITION p202510 VALUES LESS THAN (TO_DAYS('2025-11-01')),
    PARTITION p202511 VALUES LESS THAN (TO_DAYS('2025-12-01')),
    PARTITION p202512 VALUES LESS THAN (TO_DAYS('2026-01-01')),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- 实时指标缓存表
CREATE TABLE real_time_metrics_cache (
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

-- BI数据质量监控表
CREATE TABLE bi_data_quality_monitor (
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
CREATE TABLE bi_aggregation_task_log (
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
