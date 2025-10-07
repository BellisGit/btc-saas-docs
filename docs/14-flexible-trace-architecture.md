# MES系统灵活追踪架构设计

## 概述

本文档设计了一个高度灵活、可插拔的追踪系统架构，采用事件驱动的设计理念，支持像乐高积木一样随时添加新的业务逻辑，同时保持向后兼容性。该系统支持自动化CRUD框架，可通过前端UI引导进行必要结构的录入。

## 核心设计理念

### 1. 乐高积木式架构

```
基础追踪平台 (Base Platform)
    ├── 通用事件引擎 (Universal Event Engine)
    ├── 动态实体管理 (Dynamic Entity Management)  
    ├── 可插拔业务模块 (Pluggable Business Modules)
    └── 自动化CRUD框架 (Auto CRUD Framework)
```

### 2. 分层架构设计

| 层级 | 功能 | 特点 |
|------|------|------|
| **业务层** | 具体业务逻辑 | 可插拔、可配置 |
| **规则层** | 业务规则引擎 | 动态配置、热更新 |
| **事件层** | 事件驱动核心 | 标准化、可扩展 |
| **数据层** | 实体存储 | 灵活schema、版本化 |

## 核心架构设计

### 1. 通用事件引擎

#### 事件定义表
```sql
-- 事件类型定义表（元数据驱动）
CREATE TABLE trace_event_type (
    event_type_id VARCHAR(32) PRIMARY KEY COMMENT '事件类型ID',
    event_type_code VARCHAR(64) NOT NULL UNIQUE COMMENT '事件类型代码',
    event_type_name VARCHAR(128) NOT NULL COMMENT '事件类型名称',
    category VARCHAR(32) NOT NULL COMMENT '事件分类 ENGINEERING/MATERIAL/QUALITY/PRODUCTION',
    description TEXT COMMENT '事件描述',
    schema_definition JSON NOT NULL COMMENT '事件Schema定义',
    business_rules JSON COMMENT '业务规则配置',
    is_active TINYINT(1) DEFAULT 1 COMMENT '是否启用',
    version INT DEFAULT 1 COMMENT '版本号',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_category (category),
    INDEX idx_tenant (tenant_id),
    INDEX idx_active (is_active)
) COMMENT '事件类型定义表';

-- 示例数据：工程问题追踪事件类型
INSERT INTO trace_event_type VALUES (
    'ET_ENG_PROBLEM_001',
    'ENGINEERING_PROBLEM_REPORT',
    '工程问题报告',
    'ENGINEERING',
    '工程问题发现和报告事件',
    '{
        "properties": {
            "problem_id": {"type": "string", "required": true},
            "problem_description": {"type": "string", "required": true},
            "severity": {"type": "enum", "enum": ["LOW", "MEDIUM", "HIGH", "CRITICAL"], "required": true},
            "affected_components": {"type": "array", "items": {"type": "string"}},
            "reporter": {"type": "string", "required": true},
            "discovery_time": {"type": "datetime", "required": true},
            "attachments": {"type": "array", "items": {"type": "string"}}
        },
        "required": ["problem_id", "problem_description", "severity", "reporter", "discovery_time"]
    }',
    '{
        "validation_rules": [
            {"field": "severity", "rule": "required"},
            {"field": "problem_description", "rule": "min_length:10"}
        ],
        "business_rules": [
            {"condition": "severity == CRITICAL", "action": "auto_escalate"},
            {"condition": "affected_components.length > 3", "action": "require_approval"}
        ]
    }',
    1, 1, 'TENANT_001', 'SYSTEM', NOW(), NULL, NULL
);

-- 示例数据：物料问题追踪事件类型
INSERT INTO trace_event_type VALUES (
    'ET_MAT_PROBLEM_001',
    'MATERIAL_QUALITY_ISSUE',
    '物料质量问题',
    'MATERIAL',
    '物料质量问题和追溯事件',
    '{
        "properties": {
            "material_id": {"type": "string", "required": true},
            "batch_id": {"type": "string", "required": true},
            "supplier_id": {"type": "string", "required": true},
            "issue_type": {"type": "enum", "enum": ["DEFECT", "DELAY", "SPECIFICATION"], "required": true},
            "issue_description": {"type": "string", "required": true},
            "impact_level": {"type": "enum", "enum": ["MINOR", "MODERATE", "MAJOR", "CRITICAL"]},
            "discovered_by": {"type": "string", "required": true},
            "discovery_time": {"type": "datetime", "required": true},
            "affected_products": {"type": "array", "items": {"type": "string"}}
        },
        "required": ["material_id", "batch_id", "supplier_id", "issue_type", "issue_description", "discovered_by", "discovery_time"]
    }',
    '{
        "validation_rules": [
            {"field": "impact_level", "rule": "required"},
            {"field": "issue_description", "rule": "min_length:20"}
        ],
        "business_rules": [
            {"condition": "impact_level == CRITICAL", "action": "notify_supplier"},
            {"condition": "issue_type == DEFECT", "action": "quarantine_batch"}
        ]
    }',
    1, 1, 'TENANT_001', 'SYSTEM', NOW(), NULL, NULL
);
```

#### 通用事件记录表
```sql
-- 通用事件记录表（支持任意业务事件）
CREATE TABLE universal_trace_event (
    event_id VARCHAR(40) PRIMARY KEY COMMENT '事件ID',
    event_type_id VARCHAR(32) NOT NULL COMMENT '事件类型ID',
    entity_type VARCHAR(32) NOT NULL COMMENT '实体类型',
    entity_id VARCHAR(64) NOT NULL COMMENT '实体ID',
    correlation_id VARCHAR(64) COMMENT '关联ID（用于关联相关事件）',
    parent_event_id VARCHAR(40) COMMENT '父事件ID',
    event_data JSON NOT NULL COMMENT '事件数据（动态Schema）',
    event_status ENUM('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'CANCELLED') DEFAULT 'PENDING' COMMENT '事件状态',
    priority ENUM('LOW', 'NORMAL', 'HIGH', 'URGENT') DEFAULT 'NORMAL' COMMENT '优先级',
    occurred_at DATETIME NOT NULL COMMENT '发生时间',
    processed_at DATETIME COMMENT '处理时间',
    processed_by VARCHAR(64) COMMENT '处理人',
    result_data JSON COMMENT '处理结果数据',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (event_type_id) REFERENCES trace_event_type(event_type_id),
    INDEX idx_event_type (event_type_id),
    INDEX idx_entity (entity_type, entity_id),
    INDEX idx_correlation (correlation_id),
    INDEX idx_parent_event (parent_event_id),
    INDEX idx_occurred_at (occurred_at),
    INDEX idx_status (event_status),
    INDEX idx_priority (priority),
    INDEX idx_tenant_site (tenant_id, site_id)
) COMMENT '通用事件记录表';
```

### 2. 动态实体管理

#### 实体类型定义表
```sql
-- 动态实体类型定义表
CREATE TABLE dynamic_entity_type (
    entity_type_id VARCHAR(32) PRIMARY KEY COMMENT '实体类型ID',
    entity_type_code VARCHAR(64) NOT NULL UNIQUE COMMENT '实体类型代码',
    entity_type_name VARCHAR(128) NOT NULL COMMENT '实体类型名称',
    category VARCHAR(32) NOT NULL COMMENT '实体分类',
    description TEXT COMMENT '实体描述',
    schema_definition JSON NOT NULL COMMENT '实体Schema定义',
    business_rules JSON COMMENT '业务规则配置',
    lifecycle_states JSON COMMENT '生命周期状态定义',
    is_active TINYINT(1) DEFAULT 1 COMMENT '是否启用',
    version INT DEFAULT 1 COMMENT '版本号',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_category (category),
    INDEX idx_tenant (tenant_id),
    INDEX idx_active (is_active)
) COMMENT '动态实体类型定义表';

-- 示例数据：工程问题实体类型
INSERT INTO dynamic_entity_type VALUES (
    'ENTITY_ENG_PROBLEM_001',
    'ENGINEERING_PROBLEM',
    '工程问题',
    'ENGINEERING',
    '工程问题实体类型',
    '{
        "properties": {
            "problem_id": {"type": "string", "required": true, "unique": true},
            "title": {"type": "string", "required": true},
            "description": {"type": "text", "required": true},
            "category": {"type": "enum", "enum": ["DESIGN", "MANUFACTURING", "TESTING", "INSTALLATION"]},
            "severity": {"type": "enum", "enum": ["LOW", "MEDIUM", "HIGH", "CRITICAL"], "required": true},
            "priority": {"type": "enum", "enum": ["LOW", "NORMAL", "HIGH", "URGENT"]},
            "status": {"type": "enum", "enum": ["OPEN", "INVESTIGATING", "RESOLVED", "CLOSED"]},
            "assigned_to": {"type": "string"},
            "due_date": {"type": "date"},
            "affected_products": {"type": "array", "items": {"type": "string"}},
            "affected_components": {"type": "array", "items": {"type": "string"}},
            "root_cause": {"type": "text"},
            "solution": {"type": "text"},
            "prevention_measures": {"type": "text"}
        },
        "required": ["problem_id", "title", "description", "severity", "status"],
        "indexes": [
            {"fields": ["problem_id"], "unique": true},
            {"fields": ["category", "severity"]},
            {"fields": ["status", "assigned_to"]},
            {"fields": ["created_at"]}
        ]
    }',
    '{
        "validation_rules": [
            {"field": "title", "rule": "min_length:5"},
            {"field": "description", "rule": "min_length:20"},
            {"field": "due_date", "rule": "future_date"}
        ],
        "business_rules": [
            {"condition": "severity == CRITICAL", "action": "auto_escalate"},
            {"condition": "status == RESOLVED", "action": "require_solution"}
        ]
    }',
    '{
        "states": ["OPEN", "INVESTIGATING", "RESOLVED", "CLOSED"],
        "transitions": [
            {"from": "OPEN", "to": "INVESTIGATING", "condition": "assigned_to != null"},
            {"from": "INVESTIGATING", "to": "RESOLVED", "condition": "solution != null"},
            {"from": "RESOLVED", "to": "CLOSED", "condition": "verification_complete == true"}
        ]
    }',
    1, 1, 'TENANT_001', 'SYSTEM', NOW(), NULL, NULL
);
```

#### 动态实体实例表
```sql
-- 动态实体实例表（存储具体实体数据）
CREATE TABLE dynamic_entity_instance (
    instance_id VARCHAR(40) PRIMARY KEY COMMENT '实例ID',
    entity_type_id VARCHAR(32) NOT NULL COMMENT '实体类型ID',
    entity_code VARCHAR(64) NOT NULL COMMENT '实体编码',
    entity_data JSON NOT NULL COMMENT '实体数据（动态Schema）',
    current_state VARCHAR(32) COMMENT '当前状态',
    state_history JSON COMMENT '状态变更历史',
    tags JSON COMMENT '标签',
    is_active TINYINT(1) DEFAULT 1 COMMENT '是否启用',
    version INT DEFAULT 1 COMMENT '版本号',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (entity_type_id) REFERENCES dynamic_entity_type(entity_type_id),
    UNIQUE KEY uk_entity_code (entity_type_id, entity_code),
    INDEX idx_entity_type (entity_type_id),
    INDEX idx_current_state (current_state),
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_created_at (created_at)
) COMMENT '动态实体实例表';
```

### 3. 可插拔业务模块

#### 业务模块注册表
```sql
-- 业务模块注册表
CREATE TABLE business_module_registry (
    module_id VARCHAR(32) PRIMARY KEY COMMENT '模块ID',
    module_code VARCHAR(64) NOT NULL UNIQUE COMMENT '模块代码',
    module_name VARCHAR(128) NOT NULL COMMENT '模块名称',
    module_type ENUM('TRACE', 'WORKFLOW', 'ANALYTICS', 'INTEGRATION') NOT NULL COMMENT '模块类型',
    description TEXT COMMENT '模块描述',
    configuration JSON COMMENT '模块配置',
    dependencies JSON COMMENT '依赖关系',
    api_endpoints JSON COMMENT 'API端点定义',
    ui_components JSON COMMENT 'UI组件配置',
    is_active TINYINT(1) DEFAULT 1 COMMENT '是否启用',
    version VARCHAR(16) NOT NULL COMMENT '模块版本',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    installed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_module_type (module_type),
    INDEX idx_tenant (tenant_id),
    INDEX idx_active (is_active)
) COMMENT '业务模块注册表';

-- 示例数据：工程问题追踪模块
INSERT INTO business_module_registry VALUES (
    'MOD_ENG_TRACE_001',
    'ENGINEERING_PROBLEM_TRACE',
    '工程问题追踪模块',
    'TRACE',
    '专门用于工程问题追踪和管理的模块',
    '{
        "entity_types": ["ENGINEERING_PROBLEM"],
        "event_types": ["ENGINEERING_PROBLEM_REPORT", "PROBLEM_INVESTIGATION", "PROBLEM_RESOLUTION"],
        "workflows": ["PROBLEM_LIFECYCLE"],
        "permissions": ["ENG_PROBLEM_CREATE", "ENG_PROBLEM_UPDATE", "ENG_PROBLEM_RESOLVE"],
        "notifications": ["PROBLEM_ESCALATION", "DUE_DATE_REMINDER"]
    }',
    '{
        "required_modules": ["BASE_TRACE_MODULE"],
        "optional_modules": ["NOTIFICATION_MODULE", "WORKFLOW_MODULE"]
    }',
    '{
        "endpoints": [
            {"path": "/api/engineering/problems", "method": "GET", "description": "获取工程问题列表"},
            {"path": "/api/engineering/problems", "method": "POST", "description": "创建工程问题"},
            {"path": "/api/engineering/problems/{id}", "method": "PUT", "description": "更新工程问题"},
            {"path": "/api/engineering/problems/{id}/resolve", "method": "POST", "description": "解决问题"}
        ]
    }',
    '{
        "components": [
            {"name": "ProblemList", "type": "table", "config": {"columns": ["problem_id", "title", "severity", "status"]}},
            {"name": "ProblemForm", "type": "form", "config": {"fields": ["title", "description", "severity", "category"]}},
            {"name": "ProblemTimeline", "type": "timeline", "config": {"show_events": true}}
        ]
    }',
    1, '1.0.0', 'TENANT_001', NOW(), NULL
);
```

### 4. 自动化CRUD框架

#### 表单配置表
```sql
-- 动态表单配置表
CREATE TABLE dynamic_form_config (
    form_id VARCHAR(32) PRIMARY KEY COMMENT '表单ID',
    form_code VARCHAR(64) NOT NULL UNIQUE COMMENT '表单代码',
    form_name VARCHAR(128) NOT NULL COMMENT '表单名称',
    entity_type_id VARCHAR(32) NOT NULL COMMENT '关联实体类型ID',
    form_type ENUM('CREATE', 'EDIT', 'VIEW', 'SEARCH') NOT NULL COMMENT '表单类型',
    form_config JSON NOT NULL COMMENT '表单配置',
    validation_rules JSON COMMENT '验证规则',
    business_rules JSON COMMENT '业务规则',
    permissions JSON COMMENT '权限配置',
    is_active TINYINT(1) DEFAULT 1 COMMENT '是否启用',
    version INT DEFAULT 1 COMMENT '版本号',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (entity_type_id) REFERENCES dynamic_entity_type(entity_type_id),
    INDEX idx_entity_type (entity_type_id),
    INDEX idx_form_type (form_type),
    INDEX idx_tenant (tenant_id)
) COMMENT '动态表单配置表';

-- 示例数据：工程问题创建表单
INSERT INTO dynamic_form_config VALUES (
    'FORM_ENG_PROBLEM_CREATE',
    'ENGINEERING_PROBLEM_CREATE_FORM',
    '工程问题创建表单',
    'ENTITY_ENG_PROBLEM_001',
    'CREATE',
    '{
        "layout": {
            "type": "tabs",
            "tabs": [
                {
                    "title": "基本信息",
                    "fields": [
                        {
                            "name": "problem_id",
                            "type": "text",
                            "label": "问题编号",
                            "required": true,
                            "auto_generate": true,
                            "pattern": "PROB-{YYYYMMDD}-{SEQ}"
                        },
                        {
                            "name": "title",
                            "type": "text",
                            "label": "问题标题",
                            "required": true,
                            "max_length": 200
                        },
                        {
                            "name": "description",
                            "type": "textarea",
                            "label": "问题描述",
                            "required": true,
                            "rows": 4
                        },
                        {
                            "name": "category",
                            "type": "select",
                            "label": "问题类别",
                            "options": [
                                {"value": "DESIGN", "label": "设计问题"},
                                {"value": "MANUFACTURING", "label": "制造问题"},
                                {"value": "TESTING", "label": "测试问题"},
                                {"value": "INSTALLATION", "label": "安装问题"}
                            ]
                        },
                        {
                            "name": "severity",
                            "type": "radio",
                            "label": "严重程度",
                            "required": true,
                            "options": [
                                {"value": "LOW", "label": "低", "color": "green"},
                                {"value": "MEDIUM", "label": "中", "color": "yellow"},
                                {"value": "HIGH", "label": "高", "color": "orange"},
                                {"value": "CRITICAL", "label": "严重", "color": "red"}
                            ]
                        }
                    ]
                },
                {
                    "title": "影响范围",
                    "fields": [
                        {
                            "name": "affected_products",
                            "type": "multi_select",
                            "label": "影响产品",
                            "data_source": "api:/api/products/list"
                        },
                        {
                            "name": "affected_components",
                            "type": "multi_select",
                            "label": "影响组件",
                            "data_source": "api:/api/components/list"
                        }
                    ]
                },
                {
                    "title": "分配信息",
                    "fields": [
                        {
                            "name": "assigned_to",
                            "type": "user_select",
                            "label": "分配给",
                            "data_source": "api:/api/users/list"
                        },
                        {
                            "name": "due_date",
                            "type": "date",
                            "label": "截止日期"
                        }
                    ]
                }
            ]
        },
        "actions": [
            {"type": "submit", "label": "创建问题", "color": "primary"},
            {"type": "cancel", "label": "取消", "color": "default"}
        ]
    }',
    '[
        {"field": "title", "rule": "required", "message": "问题标题不能为空"},
        {"field": "description", "rule": "min_length:20", "message": "问题描述至少20个字符"},
        {"field": "severity", "rule": "required", "message": "请选择严重程度"}
    ]',
    '[
        {"condition": "severity == CRITICAL", "action": "set_priority", "value": "URGENT"},
        {"condition": "severity == HIGH", "action": "set_due_date", "value": "+3d"},
        {"condition": "severity == MEDIUM", "action": "set_due_date", "value": "+7d"},
        {"condition": "severity == LOW", "action": "set_due_date", "value": "+14d"}
    ]',
    '{
        "create": ["ENG_PROBLEM_CREATE"],
        "edit": ["ENG_PROBLEM_UPDATE"],
        "view": ["ENG_PROBLEM_VIEW"]
    }',
    1, 1, 'TENANT_001', 'SYSTEM', NOW(), NULL, NULL
);
```

### 5. 业务规则引擎

#### 规则定义表
```sql
-- 业务规则定义表
CREATE TABLE business_rule_definition (
    rule_id VARCHAR(32) PRIMARY KEY COMMENT '规则ID',
    rule_code VARCHAR(64) NOT NULL UNIQUE COMMENT '规则代码',
    rule_name VARCHAR(128) NOT NULL COMMENT '规则名称',
    rule_type ENUM('VALIDATION', 'BUSINESS', 'NOTIFICATION', 'WORKFLOW') NOT NULL COMMENT '规则类型',
    entity_type_id VARCHAR(32) COMMENT '关联实体类型ID',
    event_type_id VARCHAR(32) COMMENT '关联事件类型ID',
    rule_condition JSON NOT NULL COMMENT '规则条件',
    rule_action JSON NOT NULL COMMENT '规则动作',
    priority INT DEFAULT 0 COMMENT '优先级',
    is_active TINYINT(1) DEFAULT 1 COMMENT '是否启用',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (entity_type_id) REFERENCES dynamic_entity_type(entity_type_id),
    FOREIGN KEY (event_type_id) REFERENCES trace_event_type(event_type_id),
    INDEX idx_rule_type (rule_type),
    INDEX idx_entity_type (entity_type_id),
    INDEX idx_event_type (event_type_id),
    INDEX idx_priority (priority),
    INDEX idx_tenant (tenant_id)
) COMMENT '业务规则定义表';

-- 示例数据：工程问题自动升级规则
INSERT INTO business_rule_definition VALUES (
    'RULE_ENG_PROBLEM_ESCALATE',
    'ENGINEERING_PROBLEM_AUTO_ESCALATE',
    '工程问题自动升级',
    'BUSINESS',
    'ENTITY_ENG_PROBLEM_001',
    NULL,
    '{
        "conditions": [
            {"field": "severity", "operator": "equals", "value": "CRITICAL"},
            {"field": "status", "operator": "equals", "value": "OPEN"},
            {"field": "created_at", "operator": "before", "value": "-2h"}
        ],
        "logic": "AND"
    }',
    '{
        "actions": [
            {
                "type": "notification",
                "target": "supervisor",
                "message": "严重工程问题需要立即处理",
                "channels": ["email", "sms", "system"]
            },
            {
                "type": "state_change",
                "field": "priority",
                "value": "URGENT"
            },
            {
                "type": "event_trigger",
                "event_type": "PROBLEM_ESCALATION",
                "data": {"escalation_reason": "timeout", "escalation_level": 1}
            }
        ]
    }',
    100, 1, 'TENANT_001', 'SYSTEM', NOW(), NULL, NULL
);
```

## 自动化CRUD框架实现

### 1. 动态API生成器

```javascript
// 动态API生成器（Node.js示例）
class DynamicAPIGenerator {
    constructor(entityTypeId) {
        this.entityTypeId = entityTypeId;
        this.entityType = null;
        this.formConfigs = {};
    }
    
    async initialize() {
        // 加载实体类型定义
        this.entityType = await this.loadEntityType(this.entityTypeId);
        // 加载表单配置
        this.formConfigs = await this.loadFormConfigs(this.entityTypeId);
    }
    
    // 生成CRUD API路由
    generateRoutes() {
        const routes = [];
        
        // GET /api/entities/{entityTypeCode} - 列表查询
        routes.push({
            method: 'GET',
            path: `/api/entities/${this.entityType.entity_type_code}`,
            handler: this.generateListHandler()
        });
        
        // POST /api/entities/{entityTypeCode} - 创建
        routes.push({
            method: 'POST',
            path: `/api/entities/${this.entityType.entity_type_code}`,
            handler: this.generateCreateHandler()
        });
        
        // GET /api/entities/{entityTypeCode}/{id} - 详情
        routes.push({
            method: 'GET',
            path: `/api/entities/${this.entityType.entity_type_code}/:id`,
            handler: this.generateDetailHandler()
        });
        
        // PUT /api/entities/{entityTypeCode}/{id} - 更新
        routes.push({
            method: 'PUT',
            path: `/api/entities/${this.entityType.entity_type_code}/:id`,
            handler: this.generateUpdateHandler()
        });
        
        // DELETE /api/entities/{entityTypeCode}/{id} - 删除
        routes.push({
            method: 'DELETE',
            path: `/api/entities/${this.entityType.entity_type_code}/:id`,
            handler: this.generateDeleteHandler()
        });
        
        return routes;
    }
    
    // 生成列表查询处理器
    generateListHandler() {
        return async (req, res) => {
            try {
                const { page = 1, size = 20, filters = {}, sort = {} } = req.query;
                
                // 构建查询条件
                const whereClause = this.buildWhereClause(filters);
                const orderClause = this.buildOrderClause(sort);
                
                // 执行查询
                const entities = await this.queryEntities({
                    entityTypeId: this.entityTypeId,
                    where: whereClause,
                    order: orderClause,
                    limit: parseInt(size),
                    offset: (parseInt(page) - 1) * parseInt(size)
                });
                
                // 返回结果
                res.json({
                    code: 200,
                    data: {
                        list: entities,
                        pagination: {
                            page: parseInt(page),
                            size: parseInt(size),
                            total: await this.countEntities(whereClause)
                        }
                    }
                });
            } catch (error) {
                res.status(500).json({
                    code: 500,
                    message: error.message
                });
            }
        };
    }
    
    // 生成创建处理器
    generateCreateHandler() {
        return async (req, res) => {
            try {
                const entityData = req.body;
                
                // 验证数据
                await this.validateEntityData(entityData, 'CREATE');
                
                // 应用业务规则
                await this.applyBusinessRules(entityData, 'CREATE');
                
                // 生成实体编码
                const entityCode = await this.generateEntityCode();
                
                // 创建实体实例
                const instanceId = await this.createEntityInstance({
                    entityTypeId: this.entityTypeId,
                    entityCode: entityCode,
                    entityData: entityData,
                    currentState: this.entityType.lifecycle_states.states[0] // 初始状态
                });
                
                // 触发创建事件
                await this.triggerEvent({
                    eventTypeId: `${this.entityType.entity_type_code}_CREATED`,
                    entityType: this.entityType.entity_type_code,
                    entityId: instanceId,
                    eventData: entityData
                });
                
                res.json({
                    code: 200,
                    data: {
                        instanceId: instanceId,
                        entityCode: entityCode
                    }
                });
            } catch (error) {
                res.status(400).json({
                    code: 400,
                    message: error.message
                });
            }
        };
    }
    
    // 构建查询条件
    buildWhereClause(filters) {
        const conditions = [];
        
        Object.entries(filters).forEach(([field, value]) => {
            if (value !== null && value !== undefined && value !== '') {
                const fieldConfig = this.entityType.schema_definition.properties[field];
                if (fieldConfig) {
                    switch (fieldConfig.type) {
                        case 'string':
                        case 'text':
                            conditions.push(`JSON_EXTRACT(entity_data, '$.${field}') LIKE '%${value}%'`);
                            break;
                        case 'enum':
                            conditions.push(`JSON_EXTRACT(entity_data, '$.${field}') = '${value}'`);
                            break;
                        case 'date':
                            if (value.start) {
                                conditions.push(`JSON_EXTRACT(entity_data, '$.${field}') >= '${value.start}'`);
                            }
                            if (value.end) {
                                conditions.push(`JSON_EXTRACT(entity_data, '$.${field}') <= '${value.end}'`);
                            }
                            break;
                        case 'number':
                            if (value.min !== undefined) {
                                conditions.push(`JSON_EXTRACT(entity_data, '$.${field}') >= ${value.min}`);
                            }
                            if (value.max !== undefined) {
                                conditions.push(`JSON_EXTRACT(entity_data, '$.${field}') <= ${value.max}`);
                            }
                            break;
                    }
                }
            }
        });
        
        return conditions.join(' AND ');
    }
}
```

### 2. 动态UI组件生成器

```vue
<!-- 动态表单组件 -->
<template>
  <div class="dynamic-form">
    <el-form
      ref="form"
      :model="formData"
      :rules="validationRules"
      :label-width="formConfig.labelWidth || '120px'"
    >
      <el-tabs v-if="formConfig.layout.type === 'tabs'" v-model="activeTab">
        <el-tab-pane
          v-for="tab in formConfig.layout.tabs"
          :key="tab.title"
          :label="tab.title"
          :name="tab.title"
        >
          <el-row :gutter="20">
            <el-col
              v-for="field in tab.fields"
              :key="field.name"
              :span="field.span || 24"
            >
              <el-form-item
                :label="field.label"
                :prop="field.name"
                :required="field.required"
              >
                <!-- 文本输入 -->
                <el-input
                  v-if="field.type === 'text'"
                  v-model="formData[field.name]"
                  :placeholder="field.placeholder"
                  :maxlength="field.max_length"
                  :disabled="field.disabled"
                />
                
                <!-- 文本域 -->
                <el-input
                  v-else-if="field.type === 'textarea'"
                  v-model="formData[field.name]"
                  type="textarea"
                  :rows="field.rows || 3"
                  :placeholder="field.placeholder"
                />
                
                <!-- 选择框 -->
                <el-select
                  v-else-if="field.type === 'select'"
                  v-model="formData[field.name]"
                  :placeholder="field.placeholder"
                  :multiple="field.multiple"
                  filterable
                >
                  <el-option
                    v-for="option in field.options"
                    :key="option.value"
                    :label="option.label"
                    :value="option.value"
                  />
                </el-select>
                
                <!-- 多选 -->
                <el-select
                  v-else-if="field.type === 'multi_select'"
                  v-model="formData[field.name]"
                  :placeholder="field.placeholder"
                  multiple
                  filterable
                >
                  <el-option
                    v-for="option in getDynamicOptions(field)"
                    :key="option.value"
                    :label="option.label"
                    :value="option.value"
                  />
                </el-select>
                
                <!-- 单选框 -->
                <el-radio-group
                  v-else-if="field.type === 'radio'"
                  v-model="formData[field.name]"
                >
                  <el-radio
                    v-for="option in field.options"
                    :key="option.value"
                    :label="option.value"
                  >
                    {{ option.label }}
                  </el-radio>
                </el-radio-group>
                
                <!-- 日期选择 -->
                <el-date-picker
                  v-else-if="field.type === 'date'"
                  v-model="formData[field.name]"
                  type="date"
                  :placeholder="field.placeholder"
                />
                
                <!-- 用户选择 -->
                <user-select
                  v-else-if="field.type === 'user_select'"
                  v-model="formData[field.name]"
                  :placeholder="field.placeholder"
                  :api-endpoint="field.data_source"
                />
                
                <!-- 文件上传 -->
                <el-upload
                  v-else-if="field.type === 'file_upload'"
                  :action="uploadUrl"
                  :file-list="formData[field.name] || []"
                  :multiple="field.multiple"
                  :accept="field.accept"
                >
                  <el-button size="small" type="primary">选择文件</el-button>
                </el-upload>
              </el-form-item>
            </el-col>
          </el-row>
        </el-tab-pane>
      </el-tabs>
      
      <!-- 按钮组 -->
      <div class="form-actions">
        <el-button
          v-for="action in formConfig.actions"
          :key="action.type"
          :type="action.color || 'default'"
          @click="handleAction(action)"
        >
          {{ action.label }}
        </el-button>
      </div>
    </el-form>
  </div>
</template>

<script>
export default {
  name: 'DynamicForm',
  props: {
    formConfig: {
      type: Object,
      required: true
    },
    initialData: {
      type: Object,
      default: () => ({})
    }
  },
  data() {
    return {
      formData: { ...this.initialData },
      validationRules: {},
      activeTab: '',
      dynamicOptions: {}
    };
  },
  mounted() {
    this.activeTab = this.formConfig.layout.tabs[0]?.title || '';
    this.buildValidationRules();
    this.loadDynamicOptions();
  },
  methods: {
    // 构建验证规则
    buildValidationRules() {
      const rules = {};
      
      // 从表单配置中提取验证规则
      this.formConfig.layout.tabs.forEach(tab => {
        tab.fields.forEach(field => {
          if (field.required) {
            rules[field.name] = [
              { required: true, message: `${field.label}不能为空`, trigger: 'blur' }
            ];
          }
        });
      });
      
      // 添加自定义验证规则
      if (this.formConfig.validation_rules) {
        this.formConfig.validation_rules.forEach(rule => {
          if (!rules[rule.field]) {
            rules[rule.field] = [];
          }
          rules[rule.field].push({
            validator: this.createValidator(rule),
            trigger: 'blur'
          });
        });
      }
      
      this.validationRules = rules;
    },
    
    // 创建自定义验证器
    createValidator(rule) {
      return (rule, value, callback) => {
        switch (rule.rule) {
          case 'min_length':
            if (value && value.length < rule.value) {
              callback(new Error(rule.message));
            } else {
              callback();
            }
            break;
          case 'future_date':
            if (value && new Date(value) <= new Date()) {
              callback(new Error(rule.message));
            } else {
              callback();
            }
            break;
          default:
            callback();
        }
      };
    },
    
    // 加载动态选项
    async loadDynamicOptions() {
      const fields = this.getAllFields();
      
      for (const field of fields) {
        if (field.data_source && field.data_source.startsWith('api:')) {
          try {
            const response = await this.$http.get(field.data_source.replace('api:', ''));
            this.$set(this.dynamicOptions, field.name, response.data);
          } catch (error) {
            console.error(`Failed to load options for field ${field.name}:`, error);
          }
        }
      }
    },
    
    // 获取所有字段
    getAllFields() {
      const fields = [];
      this.formConfig.layout.tabs.forEach(tab => {
        fields.push(...tab.fields);
      });
      return fields;
    },
    
    // 获取动态选项
    getDynamicOptions(field) {
      return this.dynamicOptions[field.name] || field.options || [];
    },
    
    // 处理表单动作
    handleAction(action) {
      switch (action.type) {
        case 'submit':
          this.submitForm();
          break;
        case 'cancel':
          this.$emit('cancel');
          break;
        case 'reset':
          this.resetForm();
          break;
        default:
          this.$emit('action', action);
      }
    },
    
    // 提交表单
    async submitForm() {
      try {
        await this.$refs.form.validate();
        
        // 应用业务规则
        await this.applyBusinessRules();
        
        this.$emit('submit', this.formData);
      } catch (error) {
        console.error('Form validation failed:', error);
      }
    },
    
    // 应用业务规则
    async applyBusinessRules() {
      if (this.formConfig.business_rules) {
        for (const rule of this.formConfig.business_rules) {
          if (this.evaluateCondition(rule.condition)) {
            await this.executeAction(rule.action, rule.value);
          }
        }
      }
    },
    
    // 评估条件
    evaluateCondition(condition) {
      const fieldValue = this.formData[condition.field];
      
      switch (condition.operator) {
        case 'equals':
          return fieldValue === condition.value;
        case 'not_equals':
          return fieldValue !== condition.value;
        case 'greater_than':
          return fieldValue > condition.value;
        case 'less_than':
          return fieldValue < condition.value;
        case 'contains':
          return fieldValue && fieldValue.includes(condition.value);
        default:
          return false;
      }
    },
    
    // 执行动作
    async executeAction(action, value) {
      switch (action) {
        case 'set_priority':
          this.formData.priority = value;
          break;
        case 'set_due_date':
          const dueDate = new Date();
          dueDate.setDate(dueDate.getDate() + parseInt(value.replace('+', '').replace('d', '')));
          this.formData.due_date = dueDate.toISOString().split('T')[0];
          break;
        case 'auto_generate':
          if (action === 'auto_generate') {
            this.formData[action.field] = await this.generateCode(action.pattern);
          }
          break;
      }
    },
    
    // 生成编码
    async generateCode(pattern) {
      // 实现编码生成逻辑
      const now = new Date();
      const dateStr = now.toISOString().slice(0, 10).replace(/-/g, '');
      const seq = await this.getNextSequence();
      return pattern.replace('{YYYYMMDD}', dateStr).replace('{SEQ}', seq.toString().padStart(4, '0'));
    },
    
    // 重置表单
    resetForm() {
      this.$refs.form.resetFields();
      this.formData = { ...this.initialData };
    }
  }
};
</script>
```

### 3. 模块安装和配置界面

```vue
<!-- 模块管理界面 -->
<template>
  <div class="module-management">
    <el-card>
      <div slot="header" class="clearfix">
        <span>业务模块管理</span>
        <el-button style="float: right; padding: 3px 0" type="text" @click="showInstallDialog = true">
          安装新模块
        </el-button>
      </div>
      
      <el-table :data="modules" style="width: 100%">
        <el-table-column prop="module_name" label="模块名称" />
        <el-table-column prop="module_type" label="模块类型" />
        <el-table-column prop="version" label="版本" />
        <el-table-column prop="is_active" label="状态">
          <template slot-scope="scope">
            <el-tag :type="scope.row.is_active ? 'success' : 'danger'">
              {{ scope.row.is_active ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200">
          <template slot-scope="scope">
            <el-button size="mini" @click="configureModule(scope.row)">配置</el-button>
            <el-button 
              size="mini" 
              :type="scope.row.is_active ? 'danger' : 'success'"
              @click="toggleModule(scope.row)"
            >
              {{ scope.row.is_active ? '禁用' : '启用' }}
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
    
    <!-- 模块安装对话框 -->
    <el-dialog title="安装新模块" :visible.sync="showInstallDialog" width="800px">
      <el-form :model="newModule" label-width="120px">
        <el-form-item label="模块代码">
          <el-input v-model="newModule.module_code" placeholder="输入模块代码" />
        </el-form-item>
        <el-form-item label="模块名称">
          <el-input v-model="newModule.module_name" placeholder="输入模块名称" />
        </el-form-item>
        <el-form-item label="模块类型">
          <el-select v-model="newModule.module_type" placeholder="选择模块类型">
            <el-option label="追踪模块" value="TRACE" />
            <el-option label="工作流模块" value="WORKFLOW" />
            <el-option label="分析模块" value="ANALYTICS" />
            <el-option label="集成模块" value="INTEGRATION" />
          </el-select>
        </el-form-item>
        <el-form-item label="模块描述">
          <el-input v-model="newModule.description" type="textarea" rows="3" />
        </el-form-item>
        
        <!-- 模块配置 -->
        <el-divider>模块配置</el-divider>
        <config-editor v-model="newModule.configuration" />
        
        <!-- API端点配置 -->
        <el-divider>API端点</el-divider>
        <api-endpoints-editor v-model="newModule.api_endpoints" />
        
        <!-- UI组件配置 -->
        <el-divider>UI组件</el-divider>
        <ui-components-editor v-model="newModule.ui_components" />
      </el-form>
      
      <div slot="footer" class="dialog-footer">
        <el-button @click="showInstallDialog = false">取消</el-button>
        <el-button type="primary" @click="installModule">安装</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
export default {
  name: 'ModuleManagement',
  data() {
    return {
      modules: [],
      showInstallDialog: false,
      newModule: {
        module_code: '',
        module_name: '',
        module_type: '',
        description: '',
        configuration: {},
        api_endpoints: [],
        ui_components: {}
      }
    };
  },
  mounted() {
    this.loadModules();
  },
  methods: {
    async loadModules() {
      try {
        const response = await this.$http.get('/api/modules');
        this.modules = response.data;
      } catch (error) {
        this.$message.error('加载模块列表失败');
      }
    },
    
    async installModule() {
      try {
        await this.$http.post('/api/modules/install', this.newModule);
        this.$message.success('模块安装成功');
        this.showInstallDialog = false;
        this.loadModules();
        this.resetNewModule();
      } catch (error) {
        this.$message.error('模块安装失败: ' + error.message);
      }
    },
    
    async configureModule(module) {
      // 打开模块配置对话框
      this.$router.push({
        name: 'ModuleConfig',
        params: { moduleId: module.module_id }
      });
    },
    
    async toggleModule(module) {
      try {
        await this.$http.put(`/api/modules/${module.module_id}/toggle`);
        this.$message.success('模块状态更新成功');
        this.loadModules();
      } catch (error) {
        this.$message.error('模块状态更新失败');
      }
    },
    
    resetNewModule() {
      this.newModule = {
        module_code: '',
        module_name: '',
        module_type: '',
        description: '',
        configuration: {},
        api_endpoints: [],
        ui_components: {}
      };
    }
  }
};
</script>
```

## 总结

### 🎯 **核心优势**

1. **乐高积木式设计**: 每个业务模块都是独立的积木，可以随时添加、移除、替换
2. **事件驱动架构**: 通过标准化的事件系统实现模块间的松耦合
3. **自动化CRUD**: 通过配置即可生成完整的CRUD功能，无需编码
4. **动态Schema**: 支持任意业务实体的动态定义和扩展
5. **热插拔模块**: 支持运行时安装、配置、启用/禁用业务模块

### 🔧 **扩展能力**

- **工程问题追踪**: 可插拔模块，支持自定义字段、工作流、通知规则
- **物料问题追踪**: 独立模块，支持供应商管理、批次追溯、质量分析
- **任意业务扩展**: 通过配置即可创建新的追踪业务，无需修改核心代码

### 🚀 **实施路径**

1. **第一阶段**: 实现基础追踪平台和事件引擎
2. **第二阶段**: 开发自动化CRUD框架和动态UI组件
3. **第三阶段**: 创建工程问题追踪和物料问题追踪模块
4. **第四阶段**: 完善模块管理和配置界面

这个架构设计真正实现了您所期望的"乐高积木式"灵活扩展能力，支持通过前端UI直接配置和扩展业务逻辑！
