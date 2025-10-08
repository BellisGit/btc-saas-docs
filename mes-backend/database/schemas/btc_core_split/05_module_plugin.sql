-- ==============================================
-- BTC核心数据库 - 模块和插件表
-- ==============================================

USE btc_core;

CREATE TABLE sys_module (
    module_id VARCHAR(32) PRIMARY KEY COMMENT '模块ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    
    -- 基础属性
    module_code VARCHAR(32) NOT NULL UNIQUE COMMENT '模块代码',
    module_name VARCHAR(64) NOT NULL COMMENT '模块名称',
    module_type ENUM('SYSTEM', 'BUSINESS', 'PLUGIN') NOT NULL COMMENT '模块类型',
    description TEXT COMMENT '模块描述',
    
    -- 部署属性
    deploy_url VARCHAR(255) COMMENT '部署地址',
    api_base_url VARCHAR(255) COMMENT 'API基础地址',
    version VARCHAR(16) COMMENT '版本号',
    build_version VARCHAR(32) COMMENT '构建版本',
    
    -- 配置属性
    config JSON COMMENT '模块配置',
    dependencies JSON COMMENT '依赖关系',
    plugins JSON COMMENT '插件列表',
    
    -- 状态属性
    status ENUM('ACTIVE', 'INACTIVE', 'MAINTENANCE', 'DEPRECATED') DEFAULT 'ACTIVE' COMMENT '状态',
    is_deleted BOOLEAN DEFAULT FALSE COMMENT '是否删除',
    
    -- 审计字段
    created_by VARCHAR(64) NOT NULL COMMENT '创建人',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by VARCHAR(64) COMMENT '更新人',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    INDEX idx_tenant (tenant_id),
    INDEX idx_module_code (module_code),
    INDEX idx_module_type (module_type),
    INDEX idx_status (status),
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(tenant_id)
) COMMENT '模块表';

-- ==============================================
-- 8. 插件表 (支持插件化扩展)
-- ==============================================

CREATE TABLE sys_plugin (
    plugin_id VARCHAR(32) PRIMARY KEY COMMENT '插件ID',
    module_id VARCHAR(32) NOT NULL COMMENT '所属模块ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    
    -- 基础属性
    plugin_code VARCHAR(32) NOT NULL COMMENT '插件代码',
    plugin_name VARCHAR(64) NOT NULL COMMENT '插件名称',
    plugin_type ENUM('FUNCTION', 'WIDGET', 'INTEGRATION') NOT NULL COMMENT '插件类型',
    description TEXT COMMENT '插件描述',
    
    -- 部署属性
    plugin_url VARCHAR(255) COMMENT '插件地址',
    api_endpoint VARCHAR(255) COMMENT 'API端点',
    version VARCHAR(16) COMMENT '版本号',
    
    -- 配置属性
    config JSON COMMENT '插件配置',
    permissions JSON COMMENT '权限配置',
    menu_config JSON COMMENT '菜单配置',
    
    -- 状态属性
    status ENUM('ACTIVE', 'INACTIVE', 'LOADING', 'ERROR') DEFAULT 'INACTIVE' COMMENT '状态',
    is_deleted BOOLEAN DEFAULT FALSE COMMENT '是否删除',
    
    -- 审计字段
    created_by VARCHAR(64) NOT NULL COMMENT '创建人',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by VARCHAR(64) COMMENT '更新人',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    INDEX idx_module (module_id),
    INDEX idx_tenant (tenant_id),
    INDEX idx_plugin_code (plugin_code),
    INDEX idx_plugin_type (plugin_type),
    INDEX idx_status (status),
    FOREIGN KEY (module_id) REFERENCES sys_module(module_id),
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(tenant_id)
) COMMENT '插件表';

-- ==============================================
-- 9. 用户模块关联表 (支持模块跳转)
-- ==============================================

CREATE TABLE sys_user_module (
    user_module_id VARCHAR(32) PRIMARY KEY COMMENT '用户模块关联ID',
    user_id VARCHAR(32) NOT NULL COMMENT '用户ID',
    module_id VARCHAR(32) NOT NULL COMMENT '模块ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    
    -- 权限属性
    access_level ENUM('READ', 'WRITE', 'ADMIN') DEFAULT 'READ' COMMENT '访问级别',
    is_default BOOLEAN DEFAULT FALSE COMMENT '是否默认模块',
    auto_redirect BOOLEAN DEFAULT TRUE COMMENT '是否自动跳转',
    
    -- 状态属性
    status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE' COMMENT '状态',
    
    -- 审计字段
    created_by VARCHAR(64) NOT NULL COMMENT '创建人',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by VARCHAR(64) COMMENT '更新人',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    UNIQUE KEY uk_user_module (user_id, module_id),
    INDEX idx_user (user_id),
    INDEX idx_module (module_id),
    INDEX idx_tenant (tenant_id),
    INDEX idx_status (status),
    FOREIGN KEY (user_id) REFERENCES sys_user(user_id),
    FOREIGN KEY (module_id) REFERENCES sys_module(module_id),
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(tenant_id)
) COMMENT '用户模块关联表';
