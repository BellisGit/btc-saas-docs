-- ==============================================
-- BTC日志数据库 - 操作和业务日志表
-- ==============================================

USE btc_log;

-- 系统操作日志表
CREATE TABLE sys_operation_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    user_id VARCHAR(32) COMMENT '用户ID',
    username VARCHAR(64) COMMENT '用户名',
    operation_type VARCHAR(32) NOT NULL COMMENT '操作类型',
    operation_name VARCHAR(128) COMMENT '操作名称',
    operation_method VARCHAR(255) COMMENT '操作方法',
    request_method VARCHAR(10) COMMENT '请求方法',
    request_url VARCHAR(500) COMMENT '请求URL',
    request_ip VARCHAR(45) COMMENT '请求IP',
    request_params TEXT COMMENT '请求参数',
    response_result TEXT COMMENT '响应结果',
    response_time BIGINT COMMENT '响应时间(ms)',
    operation_status ENUM('SUCCESS', 'FAILED', 'ERROR') DEFAULT 'SUCCESS' COMMENT '操作状态',
    error_message TEXT COMMENT '错误信息',
    user_agent VARCHAR(500) COMMENT '用户代理',
    operation_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_user_id (user_id),
    INDEX idx_username (username),
    INDEX idx_operation_type (operation_type),
    INDEX idx_operation_status (operation_status),
    INDEX idx_operation_time (operation_time),
    INDEX idx_request_ip (request_ip)
) COMMENT '系统操作日志表';

-- 系统登录日志表
CREATE TABLE sys_login_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    user_id VARCHAR(32) COMMENT '用户ID',
    username VARCHAR(64) COMMENT '用户名',
    login_type ENUM('LOGIN', 'LOGOUT', 'REFRESH') DEFAULT 'LOGIN' COMMENT '登录类型',
    login_ip VARCHAR(45) COMMENT '登录IP',
    login_location VARCHAR(255) COMMENT '登录地点',
    browser VARCHAR(64) COMMENT '浏览器',
    os VARCHAR(64) COMMENT '操作系统',
    user_agent VARCHAR(500) COMMENT '用户代理',
    login_status ENUM('SUCCESS', 'FAILED', 'BLOCKED') DEFAULT 'SUCCESS' COMMENT '登录状态',
    failure_reason VARCHAR(255) COMMENT '失败原因',
    login_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登录时间',
    logout_time DATETIME COMMENT '登出时间',
    session_duration BIGINT COMMENT '会话时长(分钟)',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_user_id (user_id),
    INDEX idx_username (username),
    INDEX idx_login_type (login_type),
    INDEX idx_login_status (login_status),
    INDEX idx_login_time (login_time),
    INDEX idx_login_ip (login_ip)
) COMMENT '系统登录日志表';

-- 业务操作日志表
CREATE TABLE business_operation_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    user_id VARCHAR(32) COMMENT '用户ID',
    username VARCHAR(64) COMMENT '用户名',
    business_module VARCHAR(64) NOT NULL COMMENT '业务模块',
    business_type VARCHAR(64) NOT NULL COMMENT '业务类型',
    business_id VARCHAR(64) COMMENT '业务ID',
    operation_action VARCHAR(64) NOT NULL COMMENT '操作动作',
    operation_object VARCHAR(128) COMMENT '操作对象',
    operation_result ENUM('SUCCESS', 'FAILED', 'PARTIAL') DEFAULT 'SUCCESS' COMMENT '操作结果',
    operation_data JSON COMMENT '操作数据',
    operation_summary TEXT COMMENT '操作摘要',
    operation_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_user_id (user_id),
    INDEX idx_username (username),
    INDEX idx_business_module (business_module),
    INDEX idx_business_type (business_type),
    INDEX idx_business_id (business_id),
    INDEX idx_operation_action (operation_action),
    INDEX idx_operation_result (operation_result),
    INDEX idx_operation_time (operation_time)
) COMMENT '业务操作日志表';

-- 数据变更日志表
CREATE TABLE data_change_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    user_id VARCHAR(32) COMMENT '用户ID',
    username VARCHAR(64) COMMENT '用户名',
    table_name VARCHAR(64) NOT NULL COMMENT '表名',
    record_id VARCHAR(64) NOT NULL COMMENT '记录ID',
    operation_type ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL COMMENT '操作类型',
    change_fields JSON COMMENT '变更字段',
    old_values JSON COMMENT '旧值',
    new_values JSON COMMENT '新值',
    change_summary TEXT COMMENT '变更摘要',
    operation_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_user_id (user_id),
    INDEX idx_username (username),
    INDEX idx_table_name (table_name),
    INDEX idx_record_id (record_id),
    INDEX idx_operation_type (operation_type),
    INDEX idx_operation_time (operation_time)
) COMMENT '数据变更日志表';

-- 文件操作日志表
CREATE TABLE file_operation_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    user_id VARCHAR(32) COMMENT '用户ID',
    username VARCHAR(64) COMMENT '用户名',
    operation_type ENUM('UPLOAD', 'DOWNLOAD', 'DELETE', 'MOVE', 'COPY') NOT NULL COMMENT '操作类型',
    file_name VARCHAR(255) NOT NULL COMMENT '文件名',
    file_path VARCHAR(500) COMMENT '文件路径',
    file_size BIGINT COMMENT '文件大小(字节)',
    file_type VARCHAR(64) COMMENT '文件类型',
    storage_location VARCHAR(128) COMMENT '存储位置',
    operation_status ENUM('SUCCESS', 'FAILED', 'PARTIAL') DEFAULT 'SUCCESS' COMMENT '操作状态',
    error_message TEXT COMMENT '错误信息',
    operation_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_user_id (user_id),
    INDEX idx_username (username),
    INDEX idx_operation_type (operation_type),
    INDEX idx_file_name (file_name),
    INDEX idx_file_type (file_type),
    INDEX idx_operation_status (operation_status),
    INDEX idx_operation_time (operation_time)
) COMMENT '文件操作日志表';

-- 用户行为日志表
CREATE TABLE user_behavior_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    user_id VARCHAR(32) COMMENT '用户ID',
    username VARCHAR(64) COMMENT '用户名',
    session_id VARCHAR(64) COMMENT '会话ID',
    behavior_type VARCHAR(64) NOT NULL COMMENT '行为类型',
    behavior_action VARCHAR(128) NOT NULL COMMENT '行为动作',
    page_url VARCHAR(500) COMMENT '页面URL',
    page_title VARCHAR(255) COMMENT '页面标题',
    referrer_url VARCHAR(500) COMMENT '来源URL',
    user_agent VARCHAR(500) COMMENT '用户代理',
    client_ip VARCHAR(45) COMMENT '客户端IP',
    behavior_data JSON COMMENT '行为数据',
    duration_ms BIGINT COMMENT '持续时间(毫秒)',
    behavior_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '行为时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_user_id (user_id),
    INDEX idx_username (username),
    INDEX idx_session_id (session_id),
    INDEX idx_behavior_type (behavior_type),
    INDEX idx_behavior_action (behavior_action),
    INDEX idx_page_url (page_url),
    INDEX idx_behavior_time (behavior_time),
    INDEX idx_client_ip (client_ip)
) COMMENT '用户行为日志表';

-- API调用日志表
CREATE TABLE api_call_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    user_id VARCHAR(32) COMMENT '用户ID',
    username VARCHAR(64) COMMENT '用户名',
    api_name VARCHAR(128) NOT NULL COMMENT 'API名称',
    api_path VARCHAR(255) NOT NULL COMMENT 'API路径',
    http_method VARCHAR(10) NOT NULL COMMENT 'HTTP方法',
    request_params TEXT COMMENT '请求参数',
    request_headers TEXT COMMENT '请求头',
    response_code INT COMMENT '响应码',
    response_data TEXT COMMENT '响应数据',
    response_time BIGINT COMMENT '响应时间(ms)',
    client_ip VARCHAR(45) COMMENT '客户端IP',
    user_agent VARCHAR(500) COMMENT '用户代理',
    call_status ENUM('SUCCESS', 'FAILED', 'TIMEOUT') DEFAULT 'SUCCESS' COMMENT '调用状态',
    error_message TEXT COMMENT '错误信息',
    call_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '调用时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_user_id (user_id),
    INDEX idx_username (username),
    INDEX idx_api_name (api_name),
    INDEX idx_api_path (api_path),
    INDEX idx_http_method (http_method),
    INDEX idx_response_code (response_code),
    INDEX idx_call_status (call_status),
    INDEX idx_call_time (call_time),
    INDEX idx_client_ip (client_ip)
) COMMENT 'API调用日志表';

-- 数据库操作日志表
CREATE TABLE database_operation_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    user_id VARCHAR(32) COMMENT '用户ID',
    username VARCHAR(64) COMMENT '用户名',
    database_name VARCHAR(64) NOT NULL COMMENT '数据库名',
    table_name VARCHAR(64) NOT NULL COMMENT '表名',
    operation_type ENUM('SELECT', 'INSERT', 'UPDATE', 'DELETE', 'CREATE', 'DROP', 'ALTER') NOT NULL COMMENT '操作类型',
    sql_statement TEXT COMMENT 'SQL语句',
    affected_rows INT COMMENT '影响行数',
    execution_time BIGINT COMMENT '执行时间(ms)',
    operation_status ENUM('SUCCESS', 'FAILED', 'TIMEOUT') DEFAULT 'SUCCESS' COMMENT '操作状态',
    error_message TEXT COMMENT '错误信息',
    operation_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_user_id (user_id),
    INDEX idx_username (username),
    INDEX idx_database_name (database_name),
    INDEX idx_table_name (table_name),
    INDEX idx_operation_type (operation_type),
    INDEX idx_operation_status (operation_status),
    INDEX idx_operation_time (operation_time)
) COMMENT '数据库操作日志表';

-- 缓存操作日志表
CREATE TABLE cache_operation_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    user_id VARCHAR(32) COMMENT '用户ID',
    username VARCHAR(64) COMMENT '用户名',
    cache_type VARCHAR(32) NOT NULL COMMENT '缓存类型',
    cache_key VARCHAR(255) NOT NULL COMMENT '缓存键',
    operation_type ENUM('GET', 'SET', 'DELETE', 'CLEAR', 'EXPIRE') NOT NULL COMMENT '操作类型',
    cache_value TEXT COMMENT '缓存值',
    cache_size BIGINT COMMENT '缓存大小(字节)',
    ttl_seconds INT COMMENT 'TTL秒数',
    operation_status ENUM('SUCCESS', 'FAILED', 'NOT_FOUND') DEFAULT 'SUCCESS' COMMENT '操作状态',
    error_message TEXT COMMENT '错误信息',
    operation_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_user_id (user_id),
    INDEX idx_username (username),
    INDEX idx_cache_type (cache_type),
    INDEX idx_cache_key (cache_key),
    INDEX idx_operation_type (operation_type),
    INDEX idx_operation_status (operation_status),
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
    message_size BIGINT COMMENT '消息大小(字节)',
    operation_type ENUM('SEND', 'RECEIVE', 'PROCESS', 'ACK', 'REJECT') NOT NULL COMMENT '操作类型',
    producer_id VARCHAR(64) COMMENT '生产者ID',
    consumer_id VARCHAR(64) COMMENT '消费者ID',
    processing_time BIGINT COMMENT '处理时间(ms)',
    operation_status ENUM('SUCCESS', 'FAILED', 'TIMEOUT', 'RETRY') DEFAULT 'SUCCESS' COMMENT '操作状态',
    error_message TEXT COMMENT '错误信息',
    retry_count INT DEFAULT 0 COMMENT '重试次数',
    operation_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_queue_name (queue_name),
    INDEX idx_message_id (message_id),
    INDEX idx_message_type (message_type),
    INDEX idx_operation_type (operation_type),
    INDEX idx_producer_id (producer_id),
    INDEX idx_consumer_id (consumer_id),
    INDEX idx_operation_status (operation_status),
    INDEX idx_operation_time (operation_time)
) COMMENT '消息队列日志表';