-- ==============================================
-- BTC核心数据库 - 追溯事件表
-- ==============================================

USE btc_core;

CREATE TABLE trace_event (
    event_id VARCHAR(40) PRIMARY KEY COMMENT '事件ID',
    entity_type VARCHAR(32) NOT NULL COMMENT '实体类型(SN/LOT/WO/GRN/BOX/PLT/INSP)',
    entity_id VARCHAR(64) NOT NULL COMMENT '实体ID',
    action VARCHAR(32) NOT NULL COMMENT '动作(START/END/PASS/FAIL/REWORK/MOVE/PACK/SHIP)',
    occurred_at DATETIME NOT NULL COMMENT '发生时间',
    op_id VARCHAR(32) COMMENT '对应工序ID',
    op_name VARCHAR(64) COMMENT '工序名称',
    op_start_at DATETIME COMMENT '工序开始时间',
    op_end_at DATETIME COMMENT '工序结束时间',
    operator_id VARCHAR(64) COMMENT '操作人ID',
    result VARCHAR(16) COMMENT '结果(PASS/FAIL/REWORK/HOLD)',
    station_id VARCHAR(64) COMMENT '工位ID',
    shift_code VARCHAR(16) COMMENT '班次代码',
    ref_id VARCHAR(64) COMMENT '业务单据ID',
    data JSON COMMENT '测量值/参数/附件key等',
    prev_event_id VARCHAR(40) COMMENT '链式追溯-前一个事件ID',
    correlation_id VARCHAR(64) COMMENT '同事务/同工序相关性ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    source_system VARCHAR(32) COMMENT '来源系统',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_event_entity (entity_type, entity_id, occurred_at),
    INDEX idx_event_action (action, occurred_at),
    INDEX idx_event_operator (operator_id, occurred_at),
    INDEX idx_event_station (station_id, occurred_at),
    INDEX idx_event_correlation (correlation_id),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id)
) COMMENT '追溯事件表';

-- 链路快照（三层：原材料/组件/成品）
CREATE TABLE trace_link (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    level ENUM('RAW', 'COMPONENT', 'FINISHED') NOT NULL COMMENT '层级',
    sn VARCHAR(64) COMMENT '序列号',
    lot_id VARCHAR(32) COMMENT '批次ID',
    wo_id VARCHAR(32) COMMENT '工单ID',
    op_id VARCHAR(32) COMMENT '工序ID',
    op_name VARCHAR(64) COMMENT '工序名称',
    op_start_at DATETIME COMMENT '工序开始时间',
    op_end_at DATETIME COMMENT '工序结束时间',
    operator_id VARCHAR(64) COMMENT '操作人ID',
    result ENUM('PASS', 'FAIL', 'REWORK', 'HOLD') COMMENT '结果',
    station_id VARCHAR(64) COMMENT '工位ID',
    next_sn VARCHAR(64) COMMENT '指向上层的SN',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_trace_link_sn (sn),
    INDEX idx_trace_link_lot (lot_id),
    INDEX idx_trace_link_wo (wo_id),
    INDEX idx_trace_link_next (next_sn),
    INDEX idx_trace_link_level (level),
    FOREIGN KEY (tenant_id) REFERENCES tenant(tenant_id)
) COMMENT '追溯链路快照表';
