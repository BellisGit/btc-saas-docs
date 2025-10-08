#!/bin/bash
# ==============================================================
# BTC Core数据库初始化脚本
# 按顺序执行所有表定义和数据插入文件
# ==============================================================

DB_NAME="btc_core"
DB_USER="root"
DB_PASS="${MYSQL_PASSWORD:-}"

echo "=========================================="
echo "BTC Core Database Initialization"
echo "=========================================="
echo ""

# 检查MySQL连接
echo "Checking MySQL connection..."
if [ -z "$DB_PASS" ]; then
    mysql -u $DB_USER -e "SELECT 1" > /dev/null 2>&1
else
    mysql -u $DB_USER -p$DB_PASS -e "SELECT 1" > /dev/null 2>&1
fi

if [ $? -ne 0 ]; then
    echo "ERROR: Cannot connect to MySQL. Please check your credentials."
    exit 1
fi
echo "[OK] MySQL connection successful"
echo ""

# 创建数据库
echo "Creating database if not exists..."
if [ -z "$DB_PASS" ]; then
    mysql -u $DB_USER -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
else
    mysql -u $DB_USER -p$DB_PASS -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
fi
echo "[OK] Database $DB_NAME ready"
echo ""

# 表定义文件（DDL）
DDL_FILES=(
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

# 数据插入文件（DML）
DML_FILES=(
    "data_20_tenant_dept.sql"
    "data_24_roles.sql"
    "data_25_positions.sql"
    "data_21_users_inert.sql"
    "data_22_users_supplier_01.sql"
    "data_23_users_supplier_02.sql"
    "data_26_position_role_map_01.sql"
    "data_27_position_role_map_02.sql"
)

# 执行DDL
echo "=========================================="
echo "Step 1: Creating tables (DDL)"
echo "=========================================="
for file in "${DDL_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "Executing $file..."
        if [ -z "$DB_PASS" ]; then
            mysql -u $DB_USER $DB_NAME < $file
        else
            mysql -u $DB_USER -p$DB_PASS $DB_NAME < $file
        fi
        
        if [ $? -eq 0 ]; then
            echo "  [OK] $file executed successfully"
        else
            echo "  [ERROR] Failed to execute $file"
            exit 1
        fi
    else
        echo "  [WARNING] File not found: $file"
    fi
done
echo ""

# 执行DML
echo "=========================================="
echo "Step 2: Inserting data (DML)"
echo "=========================================="
for file in "${DML_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "Executing $file..."
        if [ -z "$DB_PASS" ]; then
            mysql -u $DB_USER $DB_NAME < $file
        else
            mysql -u $DB_USER -p$DB_PASS $DB_NAME < $file
        fi
        
        if [ $? -eq 0 ]; then
            echo "  [OK] $file executed successfully"
        else
            echo "  [ERROR] Failed to execute $file"
            exit 1
        fi
    else
        echo "  [WARNING] File not found: $file"
    fi
done
echo ""

echo "=========================================="
echo "[SUCCESS] BTC Core database initialization completed!"
echo "=========================================="
echo ""
echo "Database: $DB_NAME"
echo "Tables: 28"
echo "Initial data: Loaded"
echo ""

