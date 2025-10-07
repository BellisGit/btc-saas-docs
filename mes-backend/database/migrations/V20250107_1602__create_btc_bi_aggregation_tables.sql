-- V20250107_1602__create_bi_aggregation_tables.sql
-- 创建BI数据聚合表
-- 基于MES系统全局架构基础文档
-- 作者: MES开发团队
-- 日期: 2025-01-07

-- 使用MES核心数据库
USE mes_core;

-- ==============================================
-- BI数据聚合表
-- ==============================================

-- 良率聚合表（5分钟）
CREATE TABLE IF NOT EXISTS agg_yield_5m (
    bucket_start DATETIME PRIMARY KEY COMMENT '时间桶开始时间',
    pass_cnt INT DEFAULT 0 COMMENT '通过数量',
    fail_cnt INT DEFAULT 0 COMMENT '失败数量',
    yield DECIMAL(5,2) COMMENT '良率',
    station VARCHAR(64) COMMENT '工位',
    item_id VARCHAR(32) COMMENT '物料ID',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_station (station),
    INDEX idx_item (item_id),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '良率聚合表';

-- WIP状态聚合表
CREATE TABLE IF NOT EXISTS agg_wip_status (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    bucket_start DATETIME NOT NULL COMMENT '时间桶开始时间',
    wo_id VARCHAR(32) COMMENT '工单ID',
    item_id VARCHAR(32) COMMENT '物料ID',
    station VARCHAR(64) COMMENT '工位',
    status ENUM('PLANNED', 'IN_PROGRESS', 'COMPLETED', 'REJECTED', 'REWORK') COMMENT '状态',
    quantity DECIMAL(18,4) COMMENT '数量',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_bucket_wo (bucket_start, wo_id),
    INDEX idx_item (item_id),
    INDEX idx_station (station),
    INDEX idx_status (status)
) COMMENT 'WIP状态聚合表';

-- 生产进度聚合表
CREATE TABLE IF NOT EXISTS agg_production_progress (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    bucket_start DATETIME NOT NULL COMMENT '时间桶开始时间',
    wo_id VARCHAR(32) NOT NULL COMMENT '工单ID',
    item_id VARCHAR(32) NOT NULL COMMENT '物料ID',
    planned_quantity DECIMAL(18,4) NOT NULL COMMENT '计划数量',
    actual_quantity DECIMAL(18,4) NOT NULL COMMENT '实际数量',
    progress_rate DECIMAL(5,2) COMMENT '进度百分比',
    yield_rate DECIMAL(5,2) COMMENT '良品率',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_bucket_wo (bucket_start, wo_id),
    INDEX idx_item (item_id),
    INDEX idx_progress (progress_rate)
) COMMENT '生产进度聚合表';

-- 设备效率聚合表
CREATE TABLE IF NOT EXISTS agg_equipment_efficiency (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    bucket_start DATETIME NOT NULL COMMENT '时间桶开始时间',
    equipment_id VARCHAR(32) NOT NULL COMMENT '设备ID',
    station VARCHAR(64) COMMENT '工位',
    planned_time INT COMMENT '计划时间(分钟)',
    actual_time INT COMMENT '实际时间(分钟)',
    efficiency DECIMAL(5,2) COMMENT '效率百分比',
    downtime_minutes INT DEFAULT 0 COMMENT '停机时间(分钟)',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_bucket_equipment (bucket_start, equipment_id),
    INDEX idx_station (station),
    INDEX idx_efficiency (efficiency)
) COMMENT '设备效率聚合表';

-- 品质统计聚合表
CREATE TABLE IF NOT EXISTS agg_quality_stats (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    bucket_start DATETIME NOT NULL COMMENT '时间桶开始时间',
    inspection_type ENUM('IQC', 'IPQC', 'OQC', 'FAI') NOT NULL COMMENT '检验类型',
    total_inspections INT DEFAULT 0 COMMENT '总检验数',
    pass_count INT DEFAULT 0 COMMENT '通过数',
    fail_count INT DEFAULT 0 COMMENT '失败数',
    pass_rate DECIMAL(5,2) COMMENT '通过率',
    defect_top_5 JSON COMMENT 'Top5缺陷',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_bucket_type (bucket_start, inspection_type),
    INDEX idx_pass_rate (pass_rate)
) COMMENT '品质统计聚合表';

-- 库存周转聚合表
CREATE TABLE IF NOT EXISTS agg_inventory_turnover (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    bucket_start DATETIME NOT NULL COMMENT '时间桶开始时间',
    item_id VARCHAR(32) NOT NULL COMMENT '物料ID',
    location_id VARCHAR(32) COMMENT '库位ID',
    opening_stock DECIMAL(18,4) COMMENT '期初库存',
    closing_stock DECIMAL(18,4) COMMENT '期末库存',
    in_quantity DECIMAL(18,4) COMMENT '入库数量',
    out_quantity DECIMAL(18,4) COMMENT '出库数量',
    turnover_rate DECIMAL(5,2) COMMENT '周转率',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_bucket_item (bucket_start, item_id),
    INDEX idx_location (location_id),
    INDEX idx_turnover (turnover_rate)
) COMMENT '库存周转聚合表';

-- 供应商绩效聚合表
CREATE TABLE IF NOT EXISTS agg_supplier_performance (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    bucket_start DATETIME NOT NULL COMMENT '时间桶开始时间',
    supplier_id VARCHAR(32) NOT NULL COMMENT '供应商ID',
    total_deliveries INT DEFAULT 0 COMMENT '总交货次数',
    on_time_deliveries INT DEFAULT 0 COMMENT '准时交货次数',
    quality_pass_rate DECIMAL(5,2) COMMENT '质量通过率',
    delivery_performance DECIMAL(5,2) COMMENT '交货绩效',
    overall_score DECIMAL(5,2) COMMENT '综合评分',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_bucket_supplier (bucket_start, supplier_id),
    INDEX idx_overall_score (overall_score)
) COMMENT '供应商绩效聚合表';

-- 成本分析聚合表
CREATE TABLE IF NOT EXISTS agg_cost_analysis (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    bucket_start DATETIME NOT NULL COMMENT '时间桶开始时间',
    item_id VARCHAR(32) NOT NULL COMMENT '物料ID',
    material_cost DECIMAL(18,2) COMMENT '物料成本',
    labor_cost DECIMAL(18,2) COMMENT '人工成本',
    overhead_cost DECIMAL(18,2) COMMENT '制造费用',
    total_cost DECIMAL(18,2) COMMENT '总成本',
    unit_cost DECIMAL(18,4) COMMENT '单位成本',
    cost_variance DECIMAL(18,2) COMMENT '成本差异',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_bucket_item (bucket_start, item_id),
    INDEX idx_unit_cost (unit_cost)
) COMMENT '成本分析聚合表';

-- 告警统计聚合表
CREATE TABLE IF NOT EXISTS agg_alert_stats (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    bucket_start DATETIME NOT NULL COMMENT '时间桶开始时间',
    alert_type VARCHAR(32) NOT NULL COMMENT '告警类型',
    alert_level ENUM('INFO', 'WARNING', 'ERROR', 'CRITICAL') NOT NULL COMMENT '告警级别',
    alert_count INT DEFAULT 0 COMMENT '告警数量',
    resolved_count INT DEFAULT 0 COMMENT '已解决数量',
    resolution_rate DECIMAL(5,2) COMMENT '解决率',
    avg_resolution_time INT COMMENT '平均解决时间(分钟)',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_bucket_type (bucket_start, alert_type),
    INDEX idx_level (alert_level),
    INDEX idx_resolution_rate (resolution_rate)
) COMMENT '告警统计聚合表';

-- ==============================================
-- 创建聚合数据刷新存储过程
-- ==============================================

DELIMITER //

-- 刷新良率聚合数据
CREATE PROCEDURE IF NOT EXISTS RefreshYieldAggregation(IN start_time DATETIME, IN end_time DATETIME)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- 删除指定时间范围的数据
    DELETE FROM agg_yield_5m WHERE bucket_start BETWEEN start_time AND end_time;
    
    -- 重新计算并插入数据
    INSERT INTO agg_yield_5m (bucket_start, pass_cnt, fail_cnt, yield, station, item_id)
    SELECT 
        FROM_UNIXTIME(UNIX_TIMESTAMP(tested_at) - MOD(UNIX_TIMESTAMP(tested_at), 300)) AS bucket_start,
        SUM(CASE WHEN result = 'PASS' THEN 1 ELSE 0 END) AS pass_cnt,
        SUM(CASE WHEN result = 'FAIL' THEN 1 ELSE 0 END) AS fail_cnt,
        ROUND(100 * SUM(CASE WHEN result = 'PASS' THEN 1 ELSE 0 END) / GREATEST(COUNT(*), 1), 2) AS yield,
        station,
        (SELECT item_id FROM serial_number sn WHERE sn.sn = tr.sn LIMIT 1) AS item_id
    FROM test_record tr
    WHERE tested_at BETWEEN start_time AND end_time
    GROUP BY bucket_start, station, item_id;
    
    COMMIT;
END //

-- 刷新WIP状态聚合数据
CREATE PROCEDURE IF NOT EXISTS RefreshWipAggregation(IN start_time DATETIME, IN end_time DATETIME)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- 删除指定时间范围的数据
    DELETE FROM agg_wip_status WHERE bucket_start BETWEEN start_time AND end_time;
    
    -- 重新计算并插入数据
    INSERT INTO agg_wip_status (bucket_start, wo_id, item_id, station, status, quantity)
    SELECT 
        FROM_UNIXTIME(UNIX_TIMESTAMP(occurred_at) - MOD(UNIX_TIMESTAMP(occurred_at), 300)) AS bucket_start,
        wo_id,
        item_id,
        station_id AS station,
        result AS status,
        COUNT(*) AS quantity
    FROM trace_event te
    JOIN map_sn ms ON te.entity_id = ms.sn
    WHERE te.occurred_at BETWEEN start_time AND end_time
        AND te.entity_type = 'SN'
        AND te.action IN ('START', 'END', 'PASS', 'FAIL', 'REWORK')
    GROUP BY bucket_start, wo_id, item_id, station, status;
    
    COMMIT;
END //

-- 刷新生产进度聚合数据
CREATE PROCEDURE IF NOT EXISTS RefreshProductionProgressAggregation(IN start_time DATETIME, IN end_time DATETIME)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- 删除指定时间范围的数据
    DELETE FROM agg_production_progress WHERE bucket_start BETWEEN start_time AND end_time;
    
    -- 重新计算并插入数据
    INSERT INTO agg_production_progress (bucket_start, wo_id, item_id, planned_quantity, actual_quantity, progress_rate, yield_rate)
    SELECT 
        FROM_UNIXTIME(UNIX_TIMESTAMP(wo.updated_at) - MOD(UNIX_TIMESTAMP(wo.updated_at), 300)) AS bucket_start,
        wo.wo_id,
        wo.item_id,
        wo.planned_quantity,
        wo.actual_quantity,
        ROUND(100 * wo.actual_quantity / GREATEST(wo.planned_quantity, 1), 2) AS progress_rate,
        COALESCE(
            (SELECT ROUND(100 * SUM(CASE WHEN result = 'PASS' THEN 1 ELSE 0 END) / GREATEST(COUNT(*), 1), 2)
             FROM test_record tr
             JOIN serial_number sn ON tr.sn = sn.sn
             WHERE sn.wo_id = wo.wo_id
               AND tr.tested_at BETWEEN start_time AND end_time),
            0
        ) AS yield_rate
    FROM work_order wo
    WHERE wo.updated_at BETWEEN start_time AND end_time;
    
    COMMIT;
END //

DELIMITER ;

-- ==============================================
-- 创建定时任务事件（需要开启事件调度器）
-- ==============================================

-- 设置事件调度器
SET GLOBAL event_scheduler = ON;

-- 创建5分钟聚合任务
CREATE EVENT IF NOT EXISTS evt_agg_5m_refresh
ON SCHEDULE EVERY 5 MINUTE
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;
    
    SET start_time = DATE_SUB(NOW(), INTERVAL 10 MINUTE);
    SET end_time = NOW();
    
    -- 调用聚合刷新存储过程
    CALL RefreshYieldAggregation(start_time, end_time);
    CALL RefreshWipAggregation(start_time, end_time);
    CALL RefreshProductionProgressAggregation(start_time, end_time);
END;

-- 创建1小时聚合任务
CREATE EVENT IF NOT EXISTS evt_agg_1h_refresh
ON SCHEDULE EVERY 1 HOUR
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;
    
    SET start_time = DATE_SUB(NOW(), INTERVAL 2 HOUR);
    SET end_time = NOW();
    
    -- 刷新其他聚合表
    -- 这里可以添加更多的聚合逻辑
END;
