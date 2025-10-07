-- V20250107_1604__create_log_database.sql
-- 创建BTC日志数据库
-- 基于MES系统全局架构基础文档
-- 作者: MES开发团队
-- 日期: 2025-01-07

-- 创建BTC日志数据库
CREATE DATABASE IF NOT EXISTS btc_log CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE btc_log;

-- ==============================================
-- 1. 用户行为日志表
-- ==============================================

-- 用户行为日志表
CREATE TABLE IF NOT EXISTS user_behavior_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    user_id VARCHAR(32) NOT NULL COMMENT '用户ID',
    username VARCHAR(64) COMMENT '用户名',
    session_id VARCHAR(64) COMMENT '会话ID',
    behavior_type VARCHAR(32) NOT NULL COMMENT '行为类型 LOGIN/LOGOUT/VIEW/CLICK/SEARCH/EXPORT/PRINT',
    module VARCHAR(64) COMMENT '模块名称',
    page_path VARCHAR(255) COMMENT '页面路径',
    action VARCHAR(128) COMMENT '具体动作',
    target_element VARCHAR(128) COMMENT '目标元素',
    request_method VARCHAR(10) COMMENT '请求方法',
    request_url VARCHAR(500) COMMENT '请求URL',
    request_params TEXT COMMENT '请求参数',
    response_status INT COMMENT '响应状态码',
    response_time BIGINT COMMENT '响应时间(ms)',
    user_agent VARCHAR(500) COMMENT '用户代理',
    ip_address VARCHAR(45) COMMENT 'IP地址',
    location VARCHAR(100) COMMENT '地理位置',
    device_type VARCHAR(32) COMMENT '设备类型 PC/MOBILE/TABLET',
    browser VARCHAR(100) COMMENT '浏览器',
    os VARCHAR(100) COMMENT '操作系统',
    referrer VARCHAR(500) COMMENT '来源页面',
    extra_data JSON COMMENT '扩展数据',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_user (user_id),
    INDEX idx_behavior_type (behavior_type),
    INDEX idx_module (module),
    INDEX idx_created_at (created_at),
    INDEX idx_session (session_id),
    INDEX idx_ip (ip_address)
) COMMENT '用户行为日志表';

-- 用户会话表
CREATE TABLE IF NOT EXISTS user_session (
    session_id VARCHAR(64) PRIMARY KEY COMMENT '会话ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    user_id VARCHAR(32) NOT NULL COMMENT '用户ID',
    username VARCHAR(64) COMMENT '用户名',
    ip_address VARCHAR(45) COMMENT 'IP地址',
    user_agent VARCHAR(500) COMMENT '用户代理',
    device_type VARCHAR(32) COMMENT '设备类型',
    browser VARCHAR(100) COMMENT '浏览器',
    os VARCHAR(100) COMMENT '操作系统',
    location VARCHAR(100) COMMENT '地理位置',
    login_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登录时间',
    last_activity_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后活动时间',
    logout_time DATETIME COMMENT '登出时间',
    session_duration BIGINT COMMENT '会话时长(秒)',
    is_active TINYINT(1) DEFAULT 1 COMMENT '是否活跃',
    session_data JSON COMMENT '会话数据',
    
    INDEX idx_tenant (tenant_id),
    INDEX idx_user (user_id),
    INDEX idx_login_time (login_time),
    INDEX idx_last_activity (last_activity_time),
    INDEX idx_ip (ip_address)
) COMMENT '用户会话表';

-- ==============================================
-- 2. 系统运行日志表
-- ==============================================

-- 系统运行日志表
CREATE TABLE IF NOT EXISTS system_runtime_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id VARCHAR(32) COMMENT '租户ID',
    log_level ENUM('DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL') NOT NULL COMMENT '日志级别',
    logger_name VARCHAR(128) NOT NULL COMMENT '日志器名称',
    thread_name VARCHAR(64) COMMENT '线程名称',
    message TEXT NOT NULL COMMENT '日志消息',
    exception_info TEXT COMMENT '异常信息',
    stack_trace TEXT COMMENT '堆栈跟踪',
    class_name VARCHAR(255) COMMENT '类名',
    method_name VARCHAR(128) COMMENT '方法名',
    line_number INT COMMENT '行号',
    file_name VARCHAR(255) COMMENT '文件名',
    request_id VARCHAR(64) COMMENT '请求ID',
    trace_id VARCHAR(64) COMMENT '链路追踪ID',
    span_id VARCHAR(64) COMMENT 'Span ID',
    parent_span_id VARCHAR(64) COMMENT '父Span ID',
    service_name VARCHAR(64) COMMENT '服务名称',
    host_name VARCHAR(128) COMMENT '主机名',
    host_ip VARCHAR(45) COMMENT '主机IP',
    process_id INT COMMENT '进程ID',
    memory_usage BIGINT COMMENT '内存使用量',
    cpu_usage DECIMAL(5,2) COMMENT 'CPU使用率',
    disk_usage DECIMAL(5,2) COMMENT '磁盘使用率',
    network_io BIGINT COMMENT '网络IO',
    extra_data JSON COMMENT '扩展数据',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant (tenant_id),
    INDEX idx_log_level (log_level),
    INDEX idx_logger_name (logger_name),
    INDEX idx_created_at (created_at),
    INDEX idx_request_id (request_id),
    INDEX idx_trace_id (trace_id),
    INDEX idx_service (service_name)
) COMMENT '系统运行日志表';

-- 性能监控日志表
CREATE TABLE IF NOT EXISTS performance_monitor_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id VARCHAR(32) COMMENT '租户ID',
    service_name VARCHAR(64) NOT NULL COMMENT '服务名称',
    endpoint VARCHAR(255) COMMENT '接口端点',
    method VARCHAR(10) COMMENT 'HTTP方法',
    request_id VARCHAR(64) COMMENT '请求ID',
    user_id VARCHAR(32) COMMENT '用户ID',
    start_time DATETIME NOT NULL COMMENT '开始时间',
    end_time DATETIME NOT NULL COMMENT '结束时间',
    duration BIGINT NOT NULL COMMENT '耗时(ms)',
    status_code INT COMMENT '状态码',
    request_size BIGINT COMMENT '请求大小(bytes)',
    response_size BIGINT COMMENT '响应大小(bytes)',
    cpu_usage DECIMAL(5,2) COMMENT 'CPU使用率',
    memory_usage BIGINT COMMENT '内存使用量',
    disk_io BIGINT COMMENT '磁盘IO',
    network_io BIGINT COMMENT '网络IO',
    database_query_count INT COMMENT '数据库查询次数',
    database_query_time BIGINT COMMENT '数据库查询耗时(ms)',
    cache_hit_rate DECIMAL(5,2) COMMENT '缓存命中率',
    error_count INT DEFAULT 0 COMMENT '错误数量',
    slow_query_count INT DEFAULT 0 COMMENT '慢查询数量',
    extra_metrics JSON COMMENT '扩展指标',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant (tenant_id),
    INDEX idx_service (service_name),
    INDEX idx_endpoint (endpoint),
    INDEX idx_start_time (start_time),
    INDEX idx_duration (duration),
    INDEX idx_request_id (request_id),
    INDEX idx_user (user_id)
) COMMENT '性能监控日志表';

-- ==============================================
-- 3. 业务操作日志表
-- ==============================================

-- 业务操作日志表
CREATE TABLE IF NOT EXISTS business_operation_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    user_id VARCHAR(32) NOT NULL COMMENT '用户ID',
    username VARCHAR(64) COMMENT '用户名',
    operation_type VARCHAR(32) NOT NULL COMMENT '操作类型 CREATE/UPDATE/DELETE/APPROVE/REJECT/EXPORT/IMPORT',
    business_type VARCHAR(64) NOT NULL COMMENT '业务类型 WORK_ORDER/INSPECTION/STOCK/TRACE',
    business_id VARCHAR(32) COMMENT '业务ID',
    business_name VARCHAR(255) COMMENT '业务名称',
    operation_desc VARCHAR(500) COMMENT '操作描述',
    before_data JSON COMMENT '操作前数据',
    after_data JSON COMMENT '操作后数据',
    changed_fields JSON COMMENT '变更字段',
    operation_result ENUM('SUCCESS', 'FAILURE', 'PARTIAL') DEFAULT 'SUCCESS' COMMENT '操作结果',
    error_message TEXT COMMENT '错误信息',
    request_method VARCHAR(10) COMMENT '请求方法',
    request_url VARCHAR(500) COMMENT '请求URL',
    request_ip VARCHAR(45) COMMENT '请求IP',
    user_agent VARCHAR(500) COMMENT '用户代理',
    session_id VARCHAR(64) COMMENT '会话ID',
    request_id VARCHAR(64) COMMENT '请求ID',
    execution_time BIGINT COMMENT '执行时间(ms)',
    extra_data JSON COMMENT '扩展数据',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_user (user_id),
    INDEX idx_operation_type (operation_type),
    INDEX idx_business_type (business_type),
    INDEX idx_business_id (business_id),
    INDEX idx_created_at (created_at),
    INDEX idx_session (session_id),
    INDEX idx_request_id (request_id)
) COMMENT '业务操作日志表';

-- ==============================================
-- 4. 安全审计日志表
-- ==============================================

-- 安全审计日志表
CREATE TABLE IF NOT EXISTS security_audit_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    user_id VARCHAR(32) COMMENT '用户ID',
    username VARCHAR(64) COMMENT '用户名',
    audit_type VARCHAR(32) NOT NULL COMMENT '审计类型 LOGIN/LOGOUT/PERMISSION/DATA_ACCESS/FILE_ACCESS/SYSTEM_CONFIG',
    event_type VARCHAR(32) NOT NULL COMMENT '事件类型 SUCCESS/FAILURE/SUSPICIOUS/BLOCKED',
    severity ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') DEFAULT 'LOW' COMMENT '严重程度',
    event_desc VARCHAR(500) COMMENT '事件描述',
    target_resource VARCHAR(255) COMMENT '目标资源',
    action VARCHAR(128) COMMENT '动作',
    result ENUM('SUCCESS', 'FAILURE', 'DENIED') COMMENT '结果',
    failure_reason VARCHAR(255) COMMENT '失败原因',
    ip_address VARCHAR(45) COMMENT 'IP地址',
    user_agent VARCHAR(500) COMMENT '用户代理',
    location VARCHAR(100) COMMENT '地理位置',
    session_id VARCHAR(64) COMMENT '会话ID',
    request_id VARCHAR(64) COMMENT '请求ID',
    risk_score INT DEFAULT 0 COMMENT '风险评分 0-100',
    is_suspicious TINYINT(1) DEFAULT 0 COMMENT '是否可疑',
    is_blocked TINYINT(1) DEFAULT 0 COMMENT '是否被阻止',
    block_reason VARCHAR(255) COMMENT '阻止原因',
    extra_data JSON COMMENT '扩展数据',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_user (user_id),
    INDEX idx_audit_type (audit_type),
    INDEX idx_event_type (event_type),
    INDEX idx_severity (severity),
    INDEX idx_created_at (created_at),
    INDEX idx_ip (ip_address),
    INDEX idx_risk_score (risk_score),
    INDEX idx_suspicious (is_suspicious)
) COMMENT '安全审计日志表';

-- 登录尝试日志表
CREATE TABLE IF NOT EXISTS login_attempt_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id VARCHAR(32) COMMENT '租户ID',
    username VARCHAR(64) NOT NULL COMMENT '用户名',
    ip_address VARCHAR(45) COMMENT 'IP地址',
    user_agent VARCHAR(500) COMMENT '用户代理',
    login_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登录时间',
    result ENUM('SUCCESS', 'FAILED', 'BLOCKED') NOT NULL COMMENT '登录结果',
    failure_reason VARCHAR(255) COMMENT '失败原因',
    attempt_count INT DEFAULT 1 COMMENT '尝试次数',
    is_suspicious TINYINT(1) DEFAULT 0 COMMENT '是否可疑',
    location VARCHAR(100) COMMENT '地理位置',
    device_fingerprint VARCHAR(128) COMMENT '设备指纹',
    session_id VARCHAR(64) COMMENT '会话ID',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant (tenant_id),
    INDEX idx_username (username),
    INDEX idx_ip (ip_address),
    INDEX idx_login_time (login_time),
    INDEX idx_result (result),
    INDEX idx_suspicious (is_suspicious)
) COMMENT '登录尝试日志表';

-- ==============================================
-- 5. 系统监控日志表
-- ==============================================

-- 系统监控日志表
CREATE TABLE IF NOT EXISTS system_monitor_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id VARCHAR(32) COMMENT '租户ID',
    service_name VARCHAR(64) NOT NULL COMMENT '服务名称',
    host_name VARCHAR(128) COMMENT '主机名',
    host_ip VARCHAR(45) COMMENT '主机IP',
    metric_type VARCHAR(32) NOT NULL COMMENT '指标类型 CPU/MEMORY/DISK/NETWORK/APPLICATION',
    metric_name VARCHAR(64) NOT NULL COMMENT '指标名称',
    metric_value DECIMAL(18,6) NOT NULL COMMENT '指标值',
    metric_unit VARCHAR(16) COMMENT '指标单位',
    threshold_value DECIMAL(18,6) COMMENT '阈值',
    alert_level ENUM('INFO', 'WARNING', 'CRITICAL', 'FATAL') COMMENT '告警级别',
    is_alert TINYINT(1) DEFAULT 0 COMMENT '是否告警',
    alert_message VARCHAR(500) COMMENT '告警消息',
    collection_time DATETIME NOT NULL COMMENT '采集时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant (tenant_id),
    INDEX idx_service (service_name),
    INDEX idx_host (host_name, host_ip),
    INDEX idx_metric_type (metric_type),
    INDEX idx_metric_name (metric_name),
    INDEX idx_collection_time (collection_time),
    INDEX idx_alert (is_alert),
    INDEX idx_alert_level (alert_level)
) COMMENT '系统监控日志表';

-- 告警日志表
CREATE TABLE IF NOT EXISTS alert_log (
    alert_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    alert_type VARCHAR(32) NOT NULL COMMENT '告警类型 SYSTEM/APPLICATION/BUSINESS/SECURITY',
    alert_level ENUM('INFO', 'WARNING', 'CRITICAL', 'FATAL') NOT NULL COMMENT '告警级别',
    alert_source VARCHAR(64) NOT NULL COMMENT '告警源',
    alert_title VARCHAR(255) NOT NULL COMMENT '告警标题',
    alert_message TEXT NOT NULL COMMENT '告警消息',
    alert_data JSON COMMENT '告警数据',
    is_resolved TINYINT(1) DEFAULT 0 COMMENT '是否已解决',
    resolved_by VARCHAR(64) COMMENT '解决人',
    resolved_at DATETIME COMMENT '解决时间',
    resolved_note TEXT COMMENT '解决说明',
    first_occurred_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '首次发生时间',
    last_occurred_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后发生时间',
    occurrence_count INT DEFAULT 1 COMMENT '发生次数',
    notification_sent TINYINT(1) DEFAULT 0 COMMENT '是否已发送通知',
    notification_channels JSON COMMENT '通知渠道',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_alert_type (alert_type),
    INDEX idx_alert_level (alert_level),
    INDEX idx_alert_source (alert_source),
    INDEX idx_first_occurred (first_occurred_at),
    INDEX idx_last_occurred (last_occurred_at),
    INDEX idx_resolved (is_resolved),
    INDEX idx_notification (notification_sent)
) COMMENT '告警日志表';
