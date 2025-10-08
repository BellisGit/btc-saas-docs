#!/bin/bash
# ==============================================================
# BTC MES系统 - 全局数据库快速初始化脚本
# 一键初始化所有数据库：btc_core, btc_log, btc_bi
# ==============================================================

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
DB_USER="${MYSQL_USER:-root}"
DB_PASS="${MYSQL_PASSWORD:-}"
DB_HOST="${MYSQL_HOST:-localhost}"
DB_PORT="${MYSQL_PORT:-3306}"

# 计时
START_TIME=$(date +%s)

# 打印banner
echo ""
echo "======================================================"
echo "      BTC MES Database Quick Initialization"
echo "======================================================"
echo ""
echo "Host: $DB_HOST:$DB_PORT"
echo "User: $DB_USER"
echo ""

# 检查MySQL连接
check_mysql_connection() {
    echo -n "Checking MySQL connection... "
    if [ -z "$DB_PASS" ]; then
        if mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -e "SELECT 1" >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC}"
            return 0
        fi
    else
        if mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS -e "SELECT 1" >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC}"
            return 0
        fi
    fi
    echo -e "${RED}✗${NC}"
    echo -e "${RED}ERROR: Cannot connect to MySQL${NC}"
    echo "Please check your MySQL service and credentials."
    exit 1
}

# 执行SQL命令
execute_sql() {
    local sql=$1
    if [ -z "$DB_PASS" ]; then
        mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -e "$sql"
    else
        mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS -e "$sql"
    fi
}

# 执行SQL文件
execute_sql_file() {
    local db=$1
    local file=$2
    if [ -z "$DB_PASS" ]; then
        mysql -h $DB_HOST -P $DB_PORT -u $DB_USER $db < "$file"
    else
        mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS $db < "$file"
    fi
}

# 初始化btc_core数据库
init_btc_core() {
    local start=$(date +%s)
    echo ""
    echo "======================================================"
    echo "[1/3] Initializing btc_core database..."
    echo "======================================================"
    
    # 创建数据库
    echo -n "Creating btc_core database... "
    execute_sql "CREATE DATABASE IF NOT EXISTS btc_core CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" >/dev/null 2>&1
    echo -e "${GREEN}✓${NC}"
    
    # 进入btc_core_split目录
    cd schemas/btc_core_split
    
    # DDL文件
    local ddl_files=(
        "01_tenant_dept.sql"
        "02_user.sql"
        "03_role_permission.sql"
        "04_menu.sql"
        "05_module_plugin.sql"
        "06_menu_permission.sql"
        "07_position.sql"
        "08_user_role.sql"
        "09_workflow.sql"
        "10_trace_maps.sql"
        "11_trace_events.sql"
        "12_test_measure.sql"
    )
    
    echo "Executing table definitions (DDL)..."
    for file in "${ddl_files[@]}"; do
        if [ -f "$file" ]; then
            echo -n "  - $file... "
            execute_sql_file btc_core "$file" >/dev/null 2>&1
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "  - ${YELLOW}⚠${NC} $file not found"
        fi
    done
    
    # DML文件
    local dml_files=(
        "data_20_tenant_dept.sql"
        "data_24_roles.sql"
        "data_25_positions.sql"
        "data_21_users_inert.sql"
        "data_22_users_supplier_01.sql"
        "data_23_users_supplier_02.sql"
        "data_26_position_role_map_01.sql"
        "data_27_position_role_map_02.sql"
    )
    
    echo "Executing data insertion (DML)..."
    for file in "${dml_files[@]}"; do
        if [ -f "$file" ]; then
            echo -n "  - $file... "
            execute_sql_file btc_core "$file" >/dev/null 2>&1
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "  - ${YELLOW}⚠${NC} $file not found"
        fi
    done
    
    cd ../..
    
    local end=$(date +%s)
    local duration=$((end - start))
    echo -e "${GREEN}✓${NC} btc_core initialized (${duration}s)"
}

# 初始化btc_log数据库
init_btc_log() {
    local start=$(date +%s)
    echo ""
    echo "======================================================"
    echo "[2/3] Initializing btc_log database..."
    echo "======================================================"
    
    # 创建数据库
    echo -n "Creating btc_log database... "
    execute_sql "CREATE DATABASE IF NOT EXISTS btc_log CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" >/dev/null 2>&1
    echo -e "${GREEN}✓${NC}"
    
    # 进入btc_log目录
    cd schemas/btc_log
    
    local log_files=(
        "01_operation_logs.sql"
        "02_system_logs.sql"
    )
    
    echo "Executing log tables..."
    for file in "${log_files[@]}"; do
        if [ -f "$file" ]; then
            echo -n "  - $file... "
            execute_sql_file btc_log "$file" >/dev/null 2>&1
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "  - ${YELLOW}⚠${NC} $file not found"
        fi
    done
    
    cd ../..
    
    local end=$(date +%s)
    local duration=$((end - start))
    echo -e "${GREEN}✓${NC} btc_log initialized (${duration}s)"
}

# 初始化btc_bi数据库
init_btc_bi() {
    local start=$(date +%s)
    echo ""
    echo "======================================================"
    echo "[3/3] Initializing btc_bi database..."
    echo "======================================================"
    
    # 创建数据库
    echo -n "Creating btc_bi database... "
    execute_sql "CREATE DATABASE IF NOT EXISTS btc_bi CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" >/dev/null 2>&1
    echo -e "${GREEN}✓${NC}"
    
    # 进入btc_bi目录
    cd schemas/btc_bi
    
    local bi_files=(
        "01_production_bi.sql"
        "02_quality_bi.sql"
        "03_system_bi.sql"
        "04_alert_monitoring.sql"
    )
    
    echo "Executing BI tables..."
    for file in "${bi_files[@]}"; do
        if [ -f "$file" ]; then
            echo -n "  - $file... "
            execute_sql_file btc_bi "$file" >/dev/null 2>&1
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "  - ${YELLOW}⚠${NC} $file not found"
        fi
    done
    
    cd ../..
    
    local end=$(date +%s)
    local duration=$((end - start))
    echo -e "${GREEN}✓${NC} btc_bi initialized (${duration}s)"
}

# 数据验证
validate_databases() {
    echo ""
    echo "======================================================"
    echo "Validating databases..."
    echo "======================================================"
    
    # 验证btc_core
    echo -n "btc_core tables: "
    local core_tables=$(execute_sql "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='btc_core';" 2>/dev/null | tail -n1)
    echo -e "${GREEN}$core_tables${NC}"
    
    # 验证btc_log
    echo -n "btc_log tables: "
    local log_tables=$(execute_sql "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='btc_log';" 2>/dev/null | tail -n1)
    echo -e "${GREEN}$log_tables${NC}"
    
    # 验证btc_bi
    echo -n "btc_bi tables: "
    local bi_tables=$(execute_sql "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='btc_bi';" 2>/dev/null | tail -n1)
    echo -e "${GREEN}$bi_tables${NC}"
    
    # 验证数据
    echo -n "btc_core initial data: "
    local tenant_count=$(execute_sql "SELECT COUNT(*) FROM btc_core.tenant;" 2>/dev/null | tail -n1)
    local user_count=$(execute_sql "SELECT COUNT(*) FROM btc_core.sys_user;" 2>/dev/null | tail -n1)
    local role_count=$(execute_sql "SELECT COUNT(*) FROM btc_core.sys_role;" 2>/dev/null | tail -n1)
    echo -e "${GREEN}$tenant_count tenants, $user_count users, $role_count roles${NC}"
    
    local total_tables=$((core_tables + log_tables + bi_tables))
    echo ""
    echo -e "${GREEN}✓${NC} Total tables created: ${GREEN}$total_tables${NC}"
}

# 主函数
main() {
    # 检查连接
    check_mysql_connection
    
    # 初始化数据库
    init_btc_core
    init_btc_log
    init_btc_bi
    
    # 验证
    validate_databases
    
    # 计算总时间
    END_TIME=$(date +%s)
    TOTAL_TIME=$((END_TIME - START_TIME))
    
    # 成功总结
    echo ""
    echo "======================================================"
    echo -e "${GREEN}✓ All databases initialized successfully!${NC}"
    echo "======================================================"
    echo ""
    echo "📊 Summary:"
    echo "  - Databases: 3 (btc_core, btc_log, btc_bi)"
    echo "  - Execution time: ${TOTAL_TIME}s"
    echo ""
    echo "🎉 Your MES system database is ready!"
    echo ""
}

# 错误处理
trap 'echo -e "\n${RED}✗ Initialization failed!${NC}\nPlease check the error messages above."; exit 1' ERR

# 执行主函数
main

