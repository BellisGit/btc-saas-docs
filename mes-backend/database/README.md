# BTC MES 数据库快速初始化指南

## 🚀 快速开始（30秒上手）

### 方式1：一键初始化所有数据库（推荐）

#### Linux/Mac:
```bash
cd mes-backend/database
chmod +x init_all_databases.sh
./init_all_databases.sh
```

#### Windows:
```cmd
cd mes-backend\database
init_all_databases.bat
```

### 方式2：单独初始化某个数据库

#### 初始化btc_core（核心业务数据库）
```bash
cd mes-backend/database/schemas/btc_core_split
chmod +x init_btc_core.sh
./init_btc_core.sh
```

#### 初始化btc_log（日志数据库）
```bash
cd mes-backend/database/schemas/btc_log
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS btc_log CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p btc_log < 01_operation_logs.sql
mysql -u root -p btc_log < 02_system_logs.sql
```

#### 初始化btc_bi（BI数据库）
```bash
cd mes-backend/database/schemas/btc_bi
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS btc_bi CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p btc_bi < 01_production_bi.sql
mysql -u root -p btc_bi < 02_quality_bi.sql
mysql -u root -p btc_bi < 03_system_bi.sql
mysql -u root -p btc_bi < 04_alert_monitoring.sql
```

## 📊 数据库结构

### 三大数据库

| 数据库 | 用途 | 表数量 | 初始数据 |
|--------|------|--------|----------|
| **btc_core** | 核心业务数据 | 28 | 3租户+110用户+44角色 |
| **btc_log** | 日志存储 | 8 | 无 |
| **btc_bi** | BI数据仓库 | 12 | 无 |
| **总计** | | **48** | ~500行 |

### btc_core（核心数据库）

#### 系统管理表（10个）
- `tenant` - 租户管理
- `sys_dept` - 部门管理
- `sys_user` - 用户管理
- `sys_role` - 角色管理（支持继承）
- `sys_permission` - 权限管理
- `sys_menu` - 菜单管理
- `sys_position` - 职位管理
- `sys_user_role` - 用户角色关联
- `sys_role_permission` - 角色权限关联
- `sys_menu_permission` - 菜单权限关联

#### 模块管理表（3个）
- `sys_module` - 模块管理
- `sys_plugin` - 插件管理
- `sys_user_module` - 用户模块关联

#### 职位管理表（1个）
- `sys_position_role` - 职位角色映射

#### 工作流表（6个）
- `workflow_definition` - 流程定义
- `workflow_node` - 流程节点
- `workflow_connection` - 流程连接
- `workflow_instance` - 流程实例
- `workflow_task` - 流程任务
- `workflow_history` - 流程历史

#### 追溯映射表（4个）
- `map_sn` - 产品SN映射
- `map_box_sn` - 箱码SN映射
- `map_pallet_box` - 托盘箱码映射
- `map_lot_material` - 批次物料映射

#### 追溯事件表（2个）
- `trace_event` - 追溯事件
- `trace_link` - 追溯链路快照

#### 测试测量表（2个）
- `test_record` - 测试记录
- `measure_record` - 测量记录

### btc_log（日志数据库）

| 表名 | 用途 | 分区 |
|------|------|------|
| `user_login_log` | 用户登录日志 | 按月 |
| `user_operation_log` | 用户操作日志 | 按月 |
| `api_access_log` | API访问日志 | 按月 |
| `data_change_log` | 数据变更日志 | 按月 |
| `system_error_log` | 系统错误日志 | 按月 |
| `system_performance_log` | 性能监控日志 | 按月 |
| `security_audit_log` | 安全审计日志 | 按月 |
| `batch_job_log` | 批处理作业日志 | 按月 |

### btc_bi（BI数据库）

#### 生产BI表（3个）
- `bi_production_daily` - 生产日报
- `bi_production_monthly` - 生产月报
- `bi_efficiency` - 效率分析

#### 品质BI表（3个）
- `bi_quality_daily` - 品质日报
- `bi_defect_analysis` - 缺陷分析
- `bi_supplier_quality` - 供应商品质

#### 系统BI表（3个）
- `bi_user_activity` - 用户活跃度
- `bi_module_usage` - 模块使用率
- `bi_performance` - 系统性能

#### 告警监控表（3个）
- `alert_rule` - 告警规则
- `alert_history` - 告警历史
- `alert_notification` - 告警通知

## ⚙️ 配置说明

### 环境变量

可以通过环境变量自定义数据库连接：

```bash
export MYSQL_HOST=localhost      # 默认：localhost
export MYSQL_PORT=3306           # 默认：3306
export MYSQL_USER=root           # 默认：root
export MYSQL_PASSWORD=yourpass   # 默认：空
```

### Windows配置

编辑 `init_all_databases.bat` 文件：

```batch
SET DB_USER=root
SET DB_PASS=your_password
SET DB_HOST=localhost
SET DB_PORT=3306
```

## 📈 性能预估

### 本地MySQL

| 操作 | 时间 |
|------|------|
| btc_core初始化 | 2-3秒 |
| btc_log初始化 | 1秒 |
| btc_bi初始化 | 1-2秒 |
| **总计** | **5-7秒** |

### 网络MySQL

| 网络延迟 | 总时间 |
|----------|--------|
| <10ms（本地） | 5-7秒 |
| 10-30ms（同城） | 10-15秒 |
| 50-100ms（跨区） | 20-30秒 |

## 🔧 故障排查

### 问题1：无法连接MySQL

**症状：**
```
ERROR: Cannot connect to MySQL
```

**解决方案：**
1. 检查MySQL服务是否运行
   ```bash
   # Linux
   sudo systemctl status mysql
   
   # Windows
   services.msc  # 查找MySQL服务
   ```

2. 检查用户名密码
3. 检查防火墙设置
4. 检查MySQL监听端口

### 问题2：权限不足

**症状：**
```
ERROR: Access denied for user
```

**解决方案：**
```sql
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

### 问题3：表已存在

**症状：**
```
ERROR: Table 'tenant' already exists
```

**解决方案：**

选项1：删除并重建（⚠️ 会丢失数据）
```sql
DROP DATABASE btc_core;
DROP DATABASE btc_log;
DROP DATABASE btc_bi;
```
然后重新运行初始化脚本

选项2：跳过已存在的表（修改SQL文件）
```sql
CREATE TABLE IF NOT EXISTS tenant (
    ...
);
```

### 问题4：编码问题

**症状：**
```
中文显示乱码
```

**解决方案：**
```sql
-- 检查数据库编码
SHOW CREATE DATABASE btc_core;

-- 修改数据库编码
ALTER DATABASE btc_core CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 检查表编码
SHOW CREATE TABLE btc_core.tenant;
```

## 📝 初始数据说明

### 租户数据（3个）

| 租户代码 | 租户名称 | 类型 | 用户数 |
|----------|----------|------|--------|
| UK_HEAD | 英国总公司 | 只读 | 1 |
| INERT | 内网用户 | 主要用户 | 57 |
| SUPPLIER | 供应商 | 外部协作 | 52 |

### 用户数据（110个）

| 类别 | 数量 | 说明 |
|------|------|------|
| 英国用户 | 1 | UK总公司只读用户 |
| 内网员工 | 57 | 财务、人事、物流、采购、生产、工程、品质、维修、IT |
| 供应商 | 52 | 模具供应商、原材料供应商 |

### 角色数据（44个）

基于业务行为的RBAC角色：

| 类别 | 数量 | 代表角色 |
|------|------|----------|
| 数据查看 | 3 | DATA_VIEWER_ALL, BI_ANALYST |
| 采购域 | 4 | PROCUREMENT_ORDER_CREATE/APPROVE |
| 物流域 | 5 | WAREHOUSE_RECEIVE/ISSUE |
| 品质域 | 8 | IQC/IPQC/OQC_INSPECT |
| 生产域 | 7 | WORK_ORDER_EXECUTE |
| 工程域 | 4 | ENGINEERING_NPD |
| 追溯分析 | 2 | TRACE_ANALYST |
| 系统管理 | 4 | SYSTEM_ADMIN |
| 财务HR | 3 | FINANCE_APPROVE |
| 供应商协同 | 4 | SUPPLIER_IQC_COLLABORATE |

### 职位数据（40个）

真实组织架构中的职位，包括：
- 管理层：总经理
- 各部门经理、主管、专员
- 工程师、检验员、组长等

## 🔄 更新和维护

### 添加新表

1. 在对应的schema目录创建新SQL文件
2. 更新初始化脚本中的文件列表
3. 运行初始化脚本测试

### 修改现有表

1. 创建迁移脚本（migrations目录）
2. 使用ALTER TABLE语句
3. 更新schema文件

### 备份数据库

```bash
# 备份所有数据库
mysqldump -u root -p --databases btc_core btc_log btc_bi > backup.sql

# 恢复
mysql -u root -p < backup.sql
```

## 📚 相关文档

- [拆分说明](schemas/btc_core_split/拆分说明.md) - btc_core拆分详情
- [RBAC设计](../../docs/RBAC角色体系重新设计.md) - 角色权限体系
- [快速初始化分析](快速初始化分析报告.md) - 技术分析报告

## 🆘 获取帮助

如遇问题，请检查：
1. MySQL服务状态
2. 网络连接
3. 用户权限
4. 日志文件

或联系技术支持团队。

---

**版本**: 1.0.0  
**最后更新**: 2025-01-08  
**维护者**: MES开发团队

