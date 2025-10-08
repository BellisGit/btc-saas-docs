# 安全与合规

## 概述

本文档描述了MES系统的安全架构、合规要求和数据保护措施。确保系统符合相关法规要求，保护敏感数据，防范安全威胁。

## 安全架构

### 安全原则

#### 核心安全原则
1. **最小权限原则**：用户和系统只获得必要的权限
2. **深度防御**：多层次安全防护
3. **零信任架构**：不信任任何用户或系统
4. **数据分类保护**：根据数据敏感级别采取不同保护措施
5. **审计跟踪**：记录所有安全相关活动

#### 安全框架
- **身份认证**：验证用户身份
- **授权控制**：控制用户访问权限
- **数据加密**：保护数据传输和存储
- **网络安全**：保护网络通信
- **应用安全**：保护应用程序
- **运维安全**：保护系统运维

### 访问控制

#### 角色基础访问控制 (RBAC)

##### 角色定义
```sql
-- 创建角色表
CREATE TABLE IF NOT EXISTS roles (
    role_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_name varchar(64) NOT NULL UNIQUE,
    role_description text,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 创建权限表
CREATE TABLE IF NOT EXISTS permissions (
    permission_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    permission_name varchar(64) NOT NULL UNIQUE,
    permission_description text,
    resource_type varchar(32) NOT NULL,
    resource_name varchar(64) NOT NULL,
    action varchar(32) NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 创建角色权限关联表
CREATE TABLE IF NOT EXISTS role_permissions (
    role_permission_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_id uuid NOT NULL REFERENCES roles(role_id),
    permission_id uuid NOT NULL REFERENCES permissions(permission_id),
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE(role_id, permission_id)
);

-- 创建用户角色关联表
CREATE TABLE IF NOT EXISTS user_roles (
    user_role_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL,
    role_id uuid NOT NULL REFERENCES roles(role_id),
    assigned_by uuid,
    assigned_at timestamptz NOT NULL DEFAULT now(),
    expires_at timestamptz,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE(user_id, role_id)
);
```

##### 预定义角色
```sql
-- 插入预定义角色
INSERT INTO roles (role_name, role_description) VALUES
    ('mes_admin', 'MES系统管理员，拥有所有权限'),
    ('mes_operator', 'MES操作员，可以操作生产相关功能'),
    ('mes_viewer', 'MES查看者，只能查看数据'),
    ('mes_maintenance', 'MES维护员，可以维护设备信息'),
    ('mes_quality', 'MES质量员，可以管理质量相关数据'),
    ('mes_planner', 'MES计划员，可以制定生产计划');

-- 插入预定义权限
INSERT INTO permissions (permission_name, permission_description, resource_type, resource_name, action) VALUES
    -- 工厂管理权限
    ('plants.create', '创建工厂', 'table', 'plants', 'CREATE'),
    ('plants.read', '查看工厂', 'table', 'plants', 'READ'),
    ('plants.update', '更新工厂', 'table', 'plants', 'UPDATE'),
    ('plants.delete', '删除工厂', 'table', 'plants', 'DELETE'),
    
    -- 工作中心管理权限
    ('work_centers.create', '创建工作中心', 'table', 'work_centers', 'CREATE'),
    ('work_centers.read', '查看工作中心', 'table', 'work_centers', 'READ'),
    ('work_centers.update', '更新工作中心', 'table', 'work_centers', 'UPDATE'),
    ('work_centers.delete', '删除工作中心', 'table', 'work_centers', 'DELETE'),
    
    -- 设备管理权限
    ('equipment.create', '创建设备', 'table', 'equipment', 'CREATE'),
    ('equipment.read', '查看设备', 'table', 'equipment', 'READ'),
    ('equipment.update', '更新设备', 'table', 'equipment', 'UPDATE'),
    ('equipment.delete', '删除设备', 'table', 'equipment', 'DELETE'),
    
    -- 库存管理权限
    ('inventory.create', '创建库存', 'table', 'inventory', 'CREATE'),
    ('inventory.read', '查看库存', 'table', 'inventory', 'READ'),
    ('inventory.update', '更新库存', 'table', 'inventory', 'UPDATE'),
    ('inventory.delete', '删除库存', 'table', 'inventory', 'DELETE'),
    
    -- 系统管理权限
    ('system.admin', '系统管理', 'system', 'admin', 'ALL'),
    ('system.audit', '审计日志', 'system', 'audit', 'READ');

-- 分配角色权限
-- 管理员角色
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM roles r, permissions p
WHERE r.role_name = 'mes_admin';

-- 操作员角色
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM roles r, permissions p
WHERE r.role_name = 'mes_operator'
  AND p.action IN ('READ', 'UPDATE');

-- 查看者角色
INSERT INTO role_permissions (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM roles r, permissions p
WHERE r.role_name = 'mes_viewer'
  AND p.action = 'READ';
```

#### 数据库用户管理

##### 数据库用户创建
```sql
-- 创建数据库用户
CREATE USER mes_admin WITH PASSWORD 'secure_admin_password';
CREATE USER mes_operator WITH PASSWORD 'secure_operator_password';
CREATE USER mes_viewer WITH PASSWORD 'secure_viewer_password';
CREATE USER mes_maintenance WITH PASSWORD 'secure_maintenance_password';
CREATE USER mes_quality WITH PASSWORD 'secure_quality_password';
CREATE USER mes_planner WITH PASSWORD 'secure_planner_password';

-- 创建只读用户
CREATE USER mes_readonly WITH PASSWORD 'secure_readonly_password';

-- 创建应用用户
CREATE USER mes_app WITH PASSWORD 'secure_app_password';
```

##### 数据库权限分配
```sql
-- 管理员权限
GRANT ALL PRIVILEGES ON SCHEMA mes_core TO mes_admin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA mes_core TO mes_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA mes_core TO mes_admin;

-- 操作员权限
GRANT USAGE ON SCHEMA mes_core TO mes_operator;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA mes_core TO mes_operator;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA mes_core TO mes_operator;

-- 查看者权限
GRANT USAGE ON SCHEMA mes_core TO mes_viewer;
GRANT SELECT ON ALL TABLES IN SCHEMA mes_core TO mes_viewer;

-- 维护员权限
GRANT USAGE ON SCHEMA mes_core TO mes_maintenance;
GRANT SELECT, INSERT, UPDATE ON equipment, sensors TO mes_maintenance;
GRANT SELECT ON workstations, work_centers, plants TO mes_maintenance;

-- 质量员权限
GRANT USAGE ON SCHEMA mes_core TO mes_quality;
GRANT SELECT, INSERT, UPDATE ON quality_codes, lots TO mes_quality;
GRANT SELECT ON materials, inventory TO mes_quality;

-- 计划员权限
GRANT USAGE ON SCHEMA mes_core TO mes_planner;
GRANT SELECT, INSERT, UPDATE ON materials, inventory, locations TO mes_planner;
GRANT SELECT ON plants, work_centers, workstations TO mes_planner;

-- 只读权限
GRANT USAGE ON SCHEMA mes_core TO mes_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA mes_core TO mes_readonly;

-- 应用权限
GRANT USAGE ON SCHEMA mes_core TO mes_app;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA mes_core TO mes_app;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA mes_core TO mes_app;
```

### 数据加密

#### 传输加密

##### SSL/TLS配置
```ini
# PostgreSQL SSL配置
ssl = on
ssl_cert_file = '/etc/ssl/certs/postgresql.crt'
ssl_key_file = '/etc/ssl/private/postgresql.key'
ssl_ca_file = '/etc/ssl/certs/ca.crt'
ssl_ciphers = 'HIGH:MEDIUM:+3DES:!aNULL'
ssl_prefer_server_ciphers = on
ssl_min_protocol_version = 'TLSv1.2'
ssl_max_protocol_version = 'TLSv1.3'
```

##### 应用层加密
```python
# 应用层加密配置
import ssl
import certifi

# SSL上下文配置
ssl_context = ssl.create_default_context(cafile=certifi.where())
ssl_context.check_hostname = True
ssl_context.verify_mode = ssl.CERT_REQUIRED

# 数据库连接配置
DATABASE_CONFIG = {
    'host': 'prod-db.example.com',
    'port': 5432,
    'database': 'mes_core',
    'user': 'mes_app',
    'password': 'secure_app_password',
    'sslmode': 'require',
    'sslcontext': ssl_context
}
```

#### 存储加密

##### 数据库加密
```sql
-- 启用透明数据加密
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 创建加密函数
CREATE OR REPLACE FUNCTION encrypt_sensitive_data(data text, key text)
RETURNS text AS $$
BEGIN
    RETURN encode(pgp_sym_encrypt(data, key), 'base64');
END;
$$ LANGUAGE plpgsql;

-- 创建解密函数
CREATE OR REPLACE FUNCTION decrypt_sensitive_data(encrypted_data text, key text)
RETURNS text AS $$
BEGIN
    RETURN pgp_sym_decrypt(decode(encrypted_data, 'base64'), key);
END;
$$ LANGUAGE plpgsql;

-- 加密敏感数据列
ALTER TABLE employees ADD COLUMN phone_encrypted text;
ALTER TABLE employees ADD COLUMN email_encrypted text;

-- 更新加密数据
UPDATE employees 
SET phone_encrypted = encrypt_sensitive_data(phone, 'encryption_key'),
    email_encrypted = encrypt_sensitive_data(email, 'encryption_key')
WHERE phone IS NOT NULL OR email IS NOT NULL;

-- 删除明文数据
ALTER TABLE employees DROP COLUMN phone;
ALTER TABLE employees DROP COLUMN email;
```

##### 应用层加密
```python
# 应用层加密工具
from cryptography.fernet import Fernet
import base64
import os

class DataEncryption:
    def __init__(self, key=None):
        if key is None:
            key = os.environ.get('ENCRYPTION_KEY')
        if key is None:
            key = Fernet.generate_key()
        self.cipher = Fernet(key)
    
    def encrypt(self, data: str) -> str:
        """加密数据"""
        if data is None:
            return None
        encrypted_data = self.cipher.encrypt(data.encode())
        return base64.b64encode(encrypted_data).decode()
    
    def decrypt(self, encrypted_data: str) -> str:
        """解密数据"""
        if encrypted_data is None:
            return None
        encrypted_bytes = base64.b64decode(encrypted_data.encode())
        decrypted_data = self.cipher.decrypt(encrypted_bytes)
        return decrypted_data.decode()

# 使用示例
encryption = DataEncryption()

# 加密敏感数据
sensitive_data = "123-456-7890"
encrypted = encryption.encrypt(sensitive_data)

# 解密数据
decrypted = encryption.decrypt(encrypted)
```

### 审计日志

#### 审计表设计
```sql
-- 创建审计日志表
CREATE TABLE IF NOT EXISTS audit_logs (
    audit_log_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name varchar(64) NOT NULL,
    record_id uuid NOT NULL,
    operation_type varchar(16) NOT NULL, -- INSERT, UPDATE, DELETE
    old_values jsonb,
    new_values jsonb,
    changed_fields text[],
    user_id uuid,
    user_name varchar(128),
    session_id varchar(128),
    ip_address inet,
    user_agent text,
    operation_timestamp timestamptz NOT NULL DEFAULT now(),
    created_at timestamptz NOT NULL DEFAULT now()
);

-- 创建审计日志索引
CREATE INDEX idx_audit_logs_table_name ON audit_logs (table_name);
CREATE INDEX idx_audit_logs_record_id ON audit_logs (record_id);
CREATE INDEX idx_audit_logs_operation_type ON audit_logs (operation_type);
CREATE INDEX idx_audit_logs_user_id ON audit_logs (user_id);
CREATE INDEX idx_audit_logs_timestamp ON audit_logs (operation_timestamp);

-- 创建审计日志分区（按月分区）
-- 审计日志表创建
CREATE TABLE audit_logs (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    tenant_id VARCHAR(32) NOT NULL,
    user_id VARCHAR(32) NOT NULL,
    operation_type VARCHAR(32) NOT NULL,
    table_name VARCHAR(64),
    record_id VARCHAR(32),
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_user (tenant_id, user_id),
    INDEX idx_operation_type (operation_type),
    INDEX idx_table_record (table_name, record_id),
    INDEX idx_created_at (created_at)
);
```

#### 审计触发器
```sql
-- 创建审计触发器函数
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS trigger AS $$
DECLARE
    old_record jsonb;
    new_record jsonb;
    changed_fields text[];
    field_name text;
BEGIN
    -- 获取变更字段
    IF TG_OP = 'INSERT' THEN
        new_record = to_jsonb(NEW);
        old_record = NULL;
        changed_fields = array(SELECT key FROM jsonb_each(new_record));
    ELSIF TG_OP = 'UPDATE' THEN
        old_record = to_jsonb(OLD);
        new_record = to_jsonb(NEW);
        changed_fields = array();
        FOR field_name IN SELECT key FROM jsonb_each(new_record) LOOP
            IF old_record->field_name IS DISTINCT FROM new_record->field_name THEN
                changed_fields = array_append(changed_fields, field_name);
            END IF;
        END LOOP;
    ELSIF TG_OP = 'DELETE' THEN
        old_record = to_jsonb(OLD);
        new_record = NULL;
        changed_fields = array(SELECT key FROM jsonb_each(old_record));
    END IF;
    
    -- 插入审计记录
    INSERT INTO audit_logs (
        table_name,
        record_id,
        operation_type,
        old_values,
        new_values,
        changed_fields,
        user_id,
        user_name,
        session_id,
        ip_address,
        user_agent
    ) VALUES (
        TG_TABLE_NAME,
        COALESCE(NEW.id, OLD.id),
        TG_OP,
        old_record,
        new_record,
        changed_fields,
        current_setting('app.user_id', true)::uuid,
        current_setting('app.user_name', true),
        current_setting('app.session_id', true),
        inet_client_addr(),
        current_setting('app.user_agent', true)
    );
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- 为关键表创建审计触发器
CREATE TRIGGER audit_plants_trigger
    AFTER INSERT OR UPDATE OR DELETE ON plants
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_work_centers_trigger
    AFTER INSERT OR UPDATE OR DELETE ON work_centers
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_equipment_trigger
    AFTER INSERT OR UPDATE OR DELETE ON equipment
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_inventory_trigger
    AFTER INSERT OR UPDATE OR DELETE ON inventory
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();
```

#### 审计查询
```sql
-- 审计查询示例
-- 查询特定表的操作记录
SELECT 
    table_name,
    operation_type,
    user_name,
    operation_timestamp,
    changed_fields
FROM audit_logs
WHERE table_name = 'equipment'
  AND operation_timestamp >= '2025-01-01'
ORDER BY operation_timestamp DESC;

-- 查询特定用户的操作记录
SELECT 
    table_name,
    operation_type,
    operation_timestamp,
    changed_fields
FROM audit_logs
WHERE user_id = '01HZQ8K9M2N3P4Q5R6S7T8U9V'
  AND operation_timestamp >= '2025-01-01'
ORDER BY operation_timestamp DESC;

-- 查询敏感数据变更
SELECT 
    table_name,
    record_id,
    operation_type,
    old_values,
    new_values,
    user_name,
    operation_timestamp
FROM audit_logs
WHERE table_name IN ('employees', 'users')
  AND operation_timestamp >= '2025-01-01'
ORDER BY operation_timestamp DESC;
```

## 合规要求

### 数据保护法规

#### GDPR合规

##### 数据分类
```sql
-- 创建数据分类表
CREATE TABLE IF NOT EXISTS data_classification (
    classification_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name varchar(64) NOT NULL,
    column_name varchar(64) NOT NULL,
    data_type varchar(32) NOT NULL, -- PERSONAL, SENSITIVE, PUBLIC
    retention_period integer, -- 保留期限（天）
    anonymization_required boolean NOT NULL DEFAULT false,
    encryption_required boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE(table_name, column_name)
);

-- 插入数据分类
INSERT INTO data_classification (table_name, column_name, data_type, retention_period, anonymization_required, encryption_required) VALUES
    ('employees', 'name', 'PERSONAL', 2555, false, true),
    ('employees', 'phone', 'SENSITIVE', 2555, true, true),
    ('employees', 'email', 'SENSITIVE', 2555, true, true),
    ('employees', 'code', 'PUBLIC', NULL, false, false),
    ('equipment', 'serial_no', 'SENSITIVE', 3650, false, true),
    ('equipment', 'name', 'PUBLIC', NULL, false, false);
```

##### 数据主体权利
```sql
-- 创建数据主体权利表
CREATE TABLE IF NOT EXISTS data_subject_rights (
    right_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    subject_id varchar(128) NOT NULL,
    right_type varchar(32) NOT NULL, -- ACCESS, RECTIFICATION, ERASURE, PORTABILITY
    request_date timestamptz NOT NULL DEFAULT now(),
    status varchar(32) NOT NULL DEFAULT 'PENDING', -- PENDING, PROCESSING, COMPLETED, REJECTED
    processed_by uuid,
    processed_date timestamptz,
    response_data jsonb,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 创建数据主体权利索引
CREATE INDEX idx_data_subject_rights_subject_id ON data_subject_rights (subject_id);
CREATE INDEX idx_data_subject_rights_status ON data_subject_rights (status);
CREATE INDEX idx_data_subject_rights_request_date ON data_subject_rights (request_date);
```

##### 数据处理记录
```sql
-- 创建数据处理记录表
CREATE TABLE IF NOT EXISTS data_processing_records (
    processing_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    processing_purpose varchar(128) NOT NULL,
    data_categories text[] NOT NULL,
    data_subjects text[] NOT NULL,
    legal_basis varchar(64) NOT NULL,
    retention_period integer,
    data_sharing boolean NOT NULL DEFAULT false,
    data_sharing_parties text[],
    security_measures text[],
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 插入数据处理记录
INSERT INTO data_processing_records (
    processing_purpose,
    data_categories,
    data_subjects,
    legal_basis,
    retention_period,
    data_sharing,
    security_measures
) VALUES (
    '员工管理',
    ARRAY['员工基本信息', '联系方式'],
    ARRAY['员工'],
    'CONTRACT',
    2555,
    false,
    ARRAY['加密存储', '访问控制', '审计日志']
);
```

#### 数据本地化

##### 数据存储位置
```sql
-- 创建数据存储位置表
CREATE TABLE IF NOT EXISTS data_storage_locations (
    location_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name varchar(64) NOT NULL,
    region varchar(64) NOT NULL,
    country varchar(64) NOT NULL,
    data_center varchar(128) NOT NULL,
    is_primary boolean NOT NULL DEFAULT true,
    is_backup boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 插入数据存储位置
INSERT INTO data_storage_locations (table_name, region, country, data_center, is_primary, is_backup) VALUES
    ('employees', 'Asia-Pacific', 'China', 'Shanghai Data Center', true, false),
    ('employees', 'Asia-Pacific', 'China', 'Beijing Data Center', false, true),
    ('equipment', 'Asia-Pacific', 'China', 'Shanghai Data Center', true, false),
    ('inventory', 'Asia-Pacific', 'China', 'Shanghai Data Center', true, false);
```

### 行业标准

#### ISO 27001

##### 信息安全政策
```sql
-- 创建信息安全政策表
CREATE TABLE IF NOT EXISTS security_policies (
    policy_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    policy_name varchar(128) NOT NULL,
    policy_version varchar(16) NOT NULL,
    policy_content text NOT NULL,
    effective_date date NOT NULL,
    review_date date,
    approved_by varchar(128),
    approved_date date,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 插入信息安全政策
INSERT INTO security_policies (policy_name, policy_version, policy_content, effective_date, approved_by, approved_date) VALUES
    ('数据分类政策', 'v1.0', '定义数据分类标准和保护措施', '2025-01-01', '安全管理员', '2024-12-15'),
    ('访问控制政策', 'v1.0', '定义用户访问控制原则和流程', '2025-01-01', '安全管理员', '2024-12-15'),
    ('数据加密政策', 'v1.0', '定义数据加密要求和标准', '2025-01-01', '安全管理员', '2024-12-15');
```

##### 安全风险评估
```sql
-- 创建安全风险评估表
CREATE TABLE IF NOT EXISTS security_risk_assessments (
    assessment_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    risk_name varchar(128) NOT NULL,
    risk_category varchar(64) NOT NULL,
    risk_level varchar(16) NOT NULL, -- LOW, MEDIUM, HIGH, CRITICAL
    risk_description text NOT NULL,
    impact_description text NOT NULL,
    likelihood varchar(16) NOT NULL,
    impact varchar(16) NOT NULL,
    mitigation_measures text[],
    residual_risk varchar(16),
    assessment_date date NOT NULL,
    assessor varchar(128) NOT NULL,
    next_review_date date,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 插入安全风险评估
INSERT INTO security_risk_assessments (
    risk_name,
    risk_category,
    risk_level,
    risk_description,
    impact_description,
    likelihood,
    impact,
    mitigation_measures,
    residual_risk,
    assessment_date,
    assessor,
    next_review_date
) VALUES (
    '数据泄露风险',
    '数据安全',
    'HIGH',
    '敏感数据可能被未授权访问',
    '导致数据泄露，影响业务和声誉',
    'MEDIUM',
    'HIGH',
    ARRAY['数据加密', '访问控制', '监控告警'],
    'LOW',
    '2025-01-01',
    '安全管理员',
    '2025-07-01'
);
```

## 安全监控

### 安全事件监控

#### 安全事件表
```sql
-- 创建安全事件表
CREATE TABLE IF NOT EXISTS security_events (
    event_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_type varchar(64) NOT NULL,
    event_severity varchar(16) NOT NULL, -- LOW, MEDIUM, HIGH, CRITICAL
    event_description text NOT NULL,
    source_ip inet,
    user_id uuid,
    user_name varchar(128),
    session_id varchar(128),
    affected_resource varchar(128),
    event_data jsonb,
    status varchar(16) NOT NULL DEFAULT 'OPEN', -- OPEN, INVESTIGATING, RESOLVED, CLOSED
    assigned_to varchar(128),
    resolution_notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 创建安全事件索引
CREATE INDEX idx_security_events_type ON security_events (event_type);
CREATE INDEX idx_security_events_severity ON security_events (event_severity);
CREATE INDEX idx_security_events_status ON security_events (status);
CREATE INDEX idx_security_events_created_at ON security_events (created_at);
CREATE INDEX idx_security_events_user_id ON security_events (user_id);
```

#### 安全事件检测
```sql
-- 创建安全事件检测函数
CREATE OR REPLACE FUNCTION detect_security_events()
RETURNS void AS $$
BEGIN
    -- 检测异常登录
    INSERT INTO security_events (event_type, event_severity, event_description, source_ip, user_name, created_at)
    SELECT 
        'ABNORMAL_LOGIN',
        'HIGH',
        '异常登录检测',
        source_ip,
        user_name,
        now()
    FROM login_attempts
    WHERE login_time >= now() - INTERVAL '1 hour'
      AND success = false
      AND attempt_count > 5;
    
    -- 检测权限提升
    INSERT INTO security_events (event_type, event_severity, event_description, user_name, affected_resource, created_at)
    SELECT 
        'PRIVILEGE_ESCALATION',
        'CRITICAL',
        '权限提升检测',
        user_name,
        'role_permissions',
        now()
    FROM audit_logs
    WHERE table_name = 'user_roles'
      AND operation_type = 'INSERT'
      AND operation_timestamp >= now() - INTERVAL '1 hour';
    
    -- 检测数据异常访问
    INSERT INTO security_events (event_type, event_severity, event_description, user_name, affected_resource, created_at)
    SELECT 
        'DATA_ANOMALY_ACCESS',
        'MEDIUM',
        '数据异常访问检测',
        user_name,
        table_name,
        now()
    FROM audit_logs
    WHERE operation_type = 'SELECT'
      AND operation_timestamp >= now() - INTERVAL '1 hour'
      AND table_name IN ('employees', 'audit_logs')
    GROUP BY user_name, table_name
    HAVING COUNT(*) > 100;
END;
$$ LANGUAGE plpgsql;

-- 创建定时任务
SELECT cron.schedule('security-event-detection', '*/5 * * * *', 'SELECT detect_security_events();');
```

### 安全告警

#### 告警配置
```yaml
# monitoring/security-alerts.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: security-alerts
spec:
  groups:
  - name: security
    rules:
    - alert: SecurityEventHigh
      expr: security_events_count{severity="HIGH"} > 0
      for: 0m
      labels:
        severity: warning
      annotations:
        summary: "High severity security event detected"
        description: "Security event: {{ $labels.event_type }}"
    
    - alert: SecurityEventCritical
      expr: security_events_count{severity="CRITICAL"} > 0
      for: 0m
      labels:
        severity: critical
      annotations:
        summary: "Critical security event detected"
        description: "Security event: {{ $labels.event_type }}"
    
    - alert: AbnormalLoginAttempts
      expr: failed_login_attempts > 10
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Abnormal login attempts detected"
        description: "User {{ $labels.user }} has {{ $value }} failed login attempts"
    
    - alert: PrivilegeEscalation
      expr: privilege_escalation_events > 0
      for: 0m
      labels:
        severity: critical
      annotations:
        summary: "Privilege escalation detected"
        description: "User {{ $labels.user }} attempted privilege escalation"
    
    - alert: DataAnomalyAccess
      expr: data_anomaly_access_events > 0
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Data anomaly access detected"
        description: "User {{ $labels.user }} accessed {{ $labels.resource }} {{ $value }} times"
```

## 安全运维

### 安全配置管理

#### 安全配置检查
```bash
#!/bin/bash
# security-config-check.sh

echo "开始安全配置检查..."

# 检查数据库SSL配置
echo "检查数据库SSL配置..."
psql -h localhost -U mes_admin -d mes_core -c "SHOW ssl;"

# 检查用户权限
echo "检查用户权限..."
psql -h localhost -U mes_admin -d mes_core -c "
SELECT 
    usename,
    usesuper,
    usecreatedb,
    usebypassrls
FROM pg_user
WHERE usename LIKE 'mes_%';
"

# 检查审计日志
echo "检查审计日志..."
psql -h localhost -U mes_admin -d mes_core -c "
SELECT 
    COUNT(*) as audit_log_count,
    MIN(operation_timestamp) as earliest_log,
    MAX(operation_timestamp) as latest_log
FROM audit_logs
WHERE operation_timestamp >= CURRENT_DATE;
"

# 检查安全事件
echo "检查安全事件..."
psql -h localhost -U mes_admin -d mes_core -c "
SELECT 
    event_type,
    event_severity,
    COUNT(*) as event_count
FROM security_events
WHERE created_at >= CURRENT_DATE
GROUP BY event_type, event_severity
ORDER BY event_count DESC;
"

echo "安全配置检查完成！"
```

### 安全培训

#### 安全培训记录
```sql
-- 创建安全培训记录表
CREATE TABLE IF NOT EXISTS security_training_records (
    training_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL,
    user_name varchar(128) NOT NULL,
    training_type varchar(64) NOT NULL,
    training_title varchar(128) NOT NULL,
    training_date date NOT NULL,
    completion_date date,
    score decimal(5,2),
    status varchar(16) NOT NULL DEFAULT 'PENDING', -- PENDING, IN_PROGRESS, COMPLETED, FAILED
    certificate_id varchar(128),
    next_training_date date,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 创建安全培训记录索引
CREATE INDEX idx_security_training_user_id ON security_training_records (user_id);
CREATE INDEX idx_security_training_status ON security_training_records (status);
CREATE INDEX idx_security_training_date ON security_training_records (training_date);
```

### 安全审计

#### 安全审计计划
```sql
-- 创建安全审计计划表
CREATE TABLE IF NOT EXISTS security_audit_plans (
    audit_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    audit_name varchar(128) NOT NULL,
    audit_type varchar(64) NOT NULL,
    audit_scope text NOT NULL,
    audit_frequency varchar(32) NOT NULL,
    last_audit_date date,
    next_audit_date date,
    auditor varchar(128),
    status varchar(16) NOT NULL DEFAULT 'PLANNED', -- PLANNED, IN_PROGRESS, COMPLETED, CANCELLED
    findings text[],
    recommendations text[],
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 插入安全审计计划
INSERT INTO security_audit_plans (
    audit_name,
    audit_type,
    audit_scope,
    audit_frequency,
    next_audit_date,
    auditor
) VALUES (
    '数据库安全审计',
    '技术审计',
    '数据库访问控制、数据加密、审计日志',
    'QUARTERLY',
    '2025-04-01',
    '内部审计员'
),
(
    '用户权限审计',
    '管理审计',
    '用户角色、权限分配、访问控制',
    'MONTHLY',
    '2025-02-01',
    '安全管理员'
),
(
    '数据保护合规审计',
    '合规审计',
    '数据分类、数据保护、合规要求',
    'ANNUALLY',
    '2025-12-01',
    '外部审计员'
);
```

## 应急响应

### 安全事件响应

#### 应急响应计划
```sql
-- 创建应急响应计划表
CREATE TABLE IF NOT EXISTS incident_response_plans (
    plan_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    plan_name varchar(128) NOT NULL,
    incident_type varchar(64) NOT NULL,
    severity_level varchar(16) NOT NULL,
    response_steps text[] NOT NULL,
    escalation_procedures text[] NOT NULL,
    communication_plan text[] NOT NULL,
    recovery_procedures text[] NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 插入应急响应计划
INSERT INTO incident_response_plans (
    plan_name,
    incident_type,
    severity_level,
    response_steps,
    escalation_procedures,
    communication_plan,
    recovery_procedures
) VALUES (
    '数据泄露应急响应计划',
    'DATA_BREACH',
    'CRITICAL',
    ARRAY[
        '立即隔离受影响的系统',
        '评估数据泄露范围',
        '通知相关人员和部门',
        '启动应急响应团队',
        '收集证据和日志'
    ],
    ARRAY[
        '通知安全管理员',
        '通知IT部门负责人',
        '通知高级管理层',
        '通知法律部门',
        '通知监管机构'
    ],
    ARRAY[
        '内部通知：安全团队',
        '内部通知：IT团队',
        '内部通知：管理层',
        '外部通知：监管机构',
        '外部通知：客户（如需要）'
    ],
    ARRAY[
        '修复安全漏洞',
        '恢复系统功能',
        '加强安全措施',
        '更新安全策略',
        '进行安全培训'
    ]
);
```

### 灾难恢复

#### 灾难恢复计划
```sql
-- 创建灾难恢复计划表
CREATE TABLE IF NOT EXISTS disaster_recovery_plans (
    plan_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    plan_name varchar(128) NOT NULL,
    disaster_type varchar(64) NOT NULL,
    rto_hours integer NOT NULL, -- 恢复时间目标
    rpo_hours integer NOT NULL, -- 恢复点目标
    recovery_procedures text[] NOT NULL,
    backup_strategy text NOT NULL,
    testing_schedule varchar(64) NOT NULL,
    last_test_date date,
    next_test_date date,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 插入灾难恢复计划
INSERT INTO disaster_recovery_plans (
    plan_name,
    disaster_type,
    rto_hours,
    rpo_hours,
    recovery_procedures,
    backup_strategy,
    testing_schedule,
    next_test_date
) VALUES (
    '数据库灾难恢复计划',
    'DATABASE_FAILURE',
    4,
    1,
    ARRAY[
        '评估灾难影响',
        '启动备用数据库',
        '恢复数据备份',
        '验证数据完整性',
        '切换应用程序',
        '监控系统状态'
    ],
    '每日全量备份，每小时增量备份，异地存储',
    'QUARTERLY',
    '2025-04-01'
);
```

## 安全最佳实践

### 开发安全

#### 安全编码规范
1. **输入验证**：验证所有用户输入
2. **输出编码**：对输出数据进行编码
3. **SQL注入防护**：使用参数化查询
4. **错误处理**：不暴露敏感信息
5. **日志记录**：记录安全相关事件

#### 安全测试
1. **静态代码分析**：使用工具检查代码安全问题
2. **动态安全测试**：测试运行时的安全问题
3. **渗透测试**：模拟攻击测试系统安全性
4. **漏洞扫描**：定期扫描系统漏洞

### 运维安全

#### 安全运维规范
1. **最小权限原则**：运维人员只获得必要权限
2. **操作审计**：记录所有运维操作
3. **安全更新**：及时安装安全补丁
4. **监控告警**：实时监控安全事件
5. **应急响应**：建立应急响应机制

#### 安全工具
1. **漏洞扫描工具**：Nessus、OpenVAS
2. **安全监控工具**：SIEM、日志分析
3. **加密工具**：OpenSSL、GPG
4. **访问控制工具**：LDAP、Active Directory
5. **审计工具**：数据库审计、应用审计
