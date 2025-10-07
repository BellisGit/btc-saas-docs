# MES系统数据库架构完整设计

## 📋 概述

本文档提供了MES制造执行系统完整数据库架构的设计，包括混合架构方案、表结构设计、数据集成方案、性能优化等所有方面。数据库架构基于MES系统全局架构基础文档设计，采用MySQL 8.0+作为主要数据库。

## 🏗️ 混合架构设计

### 核心原则

1. **核心数据库（btc_core）**：包含所有基础表和核心业务表，支持复杂事务和外键约束
2. **扩展数据库**：按业务模块独立，通过API调用与核心数据库集成
3. **数据一致性**：通过事件驱动和API调用保证数据一致性
4. **扩展性**：新业务模块可以独立创建数据库，不影响现有系统

### 数据库结构

```
btc_core (核心数据库)
├── 系统基础表 (租户、用户、角色、权限等)
├── 主数据管理表 (物料、供应商、客户、库位等)
├── 环境配置表 (工厂、产线、工位、设备等)
├── 员工管理表 (员工、技能等)
├── 动态扩展表 (动态实体、属性、事件等)
├── 系统配置表 (配置、字典、参数等)
└── 扩展数据库注册表

btc_procurement (采购管理数据库)
├── 采购基础表 (订单、收货、合同等)
├── 采购BI聚合表
└── 数据同步配置表

btc_maintenance (设备维护数据库)
├── 维护基础表 (计划、工单、检查等)
├── 维护BI聚合表
└── 数据同步配置表

btc_log (日志数据库)
├── 操作日志表
├── 系统日志表
└── 监控日志表

btc_bi (BI数据库)
├── 生产BI表
├── 质量BI表
└── 系统BI表
```

## 📊 数据库架构统计

### 数据库分布
- **btc_core**: 核心业务数据库 (54个表)
- **btc_procurement**: 采购管理数据库 (8个表)
- **btc_maintenance**: 设备维护数据库 (9个表)
- **btc_log**: 日志数据库 (15个表)
- **btc_bi**: BI分析数据库 (18个表)
- **总计**: 5个数据库，104个表

### btc_core数据库表统计
- **系统管理表**: 9个表
- **环境配置表**: 7个表  
- **基础数据表**: 8个表
- **业务核心表**: 22个表
- **扩展功能表**: 8个表
- **总计**: 54个表

### btc_log数据库表统计
- **用户行为日志表**: 3个表
- **系统运行日志表**: 3个表
- **业务操作日志表**: 2个表
- **安全审计日志表**: 2个表
- **系统监控日志表**: 2个表
- **日志聚合统计表**: 3个表
- **总计**: 15个表

### btc_bi数据库表统计
- **生产域聚合表**: 3个表
- **品质域聚合表**: 2个表
- **物流域聚合表**: 2个表
- **设备域聚合表**: 2个表
- **供应商域聚合表**: 1个表
- **成本域聚合表**: 1个表
- **告警统计聚合表**: 1个表
- **BI数据质量监控表**: 2个表
- **实时指标缓存表**: 1个表
- **总计**: 15个表

### 数据库大小估算
- **预估表数量**: 104个
- **预估字段数量**: 1500+个
- **预估索引数量**: 400+个
- **预估存储空间**: 300GB+ (生产环境)
- **日志数据增长**: 每日15GB+ (按分区自动清理)

## 🔄 数据集成方案

### 1. 核心数据同步

#### 同步策略
- **实时同步**：关键基础数据（用户、角色、权限）
- **准实时同步**：业务主数据（物料、供应商、客户）
- **批量同步**：历史数据和统计数据

#### 同步机制
```sql
-- 核心数据同步表（每个扩展数据库都有）
CREATE TABLE core_data_sync (
    sync_id VARCHAR(32) PRIMARY KEY,
    entity_type VARCHAR(32) NOT NULL,
    entity_id VARCHAR(32) NOT NULL,
    sync_action ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    sync_status ENUM('PENDING', 'SUCCESS', 'FAILED') DEFAULT 'PENDING',
    sync_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    error_message TEXT,
    retry_count INT DEFAULT 0
);
```

### 2. API集成接口

#### 核心数据API
```java
@RestController
@RequestMapping("/api/core")
public class CoreDataController {
    
    // 获取用户信息
    @GetMapping("/users/{userId}")
    public ResponseEntity<User> getUser(@PathVariable String userId);
    
    // 获取物料信息
    @GetMapping("/items/{itemId}")
    public ResponseEntity<Item> getItem(@PathVariable String itemId);
    
    // 获取供应商信息
    @GetMapping("/suppliers/{supplierId}")
    public ResponseEntity<Supplier> getSupplier(@PathVariable String supplierId);
    
    // 批量获取数据
    @PostMapping("/batch")
    public ResponseEntity<Map<String, Object>> getBatchData(@RequestBody BatchRequest request);
}
```

#### 扩展数据API
```java
@RestController
@RequestMapping("/api/procurement")
public class ProcurementController {
    
    // 创建采购订单
    @PostMapping("/orders")
    public ResponseEntity<PurchaseOrder> createOrder(@RequestBody PurchaseOrder order);
    
    // 获取采购订单
    @GetMapping("/orders/{orderId}")
    public ResponseEntity<PurchaseOrder> getOrder(@PathVariable String orderId);
    
    // 同步核心数据
    @PostMapping("/sync/core-data")
    public ResponseEntity<SyncResult> syncCoreData(@RequestBody SyncRequest request);
}
```

### 3. 事件驱动同步

#### 事件发布
```java
@Service
public class CoreDataService {
    
    @Autowired
    private ApplicationEventPublisher eventPublisher;
    
    public void updateUser(User user) {
        // 更新用户
        userRepository.save(user);
        
        // 发布事件
        eventPublisher.publishEvent(new UserUpdatedEvent(user));
    }
}
```

#### 事件监听
```java
@Component
public class ProcurementEventListener {
    
    @EventListener
    @Async
    public void handleUserUpdated(UserUpdatedEvent event) {
        // 同步用户数据到采购数据库
        syncUserToProcurement(event.getUser());
    }
    
    @EventListener
    @Async
    public void handleItemUpdated(ItemUpdatedEvent event) {
        // 同步物料数据到采购数据库
        syncItemToProcurement(event.getItem());
    }
}
```

## 📊 数据一致性保证

### 1. 分布式事务

#### 使用Seata实现分布式事务
```java
@Service
public class ProcurementService {
    
    @GlobalTransactional
    public void createPurchaseOrder(PurchaseOrder order) {
        // 1. 在采购数据库创建订单
        purchaseOrderRepository.save(order);
        
        // 2. 调用核心数据库API更新库存
        coreDataService.updateInventory(order.getItems());
        
        // 3. 发送通知
        notificationService.sendNotification(order);
    }
}
```

### 2. 最终一致性

#### 补偿机制
```java
@Service
public class DataSyncService {
    
    @Scheduled(fixedDelay = 30000) // 每30秒执行一次
    public void syncPendingData() {
        List<CoreDataSync> pendingSyncs = syncRepository.findPendingSyncs();
        
        for (CoreDataSync sync : pendingSyncs) {
            try {
                syncData(sync);
                sync.setSyncStatus(SyncStatus.SUCCESS);
            } catch (Exception e) {
                sync.setSyncStatus(SyncStatus.FAILED);
                sync.setErrorMessage(e.getMessage());
                sync.setRetryCount(sync.getRetryCount() + 1);
            }
            syncRepository.save(sync);
        }
    }
}
```

## 🚀 扩展新业务模块

### 1. 创建新扩展数据库

#### 步骤1：创建数据库Schema
```sql
-- 创建新业务数据库
CREATE DATABASE IF NOT EXISTS btc_finance CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE btc_finance;

-- 创建业务表
CREATE TABLE financial_transaction (
    transaction_id VARCHAR(32) PRIMARY KEY,
    transaction_type ENUM('INCOME', 'EXPENSE', 'TRANSFER') NOT NULL,
    amount DECIMAL(18,2) NOT NULL,
    currency VARCHAR(8) DEFAULT 'CNY',
    description TEXT,
    tenant_id VARCHAR(32),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 创建数据同步表
CREATE TABLE core_data_sync (
    sync_id VARCHAR(32) PRIMARY KEY,
    entity_type VARCHAR(32) NOT NULL,
    entity_id VARCHAR(32) NOT NULL,
    sync_action ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    sync_status ENUM('PENDING', 'SUCCESS', 'FAILED') DEFAULT 'PENDING',
    sync_time DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

#### 步骤2：注册到核心数据库
```sql
-- 在核心数据库注册新扩展数据库
INSERT INTO extension_database (
    db_id, db_name, db_type, db_description, 
    business_module, version, status
) VALUES (
    'FIN001', 'btc_finance', 'MYSQL', '财务管理数据库',
    'FINANCE', '1.0', 'ACTIVE'
);
```

#### 步骤3：创建API服务
```java
@RestController
@RequestMapping("/api/finance")
public class FinanceController {
    
    @PostMapping("/transactions")
    public ResponseEntity<FinancialTransaction> createTransaction(
        @RequestBody FinancialTransaction transaction) {
        // 业务逻辑
        return ResponseEntity.ok(financeService.createTransaction(transaction));
    }
}
```

### 2. 配置数据同步

#### 配置同步规则
```sql
-- 配置跨数据库同步
INSERT INTO cross_db_sync (
    sync_id, source_db, target_db, source_table, target_table,
    sync_type, sync_frequency, sync_status
) VALUES (
    'SYNC001', 'btc_core', 'btc_finance', 'sys_user', 'user_sync',
    'REAL_TIME', 'IMMEDIATE', 'ACTIVE'
);
```

## 📋 完整表结构清单

### 1. 系统管理表（9个表）

#### 1.1 租户和站点管理
| 表名 | 说明 | 主要字段 | 索引数量 |
|------|------|----------|----------|
| `tenant` | 租户表 | tenant_id, tenant_code, tenant_name | 3 |
| `site` | 站点表 | site_id, tenant_id, site_code, site_name | 2 |

#### 1.2 用户权限管理
| 表名 | 说明 | 主要字段 | 索引数量 |
|------|------|----------|----------|
| `sys_user` | 用户表 | user_id, username, password_hash, email | 6 |
| `sys_role` | 角色表 | role_id, role_code, role_name, role_type | 2 |
| `sys_user_role` | 用户角色关联表 | user_id, role_id, assigned_at | 2 |
| `sys_permission` | 权限表 | permission_id, permission_code, permission_type | 3 |
| `sys_role_permission` | 角色权限关联表 | role_id, permission_id | 2 |
| `sys_menu` | 菜单表 | menu_id, menu_code, menu_name, menu_path | 3 |

### 2. 环境配置表（7个表）

#### 2.1 工厂环境
| 表名 | 说明 | 主要字段 | 索引数量 |
|------|------|----------|----------|
| `plant` | 工厂表 | plant_id, plant_code, plant_name, plant_type | 2 |
| `production_line` | 产线表 | line_id, plant_id, line_code, line_name | 2 |
| `workstation` | 工位表 | station_id, line_id, station_code, station_name | 3 |
| `equipment` | 设备表 | equipment_id, equipment_code, equipment_name | 4 |
| `sensor` | 传感器表 | sensor_id, equipment_id, sensor_code, sensor_type | 3 |

#### 2.2 基础环境
| 表名 | 说明 | 主要字段 | 索引数量 |
|------|------|----------|----------|
| `unit_of_measure` | 计量单位表 | uom_id, uom_code, uom_name, uom_type | 2 |
| `location` | 库位表 | location_id, location_code, location_name, location_type | 4 |

### 3. 基础数据表（8个表）

#### 3.1 时间管理
| 表名 | 说明 | 主要字段 | 索引数量 |
|------|------|----------|----------|
| `shift` | 班次表 | shift_id, shift_code, shift_name, start_time, end_time | 2 |
| `calendar` | 日历表 | calendar_id, year, month, day, is_workday | 3 |

#### 3.2 人员管理
| 表名 | 说明 | 主要字段 | 索引数量 |
|------|------|----------|----------|
| `employee` | 员工表 | employee_id, employee_no, real_name, department | 4 |
| `skill` | 技能表 | skill_id, skill_code, skill_name, skill_category | 2 |
| `employee_skill` | 员工技能关联表 | employee_id, skill_id, skill_level | 3 |

#### 3.3 系统配置
| 表名 | 说明 | 主要字段 | 索引数量 |
|------|------|----------|----------|
| `sys_config` | 系统参数表 | config_id, config_key, config_value, config_type | 2 |
| `sys_dict` | 数据字典表 | dict_id, dict_type, dict_key, dict_value | 3 |
| `sys_operation_log` | 操作日志表 | log_id, user_id, operation_type, created_at | 5 |
| `sys_login_log` | 登录日志表 | log_id, user_id, login_ip, login_time | 4 |

### 4. 业务核心表（22个表）

#### 4.1 基础数据管理（3个表）
| 表名 | 说明 | 主要字段 | 索引数量 |
|------|------|----------|----------|
| `item_master` | 物料主数据表 | item_id, item_code, item_name, item_type | 5 |
| `supplier_master` | 供应商主数据表 | supplier_id, supplier_code, supplier_name | 2 |
| `mold_master` | 模具主数据表 | mold_id, mold_code, mold_name, mold_type | 3 |

#### 4.2 采购与收货管理（4个表）
| 表名 | 说明 | 主要字段 | 索引数量 |
|------|------|----------|----------|
| `purchase_order` | 采购订单表 | po_id, po_no, supplier_id, po_date | 4 |
| `purchase_order_item` | 采购订单明细表 | po_id, item_id, quantity, unit_price | 2 |
| `goods_receipt_note` | 收货单表 | grn_id, po_id, supplier_id, grn_date | 4 |
| `goods_receipt_item` | 收货明细表 | grn_id, item_id, lot_id, quantity | 3 |

#### 4.3 生产管理（3个表）
| 表名 | 说明 | 主要字段 | 索引数量 |
|------|------|----------|----------|
| `work_order` | 生产工单表 | wo_id, wo_no, item_id, planned_quantity | 6 |
| `production_lot` | 生产批次表 | lot_id, wo_id, item_id, lot_quantity | 5 |
| `serial_number` | 序列号表 | sn, lot_id, item_id, wo_id | 7 |

#### 4.4 工艺路线管理（2个表）
| 表名 | 说明 | 主要字段 | 索引数量 |
|------|------|----------|----------|
| `routing` | 工艺路线表 | routing_id, item_id, version, status | 3 |
| `operation` | 工序定义表 | op_id, routing_id, op_seq, op_name | 3 |

#### 4.5 品质管理（3个表）
| 表名 | 说明 | 主要字段 | 索引数量 |
|------|------|----------|----------|
| `inspection` | 检验单表 | insp_id, type, ref_id, ref_type, result | 6 |
| `inspection_item` | 检验明细表 | insp_id, item_key, actual_value, result | 3 |
| `test_record` | 测试记录表 | sn, station, test_type, result | 5 |

#### 4.6 库存管理（2个表）
| 表名 | 说明 | 主要字段 | 索引数量 |
|------|------|----------|----------|
| `stock` | 库存表 | item_id, lot_id, location_id, quantity | 5 |
| `stock_transaction` | 库存事务表 | transaction_id, item_id, transaction_type | 7 |

#### 4.7 追溯系统（3个表）
| 表名 | 说明 | 主要字段 | 索引数量 |
|------|------|----------|----------|
| `trace_event` | 追溯事件表 | event_id, entity_type, entity_id, action | 6 |
| `map_sn` | 序列号映射表 | sn, lot_id, wo_id, box_no, pallet_no | 6 |
| `map_lot_material` | 批次用料映射表 | lot_id, item_id, supplier_id, grn_id | 6 |

#### 4.8 系统配置（2个表）
| 表名 | 说明 | 主要字段 | 索引数量 |
|------|------|----------|----------|
| `qms_code` | 品质代码表 | code_type, code, description, category | 3 |
| `attachment` | 附件表 | file_name, file_path, biz_type, biz_id | 2 |

### 5. 扩展功能表（8个表）

#### 5.1 动态扩展表（3个表）
| 表名 | 说明 | 主要字段 | 索引数量 |
|------|------|----------|----------|
| `dynamic_entity` | 动态实体表 | entity_id, entity_type, entity_name | 3 |
| `dynamic_attribute` | 动态属性表 | attribute_id, entity_id, attribute_name | 4 |
| `dynamic_attribute_value` | 动态属性值表 | value_id, entity_id, attribute_id | 3 |

#### 5.2 事件追踪表（2个表）
| 表名 | 说明 | 主要字段 | 索引数量 |
|------|------|----------|----------|
| `trace_event_type` | 事件类型定义表 | event_type_id, event_type_code, category | 3 |
| `universal_trace_event` | 通用事件记录表 | event_id, event_type_id, entity_type | 6 |

#### 5.3 系统配置表（3个表）
| 表名 | 说明 | 主要字段 | 索引数量 |
|------|------|----------|----------|
| `sys_parameter` | 系统参数表 | parameter_id, parameter_group, parameter_code | 3 |
| `sys_notification` | 系统通知表 | notification_id, notification_type, title | 8 |
| `sys_job` | 系统任务调度表 | job_id, job_name, cron_expression | 4 |

### 6. 扩展数据库注册表（2个表）
| 表名 | 说明 | 主要字段 | 索引数量 |
|------|------|----------|----------|
| `extension_database` | 扩展数据库注册表 | db_id, db_name, business_module | 4 |
| `cross_db_sync` | 跨数据库数据同步表 | sync_id, source_db, target_db | 5 |

### 7. 采购管理数据库表（8个表）
| 表名 | 说明 | 主要字段 | 索引数量 |
|------|------|----------|----------|
| `purchase_order` | 采购订单表 | po_id, po_number, supplier_id | 6 |
| `purchase_order_detail` | 采购订单明细表 | detail_id, po_id, item_id | 4 |
| `purchase_receipt` | 采购收货表 | receipt_id, receipt_number, po_id | 6 |
| `purchase_receipt_detail` | 采购收货明细表 | detail_id, receipt_id, item_id | 5 |
| `supplier_evaluation` | 供应商评估表 | evaluation_id, supplier_id, evaluation_period | 5 |
| `purchase_contract` | 采购合同表 | contract_id, contract_number, supplier_id | 6 |
| `purchase_contract_detail` | 采购合同明细表 | detail_id, contract_id, item_id | 4 |
| `agg_procurement_performance_1d` | 采购绩效聚合表 | bucket_start, supplier_id, total_orders | 3 |

### 8. 设备维护数据库表（9个表）
| 表名 | 说明 | 主要字段 | 索引数量 |
|------|------|----------|----------|
| `maintenance_plan` | 维护计划表 | plan_id, plan_code, equipment_id | 6 |
| `maintenance_work_order` | 维护工单表 | wo_id, wo_number, equipment_id | 8 |
| `maintenance_work_order_detail` | 维护工单明细表 | detail_id, wo_id, task_description | 4 |
| `spare_part_usage` | 备件使用记录表 | usage_id, wo_id, part_id | 5 |
| `maintenance_checklist` | 维护检查表 | checklist_id, checklist_code | 5 |
| `maintenance_checklist_item` | 维护检查项表 | item_id, checklist_id, item_code | 5 |
| `maintenance_check_record` | 维护检查记录表 | record_id, wo_id, item_id | 7 |
| `failure_record` | 故障记录表 | failure_id, equipment_id, failure_code | 8 |
| `agg_maintenance_performance_1d` | 维护绩效聚合表 | bucket_start, equipment_id, total_work_orders | 3 |

## 🔧 运维管理

### 1. 数据库监控

#### 监控指标
- 数据库连接数
- 查询性能
- 同步延迟
- 错误率

#### 监控脚本
```sql
-- 检查同步状态
SELECT 
    entity_type,
    sync_status,
    COUNT(*) as count,
    MAX(sync_time) as last_sync_time
FROM core_data_sync 
WHERE sync_time >= DATE_SUB(NOW(), INTERVAL 1 HOUR)
GROUP BY entity_type, sync_status;

-- 检查同步错误
SELECT 
    entity_type,
    entity_id,
    error_message,
    retry_count,
    sync_time
FROM core_data_sync 
WHERE sync_status = 'FAILED' 
AND retry_count < 3
ORDER BY sync_time DESC;
```

### 2. 数据备份策略

#### 备份计划
- **核心数据库**：每日全量备份 + 实时增量备份
- **扩展数据库**：每日全量备份
- **日志数据库**：每周全量备份 + 每日增量备份
- **BI数据库**：每周全量备份

#### 备份脚本
```bash
#!/bin/bash
# 核心数据库备份
mysqldump -h localhost -u root -p btc_core > /backup/btc_core_$(date +%Y%m%d).sql

# 扩展数据库备份
for db in btc_procurement btc_maintenance btc_finance; do
    mysqldump -h localhost -u root -p $db > /backup/${db}_$(date +%Y%m%d).sql
done
```

## 📈 性能优化

### 1. 查询优化

#### 索引策略
- 核心数据库：完整索引支持复杂查询
- 扩展数据库：针对性索引支持业务查询
- 跨数据库查询：通过API调用避免JOIN

#### 缓存策略
```java
@Service
public class CoreDataCacheService {
    
    @Cacheable(value = "users", key = "#userId")
    public User getUser(String userId) {
        return userRepository.findById(userId);
    }
    
    @Cacheable(value = "items", key = "#itemId")
    public Item getItem(String itemId) {
        return itemRepository.findById(itemId);
    }
}
```

### 2. 连接池配置

#### 数据库连接池
```yaml
spring:
  datasource:
    core:
      url: jdbc:mysql://localhost:3306/btc_core
      username: btc_user
      password: btc_password
      hikari:
        maximum-pool-size: 20
        minimum-idle: 5
        connection-timeout: 30000
    
    procurement:
      url: jdbc:mysql://localhost:3306/btc_procurement
      username: btc_user
      password: btc_password
      hikari:
        maximum-pool-size: 10
        minimum-idle: 3
        connection-timeout: 30000
```

## 🎯 最佳实践

### 1. 开发规范

#### 数据访问规范
- 核心数据通过API调用获取
- 扩展数据直接访问本地数据库
- 跨数据库操作使用分布式事务

#### 错误处理规范
```java
@Service
public class ProcurementService {
    
    public PurchaseOrder createOrder(PurchaseOrder order) {
        try {
            // 验证核心数据
            validateCoreData(order);
            
            // 创建订单
            return purchaseOrderRepository.save(order);
            
        } catch (CoreDataException e) {
            // 核心数据异常处理
            log.error("Core data validation failed", e);
            throw new BusinessException("核心数据验证失败", e);
        }
    }
}
```

### 2. 部署规范

#### 环境配置
```yaml
# 开发环境
btc:
  databases:
    core: btc_core_dev
    procurement: btc_procurement_dev
    maintenance: btc_maintenance_dev

# 生产环境
btc:
  databases:
    core: btc_core_prod
    procurement: btc_procurement_prod
    maintenance: btc_maintenance_prod
```

## 📋 总结

混合数据库架构提供了：

1. **灵活性**：新业务模块可以独立开发和部署
2. **可扩展性**：支持水平扩展和垂直扩展
3. **一致性**：通过多种机制保证数据一致性
4. **性能**：针对性的优化策略
5. **维护性**：清晰的模块边界和职责分离

这种架构特别适合大型MES系统，能够支持业务的快速发展和变化。

### 主要特点
1. **完整性**: 覆盖MES系统所有业务场景
2. **规范性**: 统一的命名规范和设计模式
3. **高性能**: 完善的索引和优化策略
4. **可扩展**: 支持水平和垂直扩展
5. **高安全**: 多层次的安全保障机制
6. **易维护**: 完整的审计和监控体系

这个数据库架构为MES系统提供了坚实的数据基础，能够支撑大规模的生产制造业务需求。
