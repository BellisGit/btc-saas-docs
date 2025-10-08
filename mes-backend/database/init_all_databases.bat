@echo off
REM ==============================================================
REM BTC MES系统 - 全局数据库快速初始化脚本 (Windows)
REM 一键初始化所有数据库：btc_core, btc_log, btc_bi
REM ==============================================================

SETLOCAL EnableDelayedExpansion

REM 配置
SET DB_USER=root
SET DB_PASS=
SET DB_HOST=localhost
SET DB_PORT=3306

REM 颜色和符号（Windows不支持颜色，使用文本符号）
SET OK=[OK]
SET ERROR=[ERROR]
SET WARN=[WARN]

echo.
echo ======================================================
echo       BTC MES Database Quick Initialization
echo ======================================================
echo.
echo Host: %DB_HOST%:%DB_PORT%
echo User: %DB_USER%
echo.

REM 检查MySQL连接
echo Checking MySQL connection...
mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASS% -e "SELECT 1" >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo %ERROR% Cannot connect to MySQL
    echo Please check your MySQL service and credentials.
    exit /b 1
)
echo %OK% MySQL connection successful
echo.

REM 初始化btc_core数据库
echo ======================================================
echo [1/3] Initializing btc_core database...
echo ======================================================

echo Creating btc_core database...
mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASS% -e "CREATE DATABASE IF NOT EXISTS btc_core CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" >nul 2>&1
echo %OK% btc_core database created

cd schemas\btc_core_split

REM DDL文件
echo Executing table definitions (DDL)...
FOR %%f IN (01_tenant_dept.sql 02_user.sql 03_role_permission.sql 04_menu.sql 05_module_plugin.sql 06_menu_permission.sql 07_position.sql 08_user_role.sql 09_workflow.sql 10_trace_maps.sql 11_trace_events.sql 12_test_measure.sql) DO (
    IF EXIST %%f (
        echo   - %%f...
        mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASS% btc_core < %%f >nul 2>&1
        IF !ERRORLEVEL! EQU 0 (
            echo     %OK%
        ) ELSE (
            echo     %ERROR% Failed to execute %%f
            exit /b 1
        )
    ) ELSE (
        echo   %WARN% %%f not found
    )
)

REM DML文件
echo Executing data insertion (DML)...
FOR %%f IN (data_20_tenant_dept.sql data_24_roles.sql data_25_positions.sql data_21_users_inert.sql data_22_users_supplier_01.sql data_23_users_supplier_02.sql data_26_position_role_map_01.sql data_27_position_role_map_02.sql) DO (
    IF EXIST %%f (
        echo   - %%f...
        mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASS% btc_core < %%f >nul 2>&1
        IF !ERRORLEVEL! EQU 0 (
            echo     %OK%
        ) ELSE (
            echo     %ERROR% Failed to execute %%f
            exit /b 1
        )
    ) ELSE (
        echo   %WARN% %%f not found
    )
)

cd ..\..
echo %OK% btc_core initialized
echo.

REM 初始化btc_log数据库
echo ======================================================
echo [2/3] Initializing btc_log database...
echo ======================================================

echo Creating btc_log database...
mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASS% -e "CREATE DATABASE IF NOT EXISTS btc_log CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" >nul 2>&1
echo %OK% btc_log database created

cd schemas\btc_log

echo Executing log tables...
FOR %%f IN (01_operation_logs.sql 02_system_logs.sql) DO (
    IF EXIST %%f (
        echo   - %%f...
        mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASS% btc_log < %%f >nul 2>&1
        IF !ERRORLEVEL! EQU 0 (
            echo     %OK%
        ) ELSE (
            echo     %ERROR% Failed to execute %%f
            exit /b 1
        )
    ) ELSE (
        echo   %WARN% %%f not found
    )
)

cd ..\..
echo %OK% btc_log initialized
echo.

REM 初始化btc_bi数据库
echo ======================================================
echo [3/3] Initializing btc_bi database...
echo ======================================================

echo Creating btc_bi database...
mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASS% -e "CREATE DATABASE IF NOT EXISTS btc_bi CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" >nul 2>&1
echo %OK% btc_bi database created

cd schemas\btc_bi

echo Executing BI tables...
FOR %%f IN (01_production_bi.sql 02_quality_bi.sql 03_system_bi.sql 04_alert_monitoring.sql) DO (
    IF EXIST %%f (
        echo   - %%f...
        mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASS% btc_bi < %%f >nul 2>&1
        IF !ERRORLEVEL! EQU 0 (
            echo     %OK%
        ) ELSE (
            echo     %ERROR% Failed to execute %%f
            exit /b 1
        )
    ) ELSE (
        echo   %WARN% %%f not found
    )
)

cd ..\..
echo %OK% btc_bi initialized
echo.

REM 数据验证
echo ======================================================
echo Validating databases...
echo ======================================================

REM 验证表数量
FOR /F "tokens=*" %%i IN ('mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASS% -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='btc_core';"') DO SET core_tables=%%i
echo btc_core tables: %core_tables%

FOR /F "tokens=*" %%i IN ('mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASS% -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='btc_log';"') DO SET log_tables=%%i
echo btc_log tables: %log_tables%

FOR /F "tokens=*" %%i IN ('mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASS% -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='btc_bi';"') DO SET bi_tables=%%i
echo btc_bi tables: %bi_tables%

REM 验证数据
FOR /F "tokens=*" %%i IN ('mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASS% -N -e "SELECT COUNT(*) FROM btc_core.tenant;"') DO SET tenant_count=%%i
FOR /F "tokens=*" %%i IN ('mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASS% -N -e "SELECT COUNT(*) FROM btc_core.sys_user;"') DO SET user_count=%%i
FOR /F "tokens=*" %%i IN ('mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASS% -N -e "SELECT COUNT(*) FROM btc_core.sys_role;"') DO SET role_count=%%i
echo btc_core initial data: %tenant_count% tenants, %user_count% users, %role_count% roles

SET /A total_tables=%core_tables% + %log_tables% + %bi_tables%
echo.
echo %OK% Total tables created: %total_tables%

REM 成功总结
echo.
echo ======================================================
echo %OK% All databases initialized successfully!
echo ======================================================
echo.
echo Summary:
echo   - Databases: 3 (btc_core, btc_log, btc_bi)
echo   - Total tables: %total_tables%
echo.
echo Your MES system database is ready!
echo.

pause

