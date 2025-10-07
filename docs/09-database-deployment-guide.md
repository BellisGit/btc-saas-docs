# MES系统数据库部署指南

## 概述

本文档提供了MES制造执行系统完整数据库架构的部署指南，包括三个数据库（btc_core、btc_log、btc_bi）的创建、配置、迁移和运维管理。

## 数据库架构概览

### 数据库分布
- **btc_core**: 核心业务数据库 (54个表)
- **btc_log**: 日志数据库 (15个表)  
- **btc_bi**: BI分析数据库 (15个表)
- **总计**: 3个数据库，87个表

### 部署顺序
1. **btc_core** - 核心业务数据库（基础）
2. **btc_log** - 日志数据库（运维）
3. **btc_bi** - BI分析数据库（分析）

## 环境要求

### 硬件要求
- **CPU**: 8核心以上
- **内存**: 32GB以上
- **存储**: SSD 500GB以上
- **网络**: 千兆网卡

### 软件要求
- **MySQL**: 8.0.20+
- **Flyway**: 9.0+
- **Redis**: 6.0+
- **操作系统**: Linux (CentOS 7+/Ubuntu 18+)

### 配置要求
```ini
# MySQL配置 (my.cnf)
[mysqld]
# 基础配置
port = 3306
bind-address = 0.0.0.0
max_connections = 1000
max_connect_errors = 1000

# 字符集
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# InnoDB配置
innodb_buffer_pool_size = 16G
innodb_log_file_size = 512M
innodb_log_buffer_size = 128M
innodb_flush_log_at_trx_commit = 2
innodb_file_per_table = ON
innodb_buffer_pool_instances = 8

# 查询缓存
query_cache_size = 256M
query_cache_type = 1

# 慢查询日志
slow_query_log = 1
long_query_time = 2
log_queries_not_using_indexes = 1

# 二进制日志
log-bin = mysql-bin
binlog_format = ROW
expire_logs_days = 7
max_binlog_size = 100M

# 分区支持
partition = ON
```

## 部署步骤

### 1. 创建数据库用户

```sql
-- 创建BTC系统用户
CREATE USER 'btc_app'@'%' IDENTIFIED BY 'BTC_APP_PASSWORD_2025';
CREATE USER 'btc_bi'@'%' IDENTIFIED BY 'BTC_BI_PASSWORD_2025';
CREATE USER 'btc_log'@'%' IDENTIFIED BY 'BTC_LOG_PASSWORD_2025';

-- 授予权限
GRANT ALL PRIVILEGES ON btc_core.* TO 'btc_app'@'%';
GRANT ALL PRIVILEGES ON btc_bi.* TO 'btc_bi'@'%';
GRANT ALL PRIVILEGES ON btc_log.* TO 'btc_log'@'%';

-- 授予跨库查询权限（BI需要查询core库）
GRANT SELECT ON btc_core.* TO 'btc_bi'@'%';

FLUSH PRIVILEGES;
```

### 2. 部署核心业务数据库 (btc_core)

```bash
# 创建数据库
mysql -u root -p -e "CREATE DATABASE btc_core CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 执行架构创建
mysql -u root -p btc_core < mes-backend/database/schemas/btc_core_schema.sql

# 执行系统表创建
mysql -u root -p btc_core < mes-backend/database/schemas/btc_system_tables.sql

# 使用Flyway执行迁移
./flyway migrate \
  -url=jdbc:mysql://localhost:3306/btc_core \
  -user=btc_app \
  -password=BTC_APP_PASSWORD_2025 \
  -locations=filesystem:mes-backend/database/migrations

# 初始化基础数据
mysql -u root -p btc_core < mes-backend/database/seeds/01_basic_data.sql
mysql -u root -p btc_core < mes-backend/database/seeds/02_system_data.sql
```

### 3. 部署日志数据库 (btc_log)

```bash
# 创建数据库
mysql -u root -p -e "CREATE DATABASE btc_log CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 执行架构创建
mysql -u root -p btc_log < mes-backend/database/schemas/btc_log_schema.sql

# 使用Flyway执行迁移
./flyway migrate \
  -url=jdbc:mysql://localhost:3306/btc_log \
  -user=btc_log \
  -password=BTC_LOG_PASSWORD_2025 \
  -locations=filesystem:mes-backend/database/migrations
```

### 4. 部署BI数据库 (btc_bi)

```bash
# 创建数据库
mysql -u root -p -e "CREATE DATABASE btc_bi CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 执行架构创建
mysql -u root -p btc_bi < mes-backend/database/schemas/btc_bi_schema.sql

# 使用Flyway执行迁移
./flyway migrate \
  -url=jdbc:mysql://localhost:3306/btc_bi \
  -user=btc_bi \
  -password=BTC_BI_PASSWORD_2025 \
  -locations=filesystem:mes-backend/database/migrations
```

### 5. 配置分区管理

```sql
-- 为日志表配置分区管理存储过程
USE btc_log;

DELIMITER $$

CREATE PROCEDURE CreateMonthlyPartition(
    IN table_name VARCHAR(64),
    IN partition_date DATE
)
BEGIN
    DECLARE partition_name VARCHAR(10);
    DECLARE next_month_date DATE;
    DECLARE sql_stmt TEXT;
    
    SET partition_name = CONCAT('p', DATE_FORMAT(partition_date, '%Y%m'));
    SET next_month_date = DATE_ADD(partition_date, INTERVAL 1 MONTH);
    SET next_month_date = LAST_DAY(next_month_date) + INTERVAL 1 DAY;
    
    SET @sql_stmt = CONCAT(
        'ALTER TABLE ', table_name, 
        ' ADD PARTITION (PARTITION ', partition_name, 
        ' VALUES LESS THAN (TO_DAYS(''', next_month_date, ''')))'
    );
    
    PREPARE stmt FROM @sql_stmt;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$

DELIMITER ;

-- 创建分区清理存储过程
DELIMITER $$

CREATE PROCEDURE DropOldPartitions(
    IN table_name VARCHAR(64),
    IN retention_months INT
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE partition_name VARCHAR(10);
    DECLARE partition_date DATE;
    DECLARE cutoff_date DATE;
    DECLARE sql_stmt TEXT;
    
    DECLARE partition_cursor CURSOR FOR 
        SELECT PARTITION_NAME, PARTITION_DESCRIPTION
        FROM INFORMATION_SCHEMA.PARTITIONS 
        WHERE TABLE_SCHEMA = 'mes_log' 
          AND TABLE_NAME = table_name
          AND PARTITION_NAME IS NOT NULL
          AND PARTITION_NAME != 'p_future';
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    SET cutoff_date = DATE_SUB(CURDATE(), INTERVAL retention_months MONTH);
    
    OPEN partition_cursor;
    partition_loop: LOOP
        FETCH partition_cursor INTO partition_name, partition_date;
        IF done THEN
            LEAVE partition_loop;
        END IF;
        
        IF partition_date < cutoff_date THEN
            SET @sql_stmt = CONCAT('ALTER TABLE ', table_name, ' DROP PARTITION ', partition_name);
            PREPARE stmt FROM @sql_stmt;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END IF;
    END LOOP;
    
    CLOSE partition_cursor;
END$$

DELIMITER ;
```

### 6. 配置定时任务

```bash
# 创建分区管理定时任务
cat > /etc/cron.d/btc-database-partitions << EOF
# 每月1号创建下月分区
0 2 1 * * root mysql -u root -pPASSWORD btc_log -e "CALL CreateMonthlyPartition('user_behavior_log', DATE_ADD(CURDATE(), INTERVAL 1 MONTH));"
0 2 1 * * root mysql -u root -pPASSWORD btc_log -e "CALL CreateMonthlyPartition('system_runtime_log', DATE_ADD(CURDATE(), INTERVAL 1 MONTH));"
0 2 1 * * root mysql -u root -pPASSWORD btc_log -e "CALL CreateMonthlyPartition('business_operation_log', DATE_ADD(CURDATE(), INTERVAL 1 MONTH));"

# 每月15号清理6个月前的分区
0 3 15 * * root mysql -u root -pPASSWORD btc_log -e "CALL DropOldPartitions('user_behavior_log', 6);"
0 3 15 * * root mysql -u root -pPASSWORD btc_log -e "CALL DropOldPartitions('system_runtime_log', 6);"
0 3 15 * * root mysql -u root -pPASSWORD btc_log -e "CALL DropOldPartitions('business_operation_log', 6);"
EOF
```

## 性能优化配置

### 1. 索引优化

```sql
-- 为高频查询创建复合索引
USE btc_core;

-- 工单查询优化
CREATE INDEX idx_work_order_composite ON work_order(tenant_id, site_id, status, planned_start_date);

-- 追溯查询优化
CREATE INDEX idx_trace_event_composite ON trace_event(tenant_id, site_id, entity_type, entity_id, occurred_at);

-- 库存查询优化
CREATE INDEX idx_stock_composite ON stock(tenant_id, item_id, location_id, status);

-- 检验查询优化
CREATE INDEX idx_inspection_composite ON inspection(tenant_id, type, result, inspection_date);
```

### 2. 分区策略

```sql
-- 为大表配置分区（示例：trace_event表）
USE btc_core;

ALTER TABLE trace_event 
PARTITION BY RANGE (TO_DAYS(occurred_at)) (
    PARTITION p202501 VALUES LESS THAN (TO_DAYS('2025-02-01')),
    PARTITION p202502 VALUES LESS THAN (TO_DAYS('2025-03-01')),
    PARTITION p202503 VALUES LESS THAN (TO_DAYS('2025-04-01')),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);
```

### 3. 查询优化

```sql
-- 启用查询缓存
SET GLOBAL query_cache_size = 268435456; -- 256MB
SET GLOBAL query_cache_type = 1;

-- 优化InnoDB
SET GLOBAL innodb_buffer_pool_size = 17179869184; -- 16GB
SET GLOBAL innodb_log_file_size = 536870912; -- 512MB

-- 启用慢查询日志
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2;
```

## 监控配置

### 1. 性能监控

```sql
-- 创建性能监控视图
USE btc_core;

CREATE VIEW v_database_performance AS
SELECT 
    'btc_core' as database_name,
    TABLE_NAME,
    TABLE_ROWS,
    DATA_LENGTH,
    INDEX_LENGTH,
    DATA_FREE,
    ROUND((DATA_FREE / (DATA_LENGTH + INDEX_LENGTH)) * 100, 2) AS fragmentation_pct
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'btc_core' 
  AND TABLE_TYPE = 'BASE TABLE'
ORDER BY (DATA_LENGTH + INDEX_LENGTH) DESC;
```

### 2. 告警配置

```bash
# 创建数据库监控脚本
cat > /usr/local/bin/btc-db-monitor.sh << 'EOF'
#!/bin/bash

# 数据库连接检查
check_db_connection() {
    local db_name=$1
    local user=$2
    local password=$3
    
    if mysql -u $user -p$password -e "SELECT 1;" $db_name >/dev/null 2>&1; then
        echo "✓ $db_name connection OK"
        return 0
    else
        echo "✗ $db_name connection FAILED"
        return 1
    fi
}

# 检查所有数据库
check_db_connection "btc_core" "btc_app" "BTC_APP_PASSWORD_2025"
check_db_connection "btc_log" "btc_log" "BTC_LOG_PASSWORD_2025"
check_db_connection "btc_bi" "btc_bi" "BTC_BI_PASSWORD_2025"

# 检查磁盘空间
DISK_USAGE=$(df /var/lib/mysql | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    echo "⚠ Disk usage is ${DISK_USAGE}%"
fi

# 检查连接数
CONNECTIONS=$(mysql -u root -pPASSWORD -e "SHOW STATUS LIKE 'Threads_connected';" | awk 'NR==2 {print $2}')
if [ $CONNECTIONS -gt 800 ]; then
    echo "⚠ High connection count: $CONNECTIONS"
fi
EOF

chmod +x /usr/local/bin/btc-db-monitor.sh

# 添加到crontab
echo "*/5 * * * * /usr/local/bin/btc-db-monitor.sh" >> /etc/crontab
```

## 备份策略

### 1. 全量备份脚本

```bash
cat > /usr/local/bin/mes-db-backup.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="/backup/mysql"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=30

# 创建备份目录
mkdir -p $BACKUP_DIR

# 备份btc_core
mysqldump -u root -pPASSWORD \
    --single-transaction \
    --routines \
    --triggers \
    --events \
    --hex-blob \
    --master-data=2 \
    --flush-logs \
    btc_core > $BACKUP_DIR/btc_core_${DATE}.sql

# 备份btc_log（只备份结构，数据按分区管理）
mysqldump -u root -pPASSWORD \
    --no-data \
    --routines \
    --triggers \
    --events \
    btc_log > $BACKUP_DIR/btc_log_${DATE}.sql

# 备份btc_bi
mysqldump -u root -pPASSWORD \
    --single-transaction \
    --routines \
    --triggers \
    --events \
    --hex-blob \
    btc_bi > $BACKUP_DIR/btc_bi_${DATE}.sql

# 压缩备份文件
gzip $BACKUP_DIR/*_${DATE}.sql

# 清理旧备份
find $BACKUP_DIR -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete

echo "Backup completed: $DATE"
EOF

chmod +x /usr/local/bin/btc-db-backup.sh

# 每日凌晨2点执行备份
echo "0 2 * * * /usr/local/bin/btc-db-backup.sh" >> /etc/crontab
```

### 2. 增量备份配置

```bash
# 配置binlog备份
cat > /usr/local/bin/btc-binlog-backup.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="/backup/binlog"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# 刷新binlog
mysql -u root -pPASSWORD -e "FLUSH LOGS;"

# 备份binlog文件
cp /var/lib/mysql/mysql-bin.* $BACKUP_DIR/

# 清理7天前的binlog备份
find $BACKUP_DIR -name "mysql-bin.*" -mtime +7 -delete
EOF

chmod +x /usr/local/bin/btc-binlog-backup.sh

# 每小时执行binlog备份
echo "0 * * * * /usr/local/bin/btc-binlog-backup.sh" >> /etc/crontab
```

## 高可用配置

### 1. 主从复制配置

```ini
# 主库配置 (my.cnf)
[mysqld]
server-id = 1
log-bin = mysql-bin
binlog-format = ROW
gtid-mode = ON
enforce-gtid-consistency = ON

# 从库配置 (my.cnf)
[mysqld]
server-id = 2
relay-log = mysql-relay-bin
read-only = 1
gtid-mode = ON
enforce-gtid-consistency = ON
```

### 2. 读写分离配置

```yaml
# 应用配置示例
database:
  master:
    host: mysql-master
    port: 3306
    database: btc_core
    username: btc_app
    password: BTC_APP_PASSWORD_2025
  
  slaves:
    - host: mysql-slave1
      port: 3306
      database: btc_core
      username: btc_app
      password: BTC_APP_PASSWORD_2025
    - host: mysql-slave2
      port: 3306
      database: btc_core
      username: btc_app
      password: BTC_APP_PASSWORD_2025
```

## 故障恢复

### 1. 数据恢复流程

```bash
# 停止应用服务
systemctl stop btc-backend
systemctl stop btc-frontend

# 恢复全量备份
gunzip -c /backup/mysql/btc_core_20250107_020000.sql.gz | mysql -u root -p btc_core

# 应用增量备份（binlog）
mysqlbinlog /backup/binlog/mysql-bin.000123 | mysql -u root -p btc_core

# 启动应用服务
systemctl start btc-backend
systemctl start btc-frontend
```

### 2. 表级恢复

```bash
# 恢复单个表
gunzip -c /backup/mysql/btc_core_20250107_020000.sql.gz | \
grep -A 1000 "CREATE TABLE \`table_name\`" | \
mysql -u root -p btc_core
```

## 运维检查清单

### 日常检查项目
- [ ] 数据库连接状态
- [ ] 磁盘空间使用率
- [ ] 连接数监控
- [ ] 慢查询日志
- [ ] 错误日志
- [ ] 备份文件完整性
- [ ] 分区创建状态
- [ ] 索引使用情况

### 周度检查项目
- [ ] 数据库性能分析
- [ ] 存储空间增长趋势
- [ ] 慢查询优化
- [ ] 索引优化建议
- [ ] 备份恢复测试
- [ ] 分区清理执行
- [ ] 监控告警测试

### 月度检查项目
- [ ] 数据库版本更新
- [ ] 安全补丁安装
- [ ] 性能基线更新
- [ ] 容量规划评估
- [ ] 灾难恢复演练
- [ ] 文档更新维护

## 总结

MES系统数据库架构采用三库分离设计，实现了业务数据、日志数据和BI数据的有效隔离，通过完善的监控、备份和恢复机制，确保系统的稳定性和可维护性。

### 关键特性
1. **三库分离**: 核心业务、日志、BI数据独立管理
2. **分区策略**: 大表按时间分区，支持自动管理
3. **性能优化**: 完善的索引和查询优化策略
4. **监控告警**: 全面的数据库监控和告警机制
5. **备份恢复**: 多层次备份和快速恢复能力
6. **高可用**: 主从复制和读写分离支持

这个架构为MES系统提供了坚实的数据基础，能够支撑大规模的生产制造业务需求。
