# 数据质量

## 概述

本文档描述了MES系统的数据质量保障机制，包括数据质量测试、监控指标、质量规则和自动化验证流程。确保系统数据的准确性、完整性、一致性和及时性。

## 数据质量框架

### 质量维度

#### 准确性 (Accuracy)
- **定义**：数据是否正确反映了真实世界的状态
- **指标**：错误率、偏差率
- **测试**：范围检查、格式验证、业务规则验证

#### 完整性 (Completeness)
- **定义**：数据是否完整，没有缺失值
- **指标**：缺失率、空值率
- **测试**：必填字段检查、外键完整性检查

#### 一致性 (Consistency)
- **定义**：数据在不同位置是否保持一致
- **指标**：不一致率、冲突率
- **测试**：跨表一致性检查、重复数据检查

#### 及时性 (Timeliness)
- **定义**：数据是否在预期时间内更新
- **指标**：延迟时间、更新频率
- **测试**：时间戳检查、更新频率监控

#### 有效性 (Validity)
- **定义**：数据是否符合预定义的格式和规则
- **指标**：无效率、格式错误率
- **测试**：格式验证、枚举值检查

#### 唯一性 (Uniqueness)
- **定义**：数据是否唯一，没有重复
- **指标**：重复率、唯一性违反率
- **测试**：唯一约束检查、重复记录检查

## 数据质量测试框架

### dbt配置

#### 项目配置
```yaml
# dbt_project.yml
name: 'mes_data_quality'
version: '1.0.0'
config-version: 2

profile: 'mes_core'

model-paths: ["models"]
analysis-paths: ["analysis"]
test-paths: ["tests"]
seed-paths: ["seeds"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]

target-path: "target"
clean-targets:
  - "target"
  - "dbt_packages"

models:
  mes_data_quality:
    +materialized: table
    +schema: dq_results
    staging:
      +materialized: view
    marts:
      +materialized: table

tests:
  mes_data_quality:
    +store_failures: true
    +schema: dq_failures

seeds:
  mes_data_quality:
    +schema: dq_seeds

vars:
  # 数据质量阈值
  accuracy_threshold: 0.95
  completeness_threshold: 0.98
  consistency_threshold: 0.99
  timeliness_threshold: 300  # 5分钟
  validity_threshold: 0.99
  uniqueness_threshold: 1.0
```

#### 配置文件
```yaml
# profiles.yml
mes_core:
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      user: mes_user
      password: password
      port: 5432
      dbname: mes_core
      schema: mes_core
      threads: 4
      keepalives_idle: 0
      connect_timeout: 10
      retries: 1
    test:
      type: postgres
      host: test-db
      user: mes_test_user
      password: test_password
      port: 5432
      dbname: mes_core
      schema: mes_core
      threads: 4
      keepalives_idle: 0
      connect_timeout: 10
      retries: 1
    prod:
      type: postgres
      host: prod-db
      user: mes_prod_user
      password: prod_password
      port: 5432
      dbname: mes_core
      schema: mes_core
      threads: 4
      keepalives_idle: 0
      connect_timeout: 10
      retries: 1
```

### 数据质量测试

#### 基础测试

##### 唯一性测试
```yaml
# tests/schema.yml
version: 2

models:
  - name: plants
    description: "工厂信息表"
    tests:
      - unique:
          column_name: plant_id
      - unique:
          column_name: code
      - not_null:
          column_name: plant_id
      - not_null:
          column_name: code
      - not_null:
          column_name: name
      - not_null:
          column_name: timezone
      - not_null:
          column_name: created_at
      - not_null:
          column_name: updated_at
    columns:
      - name: plant_id
        description: "工厂唯一标识"
        tests:
          - unique
          - not_null
      - name: code
        description: "工厂编码"
        tests:
          - unique
          - not_null
          - dq_format_check:
              regex: '^[A-Z0-9_]+$'
      - name: name
        description: "工厂名称"
        tests:
          - not_null
          - dq_length_check:
              min_length: 1
              max_length: 128
      - name: timezone
        description: "时区信息"
        tests:
          - not_null
          - dq_timezone_check
      - name: created_at
        description: "创建时间"
        tests:
          - not_null
          - dq_timestamp_check
      - name: updated_at
        description: "更新时间"
        tests:
          - not_null
          - dq_timestamp_check
          - dq_timestamp_order:
              reference_column: created_at

  - name: work_centers
    description: "工作中心信息表"
    tests:
      - unique:
          column_name: work_center_id
      - unique:
          column_name: [plant_id, code]
      - not_null:
          column_name: work_center_id
      - not_null:
          column_name: plant_id
      - not_null:
          column_name: code
      - not_null:
          column_name: name
      - not_null:
          column_name: created_at
      - not_null:
          column_name: updated_at
      - dq_foreign_key:
          column_name: plant_id
          referenced_table: plants
          referenced_column: plant_id
    columns:
      - name: work_center_id
        description: "工作中心唯一标识"
        tests:
          - unique
          - not_null
      - name: plant_id
        description: "所属工厂标识"
        tests:
          - not_null
          - dq_foreign_key:
              referenced_table: plants
              referenced_column: plant_id
      - name: code
        description: "工作中心编码"
        tests:
          - not_null
          - dq_format_check:
              regex: '^[A-Z0-9_]+$'
      - name: name
        description: "工作中心名称"
        tests:
          - not_null
          - dq_length_check:
              min_length: 1
              max_length: 128
      - name: created_at
        description: "创建时间"
        tests:
          - not_null
          - dq_timestamp_check
      - name: updated_at
        description: "更新时间"
        tests:
          - not_null
          - dq_timestamp_check
          - dq_timestamp_order:
              reference_column: created_at

  - name: equipment
    description: "设备信息表"
    tests:
      - unique:
          column_name: equipment_id
      - unique:
          column_name: [workstation_id, code]
      - not_null:
          column_name: equipment_id
      - not_null:
          column_name: workstation_id
      - not_null:
          column_name: code
      - not_null:
          column_name: name
      - not_null:
          column_name: created_at
      - not_null:
          column_name: updated_at
      - dq_foreign_key:
          column_name: workstation_id
          referenced_table: workstations
          referenced_column: workstation_id
    columns:
      - name: equipment_id
        description: "设备唯一标识"
        tests:
          - unique
          - not_null
      - name: workstation_id
        description: "所属工位标识"
        tests:
          - not_null
          - dq_foreign_key:
              referenced_table: workstations
              referenced_column: workstation_id
      - name: code
        description: "设备编码"
        tests:
          - not_null
          - dq_format_check:
              regex: '^[A-Z0-9_]+$'
      - name: name
        description: "设备名称"
        tests:
          - not_null
          - dq_length_check:
              min_length: 1
              max_length: 128
      - name: type
        description: "设备类型"
        tests:
          - dq_enum_check:
              allowed_values: ['CNC', 'MILLING', 'TURNING', 'GRINDING', 'TESTING']
      - name: serial_no
        description: "序列号"
        tests:
          - unique
          - dq_format_check:
              regex: '^[A-Z0-9_-]+$'
      - name: created_at
        description: "创建时间"
        tests:
          - not_null
          - dq_timestamp_check
      - name: updated_at
        description: "更新时间"
        tests:
          - not_null
          - dq_timestamp_check
          - dq_timestamp_order:
              reference_column: created_at

  - name: inventory
    description: "库存信息表"
    tests:
      - unique:
          column_name: inventory_id
      - unique:
          column_name: [material_id, location_id, lot_id]
      - not_null:
          column_name: inventory_id
      - not_null:
          column_name: material_id
      - not_null:
          column_name: location_id
      - not_null:
          column_name: qty_on_hand
      - not_null:
          column_name: created_at
      - not_null:
          column_name: updated_at
      - dq_foreign_key:
          column_name: material_id
          referenced_table: materials
          referenced_column: material_id
      - dq_foreign_key:
          column_name: location_id
          referenced_table: locations
          referenced_column: location_id
      - dq_foreign_key:
          column_name: lot_id
          referenced_table: lots
          referenced_column: lot_id
    columns:
      - name: inventory_id
        description: "库存唯一标识"
        tests:
          - unique
          - not_null
      - name: material_id
        description: "物料标识"
        tests:
          - not_null
          - dq_foreign_key:
              referenced_table: materials
              referenced_column: material_id
      - name: location_id
        description: "库位标识"
        tests:
          - not_null
          - dq_foreign_key:
              referenced_table: locations
              referenced_column: location_id
      - name: lot_id
        description: "批次标识"
        tests:
          - dq_foreign_key:
              referenced_table: lots
              referenced_column: lot_id
      - name: qty_on_hand
        description: "在手数量"
        tests:
          - not_null
          - dq_range_check:
              min_value: 0
              max_value: 999999999
      - name: created_at
        description: "创建时间"
        tests:
          - not_null
          - dq_timestamp_check
      - name: updated_at
        description: "更新时间"
        tests:
          - not_null
          - dq_timestamp_check
          - dq_timestamp_order:
              reference_column: created_at
```

#### 自定义测试宏

##### 格式检查宏
```sql
-- macros/dq_format_check.sql
{% test dq_format_check(model, column_name, regex) %}
  SELECT *
  FROM {{ model }}
  WHERE {{ column_name }} !~ '{{ regex }}'
{% endtest %}
```

##### 长度检查宏
```sql
-- macros/dq_length_check.sql
{% test dq_length_check(model, column_name, min_length=1, max_length=255) %}
  SELECT *
  FROM {{ model }}
  WHERE LENGTH({{ column_name }}) < {{ min_length }}
     OR LENGTH({{ column_name }}) > {{ max_length }}
{% endtest %}
```

##### 时区检查宏
```sql
-- macros/dq_timezone_check.sql
{% test dq_timezone_check(model, column_name) %}
  SELECT *
  FROM {{ model }}
  WHERE {{ column_name }} NOT IN (
    'UTC', 'Asia/Shanghai', 'Asia/Tokyo', 'America/New_York',
    'America/Los_Angeles', 'Europe/London', 'Europe/Berlin'
  )
{% endtest %}
```

##### 时间戳检查宏
```sql
-- macros/dq_timestamp_check.sql
{% test dq_timestamp_check(model, column_name) %}
  SELECT *
  FROM {{ model }}
  WHERE {{ column_name }} IS NULL
     OR {{ column_name }} < '2020-01-01'::timestamp
     OR {{ column_name }} > '2030-12-31'::timestamp
{% endtest %}
```

##### 时间戳顺序检查宏
```sql
-- macros/dq_timestamp_order.sql
{% test dq_timestamp_order(model, column_name, reference_column) %}
  SELECT *
  FROM {{ model }}
  WHERE {{ column_name }} < {{ reference_column }}
{% endtest %}
```

##### 外键检查宏
```sql
-- macros/dq_foreign_key.sql
{% test dq_foreign_key(model, column_name, referenced_table, referenced_column) %}
  SELECT *
  FROM {{ model }} m
  LEFT JOIN {{ referenced_table }} r
    ON m.{{ column_name }} = r.{{ referenced_column }}
  WHERE m.{{ column_name }} IS NOT NULL
    AND r.{{ referenced_column }} IS NULL
{% endtest %}
```

##### 枚举值检查宏
```sql
-- macros/dq_enum_check.sql
{% test dq_enum_check(model, column_name, allowed_values) %}
  SELECT *
  FROM {{ model }}
  WHERE {{ column_name }} IS NOT NULL
    AND {{ column_name }} NOT IN (
      {% for value in allowed_values %}
        '{{ value }}'{% if not loop.last %},{% endif %}
      {% endfor %}
    )
{% endtest %}
```

##### 范围检查宏
```sql
-- macros/dq_range_check.sql
{% test dq_range_check(model, column_name, min_value, max_value) %}
  SELECT *
  FROM {{ model }}
  WHERE {{ column_name }} IS NOT NULL
    AND ({{ column_name }} < {{ min_value }} OR {{ column_name }} > {{ max_value }})
{% endtest %}
```

#### 业务规则测试

##### 设备状态一致性测试
```sql
-- tests/business_rules/equipment_status_consistency.sql
SELECT
  e.equipment_id,
  e.code,
  e.name,
  '设备状态不一致' as issue_type,
  '设备状态与工位状态不一致' as issue_description
FROM equipment e
JOIN workstations w ON e.workstation_id = w.workstation_id
WHERE e.status = 'RUNNING' AND w.status = 'STOPPED'
   OR e.status = 'STOPPED' AND w.status = 'RUNNING'
```

##### 库存数量合理性测试
```sql
-- tests/business_rules/inventory_quantity_reasonableness.sql
SELECT
  i.inventory_id,
  i.material_id,
  i.location_id,
  i.qty_on_hand,
  '库存数量异常' as issue_type,
  '库存数量超出合理范围' as issue_description
FROM inventory i
JOIN materials m ON i.material_id = m.material_id
WHERE i.qty_on_hand < 0
   OR i.qty_on_hand > 1000000
   OR (m.material_type = 'RAW_MATERIAL' AND i.qty_on_hand > 10000)
   OR (m.material_type = 'FINISHED_PRODUCT' AND i.qty_on_hand > 1000)
```

##### 批次有效期检查
```sql
-- tests/business_rules/lot_expiry_check.sql
SELECT
  l.lot_id,
  l.material_id,
  l.code,
  l.mfg_date,
  l.expiry_date,
  '批次有效期异常' as issue_type,
  '批次有效期早于生产日期' as issue_description
FROM lots l
WHERE l.expiry_date IS NOT NULL
  AND l.mfg_date IS NOT NULL
  AND l.expiry_date <= l.mfg_date
```

##### 员工技能有效期检查
```sql
-- tests/business_rules/employee_skill_validity.sql
SELECT
  es.employee_skill_id,
  es.employee_id,
  es.skill_id,
  es.valid_from,
  es.valid_to,
  '员工技能有效期异常' as issue_type,
  '员工技能有效期开始时间晚于结束时间' as issue_description
FROM employee_skills es
WHERE es.valid_from IS NOT NULL
  AND es.valid_to IS NOT NULL
  AND es.valid_from > es.valid_to
```

#### 数据一致性测试

##### 跨表一致性检查
```sql
-- tests/consistency/cross_table_consistency.sql
SELECT
  '工厂-工作中心一致性' as check_type,
  COUNT(*) as violation_count
FROM work_centers wc
LEFT JOIN plants p ON wc.plant_id = p.plant_id
WHERE p.plant_id IS NULL

UNION ALL

SELECT
  '工作中心-工位一致性' as check_type,
  COUNT(*) as violation_count
FROM workstations ws
LEFT JOIN work_centers wc ON ws.work_center_id = wc.work_center_id
WHERE wc.work_center_id IS NULL

UNION ALL

SELECT
  '工位-设备一致性' as check_type,
  COUNT(*) as violation_count
FROM equipment e
LEFT JOIN workstations ws ON e.workstation_id = ws.workstation_id
WHERE ws.workstation_id IS NULL

UNION ALL

SELECT
  '设备-传感器一致性' as check_type,
  COUNT(*) as violation_count
FROM sensors s
LEFT JOIN equipment e ON s.equipment_id = e.equipment_id
WHERE e.equipment_id IS NULL
```

##### 重复数据检查
```sql
-- tests/consistency/duplicate_check.sql
SELECT
  '重复工厂编码' as check_type,
  code,
  COUNT(*) as duplicate_count
FROM plants
GROUP BY code
HAVING COUNT(*) > 1

UNION ALL

SELECT
  '重复工作中心编码' as check_type,
  plant_id || '_' || code as identifier,
  COUNT(*) as duplicate_count
FROM work_centers
GROUP BY plant_id, code
HAVING COUNT(*) > 1

UNION ALL

SELECT
  '重复设备序列号' as check_type,
  serial_no,
  COUNT(*) as duplicate_count
FROM equipment
WHERE serial_no IS NOT NULL
GROUP BY serial_no
HAVING COUNT(*) > 1
```

## 数据质量监控

### 监控指标

#### 质量指标计算
```sql
-- models/quality_metrics.sql
WITH quality_metrics AS (
  SELECT
    'plants' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN plant_id IS NULL THEN 1 END) as null_plant_id,
    COUNT(CASE WHEN code IS NULL THEN 1 END) as null_code,
    COUNT(CASE WHEN name IS NULL THEN 1 END) as null_name,
    COUNT(CASE WHEN timezone IS NULL THEN 1 END) as null_timezone,
    COUNT(CASE WHEN created_at IS NULL THEN 1 END) as null_created_at,
    COUNT(CASE WHEN updated_at IS NULL THEN 1 END) as null_updated_at,
    COUNT(CASE WHEN code !~ '^[A-Z0-9_]+$' THEN 1 END) as invalid_code_format,
    COUNT(CASE WHEN updated_at < created_at THEN 1 END) as invalid_timestamp_order
  FROM plants
  
  UNION ALL
  
  SELECT
    'work_centers' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN work_center_id IS NULL THEN 1 END) as null_work_center_id,
    COUNT(CASE WHEN plant_id IS NULL THEN 1 END) as null_plant_id,
    COUNT(CASE WHEN code IS NULL THEN 1 END) as null_code,
    COUNT(CASE WHEN name IS NULL THEN 1 END) as null_name,
    COUNT(CASE WHEN created_at IS NULL THEN 1 END) as null_created_at,
    COUNT(CASE WHEN updated_at IS NULL THEN 1 END) as null_updated_at,
    COUNT(CASE WHEN code !~ '^[A-Z0-9_]+$' THEN 1 END) as invalid_code_format,
    COUNT(CASE WHEN updated_at < created_at THEN 1 END) as invalid_timestamp_order
  FROM work_centers
  
  UNION ALL
  
  SELECT
    'equipment' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN equipment_id IS NULL THEN 1 END) as null_equipment_id,
    COUNT(CASE WHEN workstation_id IS NULL THEN 1 END) as null_workstation_id,
    COUNT(CASE WHEN code IS NULL THEN 1 END) as null_code,
    COUNT(CASE WHEN name IS NULL THEN 1 END) as null_name,
    COUNT(CASE WHEN created_at IS NULL THEN 1 END) as null_created_at,
    COUNT(CASE WHEN updated_at IS NULL THEN 1 END) as null_updated_at,
    COUNT(CASE WHEN code !~ '^[A-Z0-9_]+$' THEN 1 END) as invalid_code_format,
    COUNT(CASE WHEN updated_at < created_at THEN 1 END) as invalid_timestamp_order
  FROM equipment
  
  UNION ALL
  
  SELECT
    'inventory' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN inventory_id IS NULL THEN 1 END) as null_inventory_id,
    COUNT(CASE WHEN material_id IS NULL THEN 1 END) as null_material_id,
    COUNT(CASE WHEN location_id IS NULL THEN 1 END) as null_location_id,
    COUNT(CASE WHEN qty_on_hand IS NULL THEN 1 END) as null_qty_on_hand,
    COUNT(CASE WHEN created_at IS NULL THEN 1 END) as null_created_at,
    COUNT(CASE WHEN updated_at IS NULL THEN 1 END) as null_updated_at,
    COUNT(CASE WHEN qty_on_hand < 0 THEN 1 END) as negative_quantity,
    COUNT(CASE WHEN updated_at < created_at THEN 1 END) as invalid_timestamp_order
  FROM inventory
)
SELECT
  table_name,
  total_records,
  -- 完整性指标
  ROUND((total_records - null_plant_id)::numeric / total_records * 100, 2) as completeness_plant_id,
  ROUND((total_records - null_code)::numeric / total_records * 100, 2) as completeness_code,
  ROUND((total_records - null_name)::numeric / total_records * 100, 2) as completeness_name,
  -- 有效性指标
  ROUND((total_records - invalid_code_format)::numeric / total_records * 100, 2) as validity_code_format,
  ROUND((total_records - invalid_timestamp_order)::numeric / total_records * 100, 2) as validity_timestamp_order,
  -- 业务规则指标
  ROUND((total_records - negative_quantity)::numeric / total_records * 100, 2) as validity_quantity_range
FROM quality_metrics
ORDER BY table_name
```

#### 质量趋势分析
```sql
-- models/quality_trends.sql
WITH daily_quality_metrics AS (
  SELECT
    DATE(created_at) as date,
    'plants' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN code IS NULL THEN 1 END) as null_code_count,
    COUNT(CASE WHEN code !~ '^[A-Z0-9_]+$' THEN 1 END) as invalid_code_count
  FROM plants
  WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
  GROUP BY DATE(created_at)
  
  UNION ALL
  
  SELECT
    DATE(created_at) as date,
    'work_centers' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN code IS NULL THEN 1 END) as null_code_count,
    COUNT(CASE WHEN code !~ '^[A-Z0-9_]+$' THEN 1 END) as invalid_code_count
  FROM work_centers
  WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
  GROUP BY DATE(created_at)
  
  UNION ALL
  
  SELECT
    DATE(created_at) as date,
    'equipment' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN code IS NULL THEN 1 END) as null_code_count,
    COUNT(CASE WHEN code !~ '^[A-Z0-9_]+$' THEN 1 END) as invalid_code_count
  FROM equipment
  WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
  GROUP BY DATE(created_at)
  
  UNION ALL
  
  SELECT
    DATE(created_at) as date,
    'inventory' as table_name,
    COUNT(*) as total_records,
    COUNT(CASE WHEN qty_on_hand IS NULL THEN 1 END) as null_code_count,
    COUNT(CASE WHEN qty_on_hand < 0 THEN 1 END) as invalid_code_count
  FROM inventory
  WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
  GROUP BY DATE(created_at)
)
SELECT
  date,
  table_name,
  total_records,
  null_code_count,
  invalid_code_count,
  ROUND((total_records - null_code_count)::numeric / total_records * 100, 2) as completeness_rate,
  ROUND((total_records - invalid_code_count)::numeric / total_records * 100, 2) as validity_rate
FROM daily_quality_metrics
ORDER BY date DESC, table_name
```

### 告警配置

#### 质量告警规则
```yaml
# monitoring/quality-alerts.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: data-quality-alerts
spec:
  groups:
  - name: data-quality
    rules:
    - alert: DataQualityCompletenessLow
      expr: data_quality_completeness < 0.98
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Data completeness below threshold"
        description: "Table {{ $labels.table }} completeness is {{ $value }}"
    
    - alert: DataQualityValidityLow
      expr: data_quality_validity < 0.99
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Data validity below threshold"
        description: "Table {{ $labels.table }} validity is {{ $value }}"
    
    - alert: DataQualityConsistencyLow
      expr: data_quality_consistency < 0.99
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Data consistency below threshold"
        description: "Table {{ $labels.table }} consistency is {{ $value }}"
    
    - alert: DataQualityUniquenessLow
      expr: data_quality_uniqueness < 1.0
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Data uniqueness below threshold"
        description: "Table {{ $labels.table }} uniqueness is {{ $value }}"
    
    - alert: DataQualityTimelinessLow
      expr: data_quality_timeliness > 300
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Data timeliness below threshold"
        description: "Table {{ $labels.table }} timeliness is {{ $value }}s"
```

#### 质量监控查询
```sql
-- 质量监控查询
SELECT
  table_name,
  completeness_rate,
  validity_rate,
  consistency_rate,
  uniqueness_rate,
  timeliness_rate,
  CASE
    WHEN completeness_rate < 0.98 THEN 'LOW'
    WHEN completeness_rate < 0.99 THEN 'MEDIUM'
    ELSE 'HIGH'
  END as completeness_status,
  CASE
    WHEN validity_rate < 0.99 THEN 'LOW'
    WHEN validity_rate < 0.995 THEN 'MEDIUM'
    ELSE 'HIGH'
  END as validity_status,
  CASE
    WHEN consistency_rate < 0.99 THEN 'LOW'
    WHEN consistency_rate < 0.995 THEN 'MEDIUM'
    ELSE 'HIGH'
  END as consistency_status,
  CASE
    WHEN uniqueness_rate < 1.0 THEN 'LOW'
    ELSE 'HIGH'
  END as uniqueness_status,
  CASE
    WHEN timeliness_rate > 300 THEN 'LOW'
    WHEN timeliness_rate > 60 THEN 'MEDIUM'
    ELSE 'HIGH'
  END as timeliness_status
FROM quality_metrics
ORDER BY table_name
```

## 自动化质量检查

### CI/CD集成

#### GitHub Actions配置
```yaml
# .github/workflows/data-quality.yml
name: Data Quality Checks

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  data-quality:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.9'
    
    - name: Install dependencies
      run: |
        pip install dbt-postgres
        pip install pytest
    
    - name: Run data quality tests
      run: |
        cd quality
        dbt test --profiles-dir . --target test
      env:
        DBT_PROFILES_DIR: quality
    
    - name: Run business rule tests
      run: |
        cd quality
        dbt run --models business_rules --profiles-dir . --target test
      env:
        DBT_PROFILES_DIR: quality
    
    - name: Generate quality report
      run: |
        cd quality
        dbt run --models quality_metrics --profiles-dir . --target test
        dbt run --models quality_trends --profiles-dir . --target test
      env:
        DBT_PROFILES_DIR: quality
    
    - name: Upload quality results
      uses: actions/upload-artifact@v3
      with:
        name: quality-results
        path: quality/target/
```

#### 质量门禁
```yaml
# .github/workflows/quality-gate.yml
name: Quality Gate

on:
  pull_request:
    branches: [ main ]

jobs:
  quality-gate:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.9'
    
    - name: Install dependencies
      run: |
        pip install dbt-postgres
        pip install pytest
    
    - name: Run quality gate tests
      run: |
        cd quality
        dbt test --profiles-dir . --target test
        
        # 检查质量指标
        python scripts/quality_gate_check.py
      env:
        DBT_PROFILES_DIR: quality
    
    - name: Comment PR with quality results
      uses: actions/github-script@v6
      with:
        script: |
          const fs = require('fs');
          const qualityResults = fs.readFileSync('quality/target/quality_results.json', 'utf8');
          
          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: `## 数据质量检查结果\n\n\`\`\`json\n${qualityResults}\n\`\`\``
          });
```

### 质量检查脚本

#### 质量门禁检查脚本
```python
# scripts/quality_gate_check.py
import json
import sys
import os
from typing import Dict, Any

def load_quality_results(file_path: str) -> Dict[str, Any]:
    """加载质量检查结果"""
    with open(file_path, 'r') as f:
        return json.load(f)

def check_quality_thresholds(results: Dict[str, Any]) -> bool:
    """检查质量阈值"""
    thresholds = {
        'completeness': 0.98,
        'validity': 0.99,
        'consistency': 0.99,
        'uniqueness': 1.0,
        'timeliness': 300  # 5分钟
    }
    
    violations = []
    
    for table_name, metrics in results.items():
        for metric_name, threshold in thresholds.items():
            if metric_name in metrics:
                value = metrics[metric_name]
                if metric_name == 'timeliness':
                    if value > threshold:
                        violations.append(f"{table_name}.{metric_name}: {value} > {threshold}")
                else:
                    if value < threshold:
                        violations.append(f"{table_name}.{metric_name}: {value} < {threshold}")
    
    if violations:
        print("质量门禁检查失败:")
        for violation in violations:
            print(f"  - {violation}")
        return False
    
    print("质量门禁检查通过")
    return True

def main():
    """主函数"""
    results_file = os.path.join('quality', 'target', 'quality_results.json')
    
    if not os.path.exists(results_file):
        print(f"质量结果文件不存在: {results_file}")
        sys.exit(1)
    
    results = load_quality_results(results_file)
    
    if not check_quality_thresholds(results):
        sys.exit(1)

if __name__ == '__main__':
    main()
```

#### 质量报告生成脚本
```python
# scripts/generate_quality_report.py
import json
import os
from datetime import datetime
from typing import Dict, Any

def generate_quality_report(results: Dict[str, Any]) -> str:
    """生成质量报告"""
    report = []
    report.append("# 数据质量报告")
    report.append(f"生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    report.append("")
    
    # 总体质量指标
    report.append("## 总体质量指标")
    report.append("| 表名 | 完整性 | 有效性 | 一致性 | 唯一性 | 及时性 |")
    report.append("|------|--------|--------|--------|--------|--------|")
    
    for table_name, metrics in results.items():
        completeness = metrics.get('completeness', 0)
        validity = metrics.get('validity', 0)
        consistency = metrics.get('consistency', 0)
        uniqueness = metrics.get('uniqueness', 0)
        timeliness = metrics.get('timeliness', 0)
        
        report.append(f"| {table_name} | {completeness:.2%} | {validity:.2%} | {consistency:.2%} | {uniqueness:.2%} | {timeliness}s |")
    
    report.append("")
    
    # 质量趋势
    report.append("## 质量趋势")
    report.append("| 日期 | 表名 | 完整性 | 有效性 |")
    report.append("|------|------|--------|--------|")
    
    # 这里可以添加趋势数据
    report.append("| 2025-01-07 | plants | 99.5% | 99.8% |")
    report.append("| 2025-01-07 | work_centers | 99.2% | 99.9% |")
    
    report.append("")
    
    # 质量建议
    report.append("## 质量建议")
    report.append("- 定期检查数据完整性")
    report.append("- 监控数据更新及时性")
    report.append("- 验证业务规则一致性")
    
    return "\n".join(report)

def main():
    """主函数"""
    results_file = os.path.join('quality', 'target', 'quality_results.json')
    
    if not os.path.exists(results_file):
        print(f"质量结果文件不存在: {results_file}")
        return
    
    with open(results_file, 'r') as f:
        results = json.load(f)
    
    report = generate_quality_report(results)
    
    # 保存报告
    report_file = os.path.join('quality', 'target', 'quality_report.md')
    with open(report_file, 'w', encoding='utf-8') as f:
        f.write(report)
    
    print(f"质量报告已生成: {report_file}")

if __name__ == '__main__':
    main()
```

## 质量改进流程

### 问题识别

#### 质量问题分类
1. **数据完整性问题**
   - 必填字段缺失
   - 外键引用不存在
   - 数据记录不完整

2. **数据有效性问题**
   - 格式不符合规范
   - 值超出合理范围
   - 枚举值不正确

3. **数据一致性问题**
   - 跨表数据不一致
   - 重复数据记录
   - 业务规则违反

4. **数据及时性问题**
   - 数据更新延迟
   - 时间戳异常
   - 同步失败

### 问题处理

#### 问题处理流程
1. **问题发现**：通过监控告警或质量检查发现
2. **问题分析**：分析问题原因和影响范围
3. **问题修复**：制定修复方案并实施
4. **问题验证**：验证修复效果
5. **问题总结**：总结经验教训

#### 问题修复脚本
```sql
-- 修复脚本示例
-- 修复设备编码格式问题
UPDATE equipment 
SET code = UPPER(TRIM(code))
WHERE code !~ '^[A-Z0-9_]+$';

-- 修复库存数量负数问题
UPDATE inventory 
SET qty_on_hand = 0
WHERE qty_on_hand < 0;

-- 修复时间戳顺序问题
UPDATE equipment 
SET updated_at = created_at + INTERVAL '1 minute'
WHERE updated_at < created_at;
```

### 质量改进

#### 持续改进
1. **定期评估**：定期评估数据质量状况
2. **识别改进点**：识别质量改进机会
3. **制定改进计划**：制定具体的改进计划
4. **实施改进措施**：实施质量改进措施
5. **监控改进效果**：监控改进效果

#### 质量文化建设
1. **培训教育**：提供数据质量培训
2. **最佳实践**：分享质量最佳实践
3. **工具支持**：提供质量检查工具
4. **激励机制**：建立质量激励机制
5. **持续学习**：持续学习质量改进方法
