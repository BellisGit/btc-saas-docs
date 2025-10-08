# 基于Cool-Admin多模块架构的菜单设计方案

## 📋 概述

本方案基于cool-admin-vue的多模块、多插件架构，结合monorepo部署模式，设计一个支持模块化、插件化、多租户的菜单系统。系统采用分层架构，支持自动模块跳转、独立RBAC、模块管理员等特性。

---

## 🏗️ 系统架构

### 1. 整体架构层次

```
超级管理员 (Super Admin)
├── 系统级管理
│   ├── 租户管理
│   ├── 模块管理
│   ├── 插件管理
│   └── 全局配置
├── 模块级管理
│   ├── 采购域 (Procurement Domain)
│   ├── 生产域 (Production Domain)
│   ├── 物流域 (Logistics Domain)
│   ├── 质量域 (Quality Domain)
│   ├── 维护域 (Maintenance Domain)
│   └── 系统管理域 (System Domain)
└── 租户级管理
    ├── UK_HEAD (英国总公司)
    ├── INERT (内网用户)
    └── SUPPLIER (供应商群体)
```

### 2. 模块化架构特性

#### 2.1 多模块设计
- **独立部署**: 每个域作为独立的子系统部署
- **独立RBAC**: 每个模块有自己的完整权限体系
- **模块管理员**: 每个模块有独立的模块级管理员
- **自动跳转**: 根据用户角色自动跳转到对应模块

#### 2.2 插件化设计
- **插件机制**: 支持动态加载和卸载插件
- **插件管理**: 插件级别的权限和菜单管理
- **插件扩展**: 支持第三方插件集成

#### 2.3 Monorepo架构
- **统一代码库**: 所有模块在同一个代码库中
- **独立构建**: 每个模块可以独立构建和部署
- **共享组件**: 共享通用组件和工具库

---

## 🎭 权限体系设计

### 1. 权限层级结构

```
超级管理员 (Super Admin)
├── 全局权限
│   ├── 租户管理权限
│   ├── 模块管理权限
│   ├── 插件管理权限
│   └── 系统配置权限
└── 跨模块权限
    ├── 所有模块访问权限
    └── 跨模块数据权限

模块管理员 (Module Admin)
├── 模块内权限
│   ├── 模块配置权限
│   ├── 用户管理权限
│   ├── 角色管理权限
│   └── 菜单管理权限
└── 业务权限
    ├── 业务流程权限
    └── 数据访问权限

业务用户 (Business User)
├── 模块访问权限
├── 功能操作权限
└── 数据访问权限
```

### 2. 角色继承关系

```
ROLE_SUPER_ADMIN (超级管理员)
├── 继承所有模块管理员权限
├── 继承所有业务用户权限
└── 拥有系统级管理权限

ROLE_MODULE_ADMIN (模块管理员)
├── 继承模块内所有业务用户权限
├── 拥有模块管理权限
└── 拥有模块配置权限

ROLE_BUSINESS_USER (业务用户)
├── 拥有特定业务流程权限
├── 拥有数据访问权限
└── 拥有功能操作权限
```

---

## 📋 菜单表结构设计

### 1. 菜单层级设计

#### 1.1 一级菜单 (模块级)
```
系统管理 (System Management)
├── 租户管理
├── 模块管理
├── 插件管理
└── 全局配置

采购域 (Procurement Domain)
├── 供应商管理
├── 采购计划
├── 采购执行
└── 采购分析

生产域 (Production Domain)
├── 生产计划
├── 工单管理
├── 生产执行
└── 生产监控

物流域 (Logistics Domain)
├── 仓库管理
├── 库存管理
├── 配送管理
└── 物流跟踪

质量域 (Quality Domain)
├── IQC检验
├── IPQC巡检
├── OQC出货
└── 质量分析

维护域 (Maintenance Domain)
├── 设备管理
├── 维护计划
├── 故障处理
└── 维护分析
```

#### 1.2 二级菜单 (功能级)
每个模块下的具体功能菜单，支持插件扩展。

#### 1.3 三级菜单 (操作级)
具体的操作按钮和功能入口。

### 2. 菜单属性设计

#### 2.1 基础属性
- **菜单ID**: 唯一标识
- **父菜单ID**: 支持多级菜单
- **菜单名称**: 显示名称
- **菜单代码**: 唯一代码
- **菜单类型**: 目录/菜单/按钮/插件
- **菜单图标**: 显示图标
- **排序号**: 显示顺序

#### 2.2 模块化属性
- **模块代码**: 所属模块
- **插件代码**: 所属插件（可选）
- **部署地址**: 模块部署地址
- **路由路径**: 前端路由
- **组件路径**: 前端组件

#### 2.3 权限属性
- **权限标识**: 关联权限
- **访问控制**: 访问级别
- **数据权限**: 数据范围
- **操作权限**: 操作类型

#### 2.4 租户属性
- **租户ID**: 租户隔离
- **租户类型**: 租户分类
- **可见性**: 租户可见性

---

## 🗄️ 数据库表设计

### 1. 主菜单表 (sys_menu)

```sql
CREATE TABLE sys_menu (
    menu_id VARCHAR(32) PRIMARY KEY COMMENT '菜单ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    parent_id VARCHAR(32) COMMENT '父菜单ID',
    
    -- 基础属性
    menu_code VARCHAR(64) NOT NULL COMMENT '菜单代码',
    menu_name VARCHAR(64) NOT NULL COMMENT '菜单名称',
    menu_type ENUM('DIRECTORY', 'MENU', 'BUTTON', 'PLUGIN') NOT NULL COMMENT '菜单类型',
    icon VARCHAR(64) COMMENT '菜单图标',
    sort_order INT DEFAULT 0 COMMENT '排序号',
    
    -- 模块化属性
    module_code VARCHAR(32) NOT NULL COMMENT '模块代码',
    plugin_code VARCHAR(32) COMMENT '插件代码',
    deploy_url VARCHAR(255) COMMENT '部署地址',
    route_path VARCHAR(255) COMMENT '路由路径',
    component_path VARCHAR(255) COMMENT '组件路径',
    
    -- 权限属性
    permission_code VARCHAR(64) COMMENT '权限标识',
    access_level ENUM('PUBLIC', 'AUTHENTICATED', 'AUTHORIZED') DEFAULT 'AUTHORIZED' COMMENT '访问级别',
    data_scope ENUM('ALL', 'TENANT', 'DEPT', 'SELF') DEFAULT 'TENANT' COMMENT '数据权限',
    operation_type ENUM('READ', 'WRITE', 'ADMIN') DEFAULT 'READ' COMMENT '操作权限',
    
    -- 租户属性
    tenant_visible BOOLEAN DEFAULT TRUE COMMENT '租户可见性',
    tenant_config JSON COMMENT '租户配置',
    
    -- 状态属性
    status ENUM('ACTIVE', 'INACTIVE', 'MAINTENANCE') DEFAULT 'ACTIVE' COMMENT '状态',
    is_deleted BOOLEAN DEFAULT FALSE COMMENT '是否删除',
    
    -- 审计字段
    created_by VARCHAR(32) NOT NULL COMMENT '创建人',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by VARCHAR(32) COMMENT '更新人',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
);
```

### 2. 模块表 (sys_module)

```sql
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
    created_by VARCHAR(32) NOT NULL COMMENT '创建人',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by VARCHAR(32) COMMENT '更新人',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
);
```

### 3. 插件表 (sys_plugin)

```sql
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
    created_by VARCHAR(32) NOT NULL COMMENT '创建人',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by VARCHAR(32) COMMENT '更新人',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    FOREIGN KEY (module_id) REFERENCES sys_module(module_id),
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(tenant_id)
);
```

### 4. 用户模块关联表 (sys_user_module)

```sql
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
    created_by VARCHAR(32) NOT NULL COMMENT '创建人',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_by VARCHAR(32) COMMENT '更新人',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    
    UNIQUE KEY uk_user_module (user_id, module_id),
    FOREIGN KEY (user_id) REFERENCES sys_user(user_id),
    FOREIGN KEY (module_id) REFERENCES sys_module(module_id),
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(tenant_id)
);
```

---

## 🔄 模块跳转机制

### 1. 自动跳转逻辑

#### 1.1 用户登录后跳转流程
```
1. 用户登录成功
2. 获取用户角色和权限
3. 查询用户可访问的模块列表
4. 根据用户配置确定默认模块
5. 自动跳转到默认模块
6. 加载模块菜单和权限
```

#### 1.2 模块切换流程
```
1. 用户选择切换模块
2. 验证用户是否有模块访问权限
3. 跳转到目标模块
4. 加载目标模块的菜单和权限
5. 更新用户当前模块状态
```

### 2. 权限验证机制

#### 2.1 模块级权限验证
- 验证用户是否有模块访问权限
- 验证用户在当前模块的角色权限
- 验证用户的数据访问范围

#### 2.2 菜单级权限验证
- 验证用户是否有菜单访问权限
- 验证用户的操作权限级别
- 验证用户的数据权限范围

---

## 🎯 实现策略

### 1. 前端实现

#### 1.1 模块加载器
```javascript
class ModuleLoader {
  async loadModule(moduleCode) {
    // 动态加载模块
    const module = await import(`@/modules/${moduleCode}`);
    return module;
  }
  
  async loadMenus(moduleCode) {
    // 加载模块菜单
    const menus = await api.getModuleMenus(moduleCode);
    return menus;
  }
}
```

#### 1.2 路由管理器
```javascript
class RouteManager {
  async redirectToModule(moduleCode) {
    // 跳转到指定模块
    const module = await this.moduleLoader.loadModule(moduleCode);
    router.push(module.defaultRoute);
  }
}
```

### 2. 后端实现

#### 2.1 模块服务
```java
@Service
public class ModuleService {
  public List<Module> getUserModules(String userId) {
    // 获取用户可访问的模块列表
    return moduleMapper.selectUserModules(userId);
  }
  
  public List<Menu> getModuleMenus(String moduleCode, String userId) {
    // 获取模块菜单
    return menuMapper.selectModuleMenus(moduleCode, userId);
  }
}
```

#### 2.2 权限验证器
```java
@Component
public class PermissionValidator {
  public boolean hasModuleAccess(String userId, String moduleCode) {
    // 验证模块访问权限
    return userModuleMapper.hasAccess(userId, moduleCode);
  }
  
  public boolean hasMenuAccess(String userId, String menuCode) {
    // 验证菜单访问权限
    return userMenuMapper.hasAccess(userId, menuCode);
  }
}
```

---

## 📊 配置示例

### 1. 模块配置示例

```json
{
  "modules": {
    "procurement": {
      "code": "PROCUREMENT",
      "name": "采购域",
      "type": "BUSINESS",
      "deployUrl": "https://procurement.btc-saas.com",
      "apiBaseUrl": "https://api.btc-saas.com/procurement",
      "version": "1.0.0",
      "plugins": ["supplier", "purchase", "contract"]
    },
    "production": {
      "code": "PRODUCTION", 
      "name": "生产域",
      "type": "BUSINESS",
      "deployUrl": "https://production.btc-saas.com",
      "apiBaseUrl": "https://api.btc-saas.com/production",
      "version": "1.0.0",
      "plugins": ["workorder", "scheduling", "monitoring"]
    }
  }
}
```

### 2. 菜单配置示例

```json
{
  "menus": {
    "PROCUREMENT": {
      "children": [
        {
          "menuCode": "SUPPLIER_MANAGE",
          "menuName": "供应商管理",
          "menuType": "DIRECTORY",
          "routePath": "/procurement/supplier",
          "children": [
            {
              "menuCode": "SUPPLIER_LIST",
              "menuName": "供应商列表",
              "menuType": "MENU",
              "routePath": "/procurement/supplier/list",
              "componentPath": "procurement/supplier/List"
            }
          ]
        }
      ]
    }
  }
}
```

---

## 🚀 部署策略

### 1. Monorepo结构

```
btc-saas/
├── packages/
│   ├── core/                 # 核心包
│   ├── ui/                   # UI组件库
│   └── utils/                # 工具库
├── modules/
│   ├── system/               # 系统管理模块
│   ├── procurement/          # 采购模块
│   ├── production/           # 生产模块
│   ├── logistics/            # 物流模块
│   ├── quality/              # 质量模块
│   └── maintenance/          # 维护模块
├── plugins/                  # 插件目录
└── apps/
    ├── main/                 # 主应用
    └── admin/                # 管理后台
```

### 2. 独立部署

每个模块可以独立构建和部署：

```bash
# 构建采购模块
npm run build:procurement

# 部署采购模块
docker build -t btc-saas/procurement .
docker run -p 3001:80 btc-saas/procurement
```

### 3. 动态加载

支持模块的动态加载和热更新：

```javascript
// 动态加载模块
const module = await import(`/modules/${moduleCode}/index.js`);

// 热更新模块
if (module.hot) {
  module.hot.accept();
}
```

---

## 📋 总结

这个基于cool-admin多模块架构的菜单设计方案提供了：

1. **模块化架构**: 支持独立模块开发和部署
2. **插件化扩展**: 支持插件动态加载和扩展
3. **多租户支持**: 完整的租户隔离和权限控制
4. **自动跳转**: 根据用户角色自动跳转到对应模块
5. **独立RBAC**: 每个模块有完整的权限体系
6. **Monorepo支持**: 统一代码库，独立构建部署

这个设计确保了系统的可扩展性、可维护性和灵活性，同时保持了良好的用户体验和系统性能。
