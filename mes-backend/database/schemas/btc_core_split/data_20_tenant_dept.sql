-- ==============================================
-- BTC核心数据库 - 租户和部门数据
-- ==============================================

USE btc_core;

-- 插入三个租户数据
INSERT INTO tenant (
    tenant_id, 
    tenant_code, 
    tenant_name, 
    tenant_type, 
    status, 
    contact_person,
    contact_email,
    industry,
    scale,
    subscription_plan,
    description,
    created_by
) VALUES 
-- 英国总公司 - 只读用户，主要供英国领导和IT查看
('TENANT_UK_HEAD', 'UK_HEAD', '英国总公司', 'ENTERPRISE', 'ACTIVE', 'IT Administrator', 'it@ukhead.com', 'Manufacturing', 'Large', 'ENTERPRISE', '英国总公司，大部分用户为只读用户，主要供英国领导和IT部门进行数据查看和分析', 'SYSTEM'),

-- 内网用户 - MES系统主要用户群体，100-300人规模
('TENANT_INERT', 'INERT', '内网用户', 'ENTERPRISE', 'ACTIVE', 'MES Administrator', 'admin@inert.com', 'Manufacturing', 'Medium', 'STANDARD', '内网用户群体，MES系统的主要用户，当前规模约100人，未来可扩展至300人', 'SYSTEM'),

-- 供应商群体 - 包括模具供应商、原材料供应商等
('TENANT_SUPPLIER', 'SUPPLIER', '供应商群体', 'SMALL_MEDIUM', 'ACTIVE', 'Supplier Manager', 'supplier@company.com', 'Supply Chain', 'Medium', 'BASIC', '供应商群体，包括模具供应商、原材料供应商等外部合作伙伴', 'SYSTEM');

-- 为每个租户插入默认部门
INSERT INTO sys_dept (dept_id, tenant_id, dept_code, dept_name, dept_type, sort_order, created_by)
VALUES 
-- 英国总公司部门
('DEPT_UK_HEAD', 'TENANT_UK_HEAD', 'UK_IT', 'IT部门', 'DEPARTMENT', 1, 'SYSTEM'),
('DEPT_UK_LEADERSHIP', 'TENANT_UK_HEAD', 'UK_LEADERSHIP', '领导层', 'DEPARTMENT', 2, 'SYSTEM'),

-- 内网用户部门（基于真实组织架构）
('DEPT_INERT_MANAGEMENT', 'TENANT_INERT', 'MANAGEMENT', '管理层', 'COMPANY', 1, 'SYSTEM'),
('DEPT_INERT_FINANCE', 'TENANT_INERT', 'FINANCE', '财务部门', 'DEPARTMENT', 2, 'SYSTEM'),
('DEPT_INERT_HR', 'TENANT_INERT', 'HR', '人事部门', 'DEPARTMENT', 3, 'SYSTEM'),
('DEPT_INERT_LOGISTICS', 'TENANT_INERT', 'LOGISTICS', '物流部门', 'DEPARTMENT', 4, 'SYSTEM'),
('DEPT_INERT_PROCUREMENT', 'TENANT_INERT', 'PROCUREMENT', '采购部门', 'DEPARTMENT', 5, 'SYSTEM'),
('DEPT_INERT_PRODUCTION', 'TENANT_INERT', 'PRODUCTION', '生产部门', 'DEPARTMENT', 6, 'SYSTEM'),
('DEPT_INERT_ENGINEERING', 'TENANT_INERT', 'ENGINEERING', '工程部门', 'DEPARTMENT', 7, 'SYSTEM'),
('DEPT_INERT_QUALITY', 'TENANT_INERT', 'QUALITY', '品质部门', 'DEPARTMENT', 8, 'SYSTEM'),
('DEPT_INERT_MAINTENANCE', 'TENANT_INERT', 'MAINTENANCE', '维修部门', 'DEPARTMENT', 9, 'SYSTEM'),
('DEPT_INERT_IT', 'TENANT_INERT', 'IT', 'IT部门', 'DEPARTMENT', 10, 'SYSTEM'),

-- 供应商群体部门
('DEPT_SUPPLIER_MOLD', 'TENANT_SUPPLIER', 'MOLD_SUPPLIER', '模具供应商', 'DEPARTMENT', 1, 'SYSTEM'),
('DEPT_SUPPLIER_RAW', 'TENANT_SUPPLIER', 'RAW_MATERIAL', '原材料供应商', 'DEPARTMENT', 2, 'SYSTEM');
