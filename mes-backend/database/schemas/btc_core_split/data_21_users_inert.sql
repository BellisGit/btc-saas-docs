-- ==============================================
-- BTC核心数据库 - INERT内网用户数据
-- ==============================================

USE btc_core;

-- 插入基于user_profile的真实用户数据
INSERT INTO sys_user (user_id, tenant_id, dept_id, position_id, username, password_hash, real_name, email, user_type, status, created_by)
VALUES 
-- === 英国总公司用户 ===
('USER_58', 'TENANT_UK_HEAD', 'DEPT_UK_HEAD', 'POS_UK_READONLY', 'uk', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', 'UK', 'btcinformation@bellis-technology.cn', 'READONLY', 'ACTIVE', 'SYSTEM'),

-- === 内网用户 (TENANT_INERT) - 57人 ===
-- 管理层 (1人)
('USER_1', 'TENANT_INERT', 'DEPT_INERT_MANAGEMENT', 'POS_INERT_CEO', 'iji', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '季小波', 'iji@bellis-technology.cn', 'EXECUTIVE', 'ACTIVE', 'SYSTEM'),

-- 财务部门 (4人)
('USER_11', 'TENANT_INERT', 'DEPT_INERT_FINANCE', 'POS_INERT_FINANCE_MGR', 'lcai', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '蔡亮', 'lcai@bellis-technology.cn', 'MANAGER', 'ACTIVE', 'SYSTEM'),
('USER_12', 'TENANT_INERT', 'DEPT_INERT_FINANCE', 'POS_INERT_FINANCE_SUPER', 'mhong', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '洪梅', 'mhong@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_13', 'TENANT_INERT', 'DEPT_INERT_FINANCE', 'POS_INERT_FINANCE', 'ezhang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '张慧玲', 'ezhang@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_14', 'TENANT_INERT', 'DEPT_INERT_FINANCE', 'POS_INERT_FINANCE', 'dali', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '黎秋怡', 'dali@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),

-- 人事部门 (2人)
('USER_15', 'TENANT_INERT', 'DEPT_INERT_HR', 'POS_INERT_HR_SUPER', 'tding', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '丁婷', 'tding@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_16', 'TENANT_INERT', 'DEPT_INERT_HR', 'POS_INERT_HR', 'mhuang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '黄美艳', 'mhuang@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),

-- 物流部门 (4人)
('USER_2', 'TENANT_INERT', 'DEPT_INERT_LOGISTICS', 'POS_INERT_LOGISTICS_MGR', 'fxiong', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '熊匀', 'fxiong@bellis-technology.cn', 'MANAGER', 'ACTIVE', 'SYSTEM'),
('USER_3', 'TENANT_INERT', 'DEPT_INERT_LOGISTICS', 'POS_INERT_CUSTOMS', 'mliu', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '刘振飞', 'mliu@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_4', 'TENANT_INERT', 'DEPT_INERT_LOGISTICS', 'POS_INERT_CUSTOMS', 'azhang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '张米花', 'azhang@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_10', 'TENANT_INERT', 'DEPT_INERT_LOGISTICS', 'POS_INERT_WAREHOUSE_LEADER', 'hxiao', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '肖荤莲', 'hxiao@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),

-- 采购部门 (5人)
('USER_5', 'TENANT_INERT', 'DEPT_INERT_PROCUREMENT', 'POS_INERT_PROCUREMENT_MGR', 'ayang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '杨志叶', 'ayang@bellis-technology.cn', 'MANAGER', 'ACTIVE', 'SYSTEM'),
('USER_6', 'TENANT_INERT', 'DEPT_INERT_PROCUREMENT', 'POS_INERT_PROCUREMENT_ECN', 'kgao', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '高广玉', 'kgao@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_7', 'TENANT_INERT', 'DEPT_INERT_PROCUREMENT', 'POS_INERT_PROCUREMENT', 'kbao', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '鲍文林', 'kbao@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_8', 'TENANT_INERT', 'DEPT_INERT_PROCUREMENT', 'POS_INERT_PROCUREMENT_AUXMAT', 'aguo', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '郭凤英', 'aguo@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_9', 'TENANT_INERT', 'DEPT_INERT_PROCUREMENT', 'POS_INERT_PROCUREMENT_PKG', 'lwang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '王观丽', 'lwang@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),

-- 生产部门 (11人)
('USER_17', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'POS_INERT_PRODUCTION_MGR', 'azhou', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '周海涛', 'azhou@bellis-technology.cn', 'MANAGER', 'ACTIVE', 'SYSTEM'),
('USER_18', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'POS_INERT_PRODUCTION_SHIP', 'lli', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '黎艳均', 'lli@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_19', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'POS_INERT_PRODUCTION_WORKSHOP', 'jiangli', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '蒋丽', 'jiangli@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_20', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'POS_INERT_PRODUCTION_LEADER', 'pliu', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '刘培', 'pliu@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_21', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'POS_INERT_PRODUCTION_GROUP', 'cwang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '王翠平', 'cwang@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_22', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'POS_INERT_PRODUCTION_GROUP', 'cyuying', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '蔡玉颖', 'cyuying@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_23', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'POS_INERT_PRODUCTION_GROUP', 'czhu', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '朱长坤', 'czhu@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_24', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'POS_INERT_PRODUCTION_ENG', 'jguo', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '郭建强', 'jguo@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_25', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'POS_INERT_PRODUCTION_AUTO', 'sshang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '尚思丰', 'sshang@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_26', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'POS_INERT_PRODUCTION_AUTO', 'syang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '杨升', 'syang@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_27', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'POS_INERT_PRODUCTION_CLERK', 'ayi', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '易兴平', 'ayi@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_28', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'POS_INERT_PRODUCTION_CLERK', 'xxiao', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '肖丽', 'xxiao@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_29', 'TENANT_INERT', 'DEPT_INERT_PRODUCTION', 'POS_INERT_PRODUCTION_CLERK', 'dxu', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '徐德琴', 'dxu@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),

-- 工程部门 (10人)
('USER_30', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'POS_INERT_ENGINEERING_MGR', 'dwei', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '韦占光', 'dwei@bellis-technology.cn', 'MANAGER', 'ACTIVE', 'SYSTEM'),
('USER_31', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'POS_INERT_ENGINEERING_SUPER', 'dlee', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '李海林', 'dlee@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_32', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'POS_INERT_NPD_ENG', 'hhuang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '黄海辉', 'hhuang@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_33', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'POS_INERT_NPD_ENG', 'lxiao', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '肖星宇', 'lxiao@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_34', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'POS_INERT_NPD_ENG', 'kjii', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '季晨阳', 'kjii@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_35', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'POS_INERT_NPD_ENG', 'vchen', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '陈蔓', 'vchen@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_36', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'POS_INERT_NPD_ENG', 'jhu', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '胡锦伦', 'jhu@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_37', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'POS_INERT_NPD_ENG', 'sshu', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '舒恒', 'sshu@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_38', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'POS_INERT_MOLD_ENG', 'jchen', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '陈强', 'jchen@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_39', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'POS_INERT_MOLD_ENG', 'zliao', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '廖凯臻', 'zliao@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),

-- 工程部门 - 生产工程师 (3人)
('USER_40', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'POS_INERT_PROCESS_ENG', 'jxaing', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '向枕毅', 'jxaing@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_41', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'POS_INERT_PROCESS_ENG', 'ejiang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '江勤', 'ejiang@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_42', 'TENANT_INERT', 'DEPT_INERT_ENGINEERING', 'POS_INERT_PROCESS_ENG', 'hqingchuan', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '黄清传', 'hqingchuan@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),

-- 品质部门 (14人)
('USER_43', 'TENANT_INERT', 'DEPT_INERT_QUALITY', 'POS_INERT_QUALITY_MGR', 'sli', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '黎厚利', 'sli@bellis-technology.cn', 'MANAGER', 'ACTIVE', 'SYSTEM'),
('USER_50', 'TENANT_INERT', 'DEPT_INERT_QUALITY', 'POS_INERT_QUALITY_SUPER', 'nwang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '王艳', 'nwang@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_46', 'TENANT_INERT', 'DEPT_INERT_QUALITY', 'POS_INERT_FAI', 'faliu', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '刘芳', 'faliu@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_51', 'TENANT_INERT', 'DEPT_INERT_QUALITY', 'POS_INERT_IQC', 'kzhang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '张枭', 'kzhang@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_53', 'TENANT_INERT', 'DEPT_INERT_QUALITY', 'POS_INERT_IQC', 'xtan', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '谭学琼', 'xtan@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_54', 'TENANT_INERT', 'DEPT_INERT_QUALITY', 'POS_INERT_IQC', 'sjiang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '江三秀', 'sjiang@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_55', 'TENANT_INERT', 'DEPT_INERT_QUALITY', 'POS_INERT_IQC', 'hgu', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '顾红雷', 'hgu@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_56', 'TENANT_INERT', 'DEPT_INERT_QUALITY', 'POS_INERT_IPQC', 'fzhang', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '张凤云', 'fzhang@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_52', 'TENANT_INERT', 'DEPT_INERT_QUALITY', 'POS_INERT_QUALITY_EXTERNAL', 'iliu', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '刘志林', 'iliu@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_49', 'TENANT_INERT', 'DEPT_INERT_QUALITY', 'POS_INERT_QUALITY_REPAIR', 'jili', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '李建强', 'jili@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_57', 'TENANT_INERT', 'DEPT_INERT_QUALITY', 'POS_INERT_QUALITY_CLERK', 'jhao', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '郝娟', 'jhao@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),

-- 维修部门 (1人)
('USER_48', 'TENANT_INERT', 'DEPT_INERT_MAINTENANCE', 'POS_INERT_MAINTENANCE', 'ami', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '米红刚', 'ami@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),

-- IT部门 (3人)
('USER_44', 'TENANT_INERT', 'DEPT_INERT_IT', 'POS_INERT_IT_ENG', 'mlu', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '卢澳华', 'mlu@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_45', 'TENANT_INERT', 'DEPT_INERT_IT', 'POS_INERT_IT_DEV', 'jqi', '$2a$10$7JB720yubVSOfvVame6cOu7L2fR6Vj8Q9qN8Q9qN8Q9qN8Q9qN8Q9q', '覃思创', 'jqi@bellis-technology.cn', 'NORMAL', 'ACTIVE', 'SYSTEM'),
('USER_47', 'TENANT_INERT', 'DEPT_INERT_IT', 'POS_INERT_IT_OPS', 'xmei', '$2a$10$
