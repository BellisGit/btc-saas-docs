# MES系统物理布局

## 概述

本文档描述了MES制造执行系统数据库的物理布局设计，包括数据库架构、存储策略、索引设计和性能优化方案。系统采用MySQL 8.0+作为主要数据库，Redis作为缓存层，支持高并发、高可用的生产环境部署。

## 数据库架构

### 1. 架构选择

#### 1.1 单库架构（当前实现）
- **数据库名称**：`mes_core`
- **适用场景**：中小型MES系统
- **优势**：
  - 管理简单，维护成本低
  - 事务一致性强
  - 开发成本低
  - 数据查询简单
- **劣势**：
  - 扩展性有限
  - 单点故障风险
  - 性能瓶颈

#### 1.2 多库架构（扩展方案）
- **主数据库**：`mes_core`（核心业务数据）
- **BI数据库**：`mes_bi`（BI聚合数据）
- **日志数据库**：`mes_log`（操作日志）
- **适用场景**：大型MES系统、微服务架构
- **优势**：
  - 扩展性好
  - 服务隔离
  - 独立演进
  - 性能优化
- **劣势**：
  - 管理复杂
  - 跨库事务处理困难
  - 数据一致性挑战

### 2. 数据库选择

#### 2.1 MySQL 8.0+（主要选择）
**版本要求**：MySQL 8.0.20+
**特性支持**：
```sql
-- 启用必要功能
SET GLOBAL sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO';
SET GLOBAL innodb_file_per_table = ON;
SET GLOBAL innodb_buffer_pool_size = 2G;  -- 根据内存调整
```

**字符集配置**：
```sql
-- 数据库字符集
CREATE DATABASE mes_core CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 表字符集
CREATE TABLE example_table (
    id VARCHAR(32) PRIMARY KEY,
    name VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

#### 2.2 Redis（缓存层）
**版本要求**：Redis 6.0+
**配置示例**：
```conf
# redis.conf
maxmemory 2gb
maxmemory-policy allkeys-lru
save 900 1
save 300 10
save 60 10000
```

**使用场景**：
- 会话存储：`session:{user_id}`
- 分布式锁：`lock:pick:{wo_id}:{item_id}`
- 缓存数据：看板指标（TTL 30-120s）
- 幂等控制：`Idempotency-Key`

### 3. 存储引擎选择

#### 3.1 InnoDB（主要引擎）
**优势**：
- 支持ACID事务
- 行级锁定
- 外键约束
- 崩溃恢复
- 热备份

**配置优化**：
```sql
-- InnoDB配置
SET GLOBAL innodb_buffer_pool_size = 2G;
SET GLOBAL innodb_log_file_size = 256M;
SET GLOBAL innodb_flush_log_at_trx_commit = 2;
SET GLOBAL innodb_file_per_table = ON;
```

#### 3.2 MyISAM（特殊场景）
**使用场景**：
- 只读表
- 日志表
- 临时表

## 表结构设计

### 1. 核心业务表

#### 1.1 主数据表
```sql
-- 物料主数据表
CREATE TABLE item_master (
    item_id VARCHAR(32) PRIMARY KEY COMMENT '物料编码',
    item_code VARCHAR(64) NOT NULL COMMENT 'ERP物料编码',
    item_name VARCHAR(255) NOT NULL COMMENT '物料名称',
    item_type ENUM('RAW', 'COMPONENT', 'FINISHED', 'TOOL', 'CONSUMABLE') NOT NULL,
    uom VARCHAR(16) NOT NULL COMMENT '计量单位',
    specification TEXT COMMENT '规格说明',
    supplier_id VARCHAR(32) COMMENT '默认供应商',
    status ENUM('ACTIVE', 'INACTIVE', 'OBSOLETE') DEFAULT 'ACTIVE',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_item_code (item_code),
    INDEX idx_item_type (item_type),
    INDEX idx_supplier (supplier_id),
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='物料主数据表';
```

#### 1.2 生产管理表
```sql
-- 生产工单表
CREATE TABLE work_order (
    wo_id VARCHAR(32) PRIMARY KEY COMMENT '工单号',
    wo_no VARCHAR(64) NOT NULL COMMENT '工单编号',
    item_id VARCHAR(32) NOT NULL COMMENT '生产物料ID',
    planned_quantity DECIMAL(18,4) NOT NULL COMMENT '计划数量',
    actual_quantity DECIMAL(18,4) DEFAULT 0 COMMENT '实际数量',
    line_id VARCHAR(32) COMMENT '产线ID',
    priority ENUM('LOW', 'NORMAL', 'HIGH', 'URGENT') DEFAULT 'NORMAL',
    status ENUM('DRAFT', 'RELEASED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED', 'ON_HOLD') DEFAULT 'DRAFT',
    planned_start_date DATETIME COMMENT '计划开始时间',
    planned_end_date DATETIME COMMENT '计划结束时间',
    actual_start_date DATETIME COMMENT '实际开始时间',
    actual_end_date DATETIME COMMENT '实际结束时间',
    routing_id VARCHAR(32) COMMENT '工艺路线ID',
    remarks TEXT COMMENT '备注',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_wo_no (wo_no),
    INDEX idx_item (item_id),
    INDEX idx_line (line_id),
    INDEX idx_status (status),
    INDEX idx_planned_date (planned_start_date),
    INDEX idx_tenant (tenant_id),
    INDEX idx_created_at (created_at),
    
    FOREIGN KEY (item_id) REFERENCES item_master(item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='生产工单表';
```

### 2. 追溯系统表

#### 2.1 追溯事件表
```sql
-- 追溯事件表（事件溯源核心表）
CREATE TABLE trace_event (
    event_id VARCHAR(40) PRIMARY KEY COMMENT '事件ID',
    entity_type VARCHAR(32) NOT NULL COMMENT '实体类型',
    entity_id VARCHAR(64) NOT NULL COMMENT '实体ID',
    action VARCHAR(32) NOT NULL COMMENT '动作',
    occurred_at DATETIME NOT NULL COMMENT '发生时间',
    op_id VARCHAR(32) COMMENT '工序ID',
    op_name VARCHAR(64) COMMENT '工序名称',
    op_start_at DATETIME COMMENT '工序开始时间',
    op_end_at DATETIME COMMENT '工序结束时间',
    operator_id VARCHAR(64) COMMENT '操作员ID',
    result ENUM('PASS', 'FAIL', 'REWORK', 'HOLD') COMMENT '结果',
    station_id VARCHAR(64) COMMENT '工位ID',
    shift_code VARCHAR(16) COMMENT '班次代码',
    ref_id VARCHAR(64) COMMENT '关联单据ID',
    data JSON COMMENT '扩展数据',
    prev_event_id VARCHAR(40) COMMENT '前一个事件ID',
    correlation_id VARCHAR(64) COMMENT '关联ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    source_system VARCHAR(32) COMMENT '来源系统',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_entity (entity_type, entity_id, occurred_at),
    INDEX idx_action (action, occurred_at),
    INDEX idx_operator (operator_id),
    INDEX idx_station (station_id),
    INDEX idx_prev_event (prev_event_id),
    INDEX idx_correlation (correlation_id),
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_occurred_at (occurred_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='追溯事件表'
);
```

### 3. BI数据聚合表

#### 3.1 良率聚合表
```sql
-- 良率聚合表（5分钟）
CREATE TABLE agg_yield_5m (
    bucket_start DATETIME PRIMARY KEY COMMENT '时间桶开始时间',
    pass_cnt INT DEFAULT 0 COMMENT '通过数量',
    fail_cnt INT DEFAULT 0 COMMENT '失败数量',
    yield DECIMAL(5,2) COMMENT '良率',
    station VARCHAR(64) COMMENT '工位',
    item_id VARCHAR(32) COMMENT '物料ID',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_station (station),
    INDEX idx_item (item_id),
    INDEX idx_bucket_start (bucket_start),
    INDEX idx_yield (yield)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='良率聚合表';
```

## 索引设计策略

### 1. 主键索引
- **策略**：所有表都有主键
- **类型**：聚簇索引（InnoDB）
- **选择**：业务主键或自增ID

### 2. 唯一索引
- **业务唯一键**：物料代码、供应商代码等
- **复合唯一键**：多字段组合唯一约束

### 3. 普通索引
- **外键字段**：自动创建索引
- **查询字段**：WHERE条件常用字段
- **排序字段**：ORDER BY常用字段

### 4. 复合索引
- **查询优化**：多字段组合查询
- **覆盖索引**：包含查询所需的所有字段
- **最左前缀**：遵循最左前缀原则

### 5. 索引优化示例
```sql
-- 工单表索引优化
CREATE INDEX idx_wo_status_created ON work_order(status, created_at);
CREATE INDEX idx_wo_item_status ON work_order(item_id, status);
CREATE INDEX idx_wo_planned_date_status ON work_order(planned_start_date, status);

-- 追溯事件表索引优化
CREATE INDEX idx_trace_entity_time ON trace_event(entity_type, entity_id, occurred_at);
CREATE INDEX idx_trace_action_time ON trace_event(action, occurred_at);
CREATE INDEX idx_trace_operator_time ON trace_event(operator_id, occurred_at);
```

## 分区策略

### 1. 时间分区
**适用表**：
- `trace_event` - 按日期分区
- `test_record` - 按日期分区
- `stock_transaction` - 按日期分区

**分区示例**：
```sql
-- 按月分区
);
```

### 2. 哈希分区
**适用表**：
- 大表按ID哈希分区
- 负载均衡

### 3. 列表分区
**适用表**：
- 按状态分区
- 按租户分区

## 存储优化

### 1. 表空间管理
```sql
-- 创建独立表空间
CREATE TABLESPACE mes_data
ADD DATAFILE 'mes_data.ibd'
FILE_BLOCK_SIZE = 16K;

-- 使用独立表空间
CREATE TABLE large_table (
    id BIGINT PRIMARY KEY,
    data TEXT
) TABLESPACE mes_data;
```

### 2. 数据压缩
```sql
-- 启用表压缩
CREATE TABLE compressed_table (
    id BIGINT PRIMARY KEY,
    data TEXT
) ROW_FORMAT=COMPRESSED KEY_BLOCK_SIZE=8;
```

### 3. 数据归档
```sql
-- 创建归档表
CREATE TABLE trace_event_archive LIKE trace_event;

-- 归档历史数据
INSERT INTO trace_event_archive 
SELECT * FROM trace_event 
WHERE occurred_at < DATE_SUB(NOW(), INTERVAL 1 YEAR);

-- 删除已归档数据
DELETE FROM trace_event 
WHERE occurred_at < DATE_SUB(NOW(), INTERVAL 1 YEAR);
```

## 缓存策略

### 1. Redis缓存设计

#### 1.1 缓存键命名规范
```
# 会话缓存
session:{user_id}

# 分布式锁
lock:pick:{wo_id}:{item_id}
lock:inspection:{insp_id}

# 业务数据缓存
item:{item_id}
supplier:{supplier_id}
work_order:{wo_id}

# 聚合数据缓存
yield:5m:{station}:{bucket_start}
wip:status:{wo_id}
```

#### 1.2 缓存过期策略
```redis
# 短期缓存（30秒-2分钟）
SET yield:5m:ST001:202501071000 "96.5" EX 120

# 中期缓存（5-30分钟）
SET work_order:WO-L1-0001 "{...}" EX 1800

# 长期缓存（1-24小时）
SET item:ITM-202501-0001 "{...}" EX 86400
```

#### 1.3 缓存更新策略
- **Cache-Aside**：应用层控制缓存
- **Write-Through**：写入时同时更新缓存
- **Write-Behind**：异步更新缓存

### 2. 缓存一致性
```sql
-- 数据库更新后清除缓存
DEL cache:work_order:WO-L1-0001
DEL cache:work_order:list:*

-- 使用Redis事务保证一致性
MULTI
SET cache:work_order:WO-L1-0001 "{...}" EX 1800
EXPIRE cache:work_order:list:* 0
EXEC
```

## 性能优化

### 1. 查询优化

#### 1.1 慢查询优化
```sql
-- 启用慢查询日志
SET GLOBAL slow_query_log = ON;
SET GLOBAL long_query_time = 2;
SET GLOBAL log_queries_not_using_indexes = ON;

-- 分析慢查询
EXPLAIN SELECT * FROM work_order wo
JOIN item_master im ON wo.item_id = im.item_id
WHERE wo.status = 'IN_PROGRESS'
ORDER BY wo.created_at DESC
LIMIT 20;
```

#### 1.2 查询重写
```sql
-- 优化前：子查询
SELECT * FROM work_order 
WHERE item_id IN (
    SELECT item_id FROM item_master 
    WHERE item_type = 'FINISHED'
);

-- 优化后：JOIN查询
SELECT wo.* FROM work_order wo
JOIN item_master im ON wo.item_id = im.item_id
WHERE im.item_type = 'FINISHED';
```

### 2. 连接池配置
```properties
# HikariCP配置
spring.datasource.hikari.maximum-pool-size=20
spring.datasource.hikari.minimum-idle=5
spring.datasource.hikari.connection-timeout=30000
spring.datasource.hikari.idle-timeout=600000
spring.datasource.hikari.max-lifetime=1800000
spring.datasource.hikari.leak-detection-threshold=60000
```

### 3. 读写分离
```yaml
# 主从配置
datasource:
  master:
    url: jdbc:mysql://master:3306/mes_core
    username: mes_user
    password: mes_password
  slave:
    url: jdbc:mysql://slave:3306/mes_core
    username: mes_user
    password: mes_password
```

## 备份与恢复

### 1. 备份策略

#### 1.1 全量备份
```bash
# 每日全量备份
mysqldump --single-transaction --routines --triggers \
  --all-databases > backup_$(date +%Y%m%d).sql

# 压缩备份
gzip backup_$(date +%Y%m%d).sql
```

#### 1.2 增量备份
```bash
# 启用binlog
SET GLOBAL log_bin = ON;
SET GLOBAL binlog_format = ROW;

# 增量备份
mysqlbinlog --start-datetime="2025-01-07 00:00:00" \
  --stop-datetime="2025-01-07 23:59:59" \
  mysql-bin.000001 > incremental_backup.sql
```

### 2. 恢复策略
```bash
# 全量恢复
mysql < backup_20250107.sql

# 增量恢复
mysql < incremental_backup.sql
```

## 监控与告警

### 1. 性能监控
```sql
-- 查看连接数
SHOW STATUS LIKE 'Threads_connected';

-- 查看慢查询
SHOW STATUS LIKE 'Slow_queries';

-- 查看缓存命中率
SHOW STATUS LIKE 'Qcache_hits';
```

### 2. 告警配置
```yaml
# 告警规则
alerts:
  - name: "数据库连接数过高"
    condition: "Threads_connected > 80"
    severity: "warning"
  
  - name: "慢查询过多"
    condition: "Slow_queries > 100"
    severity: "error"
  
  - name: "缓存命中率过低"
    condition: "Qcache_hits / (Qcache_hits + Com_select) < 0.8"
    severity: "warning"
```

## 安全配置

### 1. 用户权限
```sql
-- 创建应用用户
CREATE USER 'mes_app'@'%' IDENTIFIED BY 'strong_password';

-- 授予权限
GRANT SELECT, INSERT, UPDATE, DELETE ON mes_core.* TO 'mes_app'@'%';
GRANT EXECUTE ON mes_core.* TO 'mes_app'@'%';

-- 创建只读用户
CREATE USER 'mes_readonly'@'%' IDENTIFIED BY 'readonly_password';
GRANT SELECT ON mes_core.* TO 'mes_readonly'@'%';
```

### 2. 数据加密
```sql
-- 启用SSL连接
SET GLOBAL require_secure_transport = ON;

-- 数据加密
CREATE TABLE sensitive_data (
    id BIGINT PRIMARY KEY,
    encrypted_data VARBINARY(255)
);
```

## 扩展性设计

### 1. 水平扩展
- **分库分表**：按租户分库
- **读写分离**：主从复制
- **负载均衡**：多实例部署

### 2. 垂直扩展
- **字段扩展**：ALTER TABLE ADD COLUMN
- **索引优化**：添加复合索引
- **存储优化**：表空间管理

### 3. 微服务架构
- **数据分库**：按业务域分库
- **服务隔离**：独立数据库实例
- **数据同步**：事件驱动同步