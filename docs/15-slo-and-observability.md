# SLO与观测

## 概述

本文档描述了MES系统的服务等级目标(SLO)和观测性设计，包括性能指标、监控告警、日志管理和可观测性工具配置。确保系统运行状态的可视化和问题快速定位。

## 服务等级目标 (SLO)

### 核心SLO指标

#### 可用性SLO
- **目标**：99.9% (月度)
- **测量**：系统正常运行时间
- **计算**：`(总时间 - 停机时间) / 总时间 * 100%`
- **告警阈值**：可用性低于99.5%

#### 延迟SLO
- **目标**：P99 < 200ms (查询), P99 < 300ms (写入)
- **测量**：API响应时间
- **计算**：99百分位响应时间
- **告警阈值**：P99 > 500ms

#### 吞吐量SLO
- **目标**：1000 req/s (查询), 100 req/s (写入)
- **测量**：每秒请求数
- **计算**：平均每秒处理请求数
- **告警阈值**：吞吐量低于目标的80%

#### 错误率SLO
- **目标**：错误率 < 0.1%
- **测量**：HTTP 5xx错误率
- **计算**：`5xx错误数 / 总请求数 * 100%`
- **告警阈值**：错误率 > 1%

### SLO配置

#### SLO定义文件
```yaml
# slo-definitions.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceLevelObjective
metadata:
  name: mes-availability-slo
  namespace: monitoring
spec:
  target: 0.999
  window: 30d
  description: "MES系统可用性SLO"
  indicators:
  - name: availability
    ratio:
      events:
        total:
          source: prometheus
          query: 'sum(rate(http_requests_total{job="mes-app"}[5m]))'
        success:
          source: prometheus
          query: 'sum(rate(http_requests_total{job="mes-app",code!~"5.."}[5m]))'

---
apiVersion: monitoring.coreos.com/v1
kind: ServiceLevelObjective
metadata:
  name: mes-latency-slo
  namespace: monitoring
spec:
  target: 0.95
  window: 30d
  description: "MES系统延迟SLO"
  indicators:
  - name: latency
    ratio:
      events:
        total:
          source: prometheus
          query: 'sum(rate(http_requests_total{job="mes-app"}[5m]))'
        success:
          source: prometheus
          query: 'sum(rate(http_requests_total{job="mes-app",le="0.2"}[5m]))'

---
apiVersion: monitoring.coreos.com/v1
kind: ServiceLevelObjective
metadata:
  name: mes-error-rate-slo
  namespace: monitoring
spec:
  target: 0.999
  window: 30d
  description: "MES系统错误率SLO"
  indicators:
  - name: error-rate
    ratio:
      events:
        total:
          source: prometheus
          query: 'sum(rate(http_requests_total{job="mes-app"}[5m]))'
        success:
          source: prometheus
          query: 'sum(rate(http_requests_total{job="mes-app",code!~"5.."}[5m]))'
```

## 监控指标

### 系统指标

#### 数据库指标
```sql
-- 数据库性能监控视图
CREATE VIEW database_performance_metrics AS
SELECT
    'connection_count' as metric_name,
    COUNT(*) as metric_value,
    now() as timestamp
FROM pg_stat_activity
WHERE state = 'active'

UNION ALL

SELECT
    'slow_query_count' as metric_name,
    COUNT(*) as metric_value,
    now() as timestamp
FROM pg_stat_statements
WHERE mean_time > 500

UNION ALL

SELECT
    'cache_hit_ratio' as metric_name,
    ROUND(
        (blks_hit::float / (blks_hit + blks_read)) * 100, 2
    ) as metric_value,
    now() as timestamp
FROM pg_stat_database
WHERE datname = current_database()

UNION ALL

SELECT
    'table_size' as metric_name,
    pg_total_relation_size(schemaname||'.'||tablename) as metric_value,
    now() as timestamp
FROM pg_tables
WHERE schemaname = 'mes_core'
ORDER BY metric_value DESC;
```

#### 应用指标
```python
# 应用性能监控
from prometheus_client import Counter, Histogram, Gauge, start_http_server
import time
import psycopg2
from functools import wraps

# 定义指标
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint', 'status'])
REQUEST_DURATION = Histogram('http_request_duration_seconds', 'HTTP request duration')
DB_CONNECTIONS = Gauge('db_connections_active', 'Active database connections')
DB_QUERY_DURATION = Histogram('db_query_duration_seconds', 'Database query duration', ['query_type'])

# 请求监控装饰器
def monitor_request(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        start_time = time.time()
        try:
            result = func(*args, **kwargs)
            REQUEST_COUNT.labels(method='GET', endpoint=func.__name__, status='200').inc()
            return result
        except Exception as e:
            REQUEST_COUNT.labels(method='GET', endpoint=func.__name__, status='500').inc()
            raise
        finally:
            REQUEST_DURATION.observe(time.time() - start_time)
    return wrapper

# 数据库查询监控装饰器
def monitor_db_query(query_type):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            start_time = time.time()
            try:
                result = func(*args, **kwargs)
                return result
            finally:
                DB_QUERY_DURATION.labels(query_type=query_type).observe(time.time() - start_time)
        return wrapper
    return decorator

# 数据库连接监控
def monitor_db_connections():
    try:
        conn = psycopg2.connect(
            host='localhost',
            database='mes_core',
            user='mes_app',
            password='app_password'
        )
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active'")
        active_connections = cursor.fetchone()[0]
        DB_CONNECTIONS.set(active_connections)
        cursor.close()
        conn.close()
    except Exception as e:
        print(f"Database connection monitoring error: {e}")

# 启动监控服务器
def start_monitoring():
    start_http_server(8000)
    print("Monitoring server started on port 8000")
```

### 业务指标

#### 业务指标定义
```sql
-- 创建业务指标视图
CREATE VIEW business_metrics AS
SELECT
    'total_plants' as metric_name,
    COUNT(*) as metric_value,
    now() as timestamp
FROM plants

UNION ALL

SELECT
    'total_work_centers' as metric_name,
    COUNT(*) as metric_value,
    now() as timestamp
FROM work_centers

UNION ALL

SELECT
    'total_equipment' as metric_name,
    COUNT(*) as metric_value,
    now() as timestamp
FROM equipment

UNION ALL

SELECT
    'active_equipment' as metric_name,
    COUNT(*) as metric_value,
    now() as timestamp
FROM equipment
WHERE status = 'ACTIVE'

UNION ALL

SELECT
    'total_inventory_items' as metric_name,
    COUNT(*) as metric_value,
    now() as timestamp
FROM inventory

UNION ALL

SELECT
    'inventory_value' as metric_name,
    SUM(qty_on_hand) as metric_value,
    now() as timestamp
FROM inventory

UNION ALL

SELECT
    'total_employees' as metric_name,
    COUNT(*) as metric_value,
    now() as timestamp
FROM employees

UNION ALL

SELECT
    'active_employees' as metric_name,
    COUNT(*) as metric_value,
    now() as timestamp
FROM employees
WHERE status = 'ACTIVE';
```

#### 业务指标监控
```python
# 业务指标监控
import psycopg2
from prometheus_client import Gauge
import time

# 定义业务指标
TOTAL_PLANTS = Gauge('mes_plants_total', 'Total number of plants')
TOTAL_WORK_CENTERS = Gauge('mes_work_centers_total', 'Total number of work centers')
TOTAL_EQUIPMENT = Gauge('mes_equipment_total', 'Total number of equipment')
ACTIVE_EQUIPMENT = Gauge('mes_equipment_active', 'Number of active equipment')
TOTAL_INVENTORY_ITEMS = Gauge('mes_inventory_items_total', 'Total number of inventory items')
INVENTORY_VALUE = Gauge('mes_inventory_value_total', 'Total inventory value')
TOTAL_EMPLOYEES = Gauge('mes_employees_total', 'Total number of employees')
ACTIVE_EMPLOYEES = Gauge('mes_employees_active', 'Number of active employees')

def collect_business_metrics():
    """收集业务指标"""
    try:
        conn = psycopg2.connect(
            host='localhost',
            database='mes_core',
            user='mes_app',
            password='app_password'
        )
        cursor = conn.cursor()
        
        # 工厂数量
        cursor.execute("SELECT COUNT(*) FROM plants")
        TOTAL_PLANTS.set(cursor.fetchone()[0])
        
        # 工作中心数量
        cursor.execute("SELECT COUNT(*) FROM work_centers")
        TOTAL_WORK_CENTERS.set(cursor.fetchone()[0])
        
        # 设备数量
        cursor.execute("SELECT COUNT(*) FROM equipment")
        TOTAL_EQUIPMENT.set(cursor.fetchone()[0])
        
        # 活跃设备数量
        cursor.execute("SELECT COUNT(*) FROM equipment WHERE status = 'ACTIVE'")
        ACTIVE_EQUIPMENT.set(cursor.fetchone()[0])
        
        # 库存项目数量
        cursor.execute("SELECT COUNT(*) FROM inventory")
        TOTAL_INVENTORY_ITEMS.set(cursor.fetchone()[0])
        
        # 库存价值
        cursor.execute("SELECT SUM(qty_on_hand) FROM inventory")
        result = cursor.fetchone()[0]
        INVENTORY_VALUE.set(result if result else 0)
        
        # 员工数量
        cursor.execute("SELECT COUNT(*) FROM employees")
        TOTAL_EMPLOYEES.set(cursor.fetchone()[0])
        
        # 活跃员工数量
        cursor.execute("SELECT COUNT(*) FROM employees WHERE status = 'ACTIVE'")
        ACTIVE_EMPLOYEES.set(cursor.fetchone()[0])
        
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"Business metrics collection error: {e}")

# 定期收集业务指标
def start_business_metrics_collection():
    while True:
        collect_business_metrics()
        time.sleep(60)  # 每分钟收集一次
```

## 监控告警

### 告警规则

#### 系统告警规则
```yaml
# system-alerts.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: mes-system-alerts
  namespace: monitoring
spec:
  groups:
  - name: system
    rules:
    # 可用性告警
    - alert: MESAvailabilityLow
      expr: (sum(rate(http_requests_total{job="mes-app",code!~"5.."}[5m])) / sum(rate(http_requests_total{job="mes-app"}[5m]))) < 0.995
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "MES系统可用性低"
        description: "MES系统可用性低于99.5%，当前值: {{ $value }}"
    
    # 延迟告警
    - alert: MESLatencyHigh
      expr: histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket{job="mes-app"}[5m])) by (le)) > 0.5
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "MES系统延迟高"
        description: "MES系统P99延迟超过500ms，当前值: {{ $value }}s"
    
    # 错误率告警
    - alert: MESErrorRateHigh
      expr: (sum(rate(http_requests_total{job="mes-app",code=~"5.."}[5m])) / sum(rate(http_requests_total{job="mes-app"}[5m]))) > 0.01
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "MES系统错误率高"
        description: "MES系统错误率超过1%，当前值: {{ $value }}"
    
    # 吞吐量告警
    - alert: MESThroughputLow
      expr: sum(rate(http_requests_total{job="mes-app"}[5m])) < 800
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: "MES系统吞吐量低"
        description: "MES系统吞吐量低于800 req/s，当前值: {{ $value }} req/s"
```

#### 数据库告警规则
```yaml
# database-alerts.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: mes-database-alerts
  namespace: monitoring
spec:
  groups:
  - name: database
    rules:
    # 数据库连接数告警
    - alert: DatabaseConnectionsHigh
      expr: db_connections_active > 80
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "数据库连接数过高"
        description: "数据库活跃连接数超过80，当前值: {{ $value }}"
    
    # 慢查询告警
    - alert: DatabaseSlowQueries
      expr: rate(db_query_duration_seconds_count{query_type="SELECT"}[5m]) > 10
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "数据库慢查询过多"
        description: "数据库慢查询数量超过10个/秒，当前值: {{ $value }}"
    
    # 数据库缓存命中率告警
    - alert: DatabaseCacheHitRatioLow
      expr: db_cache_hit_ratio < 0.95
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: "数据库缓存命中率低"
        description: "数据库缓存命中率低于95%，当前值: {{ $value }}"
    
    # 数据库锁等待告警
    - alert: DatabaseLockWaits
      expr: db_lock_waits > 0
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: "数据库锁等待"
        description: "数据库存在锁等待，当前值: {{ $value }}"
```

#### 业务告警规则
```yaml
# business-alerts.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: mes-business-alerts
  namespace: monitoring
spec:
  groups:
  - name: business
    rules:
    # 设备故障告警
    - alert: EquipmentFailure
      expr: mes_equipment_total - mes_equipment_active > 5
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "设备故障数量过多"
        description: "故障设备数量超过5台，当前值: {{ $value }}"
    
    # 库存不足告警
    - alert: InventoryLow
      expr: mes_inventory_value_total < 1000
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: "库存价值过低"
        description: "库存总价值低于1000，当前值: {{ $value }}"
    
    # 员工出勤率告警
    - alert: EmployeeAttendanceLow
      expr: (mes_employees_active / mes_employees_total) < 0.8
      for: 30m
      labels:
        severity: warning
      annotations:
        summary: "员工出勤率低"
        description: "员工出勤率低于80%，当前值: {{ $value }}"
```

### 告警通知

#### 告警通知配置
```yaml
# alertmanager-config.yaml
global:
  smtp_smarthost: 'smtp.example.com:587'
  smtp_from: 'alerts@example.com'
  smtp_auth_username: 'alerts@example.com'
  smtp_auth_password: 'alert_password'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'default'
  routes:
  - match:
      severity: critical
    receiver: 'critical-alerts'
  - match:
      severity: warning
    receiver: 'warning-alerts'

receivers:
- name: 'default'
  email_configs:
  - to: 'admin@example.com'
    subject: 'MES系统告警: {{ .GroupLabels.alertname }}'
    body: |
      {{ range .Alerts }}
      告警: {{ .Annotations.summary }}
      描述: {{ .Annotations.description }}
      时间: {{ .StartsAt }}
      {{ end }}

- name: 'critical-alerts'
  email_configs:
  - to: 'admin@example.com,manager@example.com'
    subject: 'MES系统严重告警: {{ .GroupLabels.alertname }}'
    body: |
      {{ range .Alerts }}
      严重告警: {{ .Annotations.summary }}
      描述: {{ .Annotations.description }}
      时间: {{ .StartsAt }}
      {{ end }}
  webhook_configs:
  - url: 'http://webhook.example.com/alerts'
    send_resolved: true

- name: 'warning-alerts'
  email_configs:
  - to: 'admin@example.com'
    subject: 'MES系统警告: {{ .GroupLabels.alertname }}'
    body: |
      {{ range .Alerts }}
      警告: {{ .Annotations.summary }}
      描述: {{ .Annotations.description }}
      时间: {{ .StartsAt }}
      {{ end }}
```

## 日志管理

### 日志配置

#### 应用日志配置
```python
# logging_config.py
import logging
import logging.handlers
import json
from datetime import datetime

class JSONFormatter(logging.Formatter):
    """JSON格式日志格式化器"""
    
    def format(self, record):
        log_entry = {
            'timestamp': datetime.utcnow().isoformat(),
            'level': record.levelname,
            'logger': record.name,
            'message': record.getMessage(),
            'module': record.module,
            'function': record.funcName,
            'line': record.lineno,
            'thread': record.thread,
            'process': record.process
        }
        
        # 添加异常信息
        if record.exc_info:
            log_entry['exception'] = self.formatException(record.exc_info)
        
        # 添加额外字段
        if hasattr(record, 'user_id'):
            log_entry['user_id'] = record.user_id
        if hasattr(record, 'request_id'):
            log_entry['request_id'] = record.request_id
        if hasattr(record, 'correlation_id'):
            log_entry['correlation_id'] = record.correlation_id
        
        return json.dumps(log_entry, ensure_ascii=False)

def setup_logging():
    """设置日志配置"""
    
    # 创建根日志器
    root_logger = logging.getLogger()
    root_logger.setLevel(logging.INFO)
    
    # 清除现有处理器
    for handler in root_logger.handlers[:]:
        root_logger.removeHandler(handler)
    
    # 控制台处理器
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    console_formatter = JSONFormatter()
    console_handler.setFormatter(console_formatter)
    root_logger.addHandler(console_handler)
    
    # 文件处理器
    file_handler = logging.handlers.RotatingFileHandler(
        '/var/log/mes/app.log',
        maxBytes=100*1024*1024,  # 100MB
        backupCount=10
    )
    file_handler.setLevel(logging.INFO)
    file_formatter = JSONFormatter()
    file_handler.setFormatter(file_formatter)
    root_logger.addHandler(file_handler)
    
    # 错误日志处理器
    error_handler = logging.handlers.RotatingFileHandler(
        '/var/log/mes/error.log',
        maxBytes=100*1024*1024,  # 100MB
        backupCount=10
    )
    error_handler.setLevel(logging.ERROR)
    error_formatter = JSONFormatter()
    error_handler.setFormatter(error_formatter)
    root_logger.addHandler(error_handler)
    
    # 审计日志处理器
    audit_handler = logging.handlers.RotatingFileHandler(
        '/var/log/mes/audit.log',
        maxBytes=100*1024*1024,  # 100MB
        backupCount=30
    )
    audit_handler.setLevel(logging.INFO)
    audit_formatter = JSONFormatter()
    audit_handler.setFormatter(audit_formatter)
    
    # 创建审计日志器
    audit_logger = logging.getLogger('audit')
    audit_logger.addHandler(audit_handler)
    audit_logger.setLevel(logging.INFO)
    audit_logger.propagate = False

# 使用示例
import logging

# 设置日志
setup_logging()

# 获取日志器
logger = logging.getLogger(__name__)
audit_logger = logging.getLogger('audit')

# 记录日志
logger.info("应用启动", extra={'user_id': 'admin', 'request_id': 'req-123'})
audit_logger.info("用户登录", extra={'user_id': 'user123', 'action': 'login'})
```

#### 数据库日志配置
```sql
-- PostgreSQL日志配置
-- postgresql.conf
log_destination = 'stderr'
logging_collector = on
log_directory = '/var/log/postgresql'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_rotation_age = 1d
log_rotation_size = 100MB
log_truncate_on_rotation = on

-- 日志级别
log_min_messages = info
log_min_error_statement = error
log_min_duration_statement = 1000  -- 记录超过1秒的查询

-- 日志内容
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '
log_checkpoints = on
log_connections = on
log_disconnections = on
log_lock_waits = on
log_temp_files = 0
log_autovacuum_min_duration = 0
log_error_verbosity = default
log_statement = 'none'
log_replication_commands = off
log_hostname = off
log_timezone = 'UTC'
```

### 日志收集

#### Fluentd配置
```yaml
# fluentd-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
  namespace: logging
data:
  fluent.conf: |
    <source>
      @type tail
      path /var/log/mes/*.log
      pos_file /var/log/fluentd/mes.log.pos
      tag mes.app
      format json
      time_key timestamp
      time_format %Y-%m-%dT%H:%M:%S.%LZ
    </source>
    
    <source>
      @type tail
      path /var/log/postgresql/*.log
      pos_file /var/log/fluentd/postgresql.log.pos
      tag mes.database
      format /^(?<timestamp>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}.\d{3} \w{3}) \[(?<pid>\d+)\]: \[(?<log_level>\d+)-1\] user=(?<user>\w+),db=(?<database>\w+),app=(?<app>\w+),client=(?<client>[\d.]+) (?<message>.*)$/
      time_key timestamp
      time_format %Y-%m-%d %H:%M:%S.%L %Z
    </source>
    
    <filter mes.app>
      @type record_transformer
      <record>
        service_name mes-app
        environment production
      </record>
    </filter>
    
    <filter mes.database>
      @type record_transformer
      <record>
        service_name mes-database
        environment production
      </record>
    </filter>
    
    <match mes.**>
      @type elasticsearch
      host elasticsearch.logging.svc.cluster.local
      port 9200
      index_name mes-logs
      type_name _doc
      <buffer>
        @type file
        path /var/log/fluentd/buffer
        flush_mode interval
        flush_interval 1s
        chunk_limit_size 8MB
        queue_limit_length 32
        retry_max_interval 30
        retry_forever true
      </buffer>
    </match>
```

#### 日志查询
```python
# 日志查询工具
from elasticsearch import Elasticsearch
import json
from datetime import datetime, timedelta

class LogQuery:
    def __init__(self):
        self.es = Elasticsearch(['elasticsearch.logging.svc.cluster.local:9200'])
        self.index = 'mes-logs'
    
    def search_logs(self, query, start_time=None, end_time=None, size=100):
        """搜索日志"""
        if start_time is None:
            start_time = datetime.utcnow() - timedelta(hours=1)
        if end_time is None:
            end_time = datetime.utcnow()
        
        search_body = {
            "query": {
                "bool": {
                    "must": [
                        {
                            "range": {
                                "timestamp": {
                                    "gte": start_time.isoformat(),
                                    "lte": end_time.isoformat()
                                }
                            }
                        }
                    ]
                }
            },
            "size": size,
            "sort": [{"timestamp": {"order": "desc"}}]
        }
        
        if query:
            search_body["query"]["bool"]["must"].append({
                "multi_match": {
                    "query": query,
                    "fields": ["message", "level", "logger"]
                }
            })
        
        response = self.es.search(index=self.index, body=search_body)
        return response['hits']['hits']
    
    def search_errors(self, start_time=None, end_time=None):
        """搜索错误日志"""
        return self.search_logs(
            query="level:ERROR",
            start_time=start_time,
            end_time=end_time
        )
    
    def search_audit_logs(self, user_id=None, action=None, start_time=None, end_time=None):
        """搜索审计日志"""
        query = "logger:audit"
        if user_id:
            query += f" AND user_id:{user_id}"
        if action:
            query += f" AND action:{action}"
        
        return self.search_logs(
            query=query,
            start_time=start_time,
            end_time=end_time
        )
    
    def get_log_statistics(self, start_time=None, end_time=None):
        """获取日志统计信息"""
        if start_time is None:
            start_time = datetime.utcnow() - timedelta(hours=1)
        if end_time is None:
            end_time = datetime.utcnow()
        
        search_body = {
            "query": {
                "range": {
                    "timestamp": {
                        "gte": start_time.isoformat(),
                        "lte": end_time.isoformat()
                    }
                }
            },
            "aggs": {
                "level_count": {
                    "terms": {
                        "field": "level.keyword"
                    }
                },
                "service_count": {
                    "terms": {
                        "field": "service_name.keyword"
                    }
                },
                "hourly_count": {
                    "date_histogram": {
                        "field": "timestamp",
                        "interval": "1h"
                    }
                }
            }
        }
        
        response = self.es.search(index=self.index, body=search_body)
        return response['aggregations']

# 使用示例
log_query = LogQuery()

# 搜索错误日志
errors = log_query.search_errors()

# 搜索审计日志
audit_logs = log_query.search_audit_logs(user_id='user123', action='login')

# 获取日志统计
stats = log_query.get_log_statistics()
```

## 可观测性工具

### Grafana仪表盘

#### 系统监控仪表盘
```json
{
  "dashboard": {
    "title": "MES系统监控",
    "panels": [
      {
        "title": "系统可用性",
        "type": "stat",
        "targets": [
          {
            "expr": "(sum(rate(http_requests_total{job=\"mes-app\",code!~\"5..\"}[5m])) / sum(rate(http_requests_total{job=\"mes-app\"}[5m]))) * 100",
            "legendFormat": "可用性"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "percent",
            "min": 0,
            "max": 100,
            "thresholds": {
              "steps": [
                {"color": "red", "value": 0},
                {"color": "yellow", "value": 95},
                {"color": "green", "value": 99}
              ]
            }
          }
        }
      },
      {
        "title": "响应时间",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.50, sum(rate(http_request_duration_seconds_bucket{job=\"mes-app\"}[5m])) by (le))",
            "legendFormat": "P50"
          },
          {
            "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{job=\"mes-app\"}[5m])) by (le))",
            "legendFormat": "P95"
          },
          {
            "expr": "histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket{job=\"mes-app\"}[5m])) by (le))",
            "legendFormat": "P99"
          }
        ],
        "yAxes": [
          {
            "unit": "s",
            "min": 0
          }
        ]
      },
      {
        "title": "错误率",
        "type": "graph",
        "targets": [
          {
            "expr": "(sum(rate(http_requests_total{job=\"mes-app\",code=~\"5..\"}[5m])) / sum(rate(http_requests_total{job=\"mes-app\"}[5m]))) * 100",
            "legendFormat": "错误率"
          }
        ],
        "yAxes": [
          {
            "unit": "percent",
            "min": 0
          }
        ]
      },
      {
        "title": "吞吐量",
        "type": "graph",
        "targets": [
          {
            "expr": "sum(rate(http_requests_total{job=\"mes-app\"}[5m]))",
            "legendFormat": "请求/秒"
          }
        ],
        "yAxes": [
          {
            "unit": "reqps",
            "min": 0
          }
        ]
      }
    ]
  }
}
```

#### 数据库监控仪表盘
```json
{
  "dashboard": {
    "title": "MES数据库监控",
    "panels": [
      {
        "title": "数据库连接数",
        "type": "graph",
        "targets": [
          {
            "expr": "db_connections_active",
            "legendFormat": "活跃连接"
          }
        ],
        "yAxes": [
          {
            "unit": "short",
            "min": 0
          }
        ]
      },
      {
        "title": "查询响应时间",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.50, sum(rate(db_query_duration_seconds_bucket{job=\"mes-app\"}[5m])) by (le))",
            "legendFormat": "P50"
          },
          {
            "expr": "histogram_quantile(0.95, sum(rate(db_query_duration_seconds_bucket{job=\"mes-app\"}[5m])) by (le))",
            "legendFormat": "P95"
          },
          {
            "expr": "histogram_quantile(0.99, sum(rate(db_query_duration_seconds_bucket{job=\"mes-app\"}[5m])) by (le))",
            "legendFormat": "P99"
          }
        ],
        "yAxes": [
          {
            "unit": "s",
            "min": 0
          }
        ]
      },
      {
        "title": "缓存命中率",
        "type": "stat",
        "targets": [
          {
            "expr": "db_cache_hit_ratio * 100",
            "legendFormat": "缓存命中率"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "percent",
            "min": 0,
            "max": 100,
            "thresholds": {
              "steps": [
                {"color": "red", "value": 0},
                {"color": "yellow", "value": 90},
                {"color": "green", "value": 95}
              ]
            }
          }
        }
      },
      {
        "title": "锁等待",
        "type": "graph",
        "targets": [
          {
            "expr": "db_lock_waits",
            "legendFormat": "锁等待"
          }
        ],
        "yAxes": [
          {
            "unit": "short",
            "min": 0
          }
        ]
      }
    ]
  }
}
```

#### 业务监控仪表盘
```json
{
  "dashboard": {
    "title": "MES业务监控",
    "panels": [
      {
        "title": "设备状态",
        "type": "graph",
        "targets": [
          {
            "expr": "mes_equipment_total",
            "legendFormat": "总设备数"
          },
          {
            "expr": "mes_equipment_active",
            "legendFormat": "活跃设备"
          }
        ],
        "yAxes": [
          {
            "unit": "short",
            "min": 0
          }
        ]
      },
      {
        "title": "库存价值",
        "type": "graph",
        "targets": [
          {
            "expr": "mes_inventory_value_total",
            "legendFormat": "库存总价值"
          }
        ],
        "yAxes": [
          {
            "unit": "short",
            "min": 0
          }
        ]
      },
      {
        "title": "员工出勤率",
        "type": "stat",
        "targets": [
          {
            "expr": "(mes_employees_active / mes_employees_total) * 100",
            "legendFormat": "出勤率"
          }
        ],
        "fieldConfig": {
          "defaults": {
            "unit": "percent",
            "min": 0,
            "max": 100,
            "thresholds": {
              "steps": [
                {"color": "red", "value": 0},
                {"color": "yellow", "value": 80},
                {"color": "green", "value": 95}
              ]
            }
          }
        }
      },
      {
        "title": "工作中心分布",
        "type": "piechart",
        "targets": [
          {
            "expr": "mes_work_centers_total",
            "legendFormat": "工作中心"
          }
        ]
      }
    ]
  }
}
```

### 健康检查

#### 健康检查端点
```python
# health_check.py
from flask import Flask, jsonify
import psycopg2
import redis
import time
from prometheus_client import Counter, Histogram

app = Flask(__name__)

# 健康检查指标
HEALTH_CHECK_COUNTER = Counter('health_check_total', 'Total health checks', ['status'])
HEALTH_CHECK_DURATION = Histogram('health_check_duration_seconds', 'Health check duration')

def check_database():
    """检查数据库健康状态"""
    try:
        conn = psycopg2.connect(
            host='localhost',
            database='mes_core',
            user='mes_app',
            password='app_password',
            connect_timeout=5
        )
        cursor = conn.cursor()
        cursor.execute("SELECT 1")
        cursor.fetchone()
        cursor.close()
        conn.close()
        return True, "数据库连接正常"
    except Exception as e:
        return False, f"数据库连接失败: {str(e)}"

def check_redis():
    """检查Redis健康状态"""
    try:
        r = redis.Redis(host='localhost', port=6379, db=0, socket_timeout=5)
        r.ping()
        return True, "Redis连接正常"
    except Exception as e:
        return False, f"Redis连接失败: {str(e)}"

def check_disk_space():
    """检查磁盘空间"""
    try:
        import shutil
        total, used, free = shutil.disk_usage("/")
        free_percent = (free / total) * 100
        if free_percent < 10:
            return False, f"磁盘空间不足: {free_percent:.1f}%"
        return True, f"磁盘空间正常: {free_percent:.1f}%"
    except Exception as e:
        return False, f"磁盘空间检查失败: {str(e)}"

def check_memory():
    """检查内存使用"""
    try:
        import psutil
        memory = psutil.virtual_memory()
        if memory.percent > 90:
            return False, f"内存使用率过高: {memory.percent}%"
        return True, f"内存使用正常: {memory.percent}%"
    except Exception as e:
        return False, f"内存检查失败: {str(e)}"

@app.route('/health')
def health_check():
    """健康检查端点"""
    start_time = time.time()
    
    health_status = {
        'status': 'healthy',
        'timestamp': time.time(),
        'checks': {}
    }
    
    # 检查数据库
    db_healthy, db_message = check_database()
    health_status['checks']['database'] = {
        'status': 'healthy' if db_healthy else 'unhealthy',
        'message': db_message
    }
    
    # 检查Redis
    redis_healthy, redis_message = check_redis()
    health_status['checks']['redis'] = {
        'status': 'healthy' if redis_healthy else 'unhealthy',
        'message': redis_message
    }
    
    # 检查磁盘空间
    disk_healthy, disk_message = check_disk_space()
    health_status['checks']['disk'] = {
        'status': 'healthy' if disk_healthy else 'unhealthy',
        'message': disk_message
    }
    
    # 检查内存
    memory_healthy, memory_message = check_memory()
    health_status['checks']['memory'] = {
        'status': 'healthy' if memory_healthy else 'unhealthy',
        'message': memory_message
    }
    
    # 确定总体状态
    all_healthy = all([
        db_healthy, redis_healthy, disk_healthy, memory_healthy
    ])
    
    if not all_healthy:
        health_status['status'] = 'unhealthy'
    
    # 记录指标
    duration = time.time() - start_time
    HEALTH_CHECK_DURATION.observe(duration)
    HEALTH_CHECK_COUNTER.labels(status=health_status['status']).inc()
    
    # 返回状态码
    status_code = 200 if all_healthy else 503
    
    return jsonify(health_status), status_code

@app.route('/health/ready')
def readiness_check():
    """就绪检查端点"""
    # 检查关键服务是否就绪
    db_healthy, _ = check_database()
    
    if db_healthy:
        return jsonify({'status': 'ready'}), 200
    else:
        return jsonify({'status': 'not ready'}), 503

@app.route('/health/live')
def liveness_check():
    """存活检查端点"""
    # 检查应用是否存活
    return jsonify({'status': 'alive'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
```

### 链路追踪

#### OpenTelemetry配置
```python
# tracing_config.py
from opentelemetry import trace
from opentelemetry.exporter.jaeger.thrift import JaegerExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.instrumentation.psycopg2 import Psycopg2Instrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor
import logging

def setup_tracing():
    """设置链路追踪"""
    
    # 设置追踪提供者
    trace.set_tracer_provider(TracerProvider())
    tracer = trace.get_tracer(__name__)
    
    # 设置Jaeger导出器
    jaeger_exporter = JaegerExporter(
        agent_host_name='jaeger-agent',
        agent_port=6831,
    )
    
    # 设置批处理处理器
    span_processor = BatchSpanProcessor(jaeger_exporter)
    trace.get_tracer_provider().add_span_processor(span_processor)
    
    # 自动追踪Flask应用
    FlaskInstrumentor().instrument()
    
    # 自动追踪数据库操作
    Psycopg2Instrumentor().instrument()
    
    # 自动追踪HTTP请求
    RequestsInstrumentor().instrument()
    
    return tracer

# 使用示例
tracer = setup_tracing()

@tracer.start_as_current_span("business_operation")
def process_equipment_data(equipment_id):
    """处理设备数据"""
    with tracer.start_as_current_span("database_query"):
        # 数据库查询
        conn = psycopg2.connect(...)
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM equipment WHERE equipment_id = %s", (equipment_id,))
        result = cursor.fetchone()
        cursor.close()
        conn.close()
    
    with tracer.start_as_current_span("data_processing"):
        # 数据处理
        processed_data = process_data(result)
    
    with tracer.start_as_current_span("external_api_call"):
        # 外部API调用
        response = requests.post('http://external-api.com/data', json=processed_data)
    
    return response.json()
```

## 监控最佳实践

### 监控策略

1. **分层监控**：基础设施、应用、业务三层监控
2. **关键指标**：关注SLO相关指标
3. **告警优化**：避免告警疲劳，设置合理阈值
4. **自动化响应**：自动修复常见问题
5. **持续改进**：定期评估和优化监控策略

### 观测性最佳实践

1. **结构化日志**：使用JSON格式，包含关键字段
2. **分布式追踪**：跟踪请求在系统中的流转
3. **指标聚合**：合理聚合指标，避免指标爆炸
4. **可视化设计**：设计直观的仪表盘
5. **告警管理**：建立告警生命周期管理

### 性能优化

1. **监控开销**：控制监控对系统性能的影响
2. **数据保留**：合理设置数据保留策略
3. **查询优化**：优化监控查询性能
4. **存储优化**：使用合适的数据存储方案
5. **网络优化**：优化监控数据传输
