# 备份恢复归档

## 概述

本文档描述了MES系统的数据备份、恢复和归档策略，确保数据的安全性、可用性和合规性。包括备份策略、恢复流程、归档管理和灾难恢复方案。

## 备份策略

### 备份类型

#### 全量备份 (Full Backup)
- **频率**：每日一次
- **时间**：凌晨2:00-4:00（业务低峰期）
- **保留期**：30天
- **存储位置**：本地存储 + 异地存储
- **压缩**：启用压缩减少存储空间

#### 增量备份 (Incremental Backup)
- **频率**：每小时一次
- **时间**：每小时整点
- **保留期**：7天
- **存储位置**：本地存储
- **压缩**：启用压缩

#### 差异备份 (Differential Backup)
- **频率**：每4小时一次
- **时间**：00:00, 04:00, 08:00, 12:00, 16:00, 20:00
- **保留期**：14天
- **存储位置**：本地存储
- **压缩**：启用压缩

### 备份配置

#### PostgreSQL备份配置
```bash
#!/bin/bash
# postgres-backup.sh

# 配置变量
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="mes_core"
DB_USER="mes_backup"
BACKUP_DIR="/backup/postgresql"
RETENTION_DAYS=30
COMPRESSION_LEVEL=9

# 创建备份目录
mkdir -p $BACKUP_DIR/{full,incremental,differential}
mkdir -p $BACKUP_DIR/logs

# 日志函数
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $BACKUP_DIR/logs/backup.log
}

# 全量备份函数
full_backup() {
    local backup_file="$BACKUP_DIR/full/mes_core_full_$(date +%Y%m%d_%H%M%S).sql.gz"
    
    log_message "开始全量备份: $backup_file"
    
    pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME \
        --verbose --no-password --format=plain \
        --exclude-table-data=audit_logs \
        --exclude-table-data=security_events \
        --exclude-table-data=login_attempts \
        | gzip -$COMPRESSION_LEVEL > $backup_file
    
    if [ $? -eq 0 ]; then
        log_message "全量备份成功: $backup_file"
        
        # 计算备份文件大小
        local backup_size=$(du -h $backup_file | cut -f1)
        log_message "备份文件大小: $backup_size"
        
        # 上传到异地存储
        upload_to_remote_storage $backup_file
        
        # 清理过期备份
        cleanup_old_backups $BACKUP_DIR/full $RETENTION_DAYS
    else
        log_message "全量备份失败"
        exit 1
    fi
}

# 增量备份函数
incremental_backup() {
    local backup_file="$BACKUP_DIR/incremental/mes_core_inc_$(date +%Y%m%d_%H%M%S).sql.gz"
    local last_backup_time=$(get_last_backup_time)
    
    log_message "开始增量备份: $backup_file"
    
    pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME \
        --verbose --no-password --format=plain \
        --exclude-table-data=audit_logs \
        --exclude-table-data=security_events \
        --exclude-table-data=login_attempts \
        --where="updated_at > '$last_backup_time'" \
        | gzip -$COMPRESSION_LEVEL > $backup_file
    
    if [ $? -eq 0 ]; then
        log_message "增量备份成功: $backup_file"
        
        # 计算备份文件大小
        local backup_size=$(du -h $backup_file | cut -f1)
        log_message "备份文件大小: $backup_size"
        
        # 清理过期备份
        cleanup_old_backups $BACKUP_DIR/incremental 7
    else
        log_message "增量备份失败"
        exit 1
    fi
}

# 差异备份函数
differential_backup() {
    local backup_file="$BACKUP_DIR/differential/mes_core_diff_$(date +%Y%m%d_%H%M%S).sql.gz"
    local last_full_backup_time=$(get_last_full_backup_time)
    
    log_message "开始差异备份: $backup_file"
    
    pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME \
        --verbose --no-password --format=plain \
        --exclude-table-data=audit_logs \
        --exclude-table-data=security_events \
        --exclude-table-data=login_attempts \
        --where="updated_at > '$last_full_backup_time'" \
        | gzip -$COMPRESSION_LEVEL > $backup_file
    
    if [ $? -eq 0 ]; then
        log_message "差异备份成功: $backup_file"
        
        # 计算备份文件大小
        local backup_size=$(du -h $backup_file | cut -f1)
        log_message "备份文件大小: $backup_size"
        
        # 清理过期备份
        cleanup_old_backups $BACKUP_DIR/differential 14
    else
        log_message "差异备份失败"
        exit 1
    fi
}

# 获取最后备份时间
get_last_backup_time() {
    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "
        SELECT COALESCE(MAX(operation_timestamp), '1970-01-01'::timestamp)
        FROM audit_logs
        WHERE operation_timestamp >= CURRENT_DATE - INTERVAL '1 day';
    " | tr -d ' '
}

# 获取最后全量备份时间
get_last_full_backup_time() {
    ls -t $BACKUP_DIR/full/mes_core_full_*.sql.gz | head -1 | sed 's/.*mes_core_full_\([0-9_]*\)\.sql\.gz/\1/' | sed 's/_/ /' | sed 's/\([0-9]\{8\}\) \([0-9]\{6\}\)/\1 \2/' | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\) \([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3 \4:\5:\6/'
}

# 上传到远程存储
upload_to_remote_storage() {
    local backup_file=$1
    
    log_message "上传备份到远程存储: $backup_file"
    
    # 使用rsync上传到远程服务器
    rsync -avz --progress $backup_file backup-server:/backup/mes_core/
    
    if [ $? -eq 0 ]; then
        log_message "远程存储上传成功"
    else
        log_message "远程存储上传失败"
    fi
}

# 清理过期备份
cleanup_old_backups() {
    local backup_dir=$1
    local retention_days=$2
    
    log_message "清理过期备份: $backup_dir (保留 $retention_days 天)"
    
    find $backup_dir -name "*.sql.gz" -mtime +$retention_days -delete
    
    log_message "过期备份清理完成"
}

# 主函数
main() {
    case $1 in
        "full")
            full_backup
            ;;
        "incremental")
            incremental_backup
            ;;
        "differential")
            differential_backup
            ;;
        *)
            echo "用法: $0 {full|incremental|differential}"
            exit 1
            ;;
    esac
}

# 执行主函数
main $1
```

#### MySQL备份配置
```bash
#!/bin/bash
# mysql-backup.sh

# 配置变量
DB_HOST="localhost"
DB_PORT="3306"
DB_NAME="mes_core"
DB_USER="mes_backup"
DB_PASSWORD="backup_password"
BACKUP_DIR="/backup/mysql"
RETENTION_DAYS=30
COMPRESSION_LEVEL=9

# 创建备份目录
mkdir -p $BACKUP_DIR/{full,incremental,differential}
mkdir -p $BACKUP_DIR/logs

# 日志函数
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $BACKUP_DIR/logs/backup.log
}

# 全量备份函数
full_backup() {
    local backup_file="$BACKUP_DIR/full/mes_core_full_$(date +%Y%m%d_%H%M%S).sql.gz"
    
    log_message "开始全量备份: $backup_file"
    
    mysqldump -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD \
        --single-transaction --routines --triggers \
        --ignore-table=$DB_NAME.audit_logs \
        --ignore-table=$DB_NAME.security_events \
        --ignore-table=$DB_NAME.login_attempts \
        $DB_NAME | gzip -$COMPRESSION_LEVEL > $backup_file
    
    if [ $? -eq 0 ]; then
        log_message "全量备份成功: $backup_file"
        
        # 计算备份文件大小
        local backup_size=$(du -h $backup_file | cut -f1)
        log_message "备份文件大小: $backup_size"
        
        # 上传到异地存储
        upload_to_remote_storage $backup_file
        
        # 清理过期备份
        cleanup_old_backups $BACKUP_DIR/full $RETENTION_DAYS
    else
        log_message "全量备份失败"
        exit 1
    fi
}

# 增量备份函数
incremental_backup() {
    local backup_file="$BACKUP_DIR/incremental/mes_core_inc_$(date +%Y%m%d_%H%M%S).sql.gz"
    
    log_message "开始增量备份: $backup_file"
    
    # 启用二进制日志
    mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD -e "FLUSH LOGS;"
    
    # 获取二进制日志文件
    local binlog_files=$(mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD -e "SHOW BINARY LOGS;" | grep -v "Log_name" | awk '{print $1}')
    
    # 备份二进制日志
    for binlog_file in $binlog_files; do
        mysqlbinlog -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD \
            --read-from-remote-server --raw $binlog_file
    done
    
    # 压缩二进制日志
    tar -czf $backup_file mysql-bin.*
    
    if [ $? -eq 0 ]; then
        log_message "增量备份成功: $backup_file"
        
        # 计算备份文件大小
        local backup_size=$(du -h $backup_file | cut -f1)
        log_message "备份文件大小: $backup_size"
        
        # 清理过期备份
        cleanup_old_backups $BACKUP_DIR/incremental 7
    else
        log_message "增量备份失败"
        exit 1
    fi
}

# 差异备份函数
differential_backup() {
    local backup_file="$BACKUP_DIR/differential/mes_core_diff_$(date +%Y%m%d_%H%M%S).sql.gz"
    local last_full_backup_time=$(get_last_full_backup_time)
    
    log_message "开始差异备份: $backup_file"
    
    mysqldump -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD \
        --single-transaction --routines --triggers \
        --where="updated_at > '$last_full_backup_time'" \
        --ignore-table=$DB_NAME.audit_logs \
        --ignore-table=$DB_NAME.security_events \
        --ignore-table=$DB_NAME.login_attempts \
        $DB_NAME | gzip -$COMPRESSION_LEVEL > $backup_file
    
    if [ $? -eq 0 ]; then
        log_message "差异备份成功: $backup_file"
        
        # 计算备份文件大小
        local backup_size=$(du -h $backup_file | cut -f1)
        log_message "备份文件大小: $backup_size"
        
        # 清理过期备份
        cleanup_old_backups $BACKUP_DIR/differential 14
    else
        log_message "差异备份失败"
        exit 1
    fi
}

# 获取最后全量备份时间
get_last_full_backup_time() {
    ls -t $BACKUP_DIR/full/mes_core_full_*.sql.gz | head -1 | sed 's/.*mes_core_full_\([0-9_]*\)\.sql\.gz/\1/' | sed 's/_/ /' | sed 's/\([0-9]\{8\}\) \([0-9]\{6\}\)/\1 \2/' | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\) \([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3 \4:\5:\6/'
}

# 上传到远程存储
upload_to_remote_storage() {
    local backup_file=$1
    
    log_message "上传备份到远程存储: $backup_file"
    
    # 使用rsync上传到远程服务器
    rsync -avz --progress $backup_file backup-server:/backup/mes_core/
    
    if [ $? -eq 0 ]; then
        log_message "远程存储上传成功"
    else
        log_message "远程存储上传失败"
    fi
}

# 清理过期备份
cleanup_old_backups() {
    local backup_dir=$1
    local retention_days=$2
    
    log_message "清理过期备份: $backup_dir (保留 $retention_days 天)"
    
    find $backup_dir -name "*.sql.gz" -mtime +$retention_days -delete
    
    log_message "过期备份清理完成"
}

# 主函数
main() {
    case $1 in
        "full")
            full_backup
            ;;
        "incremental")
            incremental_backup
            ;;
        "differential")
            differential_backup
            ;;
        *)
            echo "用法: $0 {full|incremental|differential}"
            exit 1
            ;;
    esac
}

# 执行主函数
main $1
```

### 备份调度

#### Cron任务配置
```bash
# 编辑crontab
crontab -e

# 添加备份任务
# 每日凌晨2点全量备份
0 2 * * * /opt/scripts/postgres-backup.sh full

# 每小时增量备份
0 * * * * /opt/scripts/postgres-backup.sh incremental

# 每4小时差异备份
0 0,4,8,12,16,20 * * * /opt/scripts/postgres-backup.sh differential

# 每周日凌晨3点备份验证
0 3 * * 0 /opt/scripts/backup-verify.sh

# 每月1日凌晨4点备份清理
0 4 1 * * /opt/scripts/backup-cleanup.sh
```

#### 备份监控
```bash
#!/bin/bash
# backup-monitor.sh

BACKUP_DIR="/backup/postgresql"
LOG_FILE="$BACKUP_DIR/logs/backup.log"
ALERT_EMAIL="admin@example.com"

# 检查备份状态
check_backup_status() {
    local backup_type=$1
    local backup_dir="$BACKUP_DIR/$backup_type"
    local last_backup=$(ls -t $backup_dir/*.sql.gz 2>/dev/null | head -1)
    
    if [ -z "$last_backup" ]; then
        echo "ERROR: 没有找到 $backup_type 备份文件"
        return 1
    fi
    
    local last_backup_time=$(stat -c %Y $last_backup)
    local current_time=$(date +%s)
    local time_diff=$((current_time - last_backup_time))
    
    # 检查备份时间
    case $backup_type in
        "full")
            if [ $time_diff -gt 86400 ]; then  # 24小时
                echo "ERROR: 全量备份超过24小时未执行"
                return 1
            fi
            ;;
        "incremental")
            if [ $time_diff -gt 3600 ]; then  # 1小时
                echo "ERROR: 增量备份超过1小时未执行"
                return 1
            fi
            ;;
        "differential")
            if [ $time_diff -gt 14400 ]; then  # 4小时
                echo "ERROR: 差异备份超过4小时未执行"
                return 1
            fi
            ;;
    esac
    
    echo "INFO: $backup_type 备份正常"
    return 0
}

# 发送告警邮件
send_alert() {
    local message=$1
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> $LOG_FILE
    
    # 发送邮件告警
    echo "$message" | mail -s "MES备份告警" $ALERT_EMAIL
}

# 主函数
main() {
    local errors=0
    
    # 检查各种备份状态
    check_backup_status "full" || errors=$((errors + 1))
    check_backup_status "incremental" || errors=$((errors + 1))
    check_backup_status "differential" || errors=$((errors + 1))
    
    if [ $errors -gt 0 ]; then
        send_alert "备份监控发现 $errors 个问题"
        exit 1
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - 备份监控正常" >> $LOG_FILE
    fi
}

# 执行主函数
main
```

## 恢复流程

### 恢复类型

#### 完全恢复
- **场景**：数据库完全损坏或丢失
- **RTO**：4小时
- **RPO**：1小时
- **步骤**：全量备份 + 增量备份 + 日志恢复

#### 部分恢复
- **场景**：特定表或数据损坏
- **RTO**：2小时
- **RPO**：30分钟
- **步骤**：表级恢复 + 数据验证

#### 时间点恢复
- **场景**：恢复到特定时间点
- **RTO**：3小时
- **RPO**：15分钟
- **步骤**：全量备份 + 日志恢复到指定时间点

### 恢复脚本

#### PostgreSQL恢复脚本
```bash
#!/bin/bash
# postgres-restore.sh

# 配置变量
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="mes_core"
DB_USER="mes_admin"
BACKUP_DIR="/backup/postgresql"
RESTORE_DIR="/tmp/restore"

# 创建恢复目录
mkdir -p $RESTORE_DIR

# 日志函数
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $RESTORE_DIR/restore.log
}

# 完全恢复函数
full_restore() {
    local backup_file=$1
    local target_time=$2
    
    log_message "开始完全恢复: $backup_file"
    
    # 停止应用程序
    log_message "停止应用程序..."
    systemctl stop mes-app
    
    # 备份当前数据库
    log_message "备份当前数据库..."
    pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME > $RESTORE_DIR/current_backup.sql
    
    # 删除现有数据库
    log_message "删除现有数据库..."
    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "DROP DATABASE IF EXISTS $DB_NAME;"
    
    # 创建新数据库
    log_message "创建新数据库..."
    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "CREATE DATABASE $DB_NAME;"
    
    # 恢复全量备份
    log_message "恢复全量备份..."
    gunzip -c $backup_file | psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME
    
    if [ $? -eq 0 ]; then
        log_message "全量备份恢复成功"
        
        # 恢复增量备份
        if [ -n "$target_time" ]; then
            restore_incremental_backups $target_time
        fi
        
        # 验证数据完整性
        verify_data_integrity
        
        # 启动应用程序
        log_message "启动应用程序..."
        systemctl start mes-app
        
        log_message "完全恢复完成"
    else
        log_message "完全恢复失败"
        exit 1
    fi
}

# 恢复增量备份
restore_incremental_backups() {
    local target_time=$1
    
    log_message "恢复增量备份到时间点: $target_time"
    
    # 查找目标时间点之前的增量备份
    local incremental_backups=$(find $BACKUP_DIR/incremental -name "*.sql.gz" -newermt "$target_time" | sort)
    
    for backup in $incremental_backups; do
        log_message "恢复增量备份: $backup"
        gunzip -c $backup | psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME
    done
}

# 表级恢复函数
table_restore() {
    local table_name=$1
    local backup_file=$2
    
    log_message "开始表级恢复: $table_name"
    
    # 备份当前表
    log_message "备份当前表: $table_name"
    pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t $table_name > $RESTORE_DIR/${table_name}_backup.sql
    
    # 删除现有表
    log_message "删除现有表: $table_name"
    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "DROP TABLE IF EXISTS $table_name CASCADE;"
    
    # 恢复表
    log_message "恢复表: $table_name"
    gunzip -c $backup_file | psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME
    
    if [ $? -eq 0 ]; then
        log_message "表级恢复成功: $table_name"
        
        # 验证表数据
        verify_table_integrity $table_name
    else
        log_message "表级恢复失败: $table_name"
        exit 1
    fi
}

# 验证数据完整性
verify_data_integrity() {
    log_message "验证数据完整性..."
    
    # 检查表数量
    local table_count=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "
        SELECT COUNT(*) FROM information_schema.tables 
        WHERE table_schema = 'mes_core';
    " | tr -d ' ')
    
    log_message "表数量: $table_count"
    
    # 检查关键表数据
    local plants_count=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM plants;" | tr -d ' ')
    local work_centers_count=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM work_centers;" | tr -d ' ')
    local equipment_count=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM equipment;" | tr -d ' ')
    local inventory_count=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM inventory;" | tr -d ' ')
    
    log_message "工厂数量: $plants_count"
    log_message "工作中心数量: $work_centers_count"
    log_message "设备数量: $equipment_count"
    log_message "库存数量: $inventory_count"
    
    # 检查外键约束
    local constraint_violations=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "
        SELECT COUNT(*) FROM work_centers wc 
        LEFT JOIN plants p ON wc.plant_id = p.plant_id 
        WHERE p.plant_id IS NULL;
    " | tr -d ' ')
    
    if [ "$constraint_violations" -gt 0 ]; then
        log_message "警告: 发现 $constraint_violations 个外键约束违反"
    else
        log_message "外键约束检查通过"
    fi
}

# 验证表完整性
verify_table_integrity() {
    local table_name=$1
    
    log_message "验证表完整性: $table_name"
    
    # 检查表是否存在
    local table_exists=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "
        SELECT COUNT(*) FROM information_schema.tables 
        WHERE table_schema = 'mes_core' AND table_name = '$table_name';
    " | tr -d ' ')
    
    if [ "$table_exists" -eq 0 ]; then
        log_message "错误: 表 $table_name 不存在"
        return 1
    fi
    
    # 检查表数据
    local row_count=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM $table_name;" | tr -d ' ')
    
    log_message "表 $table_name 数据行数: $row_count"
    
    return 0
}

# 主函数
main() {
    case $1 in
        "full")
            full_restore $2 $3
            ;;
        "table")
            table_restore $2 $3
            ;;
        "verify")
            verify_data_integrity
            ;;
        *)
            echo "用法: $0 {full|table|verify} [backup_file] [target_time]"
            exit 1
            ;;
    esac
}

# 执行主函数
main $@
```

#### MySQL恢复脚本
```bash
#!/bin/bash
# mysql-restore.sh

# 配置变量
DB_HOST="localhost"
DB_PORT="3306"
DB_NAME="mes_core"
DB_USER="mes_admin"
DB_PASSWORD="admin_password"
BACKUP_DIR="/backup/mysql"
RESTORE_DIR="/tmp/restore"

# 创建恢复目录
mkdir -p $RESTORE_DIR

# 日志函数
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $RESTORE_DIR/restore.log
}

# 完全恢复函数
full_restore() {
    local backup_file=$1
    local target_time=$2
    
    log_message "开始完全恢复: $backup_file"
    
    # 停止应用程序
    log_message "停止应用程序..."
    systemctl stop mes-app
    
    # 备份当前数据库
    log_message "备份当前数据库..."
    mysqldump -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD $DB_NAME > $RESTORE_DIR/current_backup.sql
    
    # 删除现有数据库
    log_message "删除现有数据库..."
    mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD -e "DROP DATABASE IF EXISTS $DB_NAME;"
    
    # 创建新数据库
    log_message "创建新数据库..."
    mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD -e "CREATE DATABASE $DB_NAME;"
    
    # 恢复全量备份
    log_message "恢复全量备份..."
    gunzip -c $backup_file | mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD $DB_NAME
    
    if [ $? -eq 0 ]; then
        log_message "全量备份恢复成功"
        
        # 恢复增量备份
        if [ -n "$target_time" ]; then
            restore_incremental_backups $target_time
        fi
        
        # 验证数据完整性
        verify_data_integrity
        
        # 启动应用程序
        log_message "启动应用程序..."
        systemctl start mes-app
        
        log_message "完全恢复完成"
    else
        log_message "完全恢复失败"
        exit 1
    fi
}

# 恢复增量备份
restore_incremental_backups() {
    local target_time=$1
    
    log_message "恢复增量备份到时间点: $target_time"
    
    # 查找目标时间点之前的增量备份
    local incremental_backups=$(find $BACKUP_DIR/incremental -name "*.sql.gz" -newermt "$target_time" | sort)
    
    for backup in $incremental_backups; do
        log_message "恢复增量备份: $backup"
        gunzip -c $backup | mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD $DB_NAME
    done
}

# 表级恢复函数
table_restore() {
    local table_name=$1
    local backup_file=$2
    
    log_message "开始表级恢复: $table_name"
    
    # 备份当前表
    log_message "备份当前表: $table_name"
    mysqldump -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD $DB_NAME $table_name > $RESTORE_DIR/${table_name}_backup.sql
    
    # 删除现有表
    log_message "删除现有表: $table_name"
    mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD $DB_NAME -e "DROP TABLE IF EXISTS $table_name;"
    
    # 恢复表
    log_message "恢复表: $table_name"
    gunzip -c $backup_file | mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD $DB_NAME
    
    if [ $? -eq 0 ]; then
        log_message "表级恢复成功: $table_name"
        
        # 验证表数据
        verify_table_integrity $table_name
    else
        log_message "表级恢复失败: $table_name"
        exit 1
    fi
}

# 验证数据完整性
verify_data_integrity() {
    log_message "验证数据完整性..."
    
    # 检查表数量
    local table_count=$(mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD $DB_NAME -e "SHOW TABLES;" | wc -l)
    
    log_message "表数量: $table_count"
    
    # 检查关键表数据
    local plants_count=$(mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD $DB_NAME -e "SELECT COUNT(*) FROM plants;" | tail -1)
    local work_centers_count=$(mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD $DB_NAME -e "SELECT COUNT(*) FROM work_centers;" | tail -1)
    local equipment_count=$(mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD $DB_NAME -e "SELECT COUNT(*) FROM equipment;" | tail -1)
    local inventory_count=$(mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD $DB_NAME -e "SELECT COUNT(*) FROM inventory;" | tail -1)
    
    log_message "工厂数量: $plants_count"
    log_message "工作中心数量: $work_centers_count"
    log_message "设备数量: $equipment_count"
    log_message "库存数量: $inventory_count"
    
    # 检查外键约束
    local constraint_violations=$(mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD $DB_NAME -e "
        SELECT COUNT(*) FROM work_centers wc 
        LEFT JOIN plants p ON wc.plant_id = p.plant_id 
        WHERE p.plant_id IS NULL;
    " | tail -1)
    
    if [ "$constraint_violations" -gt 0 ]; then
        log_message "警告: 发现 $constraint_violations 个外键约束违反"
    else
        log_message "外键约束检查通过"
    fi
}

# 验证表完整性
verify_table_integrity() {
    local table_name=$1
    
    log_message "验证表完整性: $table_name"
    
    # 检查表是否存在
    local table_exists=$(mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD $DB_NAME -e "SHOW TABLES LIKE '$table_name';" | wc -l)
    
    if [ "$table_exists" -eq 0 ]; then
        log_message "错误: 表 $table_name 不存在"
        return 1
    fi
    
    # 检查表数据
    local row_count=$(mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD $DB_NAME -e "SELECT COUNT(*) FROM $table_name;" | tail -1)
    
    log_message "表 $table_name 数据行数: $row_count"
    
    return 0
}

# 主函数
main() {
    case $1 in
        "full")
            full_restore $2 $3
            ;;
        "table")
            table_restore $2 $3
            ;;
        "verify")
            verify_data_integrity
            ;;
        *)
            echo "用法: $0 {full|table|verify} [backup_file] [target_time]"
            exit 1
            ;;
    esac
}

# 执行主函数
main $@
```

## 归档管理

### 归档策略

#### 数据分类归档
```sql
-- 创建归档配置表
CREATE TABLE IF NOT EXISTS archive_config (
    config_id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name varchar(64) NOT NULL,
    archive_condition text NOT NULL,
    archive_frequency varchar(32) NOT NULL, -- DAILY, WEEKLY, MONTHLY, QUARTERLY
    retention_period integer NOT NULL, -- 保留期限（天）
    archive_location varchar(256) NOT NULL,
    compression_enabled boolean NOT NULL DEFAULT true,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- 插入归档配置
INSERT INTO archive_config (table_name, archive_condition, archive_frequency, retention_period, archive_location) VALUES
    ('audit_logs', 'operation_timestamp < CURRENT_DATE - INTERVAL ''3 months''', 'MONTHLY', 3650, '/archive/audit_logs'),
    ('security_events', 'created_at < CURRENT_DATE - INTERVAL ''6 months''', 'MONTHLY', 2555, '/archive/security_events'),
    ('login_attempts', 'login_time < CURRENT_DATE - INTERVAL ''1 month''', 'WEEKLY', 365, '/archive/login_attempts'),
    ('inventory', 'updated_at < CURRENT_DATE - INTERVAL ''1 year''', 'QUARTERLY', 3650, '/archive/inventory'),
    ('calendar', 'date < CURRENT_DATE - INTERVAL ''2 years''', 'YEARLY', 3650, '/archive/calendar');
```

#### 归档脚本
```bash
#!/bin/bash
# archive-manager.sh

# 配置变量
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="mes_core"
DB_USER="mes_admin"
ARCHIVE_DIR="/archive"
LOG_FILE="$ARCHIVE_DIR/logs/archive.log"

# 创建归档目录
mkdir -p $ARCHIVE_DIR/{audit_logs,security_events,login_attempts,inventory,calendar}
mkdir -p $ARCHIVE_DIR/logs

# 日志函数
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# 归档表数据
archive_table() {
    local table_name=$1
    local archive_condition=$2
    local archive_location=$3
    local retention_period=$4
    local compression_enabled=$5
    
    log_message "开始归档表: $table_name"
    
    # 创建归档文件
    local archive_file="$archive_location/${table_name}_$(date +%Y%m%d_%H%M%S).sql"
    
    # 导出数据
    log_message "导出数据: $table_name"
    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
        COPY (
            SELECT * FROM $table_name 
            WHERE $archive_condition
        ) TO STDOUT WITH CSV HEADER;
    " > $archive_file
    
    if [ $? -eq 0 ]; then
        local record_count=$(wc -l < $archive_file)
        log_message "导出记录数: $record_count"
        
        # 压缩文件
        if [ "$compression_enabled" = true ]; then
            gzip $archive_file
            archive_file="${archive_file}.gz"
            log_message "文件已压缩: $archive_file"
        fi
        
        # 验证归档文件
        if [ -f "$archive_file" ]; then
            local file_size=$(du -h $archive_file | cut -f1)
            log_message "归档文件大小: $file_size"
            
            # 删除原表数据
            log_message "删除原表数据: $table_name"
            psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
                DELETE FROM $table_name 
                WHERE $archive_condition;
            "
            
            local deleted_count=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT ROW_COUNT();" | tr -d ' ')
            log_message "删除记录数: $deleted_count"
            
            # 清理过期归档文件
            cleanup_old_archives $archive_location $retention_period
            
            log_message "表归档完成: $table_name"
        else
            log_message "错误: 归档文件不存在: $archive_file"
            return 1
        fi
    else
        log_message "错误: 导出数据失败: $table_name"
        return 1
    fi
}

# 清理过期归档文件
cleanup_old_archives() {
    local archive_location=$1
    local retention_period=$2
    
    log_message "清理过期归档文件: $archive_location (保留 $retention_period 天)"
    
    find $archive_location -name "*.sql.gz" -mtime +$retention_period -delete
    
    log_message "过期归档文件清理完成"
}

# 归档所有表
archive_all_tables() {
    log_message "开始归档所有表"
    
    # 获取归档配置
    local archive_configs=$(psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "
        SELECT table_name, archive_condition, archive_location, retention_period, compression_enabled
        FROM archive_config
        WHERE is_active = true;
    ")
    
    # 处理每个归档配置
    while IFS='|' read -r table_name archive_condition archive_location retention_period compression_enabled; do
        # 去除空格
        table_name=$(echo $table_name | xargs)
        archive_condition=$(echo $archive_condition | xargs)
        archive_location=$(echo $archive_location | xargs)
        retention_period=$(echo $retention_period | xargs)
        compression_enabled=$(echo $compression_enabled | xargs)
        
        if [ -n "$table_name" ]; then
            archive_table "$table_name" "$archive_condition" "$archive_location" "$retention_period" "$compression_enabled"
        fi
    done <<< "$archive_configs"
    
    log_message "所有表归档完成"
}

# 恢复归档数据
restore_archive() {
    local table_name=$1
    local archive_file=$2
    
    log_message "开始恢复归档数据: $table_name"
    
    # 检查归档文件
    if [ ! -f "$archive_file" ]; then
        log_message "错误: 归档文件不存在: $archive_file"
        return 1
    fi
    
    # 解压文件（如果需要）
    if [[ "$archive_file" == *.gz ]]; then
        gunzip -c $archive_file > /tmp/${table_name}_restore.csv
        archive_file="/tmp/${table_name}_restore.csv"
    fi
    
    # 恢复数据
    log_message "恢复数据: $table_name"
    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "
        COPY $table_name FROM '$archive_file' WITH CSV HEADER;
    "
    
    if [ $? -eq 0 ]; then
        local record_count=$(wc -l < $archive_file)
        log_message "恢复记录数: $record_count"
        log_message "归档数据恢复完成: $table_name"
    else
        log_message "错误: 恢复数据失败: $table_name"
        return 1
    fi
    
    # 清理临时文件
    if [ -f "/tmp/${table_name}_restore.csv" ]; then
        rm -f "/tmp/${table_name}_restore.csv"
    fi
}

# 主函数
main() {
    case $1 in
        "archive")
            archive_all_tables
            ;;
        "restore")
            restore_archive $2 $3
            ;;
        "cleanup")
            cleanup_old_archives $2 $3
            ;;
        *)
            echo "用法: $0 {archive|restore|cleanup} [table_name] [archive_file]"
            exit 1
            ;;
    esac
}

# 执行主函数
main $@
```

### 归档监控

#### 归档监控脚本
```bash
#!/bin/bash
# archive-monitor.sh

ARCHIVE_DIR="/archive"
LOG_FILE="$ARCHIVE_DIR/logs/archive.log"
ALERT_EMAIL="admin@example.com"

# 检查归档状态
check_archive_status() {
    local table_name=$1
    local archive_location="$ARCHIVE_DIR/$table_name"
    
    if [ ! -d "$archive_location" ]; then
        echo "ERROR: 归档目录不存在: $archive_location"
        return 1
    fi
    
    # 检查最近归档文件
    local latest_archive=$(ls -t $archive_location/*.sql.gz 2>/dev/null | head -1)
    
    if [ -z "$latest_archive" ]; then
        echo "ERROR: 没有找到 $table_name 归档文件"
        return 1
    fi
    
    local archive_time=$(stat -c %Y $latest_archive)
    local current_time=$(date +%s)
    local time_diff=$((current_time - archive_time))
    
    # 检查归档时间
    case $table_name in
        "audit_logs")
            if [ $time_diff -gt 2592000 ]; then  # 30天
                echo "ERROR: $table_name 归档超过30天未执行"
                return 1
            fi
            ;;
        "security_events")
            if [ $time_diff -gt 15552000 ]; then  # 180天
                echo "ERROR: $table_name 归档超过180天未执行"
                return 1
            fi
            ;;
        "login_attempts")
            if [ $time_diff -gt 604800 ]; then  # 7天
                echo "ERROR: $table_name 归档超过7天未执行"
                return 1
            fi
            ;;
        "inventory")
            if [ $time_diff -gt 7776000 ]; then  # 90天
                echo "ERROR: $table_name 归档超过90天未执行"
                return 1
            fi
            ;;
        "calendar")
            if [ $time_diff -gt 31536000 ]; then  # 365天
                echo "ERROR: $table_name 归档超过365天未执行"
                return 1
            fi
            ;;
    esac
    
    echo "INFO: $table_name 归档正常"
    return 0
}

# 发送告警邮件
send_alert() {
    local message=$1
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> $LOG_FILE
    
    # 发送邮件告警
    echo "$message" | mail -s "MES归档告警" $ALERT_EMAIL
}

# 主函数
main() {
    local errors=0
    
    # 检查各种归档状态
    check_archive_status "audit_logs" || errors=$((errors + 1))
    check_archive_status "security_events" || errors=$((errors + 1))
    check_archive_status "login_attempts" || errors=$((errors + 1))
    check_archive_status "inventory" || errors=$((errors + 1))
    check_archive_status "calendar" || errors=$((errors + 1))
    
    if [ $errors -gt 0 ]; then
        send_alert "归档监控发现 $errors 个问题"
        exit 1
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - 归档监控正常" >> $LOG_FILE
    fi
}

# 执行主函数
main
```

## 灾难恢复

### 灾难恢复计划

#### RTO/RPO目标
- **RTO (恢复时间目标)**：4小时
- **RPO (恢复点目标)**：1小时
- **可用性目标**：99.9%
- **数据完整性**：100%

#### 灾难恢复步骤
1. **灾难评估**：评估灾难影响范围
2. **启动应急响应**：启动灾难恢复团队
3. **系统恢复**：恢复系统基础设施
4. **数据恢复**：恢复数据库和应用数据
5. **服务验证**：验证系统功能正常
6. **业务切换**：切换业务到恢复系统
7. **监控验证**：监控系统运行状态

### 灾难恢复脚本

#### 灾难恢复自动化脚本
```bash
#!/bin/bash
# disaster-recovery.sh

# 配置变量
PRIMARY_DB_HOST="primary-db.example.com"
STANDBY_DB_HOST="standby-db.example.com"
DB_PORT="5432"
DB_NAME="mes_core"
DB_USER="mes_admin"
BACKUP_SERVER="backup-server.example.com"
RECOVERY_DIR="/tmp/disaster-recovery"
LOG_FILE="$RECOVERY_DIR/disaster-recovery.log"

# 创建恢复目录
mkdir -p $RECOVERY_DIR

# 日志函数
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOG_FILE
}

# 灾难评估
assess_disaster() {
    log_message "开始灾难评估..."
    
    # 检查主数据库连接
    if pg_isready -h $PRIMARY_DB_HOST -p $DB_PORT; then
        log_message "主数据库连接正常"
        return 0
    else
        log_message "主数据库连接失败，启动灾难恢复"
        return 1
    fi
}

# 启动应急响应
activate_emergency_response() {
    log_message "启动应急响应..."
    
    # 通知相关人员
    echo "MES系统发生灾难，启动应急响应" | mail -s "灾难恢复告警" admin@example.com
    
    # 启动灾难恢复团队
    log_message "灾难恢复团队已启动"
    
    # 记录灾难事件
    log_message "灾难事件已记录"
}

# 系统恢复
restore_system() {
    log_message "开始系统恢复..."
    
    # 检查备用系统状态
    if pg_isready -h $STANDBY_DB_HOST -p $DB_PORT; then
        log_message "备用系统状态正常"
        
        # 提升备用系统为主系统
        promote_standby_system
        
        # 配置应用连接
        configure_application_connection
        
        log_message "系统恢复完成"
    else
        log_message "备用系统不可用，从备份恢复"
        restore_from_backup
    fi
}

# 提升备用系统
promote_standby_system() {
    log_message "提升备用系统为主系统..."
    
    # 停止备用系统
    ssh standby-server "systemctl stop postgresql"
    
    # 恢复备用系统
    ssh standby-server "pg_ctl promote -D /var/lib/postgresql/data"
    
    # 启动备用系统
    ssh standby-server "systemctl start postgresql"
    
    log_message "备用系统提升完成"
}

# 配置应用连接
configure_application_connection() {
    log_message "配置应用连接..."
    
    # 更新应用配置
    sed -i "s/$PRIMARY_DB_HOST/$STANDBY_DB_HOST/g" /etc/mes-app/config.yml
    
    # 重启应用
    systemctl restart mes-app
    
    log_message "应用连接配置完成"
}

# 从备份恢复
restore_from_backup() {
    log_message "从备份恢复系统..."
    
    # 获取最新备份
    local latest_backup=$(ssh $BACKUP_SERVER "ls -t /backup/mes_core/full/*.sql.gz | head -1")
    
    if [ -z "$latest_backup" ]; then
        log_message "错误: 没有找到备份文件"
        return 1
    fi
    
    log_message "使用备份文件: $latest_backup"
    
    # 下载备份文件
    scp $BACKUP_SERVER:$latest_backup $RECOVERY_DIR/
    
    # 恢复数据库
    local backup_file="$RECOVERY_DIR/$(basename $latest_backup)"
    gunzip -c $backup_file | psql -h $STANDBY_DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME
    
    if [ $? -eq 0 ]; then
        log_message "数据库恢复成功"
        
        # 启动应用
        systemctl start mes-app
        
        log_message "系统恢复完成"
    else
        log_message "错误: 数据库恢复失败"
        return 1
    fi
}

# 数据恢复
restore_data() {
    log_message "开始数据恢复..."
    
    # 验证数据完整性
    verify_data_integrity
    
    # 恢复增量数据
    restore_incremental_data
    
    log_message "数据恢复完成"
}

# 验证数据完整性
verify_data_integrity() {
    log_message "验证数据完整性..."
    
    # 检查关键表
    local plants_count=$(psql -h $STANDBY_DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM plants;" | tr -d ' ')
    local work_centers_count=$(psql -h $STANDBY_DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM work_centers;" | tr -d ' ')
    local equipment_count=$(psql -h $STANDBY_DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM equipment;" | tr -d ' ')
    local inventory_count=$(psql -h $STANDBY_DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM inventory;" | tr -d ' ')
    
    log_message "工厂数量: $plants_count"
    log_message "工作中心数量: $work_centers_count"
    log_message "设备数量: $equipment_count"
    log_message "库存数量: $inventory_count"
    
    # 检查外键约束
    local constraint_violations=$(psql -h $STANDBY_DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -c "
        SELECT COUNT(*) FROM work_centers wc 
        LEFT JOIN plants p ON wc.plant_id = p.plant_id 
        WHERE p.plant_id IS NULL;
    " | tr -d ' ')
    
    if [ "$constraint_violations" -gt 0 ]; then
        log_message "警告: 发现 $constraint_violations 个外键约束违反"
    else
        log_message "外键约束检查通过"
    fi
}

# 恢复增量数据
restore_incremental_data() {
    log_message "恢复增量数据..."
    
    # 获取增量备份
    local incremental_backups=$(ssh $BACKUP_SERVER "ls -t /backup/mes_core/incremental/*.sql.gz | head -5")
    
    for backup in $incremental_backups; do
        log_message "恢复增量备份: $backup"
        
        # 下载备份文件
        scp $BACKUP_SERVER:$backup $RECOVERY_DIR/
        
        # 恢复数据
        local backup_file="$RECOVERY_DIR/$(basename $backup)"
        gunzip -c $backup_file | psql -h $STANDBY_DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME
        
        if [ $? -eq 0 ]; then
            log_message "增量备份恢复成功: $backup"
        else
            log_message "警告: 增量备份恢复失败: $backup"
        fi
    done
}

# 服务验证
verify_services() {
    log_message "验证服务状态..."
    
    # 检查数据库服务
    if pg_isready -h $STANDBY_DB_HOST -p $DB_PORT; then
        log_message "数据库服务正常"
    else
        log_message "错误: 数据库服务异常"
        return 1
    fi
    
    # 检查应用服务
    if systemctl is-active --quiet mes-app; then
        log_message "应用服务正常"
    else
        log_message "错误: 应用服务异常"
        return 1
    fi
    
    # 检查关键功能
    check_critical_functions
    
    log_message "服务验证完成"
}

# 检查关键功能
check_critical_functions() {
    log_message "检查关键功能..."
    
    # 检查数据库连接
    if psql -h $STANDBY_DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT 1;" > /dev/null 2>&1; then
        log_message "数据库连接正常"
    else
        log_message "错误: 数据库连接失败"
        return 1
    fi
    
    # 检查应用接口
    if curl -f http://localhost:8080/health > /dev/null 2>&1; then
        log_message "应用接口正常"
    else
        log_message "错误: 应用接口异常"
        return 1
    fi
    
    log_message "关键功能检查完成"
}

# 业务切换
switch_business() {
    log_message "开始业务切换..."
    
    # 更新DNS记录
    update_dns_records
    
    # 更新负载均衡配置
    update_load_balancer_config
    
    # 通知业务用户
    notify_business_users
    
    log_message "业务切换完成"
}

# 更新DNS记录
update_dns_records() {
    log_message "更新DNS记录..."
    
    # 更新主数据库DNS记录
    nsupdate << EOF
server dns-server.example.com
zone example.com
update delete db.example.com A
update add db.example.com 3600 A $STANDBY_DB_HOST
send
EOF
    
    log_message "DNS记录更新完成"
}

# 更新负载均衡配置
update_load_balancer_config() {
    log_message "更新负载均衡配置..."
    
    # 更新负载均衡器配置
    sed -i "s/$PRIMARY_DB_HOST/$STANDBY_DB_HOST/g" /etc/nginx/nginx.conf
    
    # 重新加载配置
    nginx -s reload
    
    log_message "负载均衡配置更新完成"
}

# 通知业务用户
notify_business_users() {
    log_message "通知业务用户..."
    
    # 发送通知邮件
    echo "MES系统已切换到备用系统，服务恢复正常" | mail -s "系统恢复通知" users@example.com
    
    log_message "业务用户通知完成"
}

# 监控验证
monitor_system() {
    log_message "开始系统监控..."
    
    # 启动监控脚本
    nohup /opt/scripts/system-monitor.sh > /dev/null 2>&1 &
    
    log_message "系统监控已启动"
}

# 主函数
main() {
    log_message "开始灾难恢复流程"
    
    # 灾难评估
    if assess_disaster; then
        log_message "系统正常，无需灾难恢复"
        exit 0
    fi
    
    # 启动应急响应
    activate_emergency_response
    
    # 系统恢复
    restore_system
    
    # 数据恢复
    restore_data
    
    # 服务验证
    verify_services
    
    # 业务切换
    switch_business
    
    # 监控验证
    monitor_system
    
    log_message "灾难恢复流程完成"
}

# 执行主函数
main
```

## 备份恢复最佳实践

### 备份最佳实践

1. **备份策略**：制定合适的备份策略
2. **备份验证**：定期验证备份文件完整性
3. **备份存储**：使用多个存储位置
4. **备份监控**：监控备份执行状态
5. **备份测试**：定期测试备份恢复

### 恢复最佳实践

1. **恢复计划**：制定详细的恢复计划
2. **恢复测试**：定期进行恢复测试
3. **恢复文档**：维护恢复操作文档
4. **恢复培训**：培训恢复操作人员
5. **恢复监控**：监控恢复过程

### 归档最佳实践

1. **归档策略**：制定合适的归档策略
2. **归档验证**：验证归档数据完整性
3. **归档存储**：使用长期存储介质
4. **归档监控**：监控归档执行状态
5. **归档测试**：定期测试归档恢复

### 灾难恢复最佳实践

1. **灾难恢复计划**：制定完整的灾难恢复计划
2. **灾难恢复测试**：定期进行灾难恢复测试
3. **灾难恢复培训**：培训灾难恢复团队
4. **灾难恢复监控**：监控灾难恢复过程
5. **灾难恢复改进**：持续改进灾难恢复能力
