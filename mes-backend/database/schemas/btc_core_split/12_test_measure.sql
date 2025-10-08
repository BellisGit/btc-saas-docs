-- ==============================================
-- BTC核心数据库 - 测试和测量表
-- ==============================================

USE btc_core;

CREATE TABLE test_record (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID',
    sn VARCHAR(64) NOT NULL COMMENT '序列号',
    lot_id VARCHAR(32) COMMENT '批次ID',
    wo_id VARCHAR(32) COMMENT '工单ID',
    station VARCHAR(64) NOT NULL COMMENT '测试工位',
    test_type VARCHAR(32) COMMENT '测试类型',
    result VARCHAR(8) NOT NULL COMMENT '结果(PASS/FAIL)',
    code VARCHAR(32) COMMENT '失败代码',
    test_data JSON COMMENT '测试数据',
    tested_at DATETIME NOT NULL COMMENT '测试时间',
    operator_id VARCHAR(64) COMMENT '测试员ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_sn (sn),
    INDEX idx_lot_id (lot_id),
    INDEX idx_wo_id (wo_id),
    INDEX idx_station (station),
    INDEX idx_tested_at (tested_at),
    INDEX idx_result (result),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id)
) COMMENT '测试记录表';

-- 测量记录表
CREATE TABLE measure_record (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'ID',
    insp_id VARCHAR(32) COMMENT '检验单ID',
    test_record_id BIGINT COMMENT '测试记录ID',
    item_key VARCHAR(64) NOT NULL COMMENT '测量项目',
    value_num DECIMAL(18,6) COMMENT '数值',
    unit VARCHAR(16) COMMENT '单位',
    standard_value DECIMAL(18,6) COMMENT '标准值',
    upper_limit DECIMAL(18,6) COMMENT '上限',
    lower_limit DECIMAL(18,6) COMMENT '下限',
    measured_at DATETIME NOT NULL COMMENT '测量时间',
    operator_id VARCHAR(64) COMMENT '测量员ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_insp_id (insp_id),
    INDEX idx_test_record_id (test_record_id),
    INDEX idx_item_key (item_key),
    INDEX idx_measured_at (measured_at),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id)
) COMMENT '测量记录表';
