-- ==============================================
-- BTC日志数据库 - 系统和监控日志表
-- ==============================================

USE btc_log;

-- 系统监控日志表
CREATE TABLE system_monitor_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    monitor_type VARCHAR(32) NOT NULL COMMENT '监控类型',
    monitor_name VARCHAR(128) NOT NULL COMMENT '监控名称',
    monitor_category VARCHAR(64) COMMENT '监控分类',
    metric_name VARCHAR(128) NOT NULL COMMENT '指标名称',
    metric_value DECIMAL(18,4) COMMENT '指标值',
    metric_unit VARCHAR(16) COMMENT '指标单位',
    threshold_value DECIMAL(18,4) COMMENT '阈值',
    threshold_type ENUM('GT', 'LT', 'EQ', 'GTE', 'LTE', 'NE') COMMENT '阈值类型',
    alert_level ENUM('INFO', 'WARNING', 'ERROR', 'CRITICAL') DEFAULT 'INFO' COMMENT '告警级别',
    alert_status ENUM('NORMAL', 'ALERT', 'RESOLVED') DEFAULT 'NORMAL' COMMENT '告警状态',
    alert_message TEXT COMMENT '告警消息',
    monitor_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '监控时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_monitor_type (monitor_type),
    INDEX idx_monitor_category (monitor_category),
    INDEX idx_metric_name (metric_name),
    INDEX idx_alert_level (alert_level),
    INDEX idx_alert_status (alert_status),
    INDEX idx_monitor_time (monitor_time)
) COMMENT '系统监控日志表';

-- 告警日志表
CREATE TABLE alert_log (
    alert_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '告警ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    alert_no VARCHAR(64) NOT NULL UNIQUE COMMENT '告警单号',
    alert_type VARCHAR(32) NOT NULL COMMENT '告警类型',
    alert_category VARCHAR(64) COMMENT '告警分类',
    alert_source VARCHAR(64) COMMENT '告警源',
    alert_level ENUM('INFO', 'WARNING', 'ERROR', 'CRITICAL', 'FATAL') NOT NULL COMMENT '告警级别',
    alert_title VARCHAR(255) NOT NULL COMMENT '告警标题',
    alert_content TEXT NOT NULL COMMENT '告警内容',
    alert_status ENUM('ACTIVE', 'ACKNOWLEDGED', 'RESOLVED', 'SUPPRESSED') DEFAULT 'ACTIVE' COMMENT '告警状态',
    acknowledge_user VARCHAR(64) COMMENT '确认用户',
    acknowledge_time DATETIME COMMENT '确认时间',
    resolve_user VARCHAR(64) COMMENT '解决用户',
    resolve_time DATETIME COMMENT '解决时间',
    resolve_notes TEXT COMMENT '解决说明',
    related_entity_type VARCHAR(32) COMMENT '关联实体类型',
    related_entity_id VARCHAR(64) COMMENT '关联实体ID',
    alert_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '告警时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_alert_no (alert_no),
    INDEX idx_alert_type (alert_type),
    INDEX idx_alert_category (alert_category),
    INDEX idx_alert_level (alert_level),
    INDEX idx_alert_status (alert_status),
    INDEX idx_alert_source (alert_source),
    INDEX idx_alert_time (alert_time),
    INDEX idx_related_entity (related_entity_type, related_entity_id)
) COMMENT '告警日志表';

-- 系统任务执行日志表
CREATE TABLE sys_job_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    job_id VARCHAR(32) COMMENT '任务ID',
    job_name VARCHAR(128) NOT NULL COMMENT '任务名称',
    job_group VARCHAR(64) NOT NULL COMMENT '任务分组',
    job_class VARCHAR(255) COMMENT '任务类名',
    execution_status ENUM('SUCCESS', 'FAILED', 'RUNNING', 'CANCELLED') DEFAULT 'SUCCESS' COMMENT '执行状态',
    start_time DATETIME NOT NULL COMMENT '开始时间',
    end_time DATETIME COMMENT '结束时间',
    execution_time BIGINT COMMENT '执行时间(ms)',
    run_count INT DEFAULT 1 COMMENT '执行次数',
    error_message TEXT COMMENT '错误信息',
    exception_stack TEXT COMMENT '异常堆栈',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant (tenant_id),
    INDEX idx_job_id (job_id),
    INDEX idx_job_name (job_name),
    INDEX idx_job_group (job_group),
    INDEX idx_execution_status (execution_status),
    INDEX idx_start_time (start_time)
) COMMENT '系统任务执行日志表';

-- 接口调用日志表
CREATE TABLE api_call_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    api_name VARCHAR(128) NOT NULL COMMENT 'API名称',
    api_path VARCHAR(255) NOT NULL COMMENT 'API路径',
    http_method VARCHAR(10) NOT NULL COMMENT 'HTTP方法',
    request_id VARCHAR(64) COMMENT '请求ID',
    user_id VARCHAR(32) COMMENT '用户ID',
    username VARCHAR(64) COMMENT '用户名',
    request_ip VARCHAR(45) COMMENT '请求IP',
    user_agent VARCHAR(500) COMMENT '用户代理',
    request_params TEXT COMMENT '请求参数',
    request_body TEXT COMMENT '请求体',
    response_status INT COMMENT '响应状态码',
    response_body TEXT COMMENT '响应体',
    response_time BIGINT COMMENT '响应时间(ms)',
    call_status ENUM('SUCCESS', 'FAILED', 'TIMEOUT') DEFAULT 'SUCCESS' COMMENT '调用状态',
    error_code VARCHAR(32) COMMENT '错误代码',
    error_message TEXT COMMENT '错误信息',
    call_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '调用时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_api_name (api_name),
    INDEX idx_api_path (api_path),
    INDEX idx_http_method (http_method),
    INDEX idx_request_id (request_id),
    INDEX idx_user_id (user_id),
    INDEX idx_call_status (call_status),
    INDEX idx_response_status (response_status),
    INDEX idx_call_time (call_time)
) COMMENT '接口调用日志表';

-- 数据库操作日志表
CREATE TABLE database_operation_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    database_name VARCHAR(64) NOT NULL COMMENT '数据库名',
    table_name VARCHAR(64) NOT NULL COMMENT '表名',
    operation_type ENUM('SELECT', 'INSERT', 'UPDATE', 'DELETE', 'CREATE', 'DROP', 'ALTER') NOT NULL COMMENT '操作类型',
    sql_statement TEXT COMMENT 'SQL语句',
    affected_rows INT DEFAULT 0 COMMENT '影响行数',
    execution_time BIGINT COMMENT '执行时间(ms)',
    operation_status ENUM('SUCCESS', 'FAILED', 'TIMEOUT') DEFAULT 'SUCCESS' COMMENT '操作状态',
    error_message TEXT COMMENT '错误信息',
    user_id VARCHAR(32) COMMENT '用户ID',
    username VARCHAR(64) COMMENT '用户名',
    ip_address VARCHAR(45) COMMENT 'IP地址',
    operation_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_database_name (database_name),
    INDEX idx_table_name (table_name),
    INDEX idx_operation_type (operation_type),
    INDEX idx_operation_status (operation_status),
    INDEX idx_user_id (user_id),
    INDEX idx_operation_time (operation_time)
) COMMENT '数据库操作日志表';

-- 缓存操作日志表
CREATE TABLE cache_operation_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    cache_type VARCHAR(32) NOT NULL COMMENT '缓存类型',
    cache_key VARCHAR(255) NOT NULL COMMENT '缓存键',
    operation_type ENUM('GET', 'SET', 'DELETE', 'EXPIRE', 'CLEAR') NOT NULL COMMENT '操作类型',
    key_size INT COMMENT '键大小',
    value_size INT COMMENT '值大小',
    ttl_seconds INT COMMENT 'TTL秒数',
    hit_status ENUM('HIT', 'MISS') COMMENT '命中状态',
    operation_time BIGINT COMMENT '操作时间(ms)',
    operation_status ENUM('SUCCESS', 'FAILED') DEFAULT 'SUCCESS' COMMENT '操作状态',
    error_message TEXT COMMENT '错误信息',
    user_id VARCHAR(32) COMMENT '用户ID',
    ip_address VARCHAR(45) COMMENT 'IP地址',
    operation_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_cache_type (cache_type),
    INDEX idx_cache_key (cache_key),
    INDEX idx_operation_type (operation_type),
    INDEX idx_hit_status (hit_status),
    INDEX idx_operation_status (operation_status),
    INDEX idx_user_id (user_id),
    INDEX idx_operation_time (operation_time)
) COMMENT '缓存操作日志表';

-- 消息队列日志表
CREATE TABLE message_queue_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    queue_name VARCHAR(128) NOT NULL COMMENT '队列名称',
    message_id VARCHAR(64) NOT NULL COMMENT '消息ID',
    message_type VARCHAR(64) NOT NULL COMMENT '消息类型',
    message_content TEXT COMMENT '消息内容',
    message_size INT COMMENT '消息大小',
    operation_type ENUM('SEND', 'RECEIVE', 'ACK', 'NACK', 'REJECT') NOT NULL COMMENT '操作类型',
    producer_id VARCHAR(64) COMMENT '生产者ID',
    consumer_id VARCHAR(64) COMMENT '消费者ID',
    priority INT DEFAULT 0 COMMENT '优先级',
    delay_seconds INT DEFAULT 0 COMMENT '延迟秒数',
    retry_count INT DEFAULT 0 COMMENT '重试次数',
    max_retry_count INT DEFAULT 3 COMMENT '最大重试次数',
    processing_time BIGINT COMMENT '处理时间(ms)',
    operation_status ENUM('SUCCESS', 'FAILED', 'TIMEOUT', 'RETRY') DEFAULT 'SUCCESS' COMMENT '操作状态',
    error_message TEXT COMMENT '错误信息',
    operation_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_queue_name (queue_name),
    INDEX idx_message_id (message_id),
    INDEX idx_message_type (message_type),
    INDEX idx_operation_type (operation_type),
    INDEX idx_operation_status (operation_status),
    INDEX idx_producer_id (producer_id),
    INDEX idx_consumer_id (consumer_id),
    INDEX idx_operation_time (operation_time)
) COMMENT '消息队列日志表';

-- 系统性能监控日志表
CREATE TABLE system_performance_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    server_name VARCHAR(128) NOT NULL COMMENT '服务器名称',
    server_ip VARCHAR(45) COMMENT '服务器IP',
    metric_category VARCHAR(64) NOT NULL COMMENT '指标分类',
    metric_name VARCHAR(128) NOT NULL COMMENT '指标名称',
    metric_value DECIMAL(18,4) NOT NULL COMMENT '指标值',
    metric_unit VARCHAR(16) COMMENT '指标单位',
    threshold_warning DECIMAL(18,4) COMMENT '警告阈值',
    threshold_critical DECIMAL(18,4) COMMENT '严重阈值',
    alert_level ENUM('NORMAL', 'WARNING', 'CRITICAL') DEFAULT 'NORMAL' COMMENT '告警级别',
    collection_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '采集时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_server_name (server_name),
    INDEX idx_server_ip (server_ip),
    INDEX idx_metric_category (metric_category),
    INDEX idx_metric_name (metric_name),
    INDEX idx_alert_level (alert_level),
    INDEX idx_collection_time (collection_time)
) COMMENT '系统性能监控日志表';
