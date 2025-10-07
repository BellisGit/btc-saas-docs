# MES系统业务扩展完整指南

## 📋 概述

本文档提供了MES制造执行系统业务扩展的完整指南，包括新业务需求的评估、数据获取策略、表结构设计、BI报表扩展和部署规范。通过标准化的扩展流程，确保系统能够灵活应对各种业务变化。

## 🔍 业务扩展评估框架

### 1. 需求分析矩阵

| 评估维度 | 评估标准 | 权重 | 说明 |
|---------|---------|------|------|
| **数据来源** | 现有表 vs 新建表 | 30% | 优先使用现有数据 |
| **业务复杂度** | 简单 vs 复杂 | 25% | 影响开发工作量 |
| **数据量级** | 小量 vs 大数据 | 20% | 影响性能设计 |
| **实时性要求** | 实时 vs 批处理 | 15% | 影响架构选择 |
| **集成复杂度** | 独立 vs 强耦合 | 10% | 影响维护成本 |

### 2. 扩展决策树

```
新业务需求
    ├── 数据来源分析
    │   ├── 现有表能满足 → 直接使用
    │   ├── 现有表部分满足 → 扩展现有表
    │   └── 现有表无法满足 → 新建表
    ├── 数据库选择
    │   ├── 核心业务数据 → btc_core
    │   ├── 分析统计数据 → btc_bi
    │   └── 日志审计数据 → btc_log
    └── 实现方式
        ├── 视图/存储过程 → 快速实现
        ├── 应用层聚合 → 灵活实现
        └── 新建表结构 → 完整实现
```

## 📊 采购业务场景分析

### 场景描述
采购部门需要以下数据支持：
- **物料清单**: 当前库存物料清单
- **线边库存**: 生产线边的物料库存
- **仓库库存**: 各仓库的物料库存
- **物料用量表**: 物料消耗和使用情况

### 1. 数据来源分析

#### ✅ **现有数据完全满足的需求**

**物料清单** - 可直接从现有表获取：
```sql
-- 从 item_master 获取物料基础信息
SELECT 
    item_id,
    item_code,
    item_name,
    item_type,
    uom,
    specification,
    supplier_id,
    status
FROM item_master 
WHERE status = 'ACTIVE'
  AND tenant_id = ?;
```

**线边库存** - 可从 stock 表获取：
```sql
-- 从 stock 表获取线边库存（location_type = 'LINE_SIDE'）
SELECT 
    s.item_id,
    im.item_code,
    im.item_name,
    s.lot_id,
    s.location_id,
    s.quantity,
    s.status,
    s.unit_cost
FROM stock s
JOIN item_master im ON s.item_id = im.item_id
WHERE s.location_id IN (
    SELECT location_id FROM location_master 
    WHERE location_type = 'LINE_SIDE'
      AND tenant_id = ?
)
  AND s.status = 'AVAILABLE';
```

**仓库库存** - 可从 stock 表获取：
```sql
-- 从 stock 表获取仓库库存（location_type = 'WAREHOUSE'）
SELECT 
    s.item_id,
    im.item_code,
    im.item_name,
    s.lot_id,
    lm.location_code,
    lm.location_name,
    s.quantity,
    s.status,
    s.unit_cost,
    s.last_updated
FROM stock s
JOIN item_master im ON s.item_id = im.item_id
JOIN location_master lm ON s.location_id = lm.location_id
WHERE lm.location_type = 'WAREHOUSE'
  AND s.status = 'AVAILABLE'
  AND s.tenant_id = ?;
```

**物料用量表** - 可从 stock_transaction 表获取：
```sql
-- 从 stock_transaction 表获取物料使用情况
SELECT 
    st.item_id,
    im.item_code,
    im.item_name,
    st.transaction_type,
    st.quantity,
    st.transaction_date,
    st.reference_type,
    st.reference_id,
    st.location_id
FROM stock_transaction st
JOIN item_master im ON st.item_id = im.item_id
WHERE st.transaction_type IN ('ISSUE', 'CONSUME', 'SCRAP')
  AND st.transaction_date BETWEEN ? AND ?
  AND st.tenant_id = ?
ORDER BY st.transaction_date DESC;
```

#### 🔄 **需要扩展的数据**

**采购数据服务** - 创建采购数据视图：
```sql
-- 创建采购数据服务视图
CREATE VIEW v_procurement_inventory_summary AS
SELECT 
    s.item_id, 
    im.item_code, 
    im.item_name, 
    lm.location_type,
    SUM(s.quantity) as total_quantity,
    AVG(s.unit_cost) as avg_unit_cost,
    COUNT(DISTINCT s.lot_id) as lot_count,
    MAX(s.last_updated) as last_updated
FROM stock s
JOIN item_master im ON s.item_id = im.item_id  
JOIN location_master lm ON s.location_id = lm.location_id
WHERE s.status = 'AVAILABLE'
  AND s.tenant_id = ?
GROUP BY s.item_id, lm.location_type;
```

### 2. 扩展实现方案

#### 方案A：视图方式（快速实现）
```sql
-- 创建采购物料需求视图
CREATE VIEW v_procurement_material_requirement AS
SELECT 
    im.item_id,
    im.item_code,
    im.item_name,
    im.item_type,
    sm.supplier_code,
    sm.supplier_name,
    s.quantity as current_stock,
    s.quantity * 0.8 as reorder_point,
    s.quantity * 0.6 as safety_stock,
    CASE 
        WHEN s.quantity <= s.quantity * 0.6 THEN 'URGENT'
        WHEN s.quantity <= s.quantity * 0.8 THEN 'WARNING'
        ELSE 'NORMAL'
    END as stock_status
FROM item_master im
LEFT JOIN stock s ON im.item_id = s.item_id AND s.status = 'AVAILABLE'
LEFT JOIN supplier_master sm ON im.supplier_id = sm.supplier_id
WHERE im.status = 'ACTIVE'
  AND im.tenant_id = ?;
```

#### 方案B：新建表方式（完整实现）
```sql
-- 创建采购需求表
CREATE TABLE procurement_requirement (
    requirement_id VARCHAR(32) PRIMARY KEY,
    item_id VARCHAR(32) NOT NULL,
    requirement_type ENUM('URGENT', 'NORMAL', 'PLANNED') DEFAULT 'NORMAL',
    required_quantity DECIMAL(18,4) NOT NULL,
    required_date DATE NOT NULL,
    priority ENUM('HIGH', 'MEDIUM', 'LOW') DEFAULT 'MEDIUM',
    status ENUM('PENDING', 'APPROVED', 'ORDERED', 'RECEIVED') DEFAULT 'PENDING',
    requestor VARCHAR(64) NOT NULL,
    approver VARCHAR(64),
    approval_date DATETIME,
    remarks TEXT,
    tenant_id VARCHAR(32),
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (item_id) REFERENCES item_master(item_id),
    INDEX idx_item_id (item_id),
    INDEX idx_requirement_type (requirement_type),
    INDEX idx_required_date (required_date),
    INDEX idx_status (status),
    INDEX idx_tenant (tenant_id)
) COMMENT '采购需求表';
```

## 📈 BI报表扩展需求分析

### 1. 报表类型与数据需求

| 报表类型 | 主要数据需求 | 关键字段 | 数据来源 |
|---------|-------------|---------|---------|
| **测试报表** | 测试结果、工位效率、缺陷分析 | 测试员、测试时间、缺陷代码、测试数据 | test_record, trace_event |
| **维修报表** | 维修记录、维修效率、故障分析 | 维修员、维修时间、故障类型、维修结果 | trace_event, repair_record |
| **QC报表** | 检验结果、检验员绩效、质量问题 | 检验员、责任组长、检查时间、问题类型 | inspection, inspection_item |

### 2. 现有数据架构分析

#### ✅ **现有表结构支持度评估**

**测试报表数据支持**：
```sql
-- test_record 表已包含核心字段
SELECT 
    sn, station, test_type, result, defect_code, 
    test_data, operator, tested_at
FROM test_record 
WHERE tested_at BETWEEN ? AND ?;
```

**QC报表数据支持**：
```sql
-- inspection 表已包含检验员信息
SELECT 
    insp_id, type, inspector, inspection_date, result,
    sample_size, defect_quantity, aql_level
FROM inspection 
WHERE inspection_date BETWEEN ? AND ?;
```

#### 🔄 **需要扩展的字段**

**缺失的关键字段**：
- 责任组长信息
- 详细的问题类型分类
- 维修记录表
- 检验员绩效相关字段

## 🛠️ 完整解决方案设计

### 1. 扩展现有表结构

#### 扩展检验相关表
```sql
-- 扩展 inspection 表，添加责任组长和问题类型
ALTER TABLE inspection 
ADD COLUMN responsible_team_leader VARCHAR(64) COMMENT '责任组长',
ADD COLUMN problem_category VARCHAR(32) COMMENT '问题类别',
ADD COLUMN problem_severity ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') COMMENT '问题严重程度',
ADD COLUMN inspection_duration INT COMMENT '检验耗时(分钟)',
ADD COLUMN rework_required TINYINT(1) DEFAULT 0 COMMENT '是否需要返工',
ADD COLUMN quality_rating DECIMAL(3,2) COMMENT '质量评分';

-- 扩展 inspection_item 表，添加详细问题信息
ALTER TABLE inspection_item
ADD COLUMN problem_description TEXT COMMENT '问题描述',
ADD COLUMN root_cause VARCHAR(255) COMMENT '根本原因',
ADD COLUMN corrective_action VARCHAR(255) COMMENT '纠正措施',
ADD COLUMN prevention_action VARCHAR(255) COMMENT '预防措施',
ADD COLUMN responsible_person VARCHAR(64) COMMENT '责任人',
ADD COLUMN verification_date DATETIME COMMENT '验证日期',
ADD COLUMN verification_result ENUM('PASS', 'FAIL') COMMENT '验证结果';
```

#### 创建维修记录表
```sql
-- 维修记录表
CREATE TABLE repair_record (
    repair_id VARCHAR(32) PRIMARY KEY COMMENT '维修记录ID',
    sn VARCHAR(64) NOT NULL COMMENT '序列号',
    defect_code VARCHAR(32) NOT NULL COMMENT '缺陷代码',
    problem_description TEXT COMMENT '问题描述',
    repair_type ENUM('REPAIR', 'REPLACE', 'ADJUST', 'CLEAN') NOT NULL COMMENT '维修类型',
    repair_method TEXT COMMENT '维修方法',
    repair_parts JSON COMMENT '更换零件清单',
    repair_duration INT COMMENT '维修耗时(分钟)',
    repair_cost DECIMAL(10,2) COMMENT '维修成本',
    repair_result ENUM('SUCCESS', 'FAILED', 'PARTIAL') NOT NULL COMMENT '维修结果',
    repair_technician VARCHAR(64) NOT NULL COMMENT '维修技师',
    repair_supervisor VARCHAR(64) COMMENT '维修主管',
    repair_start_time DATETIME NOT NULL COMMENT '维修开始时间',
    repair_end_time DATETIME COMMENT '维修结束时间',
    verification_test VARCHAR(255) COMMENT '验证测试',
    verification_result ENUM('PASS', 'FAIL') COMMENT '验证结果',
    remarks TEXT COMMENT '备注',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_sn (sn),
    INDEX idx_defect_code (defect_code),
    INDEX idx_repair_technician (repair_technician),
    INDEX idx_repair_supervisor (repair_supervisor),
    INDEX idx_repair_start_time (repair_start_time),
    INDEX idx_repair_result (repair_result),
    INDEX idx_tenant_site (tenant_id, site_id)
) COMMENT '维修记录表';

-- 员工主数据表（用于责任组长管理）
CREATE TABLE employee_master (
    employee_id VARCHAR(32) PRIMARY KEY COMMENT '员工ID',
    employee_code VARCHAR(64) NOT NULL UNIQUE COMMENT '员工工号',
    employee_name VARCHAR(128) NOT NULL COMMENT '员工姓名',
    department VARCHAR(64) COMMENT '部门',
    position VARCHAR(64) COMMENT '职位',
    job_title VARCHAR(128) COMMENT '职称',
    level VARCHAR(32) COMMENT '级别',
    status ENUM('ACTIVE', 'INACTIVE', 'ON_LEAVE', 'TERMINATED') DEFAULT 'ACTIVE' COMMENT '状态',
    hire_date DATE COMMENT '入职日期',
    phone VARCHAR(32) COMMENT '电话',
    email VARCHAR(128) COMMENT '邮箱',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_employee_code (employee_code),
    INDEX idx_employee_name (employee_name),
    INDEX idx_department (department),
    INDEX idx_position (position),
    INDEX idx_status (status),
    INDEX idx_tenant_site (tenant_id, site_id)
) COMMENT '员工主数据表';
```

### 2. BI聚合表设计

#### 检验绩效聚合表
```sql
-- 检验员绩效聚合表（日级别）
CREATE TABLE agg_inspector_performance_1d (
    bucket_start DATE PRIMARY KEY COMMENT '统计日期',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    inspector VARCHAR(64) COMMENT '检验员',
    total_inspections INT DEFAULT 0 COMMENT '总检验次数',
    passed_inspections INT DEFAULT 0 COMMENT '通过检验次数',
    failed_inspections INT DEFAULT 0 COMMENT '失败检验次数',
    pass_rate DECIMAL(5,2) DEFAULT 0 COMMENT '通过率',
    avg_inspection_duration DECIMAL(8,2) DEFAULT 0 COMMENT '平均检验耗时(分钟)',
    defect_count INT DEFAULT 0 COMMENT '缺陷数量',
    rework_count INT DEFAULT 0 COMMENT '返工次数',
    quality_rating_avg DECIMAL(3,2) DEFAULT 0 COMMENT '平均质量评分',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_inspector (inspector),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '检验员绩效聚合表(日)';

-- 责任组长绩效聚合表（周级别）
CREATE TABLE agg_team_leader_performance_1w (
    bucket_start DATE PRIMARY KEY COMMENT '统计周开始日期',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    team_leader VARCHAR(64) COMMENT '责任组长',
    total_team_members INT DEFAULT 0 COMMENT '团队成员数量',
    total_inspections INT DEFAULT 0 COMMENT '团队总检验次数',
    team_pass_rate DECIMAL(5,2) DEFAULT 0 COMMENT '团队通过率',
    avg_quality_rating DECIMAL(3,2) DEFAULT 0 COMMENT '平均质量评分',
    defect_reduction_rate DECIMAL(5,2) DEFAULT 0 COMMENT '缺陷减少率',
    efficiency_improvement DECIMAL(5,2) DEFAULT 0 COMMENT '效率提升率',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_team_leader (team_leader),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '责任组长绩效聚合表(周)';
```

#### 维修绩效聚合表
```sql
-- 维修技师绩效聚合表（日级别）
CREATE TABLE agg_repair_technician_performance_1d (
    bucket_start DATE PRIMARY KEY COMMENT '统计日期',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    technician VARCHAR(64) COMMENT '维修技师',
    total_repairs INT DEFAULT 0 COMMENT '总维修次数',
    successful_repairs INT DEFAULT 0 COMMENT '成功维修次数',
    failed_repairs INT DEFAULT 0 COMMENT '失败维修次数',
    success_rate DECIMAL(5,2) DEFAULT 0 COMMENT '成功率',
    avg_repair_duration DECIMAL(8,2) DEFAULT 0 COMMENT '平均维修耗时(分钟)',
    total_repair_cost DECIMAL(18,2) DEFAULT 0 COMMENT '总维修成本',
    avg_repair_cost DECIMAL(10,2) DEFAULT 0 COMMENT '平均维修成本',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_technician (technician),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '维修技师绩效聚合表(日)';

-- 维修主管绩效聚合表（周级别）
CREATE TABLE agg_repair_supervisor_performance_1w (
    bucket_start DATE PRIMARY KEY COMMENT '统计周开始日期',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    site_id VARCHAR(32) COMMENT '站点ID',
    supervisor VARCHAR(64) COMMENT '维修主管',
    total_team_technicians INT DEFAULT 0 COMMENT '团队技师数量',
    total_team_repairs INT DEFAULT 0 COMMENT '团队总维修次数',
    team_success_rate DECIMAL(5,2) DEFAULT 0 COMMENT '团队成功率',
    avg_team_repair_duration DECIMAL(8,2) DEFAULT 0 COMMENT '团队平均维修耗时',
    cost_reduction_rate DECIMAL(5,2) DEFAULT 0 COMMENT '成本降低率',
    efficiency_improvement DECIMAL(5,2) DEFAULT 0 COMMENT '效率提升率',
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tenant_site (tenant_id, site_id),
    INDEX idx_supervisor (supervisor),
    INDEX idx_bucket_start (bucket_start)
) COMMENT '维修主管绩效聚合表(周)';
```

### 3. 综合报表视图

#### 测试报表视图
```sql
-- 测试报表综合视图
CREATE VIEW v_test_report_comprehensive AS
SELECT 
    tr.sn,
    tr.station,
    tr.test_type,
    tr.result,
    tr.defect_code,
    dc.defect_name,
    dc.defect_category,
    tr.test_data,
    tr.operator,
    tr.tested_at,
    DATE(tr.tested_at) as test_date,
    HOUR(tr.tested_at) as test_hour,
    CASE 
        WHEN tr.result = 'PASS' THEN 1 
        ELSE 0 
    END as pass_count,
    CASE 
        WHEN tr.result = 'FAIL' THEN 1 
        ELSE 0 
    END as fail_count,
    CASE 
        WHEN tr.defect_code IS NOT NULL THEN 1 
        ELSE 0 
    END as defect_count
FROM test_record tr
LEFT JOIN defect_code_master dc ON tr.defect_code = dc.defect_code
WHERE tr.tenant_id = ?;
```

#### QC报表视图
```sql
-- QC报表综合视图
CREATE VIEW v_qc_report_comprehensive AS
SELECT 
    i.insp_id,
    i.type as inspection_type,
    i.inspector,
    i.responsible_team_leader,
    i.inspection_date,
    i.result,
    i.sample_size,
    i.defect_quantity,
    i.aql_level,
    i.problem_category,
    i.problem_severity,
    i.inspection_duration,
    i.rework_required,
    i.quality_rating,
    ii.problem_description,
    ii.root_cause,
    ii.corrective_action,
    ii.responsible_person,
    ii.verification_date,
    ii.verification_result,
    DATE(i.inspection_date) as inspection_date_only,
    CASE 
        WHEN i.result = 'PASS' THEN 1 
        ELSE 0 
    END as pass_count,
    CASE 
        WHEN i.result = 'FAIL' THEN 1 
        ELSE 0 
    END as fail_count
FROM inspection i
LEFT JOIN inspection_item ii ON i.insp_id = ii.insp_id
WHERE i.tenant_id = ?;
```

#### 维修报表视图
```sql
-- 维修报表综合视图
CREATE VIEW v_repair_report_comprehensive AS
SELECT 
    rr.repair_id,
    rr.sn,
    rr.defect_code,
    dc.defect_name,
    dc.defect_category,
    rr.problem_description,
    rr.repair_type,
    rr.repair_method,
    rr.repair_duration,
    rr.repair_cost,
    rr.repair_result,
    rr.repair_technician,
    rr.repair_supervisor,
    rr.repair_start_time,
    rr.repair_end_time,
    rr.verification_result,
    DATE(rr.repair_start_time) as repair_date,
    HOUR(rr.repair_start_time) as repair_hour,
    CASE 
        WHEN rr.repair_result = 'SUCCESS' THEN 1 
        ELSE 0 
    END as success_count,
    CASE 
        WHEN rr.repair_result = 'FAILED' THEN 1 
        ELSE 0 
    END as failed_count,
    CASE 
        WHEN rr.repair_result = 'PARTIAL' THEN 1 
        ELSE 0 
    END as partial_count
FROM repair_record rr
LEFT JOIN defect_code_master dc ON rr.defect_code = dc.defect_code
WHERE rr.tenant_id = ?;
```

## 🚀 业务扩展实施指南

### 1. 扩展流程步骤

#### 步骤1：需求分析
1. **业务需求收集**：与业务部门深入沟通，明确具体需求
2. **数据需求分析**：确定需要的数据字段和业务规则
3. **影响范围评估**：评估对现有系统的影响
4. **技术方案设计**：选择合适的技术实现方案

#### 步骤2：数据模型设计
1. **现有表分析**：分析现有表结构是否满足需求
2. **扩展方案选择**：选择视图、扩展现有表或新建表
3. **表结构设计**：设计详细的表结构和索引
4. **数据迁移计划**：制定数据迁移和验证计划

#### 步骤3：开发实现
1. **数据库变更**：执行数据库结构变更
2. **业务逻辑开发**：开发相关的业务逻辑代码
3. **API接口开发**：开发数据访问和业务接口
4. **前端界面开发**：开发用户界面和报表

#### 步骤4：测试验证
1. **单元测试**：对各个模块进行单元测试
2. **集成测试**：测试各模块间的集成
3. **用户验收测试**：业务部门进行验收测试
4. **性能测试**：验证系统性能是否满足要求

#### 步骤5：部署上线
1. **生产环境部署**：在生产环境部署新功能
2. **数据迁移**：执行生产数据迁移
3. **功能验证**：验证生产环境功能正常
4. **用户培训**：对用户进行功能培训

### 2. 扩展规范要求

#### 数据库设计规范
```sql
-- 1. 表命名规范
-- 业务表：小写蛇形命名，如 procurement_requirement
-- 系统表：sys_ 前缀，如 sys_user
-- 聚合表：agg_ 前缀，如 agg_inspector_performance_1d
-- 视图：v_ 前缀，如 v_qc_report_comprehensive

-- 2. 字段命名规范
-- 主键：<entity>_id 格式，如 requirement_id
-- 外键：<referenced_table>_id 格式，如 item_id
-- 状态字段：统一使用 status
-- 时间字段：统一使用 _at 后缀，如 created_at

-- 3. 索引设计规范
-- 主键索引：自动生成 PRIMARY
-- 唯一索引：uk_<table>_<columns> 格式
-- 普通索引：idx_<table>_<columns> 格式
-- 外键索引：fk_<table>_<referenced_table> 格式

-- 4. 约束设计规范
-- 所有表都有明确的主键定义
-- 核心业务表都有完整的外键约束
-- 业务唯一字段都有唯一约束
-- 枚举类型字段有明确的取值范围
```

#### 代码开发规范
```java
// 1. 实体类命名规范
@Entity
@Table(name = "procurement_requirement")
public class ProcurementRequirement {
    @Id
    @Column(name = "requirement_id")
    private String requirementId;
    
    @Column(name = "item_id")
    private String itemId;
    
    // getter/setter...
}

// 2. 服务类命名规范
@Service
public class ProcurementRequirementService {
    
    @Autowired
    private ProcurementRequirementRepository repository;
    
    public ProcurementRequirement createRequirement(ProcurementRequirement requirement) {
        // 业务逻辑
        return repository.save(requirement);
    }
}

// 3. 控制器命名规范
@RestController
@RequestMapping("/api/procurement")
public class ProcurementRequirementController {
    
    @PostMapping("/requirements")
    public ResponseEntity<ProcurementRequirement> createRequirement(
        @RequestBody ProcurementRequirement requirement) {
        // 控制器逻辑
        return ResponseEntity.ok(service.createRequirement(requirement));
    }
}
```

### 3. 性能优化策略

#### 数据库性能优化
```sql
-- 1. 索引优化
-- 为常用查询字段创建复合索引
CREATE INDEX idx_procurement_item_status ON procurement_requirement (item_id, status);
CREATE INDEX idx_inspection_inspector_date ON inspection (inspector, inspection_date);
CREATE INDEX idx_repair_technician_date ON repair_record (repair_technician, repair_start_time);

-- 2. 分区优化
-- 对大表按时间分区
ALTER TABLE repair_record PARTITION BY RANGE (YEAR(repair_start_time)) (
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026)
);

-- 3. 查询优化
-- 使用合适的JOIN方式
-- 避免SELECT *，只查询需要的字段
-- 使用LIMIT限制结果集大小
```

#### 应用层性能优化
```java
// 1. 缓存策略
@Service
public class ProcurementRequirementService {
    
    @Cacheable(value = "procurement_requirements", key = "#itemId")
    public List<ProcurementRequirement> getRequirementsByItem(String itemId) {
        return repository.findByItemId(itemId);
    }
    
    @CacheEvict(value = "procurement_requirements", key = "#requirement.itemId")
    public ProcurementRequirement updateRequirement(ProcurementRequirement requirement) {
        return repository.save(requirement);
    }
}

// 2. 分页查询
@Repository
public interface ProcurementRequirementRepository extends JpaRepository<ProcurementRequirement, String> {
    
    @Query("SELECT p FROM ProcurementRequirement p WHERE p.itemId = :itemId")
    Page<ProcurementRequirement> findByItemId(@Param("itemId") String itemId, Pageable pageable);
}

// 3. 批量操作
@Service
public class ProcurementRequirementService {
    
    @Transactional
    public List<ProcurementRequirement> batchCreateRequirements(List<ProcurementRequirement> requirements) {
        return repository.saveAll(requirements);
    }
}
```

## 📋 总结

### 扩展方案特点

1. **数据驱动**：优先使用现有数据，减少开发工作量
2. **灵活扩展**：支持视图、扩展现有表、新建表多种方式
3. **性能优化**：完善的索引设计和查询优化策略
4. **标准化**：统一的命名规范和开发规范
5. **可维护**：清晰的架构设计和文档说明

### 适用场景

- 需要快速响应业务变化的MES系统
- 多客户定制化需求较多的系统
- 需要复杂报表分析的系统
- 对数据一致性要求较高的系统

### 实施建议

1. **分阶段实施**：先实现核心功能，再逐步添加高级特性
2. **数据优先**：优先使用现有数据，减少系统复杂度
3. **性能考虑**：合理设计索引和查询，保证系统性能
4. **规范遵循**：严格遵循开发规范，保证代码质量
5. **文档完善**：建立完整的扩展文档和使用说明

通过这个完整的业务扩展指南，MES系统可以灵活应对各种业务变化，实现真正的"乐高积木式"业务扩展。
