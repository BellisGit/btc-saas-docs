-- ==============================================
-- BTC BI数据库 - 质量相关BI聚合表
-- ==============================================

USE btc_bi;

-- 品质统计聚合表（5分钟级别）
CREATE TABLE agg_quality_stats_5m (
    bucket_start DATETIME PRIMARY KEY COMMENT '时间桶开始时间',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    inspection_type ENUM('IQC', 'IPQC', 'OQC', 'FAI') COMMENT '检验类型',
    item_id VARCHAR(32) COMMENT '物料ID',
    station_id VARCHAR(32) COMMENT '工位ID',
    total_inspections INT DEFAULT 0 COMMENT '总检验数',
    pass_inspections INT DEFAULT 0 COMMENT '通过检验数',
    fail_inspections INT DEFAULT 0 COMMENT '失败检验数',
    special_inspections INT DEFAULT 0 COMMENT '特采检验数',
    pass_rate DECIMAL(5,2) DEFAULT 0 COMMENT '通过率',
    fail_rate DECIMAL(5,2) DEFAULT 0 COMMENT '失败率',
    special_rate DECIMAL(5,2) DEFAULT 0 COMMENT '特采率',
    avg_inspection_time DECIMAL(8,2) DEFAULT 0 COMMENT '平均检验时间(分钟)',
    defect_count INT DEFAULT 0 COMMENT '缺陷总数',
    defect_rate DECIMAL(5,2) DEFAULT 0 COMMENT '缺陷率',
    top_defects JSON COMMENT 'Top缺陷列表',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_inspection_type (inspection_type),
    INDEX idx_item (item_id),
    INDEX idx_station (station_id),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '品质统计聚合表(5分钟)'
PARTITION BY RANGE (TO_DAYS(bucket_start)) (
    PARTITION p202501 VALUES LESS THAN (TO_DAYS('2025-02-01')),
    PARTITION p202502 VALUES LESS THAN (TO_DAYS('2025-03-01')),
    PARTITION p202503 VALUES LESS THAN (TO_DAYS('2025-04-01')),
    PARTITION p202504 VALUES LESS THAN (TO_DAYS('2025-05-01')),
    PARTITION p202505 VALUES LESS THAN (TO_DAYS('2025-06-01')),
    PARTITION p202506 VALUES LESS THAN (TO_DAYS('2025-07-01')),
    PARTITION p202507 VALUES LESS THAN (TO_DAYS('2025-08-01')),
    PARTITION p202508 VALUES LESS THAN (TO_DAYS('2025-09-01')),
    PARTITION p202509 VALUES LESS THAN (TO_DAYS('2025-10-01')),
    PARTITION p202510 VALUES LESS THAN (TO_DAYS('2025-11-01')),
    PARTITION p202511 VALUES LESS THAN (TO_DAYS('2025-12-01')),
    PARTITION p202512 VALUES LESS THAN (TO_DAYS('2026-01-01')),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- 缺陷分析聚合表（小时级别）
CREATE TABLE agg_defect_analysis_1h (
    bucket_start DATETIME PRIMARY KEY COMMENT '时间桶开始时间',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    defect_code VARCHAR(32) COMMENT '缺陷代码',
    defect_name VARCHAR(128) COMMENT '缺陷名称',
    item_id VARCHAR(32) COMMENT '物料ID',
    station_id VARCHAR(32) COMMENT '工位ID',
    cause_code VARCHAR(32) COMMENT '原因代码',
    cause_name VARCHAR(128) COMMENT '原因名称',
    occurrence_count INT DEFAULT 0 COMMENT '发生次数',
    defect_rate DECIMAL(5,2) DEFAULT 0 COMMENT '缺陷率',
    cost_impact DECIMAL(18,2) DEFAULT 0 COMMENT '成本影响',
    avg_repair_time DECIMAL(8,2) DEFAULT 0 COMMENT '平均修复时间(分钟)',
    trend_direction ENUM('UP', 'DOWN', 'STABLE') DEFAULT 'STABLE' COMMENT '趋势方向',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_defect_code (defect_code),
    INDEX idx_item (item_id),
    INDEX idx_station (station_id),
    INDEX idx_cause_code (cause_code),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '缺陷分析聚合表(1小时)'
PARTITION BY RANGE (TO_DAYS(bucket_start)) (
    PARTITION p202501 VALUES LESS THAN (TO_DAYS('2025-02-01')),
    PARTITION p202502 VALUES LESS THAN (TO_DAYS('2025-03-01')),
    PARTITION p202503 VALUES LESS THAN (TO_DAYS('2025-04-01')),
    PARTITION p202504 VALUES LESS THAN (TO_DAYS('2025-05-01')),
    PARTITION p202505 VALUES LESS THAN (TO_DAYS('2025-06-01')),
    PARTITION p202506 VALUES LESS THAN (TO_DAYS('2025-07-01')),
    PARTITION p202507 VALUES LESS THAN (TO_DAYS('2025-08-01')),
    PARTITION p202508 VALUES LESS THAN (TO_DAYS('2025-09-01')),
    PARTITION p202509 VALUES LESS THAN (TO_DAYS('2025-10-01')),
    PARTITION p202510 VALUES LESS THAN (TO_DAYS('2025-11-01')),
    PARTITION p202511 VALUES LESS THAN (TO_DAYS('2025-12-01')),
    PARTITION p202512 VALUES LESS THAN (TO_DAYS('2026-01-01')),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- 检验员绩效聚合表（日级别）
CREATE TABLE agg_inspector_performance_1d (
    bucket_start DATE PRIMARY KEY COMMENT '统计日期',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    inspector VARCHAR(64) COMMENT '检验员',
    inspection_type ENUM('IQC', 'IPQC', 'OQC', 'FAI') COMMENT '检验类型',
    total_inspections INT DEFAULT 0 COMMENT '总检验数',
    pass_inspections INT DEFAULT 0 COMMENT '通过检验数',
    fail_inspections INT DEFAULT 0 COMMENT '失败检验数',
    special_inspections INT DEFAULT 0 COMMENT '特采检验数',
    pass_rate DECIMAL(5,2) DEFAULT 0 COMMENT '通过率',
    avg_inspection_time DECIMAL(8,2) DEFAULT 0 COMMENT '平均检验时间(分钟)',
    defect_detection_rate DECIMAL(5,2) DEFAULT 0 COMMENT '缺陷检出率',
    false_alarm_rate DECIMAL(5,2) DEFAULT 0 COMMENT '误报率',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_inspector (inspector),
    INDEX idx_inspection_type (inspection_type),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '检验员绩效聚合表(日)'
PARTITION BY RANGE (TO_DAYS(bucket_start)) (
    PARTITION p202501 VALUES LESS THAN (TO_DAYS('2025-02-01')),
    PARTITION p202502 VALUES LESS THAN (TO_DAYS('2025-03-01')),
    PARTITION p202503 VALUES LESS THAN (TO_DAYS('2025-04-01')),
    PARTITION p202504 VALUES LESS THAN (TO_DAYS('2025-05-01')),
    PARTITION p202505 VALUES LESS THAN (TO_DAYS('2025-06-01')),
    PARTITION p202506 VALUES LESS THAN (TO_DAYS('2025-07-01')),
    PARTITION p202507 VALUES LESS THAN (TO_DAYS('2025-08-01')),
    PARTITION p202508 VALUES LESS THAN (TO_DAYS('2025-09-01')),
    PARTITION p202509 VALUES LESS THAN (TO_DAYS('2025-10-01')),
    PARTITION p202510 VALUES LESS THAN (TO_DAYS('2025-11-01')),
    PARTITION p202511 VALUES LESS THAN (TO_DAYS('2025-12-01')),
    PARTITION p202512 VALUES LESS THAN (TO_DAYS('2026-01-01')),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- 维修统计聚合表（小时级别）
CREATE TABLE agg_repair_stats_1h (
    bucket_start DATETIME PRIMARY KEY COMMENT '时间桶开始时间',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    item_id VARCHAR(32) COMMENT '物料ID',
    defect_code VARCHAR(32) COMMENT '缺陷代码',
    repair_technician VARCHAR(64) COMMENT '维修员',
    repair_supervisor VARCHAR(64) COMMENT '责任组长',
    repair_type ENUM('REPAIR', 'REPLACE', 'ADJUST') COMMENT '维修类型',
    total_repairs INT DEFAULT 0 COMMENT '总维修数',
    success_repairs INT DEFAULT 0 COMMENT '成功维修数',
    failed_repairs INT DEFAULT 0 COMMENT '失败维修数',
    success_rate DECIMAL(5,2) DEFAULT 0 COMMENT '成功率',
    avg_repair_time DECIMAL(8,2) DEFAULT 0 COMMENT '平均维修时间(分钟)',
    total_repair_cost DECIMAL(18,2) DEFAULT 0 COMMENT '总维修成本',
    avg_repair_cost DECIMAL(18,2) DEFAULT 0 COMMENT '平均维修成本',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_item (item_id),
    INDEX idx_defect_code (defect_code),
    INDEX idx_repair_technician (repair_technician),
    INDEX idx_repair_supervisor (repair_supervisor),
    INDEX idx_repair_type (repair_type),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '维修统计聚合表(1小时)'
PARTITION BY RANGE (TO_DAYS(bucket_start)) (
    PARTITION p202501 VALUES LESS THAN (TO_DAYS('2025-02-01')),
    PARTITION p202502 VALUES LESS THAN (TO_DAYS('2025-03-01')),
    PARTITION p202503 VALUES LESS THAN (TO_DAYS('2025-04-01')),
    PARTITION p202504 VALUES LESS THAN (TO_DAYS('2025-05-01')),
    PARTITION p202505 VALUES LESS THAN (TO_DAYS('2025-06-01')),
    PARTITION p202506 VALUES LESS THAN (TO_DAYS('2025-07-01')),
    PARTITION p202507 VALUES LESS THAN (TO_DAYS('2025-08-01')),
    PARTITION p202508 VALUES LESS THAN (TO_DAYS('2025-09-01')),
    PARTITION p202509 VALUES LESS THAN (TO_DAYS('2025-10-01')),
    PARTITION p202510 VALUES LESS THAN (TO_DAYS('2025-11-01')),
    PARTITION p202511 VALUES LESS THAN (TO_DAYS('2025-12-01')),
    PARTITION p202512 VALUES LESS THAN (TO_DAYS('2026-01-01')),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- 测试统计聚合表（小时级别）
CREATE TABLE agg_test_stats_1h (
    bucket_start DATETIME PRIMARY KEY COMMENT '时间桶开始时间',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    item_id VARCHAR(32) COMMENT '物料ID',
    test_type VARCHAR(64) COMMENT '测试类型',
    tester VARCHAR(64) COMMENT '测试员',
    total_tests INT DEFAULT 0 COMMENT '总测试数',
    pass_tests INT DEFAULT 0 COMMENT '通过测试数',
    fail_tests INT DEFAULT 0 COMMENT '失败测试数',
    partial_tests INT DEFAULT 0 COMMENT '部分通过测试数',
    pass_rate DECIMAL(5,2) DEFAULT 0 COMMENT '通过率',
    avg_test_time DECIMAL(8,2) DEFAULT 0 COMMENT '平均测试时间(分钟)',
    test_environment VARCHAR(128) COMMENT '测试环境',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_item (item_id),
    INDEX idx_test_type (test_type),
    INDEX idx_tester (tester),
    INDEX idx_test_environment (test_environment),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '测试统计聚合表(1小时)'
PARTITION BY RANGE (TO_DAYS(bucket_start)) (
    PARTITION p202501 VALUES LESS THAN (TO_DAYS('2025-02-01')),
    PARTITION p202502 VALUES LESS THAN (TO_DAYS('2025-03-01')),
    PARTITION p202503 VALUES LESS THAN (TO_DAYS('2025-04-01')),
    PARTITION p202504 VALUES LESS THAN (TO_DAYS('2025-05-01')),
    PARTITION p202505 VALUES LESS THAN (TO_DAYS('2025-06-01')),
    PARTITION p202506 VALUES LESS THAN (TO_DAYS('2025-07-01')),
    PARTITION p202507 VALUES LESS THAN (TO_DAYS('2025-08-01')),
    PARTITION p202508 VALUES LESS THAN (TO_DAYS('2025-09-01')),
    PARTITION p202509 VALUES LESS THAN (TO_DAYS('2025-10-01')),
    PARTITION p202510 VALUES LESS THAN (TO_DAYS('2025-11-01')),
    PARTITION p202511 VALUES LESS THAN (TO_DAYS('2025-12-01')),
    PARTITION p202512 VALUES LESS THAN (TO_DAYS('2026-01-01')),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- 质量成本聚合表（日级别）
CREATE TABLE agg_quality_cost_1d (
    bucket_start DATE PRIMARY KEY COMMENT '统计日期',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    cost_category VARCHAR(64) COMMENT '成本类别',
    prevention_cost DECIMAL(18,2) DEFAULT 0 COMMENT '预防成本',
    appraisal_cost DECIMAL(18,2) DEFAULT 0 COMMENT '鉴定成本',
    internal_failure_cost DECIMAL(18,2) DEFAULT 0 COMMENT '内部损失成本',
    external_failure_cost DECIMAL(18,2) DEFAULT 0 COMMENT '外部损失成本',
    total_quality_cost DECIMAL(18,2) DEFAULT 0 COMMENT '总质量成本',
    quality_cost_rate DECIMAL(5,2) DEFAULT 0 COMMENT '质量成本率',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_cost_category (cost_category),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '质量成本聚合表(日)'
PARTITION BY RANGE (TO_DAYS(bucket_start)) (
    PARTITION p202501 VALUES LESS THAN (TO_DAYS('2025-02-01')),
    PARTITION p202502 VALUES LESS THAN (TO_DAYS('2025-03-01')),
    PARTITION p202503 VALUES LESS THAN (TO_DAYS('2025-04-01')),
    PARTITION p202504 VALUES LESS THAN (TO_DAYS('2025-05-01')),
    PARTITION p202505 VALUES LESS THAN (TO_DAYS('2025-06-01')),
    PARTITION p202506 VALUES LESS THAN (TO_DAYS('2025-07-01')),
    PARTITION p202507 VALUES LESS THAN (TO_DAYS('2025-08-01')),
    PARTITION p202508 VALUES LESS THAN (TO_DAYS('2025-09-01')),
    PARTITION p202509 VALUES LESS THAN (TO_DAYS('2025-10-01')),
    PARTITION p202510 VALUES LESS THAN (TO_DAYS('2025-11-01')),
    PARTITION p202511 VALUES LESS THAN (TO_DAYS('2025-12-01')),
    PARTITION p202512 VALUES LESS THAN (TO_DAYS('2026-01-01')),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);
