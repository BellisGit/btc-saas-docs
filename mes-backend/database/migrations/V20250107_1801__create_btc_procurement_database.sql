-- ==============================================
-- 创建BTC采购管理数据库 - 扩展数据库
-- 独立数据库，通过API与核心数据库集成
-- ==============================================

-- 创建BTC采购管理数据库
CREATE DATABASE IF NOT EXISTS btc_procurement CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE btc_procurement;

-- 执行采购数据库Schema
SOURCE mes-backend/database/schemas/btc_procurement_schema.sql;
