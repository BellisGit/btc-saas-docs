-- ==============================================
-- BTC BI数据库 - 系统BI表
-- ==============================================

USE btc_bi;

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
) COMMENT '用户活跃度聚合表(1小时)';

-- 系统性能聚合表（5分钟级别）
CREATE TABLE agg_system_performance_5m (
    bucket_start DATETIME PRIMARY KEY COMMENT '时间桶开始时间',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    server_name VARCHAR(128) COMMENT '服务器名称',
    cpu_usage DECIMAL(5,2) DEFAULT 0 COMMENT 'CPU使用率',
    memory_usage DECIMAL(5,2) DEFAULT 0 COMMENT '内存使用率',
    disk_usage DECIMAL(5,2) DEFAULT 0 COMMENT '磁盘使用率',
    network_usage DECIMAL(5,2) DEFAULT 0 COMMENT '网络使用率',
    load_average DECIMAL(8,2) DEFAULT 0 COMMENT '负载平均值',
    active_connections INT DEFAULT 0 COMMENT '活跃连接数',
    request_count INT DEFAULT 0 COMMENT '请求数',
    response_time_avg DECIMAL(8,2) DEFAULT 0 COMMENT '平均响应时间(ms)',
    error_count INT DEFAULT 0 COMMENT '错误数',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_server_name (server_name),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '系统性能聚合表(5分钟)';

-- 数据库性能聚合表（小时级别）
CREATE TABLE agg_database_performance_1h (
    bucket_start DATETIME PRIMARY KEY COMMENT '时间桶开始时间',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    database_name VARCHAR(64) COMMENT '数据库名',
    connection_count INT DEFAULT 0 COMMENT '连接数',
    active_queries INT DEFAULT 0 COMMENT '活跃查询数',
    slow_queries INT DEFAULT 0 COMMENT '慢查询数',
    avg_query_time DECIMAL(8,2) DEFAULT 0 COMMENT '平均查询时间(ms)',
    lock_wait_time BIGINT DEFAULT 0 COMMENT '锁等待时间(ms)',
    deadlock_count INT DEFAULT 0 COMMENT '死锁次数',
    cache_hit_rate DECIMAL(5,2) DEFAULT 0 COMMENT '缓存命中率',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_database_name (database_name),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '数据库性能聚合表(1小时)';

-- 应用性能聚合表（5分钟级别）
CREATE TABLE agg_application_performance_5m (
    bucket_start DATETIME PRIMARY KEY COMMENT '时间桶开始时间',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    application_name VARCHAR(64) COMMENT '应用名称',
    component_name VARCHAR(128) COMMENT '组件名称',
    operation_name VARCHAR(128) COMMENT '操作名称',
    request_count INT DEFAULT 0 COMMENT '请求数',
    success_count INT DEFAULT 0 COMMENT '成功数',
    failure_count INT DEFAULT 0 COMMENT '失败数',
    avg_response_time DECIMAL(8,2) DEFAULT 0 COMMENT '平均响应时间(ms)',
    max_response_time DECIMAL(8,2) DEFAULT 0 COMMENT '最大响应时间(ms)',
    throughput DECIMAL(10,2) DEFAULT 0 COMMENT '吞吐量(请求/秒)',
    error_rate DECIMAL(5,2) DEFAULT 0 COMMENT '错误率',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_application_name (application_name),
    INDEX idx_component_name (component_name),
    INDEX idx_operation_name (operation_name),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '应用性能聚合表(5分钟)';

-- 业务指标聚合表（小时级别）
CREATE TABLE agg_business_metrics_1h (
    bucket_start DATETIME PRIMARY KEY COMMENT '时间桶开始时间',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    metric_type VARCHAR(64) COMMENT '指标类型',
    metric_name VARCHAR(128) COMMENT '指标名称',
    metric_value DECIMAL(18,4) DEFAULT 0 COMMENT '指标值',
    metric_unit VARCHAR(16) COMMENT '指标单位',
    threshold_value DECIMAL(18,4) COMMENT '阈值',
    alert_level ENUM('NORMAL', 'WARNING', 'CRITICAL') DEFAULT 'NORMAL' COMMENT '告警级别',
    sample_count INT DEFAULT 0 COMMENT '采样数量',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_metric_type (metric_type),
    INDEX idx_metric_name (metric_name),
    INDEX idx_alert_level (alert_level),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '业务指标聚合表(1小时)';

-- 系统日志聚合表（小时级别）
CREATE TABLE agg_system_logs_1h (
    bucket_start DATETIME PRIMARY KEY COMMENT '时间桶开始时间',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    log_level VARCHAR(16) COMMENT '日志级别',
    logger_name VARCHAR(255) COMMENT '日志器名称',
    log_count INT DEFAULT 0 COMMENT '日志数量',
    error_count INT DEFAULT 0 COMMENT '错误数量',
    warning_count INT DEFAULT 0 COMMENT '警告数量',
    info_count INT DEFAULT 0 COMMENT '信息数量',
    debug_count INT DEFAULT 0 COMMENT '调试数量',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_log_level (log_level),
    INDEX idx_logger_name (logger_name),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '系统日志聚合表(1小时)';

-- 缓存性能聚合表（5分钟级别）
CREATE TABLE agg_cache_performance_5m (
    bucket_start DATETIME PRIMARY KEY COMMENT '时间桶开始时间',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    cache_type VARCHAR(32) COMMENT '缓存类型',
    cache_name VARCHAR(128) COMMENT '缓存名称',
    hit_count INT DEFAULT 0 COMMENT '命中次数',
    miss_count INT DEFAULT 0 COMMENT '未命中次数',
    eviction_count INT DEFAULT 0 COMMENT '驱逐次数',
    hit_rate DECIMAL(5,2) DEFAULT 0 COMMENT '命中率',
    memory_usage BIGINT DEFAULT 0 COMMENT '内存使用量(字节)',
    key_count INT DEFAULT 0 COMMENT '键数量',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_cache_type (cache_type),
    INDEX idx_cache_name (cache_name),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '缓存性能聚合表(5分钟)';

-- 消息队列性能聚合表（小时级别）
CREATE TABLE agg_message_queue_performance_1h (
    bucket_start DATETIME PRIMARY KEY COMMENT '时间桶开始时间',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    queue_name VARCHAR(128) COMMENT '队列名称',
    message_type VARCHAR(64) COMMENT '消息类型',
    produced_count INT DEFAULT 0 COMMENT '生产消息数',
    consumed_count INT DEFAULT 0 COMMENT '消费消息数',
    failed_count INT DEFAULT 0 COMMENT '失败消息数',
    avg_processing_time DECIMAL(8,2) DEFAULT 0 COMMENT '平均处理时间(ms)',
    queue_size INT DEFAULT 0 COMMENT '队列大小',
    consumer_count INT DEFAULT 0 COMMENT '消费者数量',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_queue_name (queue_name),
    INDEX idx_message_type (message_type),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '消息队列性能聚合表(1小时)';