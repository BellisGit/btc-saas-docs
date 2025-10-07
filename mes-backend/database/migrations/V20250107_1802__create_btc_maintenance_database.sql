-- ==============================================
-- 创建BTC设备维护数据库 - 扩展数据库
-- 独立数据库，通过API与核心数据库集成
-- ==============================================

-- 创建BTC设备维护数据库
CREATE DATABASE IF NOT EXISTS btc_maintenance CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE btc_maintenance;

-- 执行维护数据库Schema
SOURCE mes-backend/database/schemas/btc_maintenance_schema.sql;
