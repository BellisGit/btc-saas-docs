-- ==============================================
-- 创建BTC核心数据库 - 混合架构
-- 包含所有基础表和核心业务表，支持复杂事务
-- ==============================================

-- 创建BTC核心数据库
CREATE DATABASE IF NOT EXISTS btc_core CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE btc_core;

-- 执行核心数据库Schema
SOURCE mes-backend/database/schemas/btc_core_schema.sql;
