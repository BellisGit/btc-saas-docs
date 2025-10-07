-- ==============================================
-- BTC核心数据库 - 质量管理表
-- ==============================================

USE btc_core;

-- 检验计划表
CREATE TABLE inspection_plan (
    plan_id VARCHAR(32) PRIMARY KEY COMMENT '检验计划ID',
    plan_code VARCHAR(64) NOT NULL UNIQUE COMMENT '检验计划代码',
    plan_name VARCHAR(128) NOT NULL COMMENT '检验计划名称',
    item_id VARCHAR(32) NOT NULL COMMENT '物料ID',
    inspection_type ENUM('IQC', 'IPQC', 'OQC', 'FAI') NOT NULL COMMENT '检验类型',
    sampling_method VARCHAR(64) COMMENT '抽样方法',
    aql_level VARCHAR(16) COMMENT 'AQL水平',
    sample_size INT COMMENT '样本数量',
    inspection_level VARCHAR(16) COMMENT '检验水平',
    status ENUM('ACTIVE', 'INACTIVE', 'DRAFT') DEFAULT 'ACTIVE' COMMENT '状态',
    effective_date DATE COMMENT '生效日期',
    expiry_date DATE COMMENT '失效日期',
    description TEXT COMMENT '描述',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_plan_code (plan_code),
    INDEX idx_item (item_id),
    INDEX idx_inspection_type (inspection_type),
    INDEX idx_status (status),
    INDEX idx_effective_date (effective_date),
    INDEX idx_tenant (tenant_id)
) COMMENT '检验计划表';

-- 检验项目表
CREATE TABLE inspection_item (
    item_id VARCHAR(32) PRIMARY KEY COMMENT '检验项目ID',
    plan_id VARCHAR(32) NOT NULL COMMENT '检验计划ID',
    inspection_code VARCHAR(64) NOT NULL COMMENT '检验项目代码',
    inspection_name VARCHAR(128) NOT NULL COMMENT '检验项目名称',
    inspection_method VARCHAR(128) COMMENT '检验方法',
    specification VARCHAR(255) COMMENT '规格要求',
    unit VARCHAR(16) COMMENT '单位',
    upper_limit DECIMAL(18,4) COMMENT '上限值',
    lower_limit DECIMAL(18,4) COMMENT '下限值',
    target_value DECIMAL(18,4) COMMENT '目标值',
    tolerance DECIMAL(18,4) COMMENT '公差',
    is_critical BOOLEAN DEFAULT FALSE COMMENT '是否关键项',
    sort_order INT DEFAULT 0 COMMENT '排序',
    description TEXT COMMENT '描述',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_plan (plan_id),
    INDEX idx_inspection_code (inspection_code),
    INDEX idx_is_critical (is_critical),
    INDEX idx_sort_order (sort_order),
    INDEX idx_tenant (tenant_id),
    FOREIGN KEY (plan_id) REFERENCES inspection_plan(plan_id)
) COMMENT '检验项目表';

-- 检验记录表
CREATE TABLE inspection (
    inspection_id VARCHAR(32) PRIMARY KEY COMMENT '检验ID',
    inspection_no VARCHAR(64) NOT NULL UNIQUE COMMENT '检验单号',
    plan_id VARCHAR(32) NOT NULL COMMENT '检验计划ID',
    reference_type ENUM('WO', 'PO', 'RECEIPT', 'TRANSFER', 'OTHER') NOT NULL COMMENT '参考类型',
    reference_id VARCHAR(32) NOT NULL COMMENT '参考ID',
    reference_no VARCHAR(64) COMMENT '参考单号',
    item_id VARCHAR(32) NOT NULL COMMENT '物料ID',
    batch_no VARCHAR(64) COMMENT '批次号',
    serial_no VARCHAR(64) COMMENT '序列号',
    supplier_id VARCHAR(32) COMMENT '供应商ID',
    inspection_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '检验日期',
    inspector VARCHAR(64) COMMENT '检验员',
    responsible_team_leader VARCHAR(64) COMMENT '责任组长',
    inspection_type ENUM('IQC', 'IPQC', 'OQC', 'FAI') NOT NULL COMMENT '检验类型',
    total_inspected INT NOT NULL DEFAULT 0 COMMENT '检验总数',
    pass_qty INT DEFAULT 0 COMMENT '通过数量',
    fail_qty INT DEFAULT 0 COMMENT '失败数量',
    special_qty INT DEFAULT 0 COMMENT '特采数量',
    pass_rate DECIMAL(5,2) DEFAULT 0 COMMENT '通过率',
    inspection_result ENUM('PASS', 'FAIL', 'SPECIAL') DEFAULT 'PASS' COMMENT '检验结果',
    problem_category VARCHAR(32) COMMENT '问题类别',
    problem_severity ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') COMMENT '问题严重程度',
    inspection_duration INT COMMENT '检验耗时(分钟)',
    remarks TEXT COMMENT '备注',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_inspection_no (inspection_no),
    INDEX idx_plan (plan_id),
    INDEX idx_reference (reference_type, reference_id),
    INDEX idx_item (item_id),
    INDEX idx_batch_no (batch_no),
    INDEX idx_serial_no (serial_no),
    INDEX idx_supplier (supplier_id),
    INDEX idx_inspection_date (inspection_date),
    INDEX idx_inspector (inspector),
    INDEX idx_inspection_result (inspection_result),
    INDEX idx_tenant_site (tenant_id, site_id)
) COMMENT '检验记录表';

-- 检验明细表
CREATE TABLE inspection_detail (
    detail_id VARCHAR(32) PRIMARY KEY COMMENT '检验明细ID',
    inspection_id VARCHAR(32) NOT NULL COMMENT '检验ID',
    inspection_item_id VARCHAR(32) NOT NULL COMMENT '检验项目ID',
    measured_value DECIMAL(18,4) COMMENT '测量值',
    inspection_result ENUM('PASS', 'FAIL', 'SPECIAL') DEFAULT 'PASS' COMMENT '检验结果',
    defect_code VARCHAR(32) COMMENT '缺陷代码',
    defect_description TEXT COMMENT '缺陷描述',
    remarks TEXT COMMENT '备注',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_inspection (inspection_id),
    INDEX idx_inspection_item (inspection_item_id),
    INDEX idx_inspection_result (inspection_result),
    INDEX idx_defect_code (defect_code),
    INDEX idx_tenant (tenant_id),
    FOREIGN KEY (inspection_id) REFERENCES inspection(inspection_id),
    FOREIGN KEY (inspection_item_id) REFERENCES inspection_item(item_id)
) COMMENT '检验明细表';

-- 测试记录表
CREATE TABLE test_record (
    test_id VARCHAR(32) PRIMARY KEY COMMENT '测试ID',
    test_no VARCHAR(64) NOT NULL UNIQUE COMMENT '测试单号',
    item_id VARCHAR(32) NOT NULL COMMENT '物料ID',
    batch_no VARCHAR(64) COMMENT '批次号',
    serial_no VARCHAR(64) COMMENT '序列号',
    test_type VARCHAR(64) NOT NULL COMMENT '测试类型',
    test_method VARCHAR(128) COMMENT '测试方法',
    test_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '测试日期',
    tester VARCHAR(64) COMMENT '测试员',
    test_environment VARCHAR(128) COMMENT '测试环境',
    test_result ENUM('PASS', 'FAIL', 'PARTIAL') DEFAULT 'PASS' COMMENT '测试结果',
    test_data JSON COMMENT '测试数据',
    test_duration INT COMMENT '测试耗时(分钟)',
    remarks TEXT COMMENT '备注',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_test_no (test_no),
    INDEX idx_item (item_id),
    INDEX idx_batch_no (batch_no),
    INDEX idx_serial_no (serial_no),
    INDEX idx_test_type (test_type),
    INDEX idx_test_date (test_date),
    INDEX idx_tester (tester),
    INDEX idx_test_result (test_result),
    INDEX idx_tenant_site (tenant_id, site_id)
) COMMENT '测试记录表';

-- 维修记录表
CREATE TABLE repair_record (
    repair_id VARCHAR(32) PRIMARY KEY COMMENT '维修ID',
    repair_no VARCHAR(64) NOT NULL UNIQUE COMMENT '维修单号',
    sn VARCHAR(64) NOT NULL COMMENT '序列号',
    item_id VARCHAR(32) NOT NULL COMMENT '物料ID',
    defect_code VARCHAR(32) NOT NULL COMMENT '缺陷代码',
    defect_description TEXT COMMENT '缺陷描述',
    repair_technician VARCHAR(64) NOT NULL COMMENT '维修员',
    repair_supervisor VARCHAR(64) COMMENT '责任组长',
    repair_start_time DATETIME COMMENT '维修开始时间',
    repair_end_time DATETIME COMMENT '维修结束时间',
    repair_type ENUM('REPAIR', 'REPLACE', 'ADJUST') NOT NULL COMMENT '维修类型',
    repair_duration INT COMMENT '维修耗时(分钟)',
    repair_result ENUM('SUCCESS', 'FAILED') COMMENT '维修结果',
    repair_cost DECIMAL(18,2) DEFAULT 0 COMMENT '维修成本',
    spare_parts JSON COMMENT '备件清单',
    repair_notes TEXT COMMENT '维修说明',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_repair_no (repair_no),
    INDEX idx_sn (sn),
    INDEX idx_item (item_id),
    INDEX idx_defect_code (defect_code),
    INDEX idx_repair_technician (repair_technician),
    INDEX idx_repair_start_time (repair_start_time),
    INDEX idx_repair_type (repair_type),
    INDEX idx_repair_result (repair_result),
    INDEX idx_tenant_site (tenant_id, site_id)
) COMMENT '维修记录表';

-- 添加外键约束
ALTER TABLE inspection_plan ADD CONSTRAINT fk_inspection_plan_item FOREIGN KEY (item_id) REFERENCES item_master(item_id);
ALTER TABLE inspection ADD CONSTRAINT fk_inspection_plan FOREIGN KEY (plan_id) REFERENCES inspection_plan(plan_id);
ALTER TABLE inspection ADD CONSTRAINT fk_inspection_item FOREIGN KEY (item_id) REFERENCES item_master(item_id);
ALTER TABLE inspection ADD CONSTRAINT fk_inspection_supplier FOREIGN KEY (supplier_id) REFERENCES supplier_master(supplier_id);
ALTER TABLE test_record ADD CONSTRAINT fk_test_record_item FOREIGN KEY (item_id) REFERENCES item_master(item_id);
ALTER TABLE repair_record ADD CONSTRAINT fk_repair_record_item FOREIGN KEY (item_id) REFERENCES item_master(item_id);
ALTER TABLE repair_record ADD CONSTRAINT fk_repair_record_defect FOREIGN KEY (defect_code) REFERENCES defect_code_master(defect_code);
