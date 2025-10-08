-- ==============================================
-- BTC日志数据�?- 操作和业务日志表
-- ==============================================

USE btc_log;

-- 系统操作日志�?
CREATE TABLE sys_operation_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    user_id VARCHAR(32) COMMENT '用户ID',
    username VARCHAR(64) COMMENT '用户�?,
    operation_type VARCHAR(32) NOT NULL COMMENT '操作类型',
    operation_name VARCHAR(128) COMMENT '操作名称',
    operation_method VARCHAR(255) COMMENT '操作方法',
    request_method VARCHAR(10) COMMENT '请求方法',
    request_url VARCHAR(500) COMMENT '请求URL',
    request_ip VARCHAR(45) COMMENT '请求IP',
    request_params TEXT COMMENT '请求参数',
    response_result TEXT COMMENT '响应结果',
    response_time BIGINT COMMENT '响应时间(ms)',
    operation_status ENUM('SUCCESS', 'FAILED', 'ERROR') DEFAULT 'SUCCESS' COMMENT '操作状�?,
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
) COMMENT '系统操作日志�?;

-- 系统登录日志�?
CREATE TABLE sys_login_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    user_id VARCHAR(32) COMMENT '用户ID',
    username VARCHAR(64) COMMENT '用户�?,
    login_type ENUM('LOGIN', 'LOGOUT', 'REFRESH') DEFAULT 'LOGIN' COMMENT '登录类型',
    login_ip VARCHAR(45) COMMENT '登录IP',
    login_location VARCHAR(255) COMMENT '登录地点',
    browser VARCHAR(64) COMMENT '浏览�?,
    os VARCHAR(64) COMMENT '操作系统',
    user_agent VARCHAR(500) COMMENT '用户代理',
    login_status ENUM('SUCCESS', 'FAILED') DEFAULT 'SUCCESS' COMMENT '登录状�?,
    login_message VARCHAR(255) COMMENT '登录消息',
    session_id VARCHAR(128) COMMENT '会话ID',
    login_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登录时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_user_id (user_id),
    INDEX idx_username (username),
    INDEX idx_login_type (login_type),
    INDEX idx_login_status (login_status),
    INDEX idx_login_time (login_time),
    INDEX idx_login_ip (login_ip),
    INDEX idx_session_id (session_id)
) COMMENT '系统登录日志�?;

-- 数据变更历史�?
CREATE TABLE data_change_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '历史ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    table_name VARCHAR(64) NOT NULL COMMENT '表名',
    record_id VARCHAR(64) NOT NULL COMMENT '记录ID',
    operation_type ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL COMMENT '操作类型',
    field_name VARCHAR(64) COMMENT '字段�?,
    old_value TEXT COMMENT '旧�?,
    new_value TEXT COMMENT '新�?,
    change_reason VARCHAR(255) COMMENT '变更原因',
    operator_id VARCHAR(32) COMMENT '操作人ID',
    operator_name VARCHAR(64) COMMENT '操作人姓�?,
    operation_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    ip_address VARCHAR(45) COMMENT 'IP地址',
    user_agent VARCHAR(500) COMMENT '用户代理',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_table_name (table_name),
    INDEX idx_record_id (record_id),
    INDEX idx_operation_type (operation_type),
    INDEX idx_field_name (field_name),
    INDEX idx_operator_id (operator_id),
    INDEX idx_operation_time (operation_time),
    INDEX idx_ip_address (ip_address)
) COMMENT '数据变更历史�?;

-- 登录尝试日志�?
CREATE TABLE login_attempt_log (
    attempt_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '尝试ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    username VARCHAR(64) COMMENT '用户�?,
    login_ip VARCHAR(45) COMMENT '登录IP',
    user_agent VARCHAR(500) COMMENT '用户代理',
    attempt_status ENUM('SUCCESS', 'FAILED', 'BLOCKED') DEFAULT 'FAILED' COMMENT '尝试状�?,
    fail_reason VARCHAR(255) COMMENT '失败原因',
    attempt_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '尝试时间',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant (tenant_id),
    INDEX idx_username (username),
    INDEX idx_login_ip (login_ip),
    INDEX idx_attempt_status (attempt_status),
    INDEX idx_attempt_time (attempt_time)
) COMMENT '登录尝试日志�?;

-- 业务操作日志�?
CREATE TABLE business_operation_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    business_module VARCHAR(64) NOT NULL COMMENT '业务模块',
    business_type VARCHAR(64) NOT NULL COMMENT '业务类型',
    business_id VARCHAR(64) NOT NULL COMMENT '业务ID',
    business_no VARCHAR(128) COMMENT '业务单号',
    operation_type VARCHAR(32) NOT NULL COMMENT '操作类型',
    operation_name VARCHAR(128) COMMENT '操作名称',
    operation_desc TEXT COMMENT '操作描述',
    operator_id VARCHAR(32) COMMENT '操作人ID',
    operator_name VARCHAR(64) COMMENT '操作人姓�?,
    operation_data JSON COMMENT '操作数据',
    operation_result ENUM('SUCCESS', 'FAILED', 'WARNING') DEFAULT 'SUCCESS' COMMENT '操作结果',
    error_message TEXT COMMENT '错误信息',
    operation_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    ip_address VARCHAR(45) COMMENT 'IP地址',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_business_module (business_module),
    INDEX idx_business_type (business_type),
    INDEX idx_business_id (business_id),
    INDEX idx_business_no (business_no),
    INDEX idx_operation_type (operation_type),
    INDEX idx_operator_id (operator_id),
    INDEX idx_operation_result (operation_result),
    INDEX idx_operation_time (operation_time)
) COMMENT '业务操作日志�?;

-- 文件操作日志�?
CREATE TABLE file_operation_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    file_id VARCHAR(64) COMMENT '文件ID',
    file_name VARCHAR(255) NOT NULL COMMENT '文件�?,
    file_path VARCHAR(500) COMMENT '文件路径',
    file_size BIGINT COMMENT '文件大小',
    file_type VARCHAR(64) COMMENT '文件类型',
    operation_type ENUM('UPLOAD', 'DOWNLOAD', 'DELETE', 'MODIFY', 'VIEW') NOT NULL COMMENT '操作类型',
    operator_id VARCHAR(32) COMMENT '操作人ID',
    operator_name VARCHAR(64) COMMENT '操作人姓�?,
    operation_result ENUM('SUCCESS', 'FAILED') DEFAULT 'SUCCESS' COMMENT '操作结果',
    error_message TEXT COMMENT '错误信息',
    operation_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    ip_address VARCHAR(45) COMMENT 'IP地址',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_file_id (file_id),
    INDEX idx_file_name (file_name),
    INDEX idx_operation_type (operation_type),
    INDEX idx_operator_id (operator_id),
    INDEX idx_operation_result (operation_result),
    INDEX idx_operation_time (operation_time)
) COMMENT '文件操作日志�?;

-- 数据导出日志�?
CREATE TABLE data_export_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    export_no VARCHAR(64) NOT NULL UNIQUE COMMENT '导出单号',
    export_name VARCHAR(128) NOT NULL COMMENT '导出名称',
    export_type VARCHAR(64) NOT NULL COMMENT '导出类型',
    export_format ENUM('EXCEL', 'CSV', 'PDF', 'JSON', 'XML') DEFAULT 'EXCEL' COMMENT '导出格式',
    table_name VARCHAR(64) COMMENT '数据表名',
    query_conditions JSON COMMENT '查询条件',
    export_status ENUM('PENDING', 'PROCESSING', 'SUCCESS', 'FAILED', 'CANCELLED') DEFAULT 'PENDING' COMMENT '导出状�?,
    total_records INT DEFAULT 0 COMMENT '总记录数',
    exported_records INT DEFAULT 0 COMMENT '已导出记录数',
    file_path VARCHAR(500) COMMENT '文件路径',
    file_size BIGINT COMMENT '文件大小',
    download_count INT DEFAULT 0 COMMENT '下载次数',
    operator_id VARCHAR(32) COMMENT '操作人ID',
    operator_name VARCHAR(64) COMMENT '操作人姓�?,
    start_time DATETIME COMMENT '开始时�?,
    end_time DATETIME COMMENT '结束时间',
    duration_seconds INT COMMENT '耗时(�?',
    error_message TEXT COMMENT '错误信息',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_export_no (export_no),
    INDEX idx_export_type (export_type),
    INDEX idx_export_status (export_status),
    INDEX idx_table_name (table_name),
    INDEX idx_operator_id (operator_id),
    INDEX idx_start_time (start_time)
) COMMENT '数据导出日志�?;

-- 数据导入日志�?
CREATE TABLE data_import_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '日志ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    import_no VARCHAR(64) NOT NULL UNIQUE COMMENT '导入单号',
    import_name VARCHAR(128) NOT NULL COMMENT '导入名称',
    import_type VARCHAR(64) NOT NULL COMMENT '导入类型',
    import_format ENUM('EXCEL', 'CSV', 'JSON', 'XML') DEFAULT 'EXCEL' COMMENT '导入格式',
    target_table VARCHAR(64) COMMENT '目标表名',
    file_name VARCHAR(255) NOT NULL COMMENT '文件�?,
    file_path VARCHAR(500) COMMENT '文件路径',
    file_size BIGINT COMMENT '文件大小',
    import_status ENUM('PENDING', 'PROCESSING', 'SUCCESS', 'FAILED', 'CANCELLED') DEFAULT 'PENDING' COMMENT '导入状�?,
    total_records INT DEFAULT 0 COMMENT '总记录数',
    success_records INT DEFAULT 0 COMMENT '成功记录�?,
    failed_records INT DEFAULT 0 COMMENT '失败记录�?,
    skipped_records INT DEFAULT 0 COMMENT '跳过记录�?,
    validation_errors JSON COMMENT '验证错误',
    operator_id VARCHAR(32) COMMENT '操作人ID',
    operator_name VARCHAR(64) COMMENT '操作人姓�?,
    start_time DATETIME COMMENT '开始时�?,
    end_time DATETIME COMMENT '结束时间',
    duration_seconds INT COMMENT '耗时(�?',
    error_message TEXT COMMENT '错误信息',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_import_no (import_no),
    INDEX idx_import_type (import_type),
    INDEX idx_import_status (import_status),
    INDEX idx_target_table (target_table),
    INDEX idx_operator_id (operator_id),
    INDEX idx_start_time (start_time)
) COMMENT '数据导入日志�?;

