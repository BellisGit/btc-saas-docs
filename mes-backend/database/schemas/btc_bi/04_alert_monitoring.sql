-- ==============================================
-- BTC BI数据库 - 异常预警监控表
-- ==============================================

USE btc_bi;

-- 预警规则配置表
CREATE TABLE alert_rule_config (
    rule_id VARCHAR(32) PRIMARY KEY COMMENT '规则ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    rule_name VARCHAR(128) NOT NULL COMMENT '规则名称',
    rule_code VARCHAR(64) NOT NULL COMMENT '规则代码',
    alert_type ENUM('PRODUCTION', 'QUALITY', 'EQUIPMENT', 'INVENTORY', 'SYSTEM') NOT NULL COMMENT '预警类型',
    severity_level ENUM('INFO', 'WARNING', 'CRITICAL', 'FATAL') NOT NULL COMMENT '严重级别',
    data_source VARCHAR(64) NOT NULL COMMENT '数据源表',
    condition_field VARCHAR(64) NOT NULL COMMENT '条件字段',
    condition_operator ENUM('GT', 'GTE', 'LT', 'LTE', 'EQ', 'NE', 'IN', 'NOT_IN', 'LIKE', 'NOT_LIKE') NOT NULL COMMENT '条件操作符',
    condition_value VARCHAR(255) NOT NULL COMMENT '条件值',
    threshold_value DECIMAL(18,4) COMMENT '阈值数值',
    time_window_minutes INT DEFAULT 5 COMMENT '时间窗口(分钟)',
    check_interval_seconds INT DEFAULT 60 COMMENT '检查间隔(秒)',
    is_enabled BOOLEAN DEFAULT TRUE COMMENT '是否启用',
    notification_channels JSON COMMENT '通知渠道配置',
    escalation_rules JSON COMMENT '升级规则',
    created_by VARCHAR(32) NOT NULL COMMENT '创建人',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(32) COMMENT '更新人',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_alert_type (alert_type),
    INDEX idx_severity_level (severity_level),
    INDEX idx_is_enabled (is_enabled),
    UNIQUE KEY uk_tenant_rule_code (tenant_id, rule_code)
) COMMENT '预警规则配置表';

-- 预警事件记录表
CREATE TABLE alert_event (
    event_id VARCHAR(40) PRIMARY KEY COMMENT '事件ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    rule_id VARCHAR(32) NOT NULL COMMENT '规则ID',
    alert_type ENUM('PRODUCTION', 'QUALITY', 'EQUIPMENT', 'INVENTORY', 'SYSTEM') NOT NULL COMMENT '预警类型',
    severity_level ENUM('INFO', 'WARNING', 'CRITICAL', 'FATAL') NOT NULL COMMENT '严重级别',
    title VARCHAR(255) NOT NULL COMMENT '告警标题',
    description TEXT COMMENT '告警描述',
    affected_entity_type VARCHAR(64) COMMENT '受影响实体类型',
    affected_entity_id VARCHAR(64) COMMENT '受影响实体ID',
    affected_entity_name VARCHAR(255) COMMENT '受影响实体名称',
    current_value DECIMAL(18,4) COMMENT '当前值',
    threshold_value DECIMAL(18,4) COMMENT '阈值',
    deviation_percentage DECIMAL(5,2) COMMENT '偏差百分比',
    source_data JSON COMMENT '源数据快照',
    first_occurred_at DATETIME NOT NULL COMMENT '首次发生时间',
    last_occurred_at DATETIME NOT NULL COMMENT '最后发生时间',
    occurrence_count INT DEFAULT 1 COMMENT '发生次数',
    status ENUM('ACTIVE', 'ACKNOWLEDGED', 'RESOLVED', 'SUPPRESSED') DEFAULT 'ACTIVE' COMMENT '状态',
    acknowledged_by VARCHAR(32) COMMENT '确认人',
    acknowledged_at DATETIME COMMENT '确认时间',
    resolved_by VARCHAR(32) COMMENT '解决人',
    resolved_at DATETIME COMMENT '解决时间',
    resolution_notes TEXT COMMENT '解决说明',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_rule_id (rule_id),
    INDEX idx_alert_type (alert_type),
    INDEX idx_severity_level (severity_level),
    INDEX idx_status (status),
    INDEX idx_first_occurred_at (first_occurred_at),
    INDEX idx_affected_entity (affected_entity_type, affected_entity_id),
    FOREIGN KEY (rule_id) REFERENCES alert_rule_config(rule_id)
) COMMENT '预警事件记录表';

-- 预警通知记录表
CREATE TABLE alert_notification (
    notification_id VARCHAR(40) PRIMARY KEY COMMENT '通知ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    event_id VARCHAR(40) NOT NULL COMMENT '事件ID',
    channel_type ENUM('EMAIL', 'SMS', 'WEBHOOK', 'DINGTALK', 'WECHAT', 'SYSTEM') NOT NULL COMMENT '通知渠道',
    recipient VARCHAR(255) NOT NULL COMMENT '接收人',
    notification_content TEXT NOT NULL COMMENT '通知内容',
    notification_status ENUM('PENDING', 'SENT', 'DELIVERED', 'FAILED') DEFAULT 'PENDING' COMMENT '通知状态',
    sent_at DATETIME COMMENT '发送时间',
    delivered_at DATETIME COMMENT '送达时间',
    error_message TEXT COMMENT '错误信息',
    retry_count INT DEFAULT 0 COMMENT '重试次数',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant (tenant_id),
    INDEX idx_event_id (event_id),
    INDEX idx_channel_type (channel_type),
    INDEX idx_notification_status (notification_status),
    INDEX idx_sent_at (sent_at),
    FOREIGN KEY (event_id) REFERENCES alert_event(event_id)
) COMMENT '预警通知记录表';

-- 生产异常监控表
CREATE TABLE production_alert_monitor (
    monitor_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '监控ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    wo_id VARCHAR(32) COMMENT '工单ID',
    line_id VARCHAR(32) COMMENT '产线ID',
    station_id VARCHAR(32) COMMENT '工位ID',
    equipment_id VARCHAR(32) COMMENT '设备ID',
    monitor_time DATETIME NOT NULL COMMENT '监控时间',
    monitor_type ENUM('EFFICIENCY', 'QUALITY', 'THROUGHPUT', 'CYCLE_TIME', 'DOWN_TIME', 'DEFECT_RATE') NOT NULL COMMENT '监控类型',
    current_value DECIMAL(18,4) NOT NULL COMMENT '当前值',
    normal_min_value DECIMAL(18,4) COMMENT '正常最小值',
    normal_max_value DECIMAL(18,4) COMMENT '正常最大值',
    warning_threshold DECIMAL(18,4) COMMENT '警告阈值',
    critical_threshold DECIMAL(18,4) COMMENT '严重阈值',
    alert_level ENUM('NORMAL', 'WARNING', 'CRITICAL') DEFAULT 'NORMAL' COMMENT '告警级别',
    trend_direction ENUM('UP', 'DOWN', 'STABLE', 'VOLATILE') COMMENT '趋势方向',
    is_alert_triggered BOOLEAN DEFAULT FALSE COMMENT '是否触发告警',
    alert_message TEXT COMMENT '告警信息',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_wo_id (wo_id),
    INDEX idx_line_station (line_id, station_id),
    INDEX idx_equipment_id (equipment_id),
    INDEX idx_monitor_time (monitor_time),
    INDEX idx_monitor_type (monitor_type),
    INDEX idx_alert_level (alert_level),
    INDEX idx_is_alert_triggered (is_alert_triggered)
) COMMENT '生产异常监控表';

-- 质量异常监控表
CREATE TABLE quality_alert_monitor (
    monitor_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '监控ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    item_id VARCHAR(32) COMMENT '物料ID',
    inspection_type ENUM('IQC', 'IPQC', 'OQC', 'FAI') COMMENT '检验类型',
    station_id VARCHAR(32) COMMENT '工位ID',
    inspector VARCHAR(64) COMMENT '检验员',
    monitor_time DATETIME NOT NULL COMMENT '监控时间',
    total_inspections INT DEFAULT 0 COMMENT '总检验数',
    pass_count INT DEFAULT 0 COMMENT '通过数',
    fail_count INT DEFAULT 0 COMMENT '失败数',
    defect_count INT DEFAULT 0 COMMENT '缺陷数',
    pass_rate DECIMAL(5,2) COMMENT '通过率',
    defect_rate DECIMAL(5,2) COMMENT '缺陷率',
    normal_pass_rate_min DECIMAL(5,2) COMMENT '正常通过率最小值',
    normal_pass_rate_max DECIMAL(5,2) COMMENT '正常通过率最大值',
    warning_defect_rate_threshold DECIMAL(5,2) COMMENT '警告缺陷率阈值',
    critical_defect_rate_threshold DECIMAL(5,2) COMMENT '严重缺陷率阈值',
    alert_level ENUM('NORMAL', 'WARNING', 'CRITICAL') DEFAULT 'NORMAL' COMMENT '告警级别',
    top_defects JSON COMMENT '主要缺陷类型',
    is_alert_triggered BOOLEAN DEFAULT FALSE COMMENT '是否触发告警',
    alert_message TEXT COMMENT '告警信息',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_item_id (item_id),
    INDEX idx_inspection_type (inspection_type),
    INDEX idx_station_id (station_id),
    INDEX idx_inspector (inspector),
    INDEX idx_monitor_time (monitor_time),
    INDEX idx_alert_level (alert_level),
    INDEX idx_is_alert_triggered (is_alert_triggered)
) COMMENT '质量异常监控表';


-- 库存异常监控表
CREATE TABLE inventory_alert_monitor (
    monitor_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '监控ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    item_id VARCHAR(32) NOT NULL COMMENT '物料ID',
    item_code VARCHAR(64) COMMENT '物料代码',
    location_id VARCHAR(32) COMMENT '库位ID',
    warehouse_code VARCHAR(64) COMMENT '仓库代码',
    monitor_time DATETIME NOT NULL COMMENT '监控时间',
    current_stock DECIMAL(18,4) NOT NULL COMMENT '当前库存',
    reserved_stock DECIMAL(18,4) DEFAULT 0 COMMENT '预留库存',
    available_stock DECIMAL(18,4) COMMENT '可用库存',
    min_stock_level DECIMAL(18,4) COMMENT '最小库存水平',
    max_stock_level DECIMAL(18,4) COMMENT '最大库存水平',
    safety_stock DECIMAL(18,4) COMMENT '安全库存',
    warning_stock_threshold DECIMAL(18,4) COMMENT '警告库存阈值',
    critical_stock_threshold DECIMAL(18,4) COMMENT '严重库存阈值',
    stock_usage_rate DECIMAL(8,4) COMMENT '库存使用率',
    days_of_supply DECIMAL(8,2) COMMENT '供应天数',
    alert_level ENUM('NORMAL', 'WARNING', 'CRITICAL') DEFAULT 'NORMAL' COMMENT '告警级别',
    stock_status ENUM('NORMAL', 'LOW', 'CRITICAL', 'OVERSTOCK', 'EXPIRED') DEFAULT 'NORMAL' COMMENT '库存状态',
    is_alert_triggered BOOLEAN DEFAULT FALSE COMMENT '是否触发告警',
    alert_message TEXT COMMENT '告警信息',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_item_id (item_id),
    INDEX idx_item_code (item_code),
    INDEX idx_location_id (location_id),
    INDEX idx_warehouse_code (warehouse_code),
    INDEX idx_monitor_time (monitor_time),
    INDEX idx_alert_level (alert_level),
    INDEX idx_stock_status (stock_status),
    INDEX idx_is_alert_triggered (is_alert_triggered)
) COMMENT '库存异常监控表';

-- 预警统计聚合表（小时级别）
CREATE TABLE agg_alert_stats_1h (
    bucket_start DATETIME PRIMARY KEY COMMENT '时间桶开始时间',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    alert_type ENUM('PRODUCTION', 'QUALITY', 'EQUIPMENT', 'INVENTORY', 'SYSTEM') COMMENT '预警类型',
    severity_level ENUM('INFO', 'WARNING', 'CRITICAL', 'FATAL') COMMENT '严重级别',
    total_alerts INT DEFAULT 0 COMMENT '总告警数',
    new_alerts INT DEFAULT 0 COMMENT '新增告警数',
    resolved_alerts INT DEFAULT 0 COMMENT '已解决告警数',
    acknowledged_alerts INT DEFAULT 0 COMMENT '已确认告警数',
    active_alerts INT DEFAULT 0 COMMENT '活跃告警数',
    avg_resolution_time DECIMAL(8,2) DEFAULT 0 COMMENT '平均解决时间(分钟)',
    max_resolution_time DECIMAL(8,2) DEFAULT 0 COMMENT '最大解决时间(分钟)',
    false_positive_rate DECIMAL(5,2) DEFAULT 0 COMMENT '误报率',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_alert_type (alert_type),
    INDEX idx_severity_level (severity_level),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '预警统计聚合表(1小时)';

-- 实时告警仪表板数据表
CREATE TABLE real_time_alert_dashboard (
    dashboard_id VARCHAR(32) PRIMARY KEY COMMENT '仪表板ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    dashboard_name VARCHAR(128) NOT NULL COMMENT '仪表板名称',
    alert_type ENUM('PRODUCTION', 'QUALITY', 'EQUIPMENT', 'INVENTORY', 'SYSTEM', 'ALL') NOT NULL COMMENT '告警类型',
    severity_level ENUM('INFO', 'WARNING', 'CRITICAL', 'FATAL', 'ALL') NOT NULL COMMENT '严重级别',
    total_active_alerts INT DEFAULT 0 COMMENT '总活跃告警数',
    critical_alerts INT DEFAULT 0 COMMENT '严重告警数',
    warning_alerts INT DEFAULT 0 COMMENT '警告告警数',
    new_alerts_last_hour INT DEFAULT 0 COMMENT '最近1小时新增告警',
    resolved_alerts_last_hour INT DEFAULT 0 COMMENT '最近1小时解决告警',
    avg_response_time DECIMAL(8,2) DEFAULT 0 COMMENT '平均响应时间(分钟)',
    top_alert_sources JSON COMMENT '主要告警源',
    alert_trend_data JSON COMMENT '告警趋势数据',
    last_updated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_alert_type (alert_type),
    INDEX idx_severity_level (severity_level),
    INDEX idx_last_updated (last_updated)
) COMMENT '实时告警仪表板数据表';

-- 预警规则执行日志表
CREATE TABLE alert_rule_execution_log (
    execution_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '执行ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    rule_id VARCHAR(32) NOT NULL COMMENT '规则ID',
    execution_time DATETIME NOT NULL COMMENT '执行时间',
    execution_status ENUM('SUCCESS', 'FAILED', 'SKIPPED') NOT NULL COMMENT '执行状态',
    records_checked INT DEFAULT 0 COMMENT '检查记录数',
    alerts_triggered INT DEFAULT 0 COMMENT '触发告警数',
    execution_duration_ms BIGINT COMMENT '执行耗时(毫秒)',
    error_message TEXT COMMENT '错误信息',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant (tenant_id),
    INDEX idx_rule_id (rule_id),
    INDEX idx_execution_time (execution_time),
    INDEX idx_execution_status (execution_status),
    FOREIGN KEY (rule_id) REFERENCES alert_rule_config(rule_id)
) COMMENT '预警规则执行日志表';
