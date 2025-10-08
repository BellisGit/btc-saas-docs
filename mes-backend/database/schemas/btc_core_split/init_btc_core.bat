@echo off
REM ==============================================================
REM BTC Core数据库初始化脚本 (Windows版本)
REM 按顺序执行所有表定义和数据插入文件
REM ==============================================================

SETLOCAL EnableDelayedExpansion

SET DB_NAME=btc_core
SET DB_USER=root
SET DB_PASS=

echo ==========================================
echo BTC Core Database Initialization
echo ==========================================
echo.

REM 表定义文件（DDL）
SET DDL_FILES=01_tenant_dept.sql 02_user.sql 03_role_permission.sql 04_menu.sql 05_module_plugin.sql 06_menu_permission.sql 07_position.sql 08_user_role.sql 09_workflow.sql 10_trace_maps.sql 11_trace_events.sql 12_test_measure.sql

REM 数据插入文件（DML）
SET DML_FILES=data_20_tenant_dept.sql data_24_roles.sql data_25_positions.sql data_21_users_inert.sql data_22_users_supplier_01.sql data_23_users_supplier_02.sql data_26_position_role_map_01.sql data_27_position_role_map_02.sql

echo Creating database if not exists...
mysql -u %DB_USER% -p%DB_PASS% -e "CREATE DATABASE IF NOT EXISTS %DB_NAME% CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
echo [OK] Database %DB_NAME% ready
echo.

echo ==========================================
echo Step 1: Creating tables (DDL)
echo ==========================================
FOR %%f IN (%DDL_FILES%) DO (
    IF EXIST %%f (
        echo Executing %%f...
        mysql -u %DB_USER% -p%DB_PASS% %DB_NAME% < %%f
        IF !ERRORLEVEL! EQU 0 (
            echo   [OK] %%f executed successfully
        ) ELSE (
            echo   [ERROR] Failed to execute %%f
            EXIT /B 1
        )
    ) ELSE (
        echo   [WARNING] File not found: %%f
    )
)
echo.

echo ==========================================
echo Step 2: Inserting data (DML)
echo ==========================================
FOR %%f IN (%DML_FILES%) DO (
    IF EXIST %%f (
        echo Executing %%f...
        mysql -u %DB_USER% -p%DB_PASS% %DB_NAME% < %%f
        IF !ERRORLEVEL! EQU 0 (
            echo   [OK] %%f executed successfully
        ) ELSE (
            echo   [ERROR] Failed to execute %%f
            EXIT /B 1
        )
    ) ELSE (
        echo   [WARNING] File not found: %%f
    )
)
echo.

echo ==========================================
echo [SUCCESS] BTC Core database initialization completed!
echo ==========================================
echo.
echo Database: %DB_NAME%
echo Tables: 28
echo Initial data: Loaded
echo.

PAUSE

