# 数据库维护手册

## 概述
本手册描述了MES系统MySQL数据库的日常维护、备份恢复、性能优化和故障处理流程。

## 日常维护任务

### 1. 数据库健康检查
```bash
# 检查数据库状态
mysql -u root -p -e "SHOW STATUS LIKE 'Uptime';"

# 检查连接数
mysql -u root -p -e "SHOW STATUS LIKE 'Threads_connected';"

# 检查慢查询
mysql -u root -p -e "SHOW STATUS LIKE 'Slow_queries';"

# 检查锁等待
mysql -u root -p -e "SHOW STATUS LIKE 'Innodb_row_lock_waits';"
```

### 2. 日志文件清理
```bash
# 清理二进制日志（保留7天）
mysql -u root -p -e "PURGE BINARY LOGS BEFORE DATE_SUB(NOW(), INTERVAL 7 DAY);"

# 清理错误日志（保留30天）
find /var/log/mysql/ -name "error.log*" -mtime +30 -delete

# 清理慢查询日志（保留7天）
find /var/log/mysql/ -name "slow.log*" -mtime +7 -delete
```

### 3. 表维护
```sql
-- 检查表碎片
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    DATA_LENGTH,
    INDEX_LENGTH,
    DATA_FREE,
    ROUND((DATA_FREE / (DATA_LENGTH + INDEX_LENGTH)) * 100, 2) AS fragmentation_pct
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'mes_core' 
    AND DATA_FREE > 0
    AND (DATA_LENGTH + INDEX_LENGTH) > 0
ORDER BY fragmentation_pct DESC;

-- 优化碎片化严重的表
OPTIMIZE TABLE mes_core.trace_event;
OPTIMIZE TABLE mes_core.test_record;
OPTIMIZE TABLE mes_core.stock_transaction;
```

## 备份策略

### 1. 全量备份
```bash
#!/bin/bash
# 全量备份脚本
BACKUP_DIR="/backup/mysql"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="mes_full_backup_${DATE}.sql"

# 创建备份目录
mkdir -p $BACKUP_DIR

# 执行全量备份
mysqldump -u root -p \
    --single-transaction \
    --routines \
    --triggers \
    --events \
    --hex-blob \
    --master-data=2 \
    --flush-logs \
    --all-databases > $BACKUP_DIR/$BACKUP_FILE

# 压缩备份文件
gzip $BACKUP_DIR/$BACKUP_FILE

# 删除7天前的备份
find $BACKUP_DIR -name "mes_full_backup_*.sql.gz" -mtime +7 -delete
```

### 2. 增量备份
```bash
#!/bin/bash
# 增量备份脚本
BACKUP_DIR="/backup/mysql/incremental"
DATE=$(date +%Y%m%d_%H%M%S)

# 创建备份目录
mkdir -p $BACKUP_DIR

# 刷新二进制日志
mysql -u root -p -e "FLUSH LOGS;"

# 复制二进制日志
cp /var/lib/mysql/mysql-bin.* $BACKUP_DIR/

# 删除7天前的增量备份
find $BACKUP_DIR -name "mysql-bin.*" -mtime +7 -delete
```

### 3. 自动备份配置
```bash
# 添加到crontab
# 每天凌晨2点执行全量备份
0 2 * * * /scripts/mysql_full_backup.sh

# 每小时执行增量备份
0 * * * * /scripts/mysql_incremental_backup.sh
```

## 恢复流程

### 1. 全量恢复
```bash
# 停止MySQL服务
systemctl stop mysql

# 恢复全量备份
gunzip -c /backup/mysql/mes_full_backup_20250107_020000.sql.gz | mysql -u root -p

# 启动MySQL服务
systemctl start mysql
```

### 2. 时间点恢复
```bash
# 恢复全量备份
gunzip -c /backup/mysql/mes_full_backup_20250107_020000.sql.gz | mysql -u root -p

# 应用增量备份（二进制日志）
mysqlbinlog /backup/mysql/incremental/mysql-bin.000123 | mysql -u root -p
```

## 性能优化

### 1. 索引优化
```sql
-- 检查未使用的索引
SELECT 
    OBJECT_SCHEMA,
    OBJECT_NAME,
    INDEX_NAME,
    COUNT_READ,
    COUNT_FETCH,
    COUNT_INSERT,
    COUNT_UPDATE,
    COUNT_DELETE
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE OBJECT_SCHEMA = 'mes_core'
    AND COUNT_STAR = 0
ORDER BY OBJECT_NAME, INDEX_NAME;

-- 删除未使用的索引
ALTER TABLE mes_core.work_order DROP INDEX idx_unused;
```

### 2. 查询优化
```sql
-- 启用慢查询日志
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2;
SET GLOBAL log_queries_not_using_indexes = 'ON';

-- 分析慢查询
SELECT 
    sql_text,
    exec_count,
    avg_timer_wait/1000000000 as avg_time_sec,
    sum_timer_wait/1000000000 as total_time_sec
FROM performance_schema.events_statements_summary_by_digest
WHERE SCHEMA_NAME = 'mes_core'
    AND avg_timer_wait/1000000000 > 1
ORDER BY avg_timer_wait DESC;
```

### 3. 配置优化
```ini
# /etc/mysql/mysql.conf.d/mysqld.cnf
[mysqld]
# 内存配置
innodb_buffer_pool_size = 2G
innodb_log_buffer_size = 64M
key_buffer_size = 256M

# 连接配置
max_connections = 200
max_connect_errors = 1000

# 查询缓存
query_cache_size = 128M
query_cache_type = 1

# 慢查询
slow_query_log = 1
long_query_time = 2
log_queries_not_using_indexes = 1

# 二进制日志
log-bin = mysql-bin
binlog_format = ROW
expire_logs_days = 7
max_binlog_size = 100M
```

## 故障处理

### 1. 连接数过多
```sql
-- 查看当前连接
SHOW PROCESSLIST;

-- 查看连接详情
SELECT 
    ID,
    USER,
    HOST,
    DB,
    COMMAND,
    TIME,
    STATE,
    INFO
FROM information_schema.PROCESSLIST
WHERE COMMAND != 'Sleep'
ORDER BY TIME DESC;

-- 杀死长时间运行的查询
KILL 12345;
```

### 2. 死锁处理
```sql
-- 查看死锁信息
SHOW ENGINE INNODB STATUS;

-- 查看当前锁等待
SELECT 
    r.trx_id waiting_trx_id,
    r.trx_mysql_thread_id waiting_thread,
    r.trx_query waiting_query,
    b.trx_id blocking_trx_id,
    b.trx_mysql_thread_id blocking_thread,
    b.trx_query blocking_query
FROM information_schema.innodb_lock_waits w
INNER JOIN information_schema.innodb_trx b ON b.trx_id = w.blocking_trx_id
INNER JOIN information_schema.innodb_trx r ON r.trx_id = w.requesting_trx_id;
```

### 3. 磁盘空间不足
```bash
# 检查磁盘使用情况
df -h

# 清理临时文件
rm -rf /tmp/mysql*

# 清理二进制日志
mysql -u root -p -e "PURGE BINARY LOGS BEFORE DATE_SUB(NOW(), INTERVAL 1 DAY);"

# 清理错误日志
find /var/log/mysql/ -name "*.log*" -mtime +1 -delete
```

### 4. 数据损坏
```bash
# 检查表完整性
mysqlcheck -u root -p --check mes_core

# 修复损坏的表
mysqlcheck -u root -p --repair mes_core

# 使用InnoDB恢复
# 在my.cnf中添加
innodb_force_recovery = 1
```

## 监控指标

### 1. 关键指标
- **连接数**: `Threads_connected`
- **查询数**: `Queries`
- **慢查询数**: `Slow_queries`
- **锁等待数**: `Innodb_row_lock_waits`
- **缓存命中率**: `Qcache_hits / (Qcache_hits + Qcache_inserts)`

### 2. 告警阈值
- 连接数 > 150 (80% of max_connections)
- 慢查询数 > 10/minute
- 锁等待数 > 5/minute
- 缓存命中率 < 90%

## 安全维护

### 1. 用户权限管理
```sql
-- 创建只读用户
CREATE USER 'mes_readonly'@'%' IDENTIFIED BY 'strong_password';
GRANT SELECT ON mes_core.* TO 'mes_readonly'@'%';

-- 创建备份用户
CREATE USER 'mes_backup'@'localhost' IDENTIFIED BY 'backup_password';
GRANT SELECT, LOCK TABLES, SHOW VIEW, EVENT, TRIGGER ON *.* TO 'mes_backup'@'localhost';

-- 定期修改密码
ALTER USER 'mes_app'@'%' IDENTIFIED BY 'new_password';
```

### 2. 审计日志
```sql
-- 启用审计插件
INSTALL PLUGIN audit_log SONAME 'audit_log.so';

-- 配置审计日志
SET GLOBAL audit_log_policy = 'ALL';
SET GLOBAL audit_log_file = '/var/log/mysql/audit.log';
```

## 升级维护

### 1. 版本升级
```bash
# 备份数据库
mysqldump -u root -p --all-databases > upgrade_backup.sql

# 停止服务
systemctl stop mysql

# 升级MySQL
apt update
apt install mysql-server-8.0

# 启动服务
systemctl start mysql

# 验证升级
mysql -u root -p -e "SELECT VERSION();"
```

### 2. 字符集升级
```sql
-- 检查字符集
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_COLLATION
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'mes_core'
    AND TABLE_COLLATION != 'utf8mb4_unicode_ci';

-- 转换字符集
ALTER TABLE mes_core.work_order CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

## 联系信息
- 数据库管理员: DBA Team
- 紧急联系: +86-xxx-xxxx-xxxx
- 邮箱: dba@company.com
- 值班电话: +86-xxx-xxxx-xxxx
