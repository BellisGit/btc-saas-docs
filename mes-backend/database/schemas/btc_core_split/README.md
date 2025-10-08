# BTC Core Schema - 拆分文件说明

## 文件结构

### 表定义文件（DDL）- 每个文件≤200行

| 序号 | 文件名 | 内容 | 表数量 |
|------|--------|------|--------|
| 01 | `01_tenant_dept.sql` | 租户和部门表 | 2 |
| 02 | `02_user.sql` | 用户表 | 1 |
| 03 | `03_role_permission.sql` | 角色和权限表 | 2 |
| 04 | `04_menu.sql` | 菜单表 | 1 |
| 05 | `05_module_plugin.sql` | 模块、插件、用户模块表 | 3 |
| 06 | `06_associations.sql` | 菜单权限关联表 | 1 |
| 07 | `07_position.sql` | 职位和职位-角色映射表 | 2 |
| 08 | `08_user_role.sql` | 用户角色和角色权限关联表 | 2 |
| 09 | `09_workflow.sql` | 工作流相关表 | 6 |
| 10 | `10_trace_maps.sql` | 追溯映射表 | 4 |
| 11 | `11_trace_events.sql` | 追溯事件和链路表 | 2 |
| 12 | `12_test_measure.sql` | 测试和测量记录表 | 2 |

### 数据插入文件（DML）- 每个文件≤200行

| 序号 | 文件名 | 内容 | 数据量 |
|------|--------|------|--------|
| 20 | `data_20_tenant_dept.sql` | 租户和部门初始数据 | 3租户+12部门 |
| 21 | `data_21_users_inert.sql` | INERT内网用户（1-57） | 58人 |
| 22 | `data_22_users_supplier_01.sql` | 供应商用户（59-85） | 27人 |
| 23 | `data_23_users_supplier_02.sql` | 供应商用户（86-110） | 25人 |
| 24 | `data_24_roles.sql` | 44个业务角色数据 | 44角色 |
| 25 | `data_25_positions.sql` | 职位数据 | 40职位 |
| 26 | `data_26_position_role_map_01.sql` | 职位-角色映射（1-50） | 50条 |
| 27 | `data_27_position_role_map_02.sql` | 职位-角色映射（51-100+） | 50+条 |
| 28 | `data_28_modules_plugins.sql` | 模块和插件数据 | 11模块+14插件 |
| 29 | `data_29_menus.sql` | 菜单数据 | 38菜单项 |
| 30 | `data_30_user_modules.sql` | 用户-模块关联 | 若干条 |
| 31 | `data_31_permissions.sql` | 权限数据 | 若干条 |
| 32 | `data_32_role_permissions.sql` | 角色-权限关联 | 若干条 |

## 执行顺序

### 1. 表定义（按序号执行）
```bash
mysql -u root -p btc_core < 01_tenant_dept.sql
mysql -u root -p btc_core < 02_user.sql
mysql -u root -p btc_core < 03_role_permission.sql
mysql -u root -p btc_core < 04_menu.sql
mysql -u root -p btc_core < 05_module_plugin.sql
mysql -u root -p btc_core < 06_associations.sql
mysql -u root -p btc_core < 07_position.sql
mysql -u root -p btc_core < 08_user_role.sql
mysql -u root -p btc_core < 09_workflow.sql
mysql -u root -p btc_core < 10_trace_maps.sql
mysql -u root -p btc_core < 11_trace_events.sql
mysql -u root -p btc_core < 12_test_measure.sql
```

### 2. 数据插入（按序号执行）
```bash
mysql -u root -p btc_core < data_20_tenant_dept.sql
mysql -u root -p btc_core < data_21_users_inert.sql
mysql -u root -p btc_core < data_22_users_supplier_01.sql
mysql -u root -p btc_core < data_23_users_supplier_02.sql
mysql -u root -p btc_core < data_24_roles.sql
mysql -u root -p btc_core < data_25_positions.sql
mysql -u root -p btc_core < data_26_position_role_map_01.sql
mysql -u root -p btc_core < data_27_position_role_map_02.sql
mysql -u root -p btc_core < data_28_modules_plugins.sql
mysql -u root -p btc_core < data_29_menus.sql
mysql -u root -p btc_core < data_30_user_modules.sql
mysql -u root -p btc_core < data_31_permissions.sql
mysql -u root -p btc_core < data_32_role_permissions.sql
```

## 自动化执行脚本

```bash
#!/bin/bash
# init_btc_core.sh

DB_NAME="btc_core"
USER="root"

# 执行所有DDL
for file in $(ls [0-9][0-9]_*.sql | sort); do
    echo "Executing $file..."
    mysql -u $USER -p $DB_NAME < $file
done

# 执行所有DML
for file in $(ls data_*.sql | sort); do
    echo "Executing $file..."
    mysql -u $USER -p $DB_NAME < $file
done

echo "BTC Core database initialization completed!"
```

## 注意事项

1. **依赖顺序**: 必须按序号顺序执行，因为存在外键依赖
2. **编码格式**: 所有文件使用UTF-8编码
3. **数据完整性**: 用户数据中的position_id等外键必须在对应表创建后才能插入
4. **大文件处理**: 供应商用户数据分为2个文件，避免单文件过大

