-- ==============================================
-- BTC核心数据库 - 工作流表
-- ==============================================

USE btc_core;

CREATE TABLE workflow_definition (
    workflow_id VARCHAR(32) PRIMARY KEY COMMENT '流程ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    workflow_code VARCHAR(64) NOT NULL COMMENT '流程代码',
    workflow_name VARCHAR(128) NOT NULL COMMENT '流程名称',
    workflow_type ENUM('PRODUCTION', 'QUALITY', 'LOGISTICS', 'MAINTENANCE', 'CUSTOM') DEFAULT 'PRODUCTION' COMMENT '流程类型',
    description TEXT COMMENT '流程描述',
    version INT DEFAULT 1 COMMENT '版本号',
    status ENUM('ACTIVE', 'INACTIVE', 'DRAFT') DEFAULT 'DRAFT' COMMENT '状态',
    is_template BOOLEAN DEFAULT FALSE COMMENT '是否模板',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tenant (tenant_id),
    INDEX idx_workflow_code (workflow_code),
    INDEX idx_workflow_type (workflow_type),
    INDEX idx_status (status),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id)
) COMMENT '流程定义表';

-- 流程节点表
CREATE TABLE workflow_node (
    node_id VARCHAR(32) PRIMARY KEY COMMENT '节点ID',
    workflow_id VARCHAR(32) NOT NULL COMMENT '流程ID',
    node_code VARCHAR(64) NOT NULL COMMENT '节点代码',
    node_name VARCHAR(128) NOT NULL COMMENT '节点名称',
    node_type ENUM('START', 'END', 'TASK', 'GATEWAY', 'SUB_PROCESS') DEFAULT 'TASK' COMMENT '节点类型',
    sequence_order INT NOT NULL COMMENT '执行顺序',
    parent_node_id VARCHAR(32) COMMENT '父节点ID',
    is_parallel BOOLEAN DEFAULT FALSE COMMENT '是否并行执行',
    timeout_minutes INT COMMENT '超时时间(分钟)',
    retry_count INT DEFAULT 0 COMMENT '重试次数',
    node_config JSON COMMENT '节点配置',
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_workflow_id (workflow_id),
    INDEX idx_node_code (node_code),
    INDEX idx_sequence_order (sequence_order),
    INDEX idx_parent_node (parent_node_id),
    FOREIGN KEY (workflow_id) REFERENCES workflow_definition(workflow_id),
    FOREIGN KEY (parent_node_id) REFERENCES workflow_node(node_id)
) COMMENT '流程节点表';

-- 流程连接表
CREATE TABLE workflow_connection (
    connection_id VARCHAR(32) PRIMARY KEY COMMENT '连接ID',
    workflow_id VARCHAR(32) NOT NULL COMMENT '流程ID',
    from_node_id VARCHAR(32) NOT NULL COMMENT '源节点ID',
    to_node_id VARCHAR(32) NOT NULL COMMENT '目标节点ID',
    connection_type ENUM('NORMAL', 'CONDITIONAL', 'EXCEPTION') DEFAULT 'NORMAL' COMMENT '连接类型',
    condition_expression TEXT COMMENT '条件表达式',
    connection_label VARCHAR(128) COMMENT '连接标签',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_workflow_id (workflow_id),
    INDEX idx_from_node (from_node_id),
    INDEX idx_to_node (to_node_id),
    FOREIGN KEY (workflow_id) REFERENCES workflow_definition(workflow_id),
    FOREIGN KEY (from_node_id) REFERENCES workflow_node(node_id),
    FOREIGN KEY (to_node_id) REFERENCES workflow_node(node_id)
) COMMENT '流程连接表';

-- 流程实例表
CREATE TABLE workflow_instance (
    instance_id VARCHAR(32) PRIMARY KEY COMMENT '实例ID',
    workflow_id VARCHAR(32) NOT NULL COMMENT '流程ID',
    instance_name VARCHAR(128) COMMENT '实例名称',
    business_key VARCHAR(128) COMMENT '业务键',
    business_type VARCHAR(64) COMMENT '业务类型',
    current_node_id VARCHAR(32) COMMENT '当前节点ID',
    instance_status ENUM('RUNNING', 'COMPLETED', 'SUSPENDED', 'TERMINATED', 'FAILED') DEFAULT 'RUNNING' COMMENT '实例状态',
    start_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '开始时间',
    end_time DATETIME COMMENT '结束时间',
    started_by VARCHAR(64) NOT NULL COMMENT '启动人',
    variables JSON COMMENT '流程变量',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_workflow_id (workflow_id),
    INDEX idx_business_key (business_key),
    INDEX idx_business_type (business_type),
    INDEX idx_current_node (current_node_id),
    INDEX idx_instance_status (instance_status),
    INDEX idx_start_time (start_time),
    INDEX idx_tenant_site (tenant_id, site_id),
    FOREIGN KEY (workflow_id) REFERENCES workflow_definition(workflow_id),
    FOREIGN KEY (current_node_id) REFERENCES workflow_node(node_id)
) COMMENT '流程实例表';

-- 流程任务表
CREATE TABLE workflow_task (
    task_id VARCHAR(32) PRIMARY KEY COMMENT '任务ID',
    instance_id VARCHAR(32) NOT NULL COMMENT '实例ID',
    node_id VARCHAR(32) NOT NULL COMMENT '节点ID',
    task_name VARCHAR(128) NOT NULL COMMENT '任务名称',
    task_type ENUM('MANUAL', 'AUTOMATIC', 'SERVICE') DEFAULT 'MANUAL' COMMENT '任务类型',
    assignee_type ENUM('USER', 'ROLE', 'GROUP') DEFAULT 'USER' COMMENT '分配类型',
    assignee_id VARCHAR(64) COMMENT '分配人ID',
    task_status ENUM('PENDING', 'IN_PROGRESS', 'COMPLETED', 'SKIPPED', 'FAILED') DEFAULT 'PENDING' COMMENT '任务状态',
    priority ENUM('LOW', 'NORMAL', 'HIGH', 'URGENT') DEFAULT 'NORMAL' COMMENT '优先级',
    due_date DATETIME COMMENT '截止时间',
    start_time DATETIME COMMENT '开始时间',
    end_time DATETIME COMMENT '结束时间',
    completion_notes TEXT COMMENT '完成备注',
    form_data JSON COMMENT '表单数据',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_instance_id (instance_id),
    INDEX idx_node_id (node_id),
    INDEX idx_assignee (assignee_type, assignee_id),
    INDEX idx_task_status (task_status),
    INDEX idx_due_date (due_date),
    INDEX idx_tenant_site (tenant_id, site_id),
    FOREIGN KEY (instance_id) REFERENCES workflow_instance(instance_id),
    FOREIGN KEY (node_id) REFERENCES workflow_node(node_id)
) COMMENT '流程任务表';

-- 流程历史表
CREATE TABLE workflow_history (
    history_id VARCHAR(32) PRIMARY KEY COMMENT '历史ID',
    instance_id VARCHAR(32) NOT NULL COMMENT '实例ID',
    node_id VARCHAR(32) NOT NULL COMMENT '节点ID',
    task_id VARCHAR(32) COMMENT '任务ID',
    action_type ENUM('START', 'COMPLETE', 'SKIP', 'FAIL', 'SUSPEND', 'RESUME', 'TERMINATE') NOT NULL COMMENT '动作类型',
    action_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '动作时间',
    operator_id VARCHAR(64) COMMENT '操作人ID',
    operator_name VARCHAR(64) COMMENT '操作人姓名',
    action_notes TEXT COMMENT '动作备注',
    form_data JSON COMMENT '表单数据快照',
    variables JSON COMMENT '变量快照',
    execution_time BIGINT COMMENT '执行时间(毫秒)',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_instance_id (instance_id),
    INDEX idx_node_id (node_id),
    INDEX idx_task_id (task_id),
    INDEX idx_action_type (action_type),
    INDEX idx_action_time (action_time),
    INDEX idx_operator (operator_id),
    INDEX idx_tenant_site (tenant_id, site_id),
    FOREIGN KEY (instance_id) REFERENCES workflow_instance(instance_id),
    FOREIGN KEY (node_id) REFERENCES workflow_node(node_id),
    FOREIGN KEY (task_id) REFERENCES workflow_task(task_id)
) COMMENT '流程历史表';
