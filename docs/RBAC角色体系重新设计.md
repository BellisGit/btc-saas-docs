# RBAC角色体系重新设计

## 📋 设计原则说明

### 问题分析

原有设计存在的问题：
- ❌ **职位 = 角色**: 直接将"财务经理"、"生产组长"作为角色
- ❌ **冗余爆炸**: 57个员工对应43个角色，过度细化
- ❌ **灵活性差**: 组织调整会破坏权限体系
- ❌ **难以复用**: 角色与具体职位绑定，无法跨部门共享

### 正确的RBAC设计原则

#### 1. 角色 ≠ 职位
- **职位**: 组织学概念，"你是谁"、"你做什么工作"
- **角色**: 权限控制概念，"你能在系统里做什么"

#### 2. 最小权限原则
- 角色应仅包含完成工作所需的最小权限
- 避免"超权"或"越权"

#### 3. 权限的可复用性
- 角色应该是权限模板，多个用户可共用
- 一个用户可以有多个角色（权限组合）

#### 4. 职责分离（SoD）
- 关键操作需要多角色协作
- 创建和审批不能是同一角色

---

## 🎯 基于MES业务流程的角色设计

### 一、数据查看类角色（READ权限）

#### ROLE_DATA_VIEWER_ALL
- **权限范围**: 查看所有数据（只读）
- **适用职位**: 总经理、英国领导
- **典型操作**:
  - 查看BI大屏
  - 查看所有报表
  - 查看生产状态
- **数据权限**: ALL (只读)

#### ROLE_DATA_VIEWER_DEPT
- **权限范围**: 查看本部门数据（只读）
- **适用职位**: 各部门主管、文员
- **典型操作**:
  - 查看本部门报表
  - 查看本部门人员数据
- **数据权限**: DEPT (只读)

#### ROLE_BI_ANALYST
- **权限范围**: BI数据分析
- **适用职位**: 数据分析师、高管
- **典型操作**:
  - 查看BI看板
  - 生成分析报表
  - 数据导出
- **数据权限**: ALL (只读) + 报表生成

---

### 二、采购域角色（Procurement Domain）

#### ROLE_PROCUREMENT_ORDER_CREATE
- **权限范围**: 创建采购订单
- **适用职位**: 采购专员、采购经理
- **典型操作**:
  - 创建采购申请
  - 填写采购订单
  - 选择供应商
- **数据权限**: DEPT (写)

#### ROLE_PROCUREMENT_ORDER_APPROVE
- **权限范围**: 审批采购订单
- **适用职位**: 采购经理、财务经理
- **典型操作**:
  - 审批采购订单
  - 驳回订单
  - 审批特采
- **数据权限**: DEPT_AND_CHILD

#### ROLE_PROCUREMENT_ECN_MANAGE
- **权限范围**: ECN变更管理
- **适用职位**: 采购ECN专员、工程师
- **典型操作**:
  - 创建ECN变更单
  - 上传ECN文件到ITL
  - 追踪变更状态
- **数据权限**: DEPT

#### ROLE_SUPPLIER_MANAGE
- **权限范围**: 供应商管理
- **适用职位**: 采购经理、采购专员
- **典型操作**:
  - 供应商信息维护
  - 供应商评分
  - 供应商评估
- **数据权限**: DEPT

---

### 三、物流域角色（Logistics Domain）

#### ROLE_CUSTOMS_DECLARE
- **权限范围**: 海关报备
- **适用职位**: 海关专员
- **典型操作**:
  - 创建报关单
  - 上传报关资料
  - 追踪报关状态
- **数据权限**: DEPT

#### ROLE_WAREHOUSE_RECEIVE
- **权限范围**: 收货入库
- **适用职位**: 仓管员、仓管大组长
- **典型操作**:
  - 创建GRN收货单
  - 扫码入库
  - 库位分配
- **数据权限**: DEPT

#### ROLE_WAREHOUSE_ISSUE
- **权限范围**: 备料出库
- **适用职位**: 仓管员、生产领料员
- **典型操作**:
  - 备料单创建
  - 物料发放
  - 出库扫码
- **数据权限**: DEPT

#### ROLE_INVENTORY_COUNT
- **权限范围**: 库存盘点
- **适用职位**: 仓管员、盘点员
- **典型操作**:
  - 移动端扫码盘点
  - 差异录入
  - 盘点数据上传
- **数据权限**: DEPT

#### ROLE_INVENTORY_APPROVE
- **权限范围**: 库存审批
- **适用职位**: 物流经理、仓库经理
- **典型操作**:
  - 差异复核
  - 调账审批
  - ERP同步审批
- **数据权限**: DEPT_AND_CHILD

---

### 四、品质域角色（Quality Domain）

#### ROLE_IQC_INSPECT
- **权限范围**: IQC进料检验
- **适用职位**: IQC检验员
- **典型操作**:
  - 创建IQC检验单
  - AQL抽样检验
  - 上传检验影像
  - 判定合格/不合格
- **数据权限**: DEPT

#### ROLE_IQC_APPROVE
- **权限范围**: IQC结果审批
- **适用职位**: 品质主管、品质经理
- **典型操作**:
  - 审批IQC结果
  - 不合格品处理决策
  - 特采审批
- **数据权限**: DEPT_AND_CHILD

#### ROLE_IPQC_INSPECT
- **权限范围**: IPQC过程巡检
- **适用职位**: IPQC巡检员
- **典型操作**:
  - 生产过程抽检
  - 记录抽检结果
  - 动态调整抽检频次
- **数据权限**: DEPT

#### ROLE_OQC_INSPECT
- **权限范围**: OQC出货检验
- **适用职位**: OQC检验员
- **典型操作**:
  - 成品抽检
  - AQL判定
  - 箱号/托盘号检验
- **数据权限**: DEPT

#### ROLE_FAI_VERIFY
- **权限范围**: 首件验证
- **适用职位**: FAI专员、工程师
- **典型操作**:
  - 首件检验
  - 首件报告生成
  - 首件合格判定
  - 禁止/允许批量生产
- **数据权限**: DEPT

#### ROLE_QUALITY_NCR_CREATE
- **权限范围**: 创建NCR/SCAR
- **适用职位**: 品质检验员、工程师
- **典型操作**:
  - 创建不合格报告
  - 记录问题描述
  - 关联检验单
- **数据权限**: DEPT

#### ROLE_QUALITY_NCR_HANDLE
- **权限范围**: 处理NCR/SCAR
- **适用职位**: 品质主管、供应商
- **典型操作**:
  - 制定纠正措施
  - 执行整改
  - 提交验证
- **数据权限**: DEPT

#### ROLE_QUALITY_APPROVE
- **权限范围**: 品质审批
- **适用职位**: 品质经理
- **典型操作**:
  - NCR/SCAR审批
  - 供应商评分审批
  - 客诉处理审批
  - 出货放行
- **数据权限**: DEPT_AND_CHILD

---

### 五、生产域角色（Production Domain）

#### ROLE_PRODUCTION_PLAN_CREATE
- **权限范围**: 创建生产计划
- **适用职位**: 计划工程师、生产经理
- **典型操作**:
  - 创建生产计划
  - 工单排程
  - 资源分配
- **数据权限**: DEPT

#### ROLE_PRODUCTION_PLAN_APPROVE
- **权限范围**: 审批生产计划
- **适用职位**: 生产经理、工程经理
- **典型操作**:
  - 审批生产计划
  - 调整排程
  - 资源确认
- **数据权限**: DEPT_AND_CHILD

#### ROLE_WORK_ORDER_CREATE
- **权限范围**: 创建工单
- **适用职位**: 生产计划员、生产经理
- **典型操作**:
  - 创建工单
  - 下发工单
  - 工单分配
- **数据权限**: DEPT

#### ROLE_WORK_ORDER_EXECUTE
- **权限范围**: 执行工单
- **适用职位**: 生产组长、生产操作员
- **典型操作**:
  - 领取工单
  - 报工
  - 记录WIP状态
  - 装配/组装操作
- **数据权限**: DEPT

#### ROLE_PRODUCTION_TEST
- **权限范围**: 生产测试
- **适用职位**: 测试操作员、生产组长
- **典型操作**:
  - 初测/终测
  - 记录测试结果
  - 标记PASS/FAIL
- **数据权限**: DEPT

#### ROLE_PRODUCTION_REPAIR
- **权限范围**: 返修操作
- **适用职位**: 维修专员、生产操作员
- **典型操作**:
  - 记录返修
  - 返修次数控制
  - 复测标记
- **数据权限**: DEPT

#### ROLE_PRODUCTION_PACK
- **权限范围**: 打包出货
- **适用职位**: 生产出货主管、包装员
- **典型操作**:
  - 生成箱号
  - 生成托盘号
  - 打包记录
- **数据权限**: DEPT

---

### 六、工程域角色（Engineering Domain）

#### ROLE_ENGINEERING_NPD
- **权限范围**: 新产品开发
- **适用职位**: NPD工程师、工程经理
- **典型操作**:
  - 新项目立项
  - 与ITL总部沟通
  - 试产方案制定
  - FAI执行
  - 上传FAI报告到ITL
- **数据权限**: DEPT

#### ROLE_ENGINEERING_PROCESS
- **权限范围**: 工艺管理
- **适用职位**: 工艺工程师、生产工程师
- **典型操作**:
  - 工艺路线设计
  - SOP编制
  - 工艺参数调整
  - 工序优化
- **数据权限**: DEPT

#### ROLE_ENGINEERING_MOLD
- **权限范围**: 模具管理
- **适用职位**: 模具工程师
- **典型操作**:
  - 模具信息维护
  - 模具寿命管理
  - 模具维护记录
  - 模具供应商协调
- **数据权限**: DEPT

#### ROLE_ENGINEERING_APPROVE
- **权限范围**: 工程审批
- **适用职位**: 工程经理
- **典型操作**:
  - FAI报告审批
  - 工艺路线审批
  - ECN变更审批
- **数据权限**: DEPT_AND_CHILD

---

### 七、追溯与分析角色（Traceability & Analysis）

#### ROLE_TRACE_QUERY
- **权限范围**: 追溯查询
- **适用职位**: 品质人员、工程师、客服
- **典型操作**:
  - 正向追溯（订单→出货）
  - 反向追溯（SN→用料）
  - 查询检验记录
  - 查询测试记录
- **数据权限**: ALL (只读)

#### ROLE_TRACE_ANALYST
- **权限范围**: 追溯分析
- **适用职位**: 品质经理、工程经理
- **典型操作**:
  - 客诉追溯分析
  - 生成责任归因报告
  - 问题根因分析
- **数据权限**: ALL

---

### 八、系统管理角色（System Management）

#### ROLE_SYSTEM_ADMIN
- **权限范围**: 系统管理
- **适用职位**: IT工程师、系统管理员
- **典型操作**:
  - 用户管理
  - 角色管理
  - 权限配置
  - 系统配置
- **数据权限**: ALL

#### ROLE_USER_MANAGE
- **权限范围**: 用户管理
- **适用职位**: HR人员、部门经理
- **典型操作**:
  - 创建用户
  - 修改用户信息
  - 停用用户
- **数据权限**: DEPT_AND_CHILD

#### ROLE_TENANT_ADMIN
- **权限范围**: 租户管理
- **适用职位**: 超级管理员
- **典型操作**:
  - 租户创建
  - 租户配置
  - 跨租户管理
- **数据权限**: ALL

#### ROLE_MODULE_ADMIN
- **权限范围**: 模块管理
- **适用职位**: 系统管理员、模块负责人
- **典型操作**:
  - 模块配置
  - 插件管理
  - 模块部署
- **数据权限**: DEPT_AND_CHILD

---

### 九、财务与HR角色

#### ROLE_FINANCE_VIEW
- **权限范围**: 财务数据查看
- **适用职位**: 财务专员、财务主管
- **典型操作**:
  - 查看成本数据
  - 查看费用明细
  - 查看财务报表
- **数据权限**: DEPT

#### ROLE_FINANCE_APPROVE
- **权限范围**: 财务审批
- **适用职位**: 财务经理
- **典型操作**:
  - 审批费用
  - 审批预算
  - 财务报表审批
- **数据权限**: DEPT_AND_CHILD

#### ROLE_HR_MANAGE
- **权限范围**: 人事管理
- **适用职位**: HR专员、HR主管
- **典型操作**:
  - 员工信息管理
  - 考勤管理
  - 招聘管理
- **数据权限**: DEPT

---

### 十、供应商协同角色（Supplier Collaboration）

#### ROLE_SUPPLIER_ORDER_VIEW
- **权限范围**: 查看采购订单
- **适用职位**: 供应商
- **典型操作**:
  - 查看自己的订单
  - 查看交付要求
  - 查看订单状态
- **数据权限**: SELF (只读)

#### ROLE_SUPPLIER_IQC_COLLABORATE
- **权限范围**: IQC协同
- **适用职位**: 供应商
- **典型操作**:
  - 查看IQC结果
  - 查看不合格通知
  - 查看NCR/SCAR
  - 提交整改报告
- **数据权限**: SELF

#### ROLE_SUPPLIER_DELIVERY_MANAGE
- **权限范围**: 发货管理
- **适用职位**: 供应商
- **典型操作**:
  - 上传发货单
  - 更新发货状态
  - 物流追踪
- **数据权限**: SELF

#### ROLE_SUPPLIER_MOLD_UPDATE
- **权限范围**: 模具状态更新
- **适用职位**: 模具供应商
- **典型操作**:
  - 更新模具状态
  - 上传维护记录
  - 报告模具寿命
- **数据权限**: SELF

---

## 📊 完整角色清单（基于业务行为）

### 角色分类统计

| 类别 | 角色数量 | 角色列表 |
|------|----------|----------|
| 数据查看类 | 3 | DATA_VIEWER_ALL, DATA_VIEWER_DEPT, BI_ANALYST |
| 采购域 | 4 | PROCUREMENT_ORDER_CREATE/APPROVE, ECN_MANAGE, SUPPLIER_MANAGE |
| 物流域 | 5 | CUSTOMS_DECLARE, WAREHOUSE_RECEIVE/ISSUE, INVENTORY_COUNT/APPROVE |
| 品质域 | 8 | IQC/IPQC/OQC_INSPECT, FAI_VERIFY, IQC/QUALITY_APPROVE, NCR_CREATE/HANDLE |
| 生产域 | 7 | PLAN_CREATE/APPROVE, WO_CREATE/EXECUTE, TEST, REPAIR, PACK |
| 工程域 | 4 | NPD, PROCESS, MOLD, APPROVE |
| 追溯分析 | 2 | TRACE_QUERY, TRACE_ANALYST |
| 系统管理 | 4 | SYSTEM_ADMIN, USER_MANAGE, TENANT_ADMIN, MODULE_ADMIN |
| 财务HR | 3 | FINANCE_VIEW/APPROVE, HR_MANAGE |
| 供应商协同 | 4 | SUPPLIER_ORDER_VIEW, IQC_COLLABORATE, DELIVERY_MANAGE, MOLD_UPDATE |
| **总计** | **44** | |

---

## 🔗 职位到角色的映射关系

### 内网用户职位映射

#### 总经理 (季小波)
```
职位: 总经理
角色组合:
  - ROLE_DATA_VIEWER_ALL
  - ROLE_BI_ANALYST
  - ROLE_PRODUCTION_PLAN_APPROVE
  - ROLE_PROCUREMENT_ORDER_APPROVE
  - ROLE_FINANCE_APPROVE
```

#### 品质经理 (黎厚利)
```
职位: 品质经理
角色组合:
  - ROLE_DATA_VIEWER_DEPT
  - ROLE_IQC_APPROVE
  - ROLE_QUALITY_APPROVE
  - ROLE_TRACE_ANALYST
  - ROLE_QUALITY_NCR_HANDLE
```

#### IQC检验员 (张枭、谭学琼、江三秀、顾红雷)
```
职位: IQC检验员
角色组合:
  - ROLE_IQC_INSPECT
  - ROLE_QUALITY_NCR_CREATE
  - ROLE_DATA_VIEWER_DEPT
```

#### 采购经理 (杨志叶)
```
职位: 采购经理
角色组合:
  - ROLE_PROCUREMENT_ORDER_CREATE
  - ROLE_PROCUREMENT_ORDER_APPROVE
  - ROLE_SUPPLIER_MANAGE
  - ROLE_DATA_VIEWER_DEPT
```

#### 采购ECN专员 (高广玉)
```
职位: 采购ECN变更专员
角色组合:
  - ROLE_PROCUREMENT_ECN_MANAGE
  - ROLE_PROCUREMENT_ORDER_CREATE
  - ROLE_DATA_VIEWER_DEPT
```

#### 物流经理 (熊匀)
```
职位: 物流经理
角色组合:
  - ROLE_WAREHOUSE_RECEIVE
  - ROLE_WAREHOUSE_ISSUE
  - ROLE_INVENTORY_APPROVE
  - ROLE_CUSTOMS_DECLARE
  - ROLE_DATA_VIEWER_DEPT
```

#### 海关专员 (刘振飞、张米花)
```
职位: 海关专员
角色组合:
  - ROLE_CUSTOMS_DECLARE
  - ROLE_DATA_VIEWER_DEPT
```

#### 仓管大组长 (肖荤莲)
```
职位: 仓管大组长
角色组合:
  - ROLE_WAREHOUSE_RECEIVE
  - ROLE_WAREHOUSE_ISSUE
  - ROLE_INVENTORY_COUNT
  - ROLE_DATA_VIEWER_DEPT
```

#### 生产经理 (周海涛)
```
职位: 生产经理
角色组合:
  - ROLE_PRODUCTION_PLAN_CREATE
  - ROLE_PRODUCTION_PLAN_APPROVE
  - ROLE_WORK_ORDER_CREATE
  - ROLE_DATA_VIEWER_DEPT
```

#### 生产组长 (王翠平、蔡玉颖、朱长坤)
```
职位: 生产组长
角色组合:
  - ROLE_WORK_ORDER_EXECUTE
  - ROLE_PRODUCTION_TEST
  - ROLE_PRODUCTION_REPAIR
  - ROLE_DATA_VIEWER_DEPT
```

#### NPD工程师 (黄海辉、肖星宇等6人)
```
职位: NPD工程师
角色组合:
  - ROLE_ENGINEERING_NPD
  - ROLE_FAI_VERIFY
  - ROLE_ENGINEERING_PROCESS
  - ROLE_DATA_VIEWER_DEPT
```

#### 工程经理 (韦占光)
```
职位: 工程经理
角色组合:
  - ROLE_ENGINEERING_NPD
  - ROLE_ENGINEERING_APPROVE
  - ROLE_PRODUCTION_PLAN_APPROVE
  - ROLE_DATA_VIEWER_DEPT
```

#### 供应商用户 (52人)
```
职位: 原材料供应商
角色组合:
  - ROLE_SUPPLIER_ORDER_VIEW
  - ROLE_SUPPLIER_IQC_COLLABORATE
  - ROLE_SUPPLIER_DELIVERY_MANAGE
```

---

## 🎭 角色设计优势

### 1. 权限复用
```
ROLE_IQC_INSPECT:
  - 被5个IQC检验员使用
  - 权限统一管理
  - 一次修改，全部生效
```

### 2. 灵活组合
```
品质经理 = ROLE_IQC_APPROVE + ROLE_QUALITY_APPROVE + ROLE_TRACE_ANALYST
品质主管 = ROLE_IQC_APPROVE + ROLE_QUALITY_NCR_HANDLE
IQC专员 = ROLE_IQC_INSPECT + ROLE_QUALITY_NCR_CREATE
```

### 3. 职责分离
```
创建采购订单: ROLE_PROCUREMENT_ORDER_CREATE
审批采购订单: ROLE_PROCUREMENT_ORDER_APPROVE
(两个角色不能同时分配给一个人)
```

### 4. 独立演化
```
组织调整: 
  财务经理 → 财务总监
  
权限不变:
  仍然拥有 ROLE_FINANCE_APPROVE
  无需修改角色定义
```

---

## 📋 与职位的映射表

### 职位表设计

```sql
CREATE TABLE sys_position (
    position_id VARCHAR(32) PRIMARY KEY COMMENT '职位ID',
    tenant_id VARCHAR(32) NOT NULL COMMENT '租户ID',
    position_code VARCHAR(64) NOT NULL COMMENT '职位代码',
    position_name VARCHAR(128) NOT NULL COMMENT '职位名称',
    dept_id VARCHAR(32) COMMENT '所属部门',
    level INT COMMENT '职级',
    description TEXT COMMENT '职位描述',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tenant_id) REFERENCES sys_tenant(tenant_id),
    FOREIGN KEY (dept_id) REFERENCES sys_dept(dept_id)
) COMMENT '职位表';
```

### 职位-角色映射表

```sql
CREATE TABLE sys_position_role (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    position_id VARCHAR(32) NOT NULL COMMENT '职位ID',
    role_id VARCHAR(32) NOT NULL COMMENT '角色ID',
    is_default BOOLEAN DEFAULT TRUE COMMENT '是否默认角色',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_position_role (position_id, role_id),
    FOREIGN KEY (position_id) REFERENCES sys_position(position_id),
    FOREIGN KEY (role_id) REFERENCES sys_role(role_id)
) COMMENT '职位角色映射表';
```

### 用户-职位关联

```sql
ALTER TABLE sys_user 
ADD COLUMN position_id VARCHAR(32) COMMENT '职位ID',
ADD FOREIGN KEY (position_id) REFERENCES sys_position(position_id);
```

---

## 🔄 角色自动分配流程

### 1. 基于职位自动分配角色

```sql
-- 创建用户时，根据职位自动分配角色
INSERT INTO sys_user_role (user_id, role_id, created_by)
SELECT 
    'new_user_id',
    role_id,
    'SYSTEM'
FROM sys_position_role
WHERE position_id = 'selected_position_id';
```

### 2. 职位变更自动调整角色

```sql
-- 用户职位变更时，自动更新角色
-- 1. 删除旧职位的默认角色
DELETE FROM sys_user_role 
WHERE user_id = 'user_id' 
AND role_id IN (
    SELECT role_id FROM sys_position_role 
    WHERE position_id = 'old_position_id' AND is_default = TRUE
);

-- 2. 添加新职位的默认角色
INSERT INTO sys_user_role (user_id, role_id, created_by)
SELECT 'user_id', role_id, 'SYSTEM'
FROM sys_position_role
WHERE position_id = 'new_position_id' AND is_default = TRUE;
```

---

## 📈 对比总结

### 错误设计（职位 = 角色）
```
角色数: 43个
示例角色:
  - ROLE_INERT_FINANCE_MANAGER (财务经理)
  - ROLE_INERT_QC_INSPECTOR (品质检验员)
  - ROLE_INERT_PRODUCTION_GROUP_LEADER (生产组长)

问题:
  ❌ 角色与职位一一对应
  ❌ 组织调整影响权限
  ❌ 权限难以复用
  ❌ 角色数量过多
```

### 正确设计（权限 = 角色）
```
角色数: 44个
示例角色:
  - ROLE_IQC_INSPECT (IQC检验)
  - ROLE_PROCUREMENT_ORDER_APPROVE (采购审批)
  - ROLE_TRACE_ANALYST (追溯分析)

优势:
  ✅ 角色基于业务行为
  ✅ 权限可复用
  ✅ 灵活组合
  ✅ 独立于组织结构
```

### 映射关系
```
职位: 品质经理
↓ (多对多映射)
角色:
  - ROLE_IQC_APPROVE
  - ROLE_QUALITY_APPROVE
  - ROLE_TRACE_ANALYST
  - ROLE_DATA_VIEWER_DEPT
```

---

## 🚀 实施建议

### 第一阶段：重构角色定义
1. 删除基于职位的角色
2. 创建基于业务行为的角色
3. 建立职位表和职位-角色映射表

### 第二阶段：数据迁移
1. 创建44个新角色
2. 为57个内网用户分配角色组合
3. 为52个供应商分配协同角色

### 第三阶段：自动化
1. 实现职位变更自动调整角色
2. 实现基于职位的角色模板
3. 实现权限审计和检查

---

## 📝 总结

正确的RBAC设计应该：

1. ✅ **角色基于业务行为**，而非职位
2. ✅ **权限可组合复用**，而非固化绑定
3. ✅ **职责分离**，关键操作需要多角色
4. ✅ **独立演化**，组织调整不影响权限体系
5. ✅ **最小权限**，仅授予必要的操作权限

通过职位-角色映射表，实现：
- 组织结构 (职位) ↔ 权限系统 (角色) 的解耦
- 灵活的权限组合和管理
- 自动化的角色分配机制

这才是真正符合RBAC设计原则的权限体系！
