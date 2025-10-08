# 用户ID设计规范

## 📋 概述

本文档定义MES系统中用户ID的设计规范和生成规则。

---

## 🎯 设计原则

### 1. 唯一性
- 全局唯一，跨租户不重复
- 支持分布式环境下的并发生成

### 2. 可读性
- 包含业务语义
- 便于人工识别和调试

### 3. 安全性
- 不暴露业务敏感信息
- 不可预测，防止遍历攻击

### 4. 可扩展性
- 支持未来用户规模增长
- 预留扩展空间

---

## 🔢 推荐方案

### 方案1: UUID v4 (推荐用于生产环境)

#### 格式
```
xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
```

#### 示例
```sql
user_id: '550e8400-e29b-41d4-a716-446655440000'
```

#### 优点
- ✅ 全局唯一性保证
- ✅ 无序列依赖，支持分布式
- ✅ 安全性高，不可预测
- ✅ 标准化，各语言有原生支持

#### 缺点
- ❌ 占用空间较大 (36字符)
- ❌ 作为主键影响索引性能
- ❌ 不易记忆和调试

---

### 方案2: 业务前缀 + 雪花ID (推荐)

#### 格式
```
{租户前缀}-{用户类型}-{雪花ID}
```

#### 示例
```sql
-- 内网用户
user_id: 'INERT-EMP-1744992000000000001'

-- 英国用户  
user_id: 'UK-EMP-1744992000000000002'

-- 供应商用户
user_id: 'SUP-VENDOR-1744992000000000003'
```

#### 前缀定义
| 租户代码 | 用户类型 | 前缀 | 说明 |
|----------|----------|------|------|
| INERT | Employee | INERT-EMP | 内网员工 |
| UK_HEAD | Employee | UK-EMP | 英国员工 |
| SUPPLIER | Vendor | SUP-VENDOR | 供应商 |

#### 雪花ID结构
```
64位整数:
- 1位符号位 (0)
- 41位时间戳 (毫秒)
- 10位机器ID
- 12位序列号
```

#### 优点
- ✅ 全局唯一
- ✅ 有序递增，索引友好
- ✅ 包含业务语义
- ✅ 支持分布式生成

#### 缺点
- ❌ 需要实现雪花ID生成器
- ❌ 较长 (30-35字符)

---

### 方案3: 业务前缀 + 序列号 (适用于小规模)

#### 格式
```
{租户前缀}-{部门代码}-{序列号}
```

#### 示例
```sql
-- 总经理
user_id: 'INERT-MGT-0001'

-- 品质经理
user_id: 'INERT-QC-0001'

-- 供应商
user_id: 'SUP-RAW-0001'
```

#### 部门代码定义
| 部门 | 代码 |
|------|------|
| 管理层 | MGT |
| 财务部门 | FIN |
| 人事部门 | HR |
| 物流部门 | LOG |
| 采购部门 | PUR |
| 生产部门 | PRD |
| 工程部门 | ENG |
| 品质部门 | QC |
| 维修部门 | MNT |
| IT部门 | IT |

#### 优点
- ✅ 简洁易读
- ✅ 包含部门信息
- ✅ 便于人工识别
- ✅ 占用空间小

#### 缺点
- ❌ 需要中心化序列生成
- ❌ 不适合大规模分布式
- ❌ 暴露组织信息

---

### 方案4: 邮箱前缀 (适用于已有邮箱体系)

#### 格式
```
邮箱用户名部分作为user_id
```

#### 示例
```sql
-- 从 iji@bellis-technology.cn 提取
user_id: 'iji'

-- 从 fxiong@bellis-technology.cn 提取
user_id: 'fxiong'

-- 从 ct.liu@suga.com.cn 提取
user_id: 'ctliu'
```

#### 优点
- ✅ 与现有邮箱体系一致
- ✅ 用户易记忆
- ✅ 简洁

#### 缺点
- ❌ 可能存在重复（不同域名相同前缀）
- ❌ 缺乏业务语义
- ❌ 不适合没有邮箱的用户

---

## 💡 推荐实施方案

### 混合方案（最佳实践）

#### 设计
```sql
CREATE TABLE sys_user (
    user_id VARCHAR(64) PRIMARY KEY COMMENT '用户ID (UUID)',
    user_code VARCHAR(32) UNIQUE COMMENT '用户编码 (业务ID)',
    username VARCHAR(64) UNIQUE COMMENT '用户名 (登录用)',
    email VARCHAR(255) UNIQUE COMMENT '邮箱',
    ...
);
```

#### 字段说明

**1. user_id (主键)**
- **格式**: UUID v4
- **示例**: `550e8400-e29b-41d4-a716-446655440000`
- **用途**: 系统内部主键，关联外键
- **优势**: 全局唯一，安全，分布式友好

**2. user_code (业务ID)**
- **格式**: `{租户前缀}-{部门代码}-{序列号}`
- **示例**: `INERT-QC-0001`
- **用途**: 业务展示，报表显示
- **优势**: 可读性强，包含业务语义

**3. username (登录名)**
- **格式**: 邮箱前缀或自定义
- **示例**: `iji`, `fxiong`, `sli`
- **用途**: 用户登录
- **优势**: 简洁，用户易记

**4. email (邮箱)**
- **格式**: 标准邮箱格式
- **示例**: `iji@bellis-technology.cn`
- **用途**: 通知，找回密码
- **优势**: 唯一，标准化

---

## 📊 实际应用示例

### 示例1: 内网用户

```sql
INSERT INTO sys_user (user_id, user_code, username, email, real_name, dept_id, tenant_id) VALUES
(
    '550e8400-e29b-41d4-a716-446655440001',  -- UUID
    'INERT-MGT-0001',                         -- 业务编码
    'iji',                                     -- 登录名
    'iji@bellis-technology.cn',               -- 邮箱
    '季小波',                                  -- 真实姓名
    'DEPT_INERT_MANAGEMENT',
    'TENANT_INERT'
);
```

### 示例2: 供应商用户

```sql
INSERT INTO sys_user (user_id, user_code, username, email, real_name, dept_id, tenant_id) VALUES
(
    '550e8400-e29b-41d4-a716-446655440059',  -- UUID
    'SUP-RAW-0001',                           -- 业务编码
    'ctliu',                                   -- 登录名
    'ct.liu@suga.com.cn',                     -- 邮箱
    'ctliu',                                   -- 真实姓名
    'DEPT_SUPPLIER_RAW',
    'TENANT_SUPPLIER'
);
```

### 示例3: 英国用户

```sql
INSERT INTO sys_user (user_id, user_code, username, email, real_name, dept_id, tenant_id) VALUES
(
    '550e8400-e29b-41d4-a716-446655440058',  -- UUID
    'UK-IT-0001',                             -- 业务编码
    'uk',                                      -- 登录名
    'btcinformation@bellis-technology.cn',    -- 邮箱
    'UK',                                      -- 真实姓名
    'DEPT_UK_HEAD',
    'TENANT_UK_HEAD'
);
```

---

## 🔧 ID生成策略

### 1. UUID生成

#### Java实现
```java
import java.util.UUID;

public String generateUserId() {
    return UUID.randomUUID().toString();
}
```

#### Python实现
```python
import uuid

def generate_user_id():
    return str(uuid.uuid4())
```

#### MySQL生成
```sql
SELECT UUID() as user_id;
```

### 2. 业务编码生成

#### 自动生成示例
```sql
-- 获取部门下一个序列号
SELECT CONCAT(
    'INERT-QC-',
    LPAD(
        COALESCE(MAX(CAST(SUBSTRING(user_code, -4) AS UNSIGNED)), 0) + 1,
        4,
        '0'
    )
) AS next_user_code
FROM sys_user
WHERE user_code LIKE 'INERT-QC-%';

-- 结果: INERT-QC-0015
```

### 3. 序列表方案

```sql
CREATE TABLE sys_sequence (
    seq_name VARCHAR(64) PRIMARY KEY COMMENT '序列名称',
    current_value BIGINT NOT NULL DEFAULT 0 COMMENT '当前值',
    increment_by INT NOT NULL DEFAULT 1 COMMENT '步长',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT '序列生成器';

-- 获取下一个值（原子操作）
UPDATE sys_sequence SET current_value = LAST_INSERT_ID(current_value + increment_by)
WHERE seq_name = 'USER_CODE_INERT_QC';

SELECT LAST_INSERT_ID() as next_value;
```

---

## 📋 数据迁移建议

### 当前状态
```sql
-- 当前使用简单ID
user_id: 'USER_1', 'USER_2', 'USER_58'
```

### 迁移步骤

#### 步骤1: 添加新字段
```sql
ALTER TABLE sys_user 
ADD COLUMN user_uuid VARCHAR(64) COMMENT 'UUID主键',
ADD COLUMN user_code VARCHAR(32) COMMENT '业务编码',
ADD INDEX idx_user_uuid (user_uuid),
ADD INDEX idx_user_code (user_code);
```

#### 步骤2: 生成UUID和业务编码
```sql
-- 为现有用户生成UUID
UPDATE sys_user SET user_uuid = UUID();

-- 生成业务编码
UPDATE sys_user u
JOIN sys_dept d ON u.dept_id = d.dept_id
SET u.user_code = CONCAT(
    u.tenant_id, '-',
    CASE d.dept_code
        WHEN 'MANAGEMENT' THEN 'MGT'
        WHEN 'FINANCE' THEN 'FIN'
        WHEN 'HR' THEN 'HR'
        WHEN 'LOGISTICS' THEN 'LOG'
        WHEN 'PROCUREMENT' THEN 'PUR'
        WHEN 'PRODUCTION' THEN 'PRD'
        WHEN 'ENGINEERING' THEN 'ENG'
        WHEN 'QUALITY' THEN 'QC'
        WHEN 'MAINTENANCE' THEN 'MNT'
        WHEN 'IT' THEN 'IT'
        ELSE 'MISC'
    END, '-',
    LPAD(CAST(SUBSTRING(user_id, 6) AS UNSIGNED), 4, '0')
);
```

#### 步骤3: 渐进式切换
```sql
-- 阶段1: 双主键并存
-- 保留 user_id，新增 user_uuid 和 user_code

-- 阶段2: 修改外键
-- 逐步将外键从 user_id 迁移到 user_uuid

-- 阶段3: 完全切换
-- 将 user_uuid 改名为 user_id
-- 删除旧的 user_id 字段
```

---

## 🎯 最终推荐方案

### 数据库表结构

```sql
CREATE TABLE sys_user (
    -- 主键：UUID (系统内部使用)
    user_id VARCHAR(64) PRIMARY KEY COMMENT '用户UUID',
    
    -- 业务ID：可读编码 (业务展示用)
    user_code VARCHAR(32) UNIQUE NOT NULL COMMENT '用户编码',
    
    -- 登录名：简短易记 (登录使用)
    username VARCHAR(64) UNIQUE NOT NULL COMMENT '登录用户名',
    
    -- 邮箱：通知和找回密码
    email VARCHAR(255) UNIQUE COMMENT '邮箱',
    
    -- 基础信息
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    dept_id VARCHAR(32) NOT NULL COMMENT '部门ID',
    real_name VARCHAR(128) NOT NULL COMMENT '真实姓名',
    english_name VARCHAR(128) COMMENT '英文名',
    
    -- 密码和安全
    password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希',
    
    -- 其他字段...
    user_type ENUM('EXECUTIVE', 'MANAGER', 'NORMAL', 'READONLY', 'SUPPLIER') DEFAULT 'NORMAL',
    status ENUM('ACTIVE', 'INACTIVE', 'LOCKED') DEFAULT 'ACTIVE',
    
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user_code (user_code),
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_tenant (tenant_id),
    INDEX idx_dept (dept_id),
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(tenant_id),
    FOREIGN KEY (dept_id) REFERENCES sys_dept(dept_id)
) COMMENT '用户表';
```

### 示例数据

```sql
INSERT INTO sys_user (
    user_id, 
    user_code, 
    username, 
    email, 
    real_name, 
    english_name,
    tenant_id, 
    dept_id, 
    password_hash, 
    user_type, 
    created_by
) VALUES
-- 总经理
(
    '550e8400-e29b-41d4-a716-446655440001',
    'INERT-MGT-0001',
    'iji',
    'iji@bellis-technology.cn',
    '季小波',
    'Ivan Ji',
    'TENANT_INERT',
    'DEPT_INERT_MANAGEMENT',
    '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q',
    'EXECUTIVE',
    'SYSTEM'
),
-- 品质经理
(
    '550e8400-e29b-41d4-a716-446655440043',
    'INERT-QC-0001',
    'sli',
    'sli@bellis-technology.cn',
    '黎厚利',
    'Stanley Li',
    'TENANT_INERT',
    'DEPT_INERT_QUALITY',
    '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q',
    'MANAGER',
    'SYSTEM'
),
-- 供应商
(
    '550e8400-e29b-41d4-a716-446655440059',
    'SUP-RAW-0001',
    'ctliu',
    'ct.liu@suga.com.cn',
    'ctliu',
    NULL,
    'TENANT_SUPPLIER',
    'DEPT_SUPPLIER_RAW',
    '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q',
    'SUPPLIER',
    'SYSTEM'
);
```

---

## 🚀 实施建议

### 阶段1: 保持兼容（当前）
```sql
-- 保留 USER_1, USER_58 等简单ID
-- 仅用于开发和测试阶段
```

### 阶段2: 添加规范ID（迁移准备）
```sql
-- 添加 user_code 字段
-- 为现有用户生成业务编码
-- 双ID并存
```

### 阶段3: 完整迁移（生产环境）
```sql
-- 使用UUID作为主键
-- user_code作为业务展示
-- username作为登录名
```

---

## 📋 各场景下的ID选择

| 使用场景 | 推荐ID类型 | 示例 |
|----------|------------|------|
| 数据库主键 | UUID | `550e8400-e29b-41d4-a716-446655440001` |
| 业务展示 | user_code | `INERT-QC-0001` |
| 用户登录 | username | `iji`, `sli` |
| 邮件通知 | email | `iji@bellis-technology.cn` |
| API返回 | user_code | `INERT-QC-0001` |
| 日志记录 | user_code + username | `INERT-QC-0001 (sli)` |
| 报表显示 | user_code + real_name | `INERT-QC-0001 (黎厚利)` |

---

## 🔐 安全考虑

### 1. 不暴露敏感信息
- ❌ 不在URL中直接使用user_id
- ✅ 使用加密的token或session

### 2. 防止遍历攻击
- ❌ 不使用连续递增的数字ID作为主键
- ✅ 使用UUID或雪花ID

### 3. 审计追踪
- ✅ created_by/updated_by 记录操作人的user_code
- ✅ 日志中同时记录user_code和username

---

## 📝 总结

### 最佳实践（推荐）

```
主键ID: UUID v4 (user_id)
业务ID: INERT-QC-0001 (user_code)  
登录名: sli (username)
邮箱: sli@bellis-technology.cn (email)
```

### 当前系统建议

对于当前MES系统，建议：

1. **开发/测试阶段**: 保持 `USER_1`, `USER_58` 等简单ID，快速迭代
2. **迁移准备阶段**: 添加 `user_code` 字段，生成业务编码
3. **生产部署阶段**: 切换到UUID主键 + user_code业务ID的混合方案

这样既保证了系统的专业性和安全性，又具有良好的可读性和可维护性。
