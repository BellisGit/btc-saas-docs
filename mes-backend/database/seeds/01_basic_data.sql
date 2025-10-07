-- 01_basic_data.sql
-- 基础数据种子文件
-- 基于MES系统全局架构基础文档
-- 作者: MES开发团队
-- 日期: 2025-01-07

-- 使用MES核心数据库
USE mes_core;

-- ==============================================
-- 1. 品质代码基础数据
-- ==============================================

-- 缺陷代码
INSERT INTO qms_code (code_type, code, description, category, status, tenant_id, created_by) VALUES
('DEFECT', 'SOLDER-01', '焊接不良', '焊接缺陷', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('DEFECT', 'SOLDER-02', '虚焊', '焊接缺陷', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('DEFECT', 'SOLDER-03', '连锡', '焊接缺陷', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('DEFECT', 'ASSY-01', '装配错误', '装配缺陷', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('DEFECT', 'ASSY-02', '漏装', '装配缺陷', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('DEFECT', 'ASSY-03', '错装', '装配缺陷', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('DEFECT', 'TEST-01', '功能测试失败', '测试缺陷', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('DEFECT', 'TEST-02', '参数超差', '测试缺陷', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('DEFECT', 'TEST-03', '外观不良', '外观缺陷', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('DEFECT', 'PACK-01', '包装错误', '包装缺陷', 'ACTIVE', 'TENANT001', 'SYSTEM');

-- 原因代码
INSERT INTO qms_code (code_type, code, description, category, status, tenant_id, created_by) VALUES
('CAUSE', 'MAT-01', '物料问题', '物料原因', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('CAUSE', 'MAT-02', '物料规格不符', '物料原因', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('CAUSE', 'EQP-01', '设备故障', '设备原因', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('CAUSE', 'EQP-02', '设备参数设置错误', '设备原因', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('CAUSE', 'OPE-01', '操作错误', '操作原因', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('CAUSE', 'OPE-02', '未按SOP操作', '操作原因', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('CAUSE', 'ENV-01', '环境因素', '环境原因', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('CAUSE', 'ENV-02', '温湿度异常', '环境原因', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('CAUSE', 'MOLD-01', '模具问题', '模具原因', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('CAUSE', 'MOLD-02', '模具磨损', '模具原因', 'ACTIVE', 'TENANT001', 'SYSTEM');

-- 处置代码
INSERT INTO qms_code (code_type, code, description, category, status, tenant_id, created_by) VALUES
('ACTION', 'REPAIR', '返修', '返工处置', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('ACTION', 'REWORK', '重工', '返工处置', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('ACTION', 'SCRAP', '报废', '报废处置', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('ACTION', 'CONCESSION', '让步接收', '让步处置', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('ACTION', 'RETURN', '退货', '退货处置', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('ACTION', 'REPLACE', '更换', '更换处置', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('ACTION', 'ISOLATE', '隔离', '隔离处置', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('ACTION', 'INVESTIGATE', '调查', '调查处置', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('ACTION', 'PREVENT', '预防', '预防处置', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('ACTION', 'ACCEPT', '接受', '接受处置', 'ACTIVE', 'TENANT001', 'SYSTEM');

-- ==============================================
-- 2. 供应商基础数据
-- ==============================================

INSERT INTO supplier_master (supplier_id, supplier_code, supplier_name, contact_person, contact_phone, contact_email, address, status, quality_rating, tenant_id, created_by) VALUES
('SUP-ACME001', 'ACME001', 'ACME电子有限公司', '张三', '13800138001', 'zhangsan@acme.com', '深圳市南山区科技园', 'ACTIVE', 4.8, 'TENANT001', 'SYSTEM'),
('SUP-TECH002', 'TECH002', 'Tech制造有限公司', '李四', '13800138002', 'lisi@tech.com', '东莞市长安镇', 'ACTIVE', 4.5, 'TENANT001', 'SYSTEM'),
('SUP-PREC003', 'PREC003', '精密模具有限公司', '王五', '13800138003', 'wangwu@prec.com', '苏州市工业园区', 'ACTIVE', 4.9, 'TENANT001', 'SYSTEM'),
('SUP-COMP004', 'COMP004', '组件供应商', '赵六', '13800138004', 'zhaoliu@comp.com', '上海市浦东新区', 'ACTIVE', 4.3, 'TENANT001', 'SYSTEM'),
('SUP-RAW005', 'RAW005', '原材料供应商', '钱七', '13800138005', 'qianqi@raw.com', '广州市天河区', 'ACTIVE', 4.6, 'TENANT001', 'SYSTEM');

-- ==============================================
-- 3. 物料基础数据
-- ==============================================

INSERT INTO item_master (item_id, item_code, item_name, item_type, uom, specification, supplier_id, status, tenant_id, created_by) VALUES
-- 原材料
('ITM-202501-0001', 'RAW-001', 'PCB主板', 'RAW', 'PCS', 'FR4材质，4层板', 'SUP-ACME001', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('ITM-202501-0002', 'RAW-002', 'IC芯片', 'RAW', 'PCS', 'STM32F407VGT6', 'SUP-TECH002', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('ITM-202501-0003', 'RAW-003', '电阻', 'RAW', 'PCS', '1KΩ ±5%', 'SUP-COMP004', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('ITM-202501-0004', 'RAW-004', '电容', 'RAW', 'PCS', '100uF 25V', 'SUP-COMP004', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('ITM-202501-0005', 'RAW-005', '外壳', 'RAW', 'PCS', 'ABS材质，黑色', 'SUP-RAW005', 'ACTIVE', 'TENANT001', 'SYSTEM'),

-- 组件
('ITM-202501-1001', 'COMP-001', '电源模块', 'COMPONENT', 'PCS', '5V/3A输出', 'SUP-TECH002', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('ITM-202501-1002', 'COMP-002', '显示模块', 'COMPONENT', 'PCS', 'LCD 2.4寸', 'SUP-TECH002', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('ITM-202501-1003', 'COMP-003', '按键模块', 'COMPONENT', 'PCS', '4键薄膜按键', 'SUP-COMP004', 'ACTIVE', 'TENANT001', 'SYSTEM'),

-- 成品
('ITM-202501-2001', 'FIN-001', '验钞机', 'FINISHED', 'PCS', '便携式验钞机', NULL, 'ACTIVE', 'TENANT001', 'SYSTEM'),
('ITM-202501-2002', 'FIN-002', '钱箱', 'FINISHED', 'PCS', '电子钱箱', NULL, 'ACTIVE', 'TENANT001', 'SYSTEM'),

-- 工具
('ITM-202501-3001', 'TOOL-001', '焊接夹具', 'TOOL', 'PCS', 'PCB焊接专用夹具', 'SUP-PREC003', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('ITM-202501-3002', 'TOOL-002', '测试治具', 'TOOL', 'PCS', '功能测试治具', 'SUP-PREC003', 'ACTIVE', 'TENANT001', 'SYSTEM'),

-- 耗材
('ITM-202501-4001', 'CONS-001', '焊锡丝', 'CONSUMABLE', 'KG', '0.8mm无铅焊锡丝', 'SUP-RAW005', 'ACTIVE', 'TENANT001', 'SYSTEM'),
('ITM-202501-4002', 'CONS-002', '助焊剂', 'CONSUMABLE', 'ML', '免清洗助焊剂', 'SUP-RAW005', 'ACTIVE', 'TENANT001', 'SYSTEM');

-- ==============================================
-- 4. 模具基础数据
-- ==============================================

INSERT INTO mold_master (mold_id, mold_code, mold_name, supplier_id, item_id, mold_type, status, last_maintenance_date, next_maintenance_date, tenant_id, created_by) VALUES
('MLD-SUP-0001', 'MOLD-001', 'PCB注塑模具', 'SUP-PREC003', 'ITM-202501-0001', 'INJECTION', 'ACTIVE', '2024-12-01', '2025-03-01', 'TENANT001', 'SYSTEM'),
('MLD-SUP-0002', 'MOLD-002', '外壳注塑模具', 'SUP-PREC003', 'ITM-202501-0005', 'INJECTION', 'ACTIVE', '2024-11-15', '2025-02-15', 'TENANT001', 'SYSTEM'),
('MLD-SUP-0003', 'MOLD-003', '按键冲压模具', 'SUP-PREC003', 'ITM-202501-1003', 'STAMPING', 'ACTIVE', '2024-12-10', '2025-03-10', 'TENANT001', 'SYSTEM'),
('MLD-SUP-0004', 'MOLD-004', '装配治具', 'SUP-PREC003', 'ITM-202501-2001', 'ASSEMBLY', 'ACTIVE', '2024-11-20', '2025-02-20', 'TENANT001', 'SYSTEM'),
('MLD-SUP-0005', 'MOLD-005', '测试治具', 'SUP-PREC003', 'ITM-202501-2001', 'TESTING', 'ACTIVE', '2024-12-05', '2025-03-05', 'TENANT001', 'SYSTEM');

-- ==============================================
-- 5. 工艺路线基础数据
-- ==============================================

-- 验钞机工艺路线
INSERT INTO routing (routing_id, item_id, version, effective_from, effective_to, status, description, tenant_id, created_by) VALUES
('ROUT-001', 'ITM-202501-2001', 1, '2025-01-01 00:00:00', '2025-12-31 23:59:59', 'ACTIVE', '验钞机标准工艺路线', 'TENANT001', 'SYSTEM');

-- 验钞机工序定义
INSERT INTO operation (op_id, routing_id, op_seq, op_code, op_name, station_id, sop_id, sop_version, sample_plan, check_items, estimated_time, tenant_id, created_by) VALUES
('OP-001', 'ROUT-001', 1, 'SMT', 'SMT贴片', 'ST-001', 'SOP-001', 1, '{"type":"AQL","level":"II","sample_size":32}', '{"items":["贴片位置","焊接质量","极性检查"]}', 30, 'TENANT001', 'SYSTEM'),
('OP-002', 'ROUT-001', 2, 'DIP', 'DIP插件', 'ST-002', 'SOP-002', 1, '{"type":"AQL","level":"II","sample_size":32}', '{"items":["插件位置","焊接质量","剪脚长度"]}', 25, 'TENANT001', 'SYSTEM'),
('OP-003', 'ROUT-001', 3, 'ASSY', '组装', 'ST-003', 'SOP-003', 1, '{"type":"AQL","level":"II","sample_size":32}', '{"items":["装配顺序","螺丝扭矩","外观检查"]}', 20, 'TENANT001', 'SYSTEM'),
('OP-004', 'ROUT-001', 4, 'TEST1', '初测', 'ST-004', 'SOP-004', 1, '{"type":"100%","level":"","sample_size":100}', '{"items":["电源测试","功能测试","参数测试"]}', 15, 'TENANT001', 'SYSTEM'),
('OP-005', 'ROUT-001', 5, 'TEST2', '终测', 'ST-005', 'SOP-005', 1, '{"type":"100%","level":"","sample_size":100}', '{"items":["全功能测试","老化测试","外观检查"]}', 20, 'TENANT001', 'SYSTEM'),
('OP-006', 'ROUT-001', 6, 'PACK', '包装', 'ST-006', 'SOP-006', 1, '{"type":"AQL","level":"II","sample_size":32}', '{"items":["包装完整性","标签正确性","数量准确性"]}', 10, 'TENANT001', 'SYSTEM');

-- 钱箱工艺路线
INSERT INTO routing (routing_id, item_id, version, effective_from, effective_to, status, description, tenant_id, created_by) VALUES
('ROUT-002', 'ITM-202501-2002', 1, '2025-01-01 00:00:00', '2025-12-31 23:59:59', 'ACTIVE', '钱箱标准工艺路线', 'TENANT001', 'SYSTEM');

-- 钱箱工序定义
INSERT INTO operation (op_id, routing_id, op_seq, op_code, op_name, station_id, sop_id, sop_version, sample_plan, check_items, estimated_time, tenant_id, created_by) VALUES
('OP-007', 'ROUT-002', 1, 'SMT', 'SMT贴片', 'ST-001', 'SOP-007', 1, '{"type":"AQL","level":"II","sample_size":32}', '{"items":["贴片位置","焊接质量","极性检查"]}', 35, 'TENANT001', 'SYSTEM'),
('OP-008', 'ROUT-002', 2, 'DIP', 'DIP插件', 'ST-002', 'SOP-008', 1, '{"type":"AQL","level":"II","sample_size":32}', '{"items":["插件位置","焊接质量","剪脚长度"]}', 30, 'TENANT001', 'SYSTEM'),
('OP-009', 'ROUT-002', 3, 'ASSY', '组装', 'ST-003', 'SOP-009', 1, '{"type":"AQL","level":"II","sample_size":32}', '{"items":["装配顺序","螺丝扭矩","外观检查"]}', 25, 'TENANT001', 'SYSTEM'),
('OP-010', 'ROUT-002', 4, 'TEST1', '初测', 'ST-004', 'SOP-010', 1, '{"type":"100%","level":"","sample_size":100}', '{"items":["电源测试","功能测试","参数测试"]}', 18, 'TENANT001', 'SYSTEM'),
('OP-011', 'ROUT-002', 5, 'TEST2', '终测', 'ST-005', 'SOP-011', 1, '{"type":"100%","level":"","sample_size":100}', '{"items":["全功能测试","老化测试","外观检查"]}', 22, 'TENANT001', 'SYSTEM'),
('OP-012', 'ROUT-002', 6, 'PACK', '包装', 'ST-006', 'SOP-012', 1, '{"type":"AQL","level":"II","sample_size":32}', '{"items":["包装完整性","标签正确性","数量准确性"]}', 12, 'TENANT001', 'SYSTEM');
