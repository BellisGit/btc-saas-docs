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
    resolution_notes TEXT COMMENT '解决说明',
    escalation_level INT DEFAULT 0 COMMENT '升级级别',
    escalation_users JSON COMMENT '升级用户列表',
    notification_channels JSON COMMENT '通知渠道',
    notification_status JSON COMMENT '通知状态',
    alert_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '告警时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_alert_no (alert_no),
    INDEX idx_alert_type (alert_type),
    INDEX idx_alert_category (alert_category),
    INDEX idx_alert_level (alert_level),
    INDEX idx_alert_status (alert_status),
    INDEX idx_acknowledge_user (acknowledge_user),
    INDEX idx_resolve_user (resolve_user),
    INDEX idx_alert_time (alert_time)
) COMMENT '告警日志表';

-- 系统运行日志表
CREATE TABLE system_runtime_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    server_name VARCHAR(128) COMMENT '服务器名称',
    application_name VARCHAR(64) COMMENT '应用名称',
    log_level ENUM('DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL') NOT NULL COMMENT '日志级别',
    logger_name VARCHAR(255) COMMENT '日志器名称',
    thread_name VARCHAR(128) COMMENT '线程名称',
    message TEXT NOT NULL COMMENT '日志消息',
    exception_stack TEXT COMMENT '异常堆栈',
    mdc_data JSON COMMENT 'MDC数据',
    marker VARCHAR(128) COMMENT '标记',
    timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '时间戳',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_server_name (server_name),
    INDEX idx_application_name (application_name),
    INDEX idx_log_level (log_level),
    INDEX idx_logger_name (logger_name),
    INDEX idx_timestamp (timestamp)
) COMMENT '系统运行日志表';

-- 安全审计日志表
CREATE TABLE security_audit_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    user_id VARCHAR(32) COMMENT '用户ID',
    username VARCHAR(64) COMMENT '用户名',
    audit_type VARCHAR(32) NOT NULL COMMENT '审计类型',
    audit_action VARCHAR(64) NOT NULL COMMENT '审计动作',
    resource_type VARCHAR(64) COMMENT '资源类型',
    resource_id VARCHAR(64) COMMENT '资源ID',
    resource_name VARCHAR(255) COMMENT '资源名称',
    operation_result ENUM('SUCCESS', 'FAILED', 'DENIED') DEFAULT 'SUCCESS' COMMENT '操作结果',
    failure_reason VARCHAR(255) COMMENT '失败原因',
    client_ip VARCHAR(45) COMMENT '客户端IP',
    user_agent VARCHAR(500) COMMENT '用户代理',
    session_id VARCHAR(64) COMMENT '会话ID',
    audit_data JSON COMMENT '审计数据',
    risk_level ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') DEFAULT 'LOW' COMMENT '风险级别',
    audit_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '审计时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_user_id (user_id),
    INDEX idx_username (username),
    INDEX idx_audit_type (audit_type),
    INDEX idx_audit_action (audit_action),
    INDEX idx_resource_type (resource_type),
    INDEX idx_operation_result (operation_result),
    INDEX idx_risk_level (risk_level),
    INDEX idx_audit_time (audit_time),
    INDEX idx_client_ip (client_ip)
) COMMENT '安全审计日志表';

-- 性能监控日志表
CREATE TABLE performance_monitor_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    server_name VARCHAR(128) COMMENT '服务器名称',
    application_name VARCHAR(64) COMMENT '应用名称',
    component_name VARCHAR(128) COMMENT '组件名称',
    operation_name VARCHAR(128) NOT NULL COMMENT '操作名称',
    operation_type VARCHAR(32) NOT NULL COMMENT '操作类型',
    execution_time BIGINT NOT NULL COMMENT '执行时间(ms)',
    cpu_usage DECIMAL(5,2) COMMENT 'CPU使用率',
    memory_usage DECIMAL(5,2) COMMENT '内存使用率',
    disk_io BIGINT COMMENT '磁盘IO',
    network_io BIGINT COMMENT '网络IO',
    thread_count INT COMMENT '线程数',
    connection_count INT COMMENT '连接数',
    queue_size INT COMMENT '队列大小',
    cache_hit_rate DECIMAL(5,2) COMMENT '缓存命中率',
    error_count INT DEFAULT 0 COMMENT '错误数',
    warning_count INT DEFAULT 0 COMMENT '警告数',
    monitor_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '监控时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_server_name (server_name),
    INDEX idx_application_name (application_name),
    INDEX idx_component_name (component_name),
    INDEX idx_operation_name (operation_name),
    INDEX idx_operation_type (operation_type),
    INDEX idx_monitor_time (monitor_time)
) COMMENT '性能监控日志表';

-- 数据库性能日志表
CREATE TABLE database_performance_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    database_name VARCHAR(64) NOT NULL COMMENT '数据库名',
    connection_pool_name VARCHAR(64) COMMENT '连接池名称',
    sql_hash VARCHAR(64) COMMENT 'SQL哈希',
    sql_statement TEXT COMMENT 'SQL语句',
    execution_time BIGINT NOT NULL COMMENT '执行时间(ms)',
    rows_affected INT COMMENT '影响行数',
    rows_returned INT COMMENT '返回行数',
    lock_time BIGINT COMMENT '锁定时间(ms)',
    query_cache_hit BOOLEAN DEFAULT FALSE COMMENT '查询缓存命中',
    slow_query BOOLEAN DEFAULT FALSE COMMENT '慢查询',
    connection_time BIGINT COMMENT '连接时间(ms)',
    wait_time BIGINT COMMENT '等待时间(ms)',
    error_message TEXT COMMENT '错误信息',
    monitor_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '监控时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_database_name (database_name),
    INDEX idx_connection_pool_name (connection_pool_name),
    INDEX idx_sql_hash (sql_hash),
    INDEX idx_execution_time (execution_time),
    INDEX idx_slow_query (slow_query),
    INDEX idx_monitor_time (monitor_time)
) COMMENT '数据库性能日志表';

-- 网络监控日志表
CREATE TABLE network_monitor_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    server_name VARCHAR(128) COMMENT '服务器名称',
    interface_name VARCHAR(64) COMMENT '网络接口名称',
    protocol VARCHAR(16) COMMENT '协议',
    remote_host VARCHAR(255) COMMENT '远程主机',
    remote_port INT COMMENT '远程端口',
    connection_count INT COMMENT '连接数',
    active_connections INT COMMENT '活跃连接数',
    bytes_sent BIGINT COMMENT '发送字节数',
    bytes_received BIGINT COMMENT '接收字节数',
    packets_sent BIGINT COMMENT '发送包数',
    packets_received BIGINT COMMENT '接收包数',
    connection_errors INT COMMENT '连接错误数',
    timeout_count INT COMMENT '超时次数',
    retry_count INT COMMENT '重试次数',
    bandwidth_usage DECIMAL(8,2) COMMENT '带宽使用率',
    latency_ms DECIMAL(8,2) COMMENT '延迟(ms)',
    monitor_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '监控时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_server_name (server_name),
    INDEX idx_interface_name (interface_name),
    INDEX idx_protocol (protocol),
    INDEX idx_remote_host (remote_host),
    INDEX idx_monitor_time (monitor_time)
) COMMENT '网络监控日志表';

-- 系统资源使用日志表
CREATE TABLE system_resource_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    server_name VARCHAR(128) COMMENT '服务器名称',
    cpu_usage DECIMAL(5,2) COMMENT 'CPU使用率',
    memory_usage DECIMAL(5,2) COMMENT '内存使用率',
    memory_total BIGINT COMMENT '总内存(字节)',
    memory_used BIGINT COMMENT '已用内存(字节)',
    memory_free BIGINT COMMENT '空闲内存(字节)',
    disk_usage DECIMAL(5,2) COMMENT '磁盘使用率',
    disk_total BIGINT COMMENT '总磁盘空间(字节)',
    disk_used BIGINT COMMENT '已用磁盘空间(字节)',
    disk_free BIGINT COMMENT '空闲磁盘空间(字节)',
    load_average DECIMAL(8,2) COMMENT '负载平均值',
    process_count INT COMMENT '进程数',
    thread_count INT COMMENT '线程数',
    file_descriptor_count INT COMMENT '文件描述符数量',
    swap_usage DECIMAL(5,2) COMMENT '交换空间使用率',
    swap_total BIGINT COMMENT '总交换空间(字节)',
    swap_used BIGINT COMMENT '已用交换空间(字节)',
    monitor_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '监控时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_server_name (server_name),
    INDEX idx_cpu_usage (cpu_usage),
    INDEX idx_memory_usage (memory_usage),
    INDEX idx_disk_usage (disk_usage),
    INDEX idx_load_average (load_average),
    INDEX idx_monitor_time (monitor_time)
) COMMENT '系统资源使用日志表';

-- 定时任务执行日志表
CREATE TABLE scheduled_task_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    task_name VARCHAR(128) NOT NULL COMMENT '任务名称',
    task_group VARCHAR(64) COMMENT '任务组',
    task_class VARCHAR(255) COMMENT '任务类名',
    execution_id VARCHAR(64) NOT NULL COMMENT '执行ID',
    start_time DATETIME NOT NULL COMMENT '开始时间',
    end_time DATETIME COMMENT '结束时间',
    execution_time BIGINT COMMENT '执行时间(ms)',
    execution_status ENUM('RUNNING', 'SUCCESS', 'FAILED', 'TIMEOUT', 'CANCELLED') DEFAULT 'RUNNING' COMMENT '执行状态',
    result_data TEXT COMMENT '结果数据',
    error_message TEXT COMMENT '错误信息',
    trigger_type VARCHAR(32) COMMENT '触发器类型',
    trigger_name VARCHAR(128) COMMENT '触发器名称',
    previous_execution_time DATETIME COMMENT '上次执行时间',
    next_execution_time DATETIME COMMENT '下次执行时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_task_name (task_name),
    INDEX idx_task_group (task_group),
    INDEX idx_execution_id (execution_id),
    INDEX idx_execution_status (execution_status),
    INDEX idx_start_time (start_time),
    INDEX idx_end_time (end_time)
) COMMENT '定时任务执行日志表';

-- 外部系统调用日志表
CREATE TABLE external_system_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    user_id VARCHAR(32) COMMENT '用户ID',
    username VARCHAR(64) COMMENT '用户名',
    system_name VARCHAR(128) NOT NULL COMMENT '外部系统名称',
    system_type VARCHAR(64) COMMENT '系统类型',
    api_endpoint VARCHAR(255) COMMENT 'API端点',
    request_method VARCHAR(10) COMMENT '请求方法',
    request_data TEXT COMMENT '请求数据',
    response_data TEXT COMMENT '响应数据',
    response_code INT COMMENT '响应码',
    execution_time BIGINT COMMENT '执行时间(ms)',
    connection_time BIGINT COMMENT '连接时间(ms)',
    read_time BIGINT COMMENT '读取时间(ms)',
    call_status ENUM('SUCCESS', 'FAILED', 'TIMEOUT', 'CONNECTION_ERROR') DEFAULT 'SUCCESS' COMMENT '调用状态',
    error_message TEXT COMMENT '错误信息',
    retry_count INT DEFAULT 0 COMMENT '重试次数',
    call_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '调用时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_user_id (user_id),
    INDEX idx_username (username),
    INDEX idx_system_name (system_name),
    INDEX idx_system_type (system_type),
    INDEX idx_api_endpoint (api_endpoint),
    INDEX idx_response_code (response_code),
    INDEX idx_call_status (call_status),
    INDEX idx_call_time (call_time)
) COMMENT '外部系统调用日志表';