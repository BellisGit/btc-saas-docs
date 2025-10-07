# MES系统迁移与发布

## 概述

本文档描述了MES制造执行系统的数据库迁移和发布管理策略，包括版本控制、迁移脚本管理、发布流程和回滚策略。系统采用Flyway作为数据库迁移工具，确保数据库变更的可追溯性和可重复性。

## 迁移工具选择

### 1. Flyway（主要选择）
**优势**：
- 简单易用，学习成本低
- 支持SQL脚本和Java代码迁移
- 版本控制机制完善
- 支持回滚操作
- 与Spring Boot集成良好

**配置示例**：
```yaml
# application.yml
spring:
  flyway:
    enabled: true
    locations: classpath:db/migration
    baseline-on-migrate: true
    validate-on-migrate: true
    clean-disabled: false
    out-of-order: false
    placeholder-replacement: true
    placeholders:
      table_prefix: mes_
```

### 2. Liquibase（备选方案）
**适用场景**：
- 需要更复杂的变更管理
- 支持多种数据库
- 需要XML格式的变更定义

## 迁移脚本管理

### 1. 文件命名规范
```
V{version}__{description}.sql
```

**示例**：
```
V20250107_1600__init_mes_core_tables.sql
V20250107_1601__add_foreign_keys.sql
V20250107_1602__create_bi_aggregation_tables.sql
V20250107_1603__add_indexes_for_performance.sql
```

### 2. 版本号规范
- **格式**：YYYYMMDD_HHMM
- **示例**：20250107_1600
- **说明**：年月日_时分，确保版本号唯一且有序

### 3. 脚本分类

#### 3.1 结构变更脚本
```sql
-- V20250107_1600__init_mes_core_tables.sql
-- 创建核心业务表
CREATE TABLE IF NOT EXISTS item_master (
    item_id VARCHAR(32) PRIMARY KEY COMMENT '物料编码',
    item_code VARCHAR(64) NOT NULL COMMENT 'ERP物料编码',
    -- ... 其他字段
    INDEX idx_item_code (item_code),
    INDEX idx_item_type (item_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='物料主数据表';
```

#### 3.2 约束添加脚本
```sql
-- V20250107_1601__add_foreign_keys.sql
-- 添加外键约束
ALTER TABLE item_master 
ADD CONSTRAINT fk_item_supplier 
FOREIGN KEY (supplier_id) REFERENCES supplier_master(supplier_id);
```

#### 3.3 索引优化脚本
```sql
-- V20250107_1603__add_indexes_for_performance.sql
-- 添加性能优化索引
CREATE INDEX idx_work_order_status_created ON work_order(status, created_at);
CREATE INDEX idx_trace_event_entity_time ON trace_event(entity_type, entity_id, occurred_at);
```

#### 3.4 数据迁移脚本
```sql
-- V20250107_1604__migrate_legacy_data.sql
-- 迁移历史数据
INSERT INTO item_master (item_id, item_code, item_name, item_type, uom, status, tenant_id, created_by, created_at)
SELECT 
    CONCAT('ITM-', DATE_FORMAT(NOW(), '%Y%m'), '-', LPAD(ROW_NUMBER() OVER (ORDER BY id), 4, '0')) as item_id,
    legacy_code as item_code,
    legacy_name as item_name,
    CASE 
        WHEN legacy_type = 'RAW' THEN 'RAW'
        WHEN legacy_type = 'COMP' THEN 'COMPONENT'
        WHEN legacy_type = 'FIN' THEN 'FINISHED'
        ELSE 'RAW'
    END as item_type,
    'PCS' as uom,
    'ACTIVE' as status,
    'TENANT001' as tenant_id,
    'SYSTEM' as created_by,
    NOW() as created_at
FROM legacy_items 
WHERE status = 'ACTIVE';
```

### 4. 脚本编写规范

#### 4.1 安全性要求
```sql
-- 使用IF NOT EXISTS避免重复创建
CREATE TABLE IF NOT EXISTS new_table (
    id BIGINT AUTO_INCREMENT PRIMARY KEY
);

-- 使用IF EXISTS避免删除不存在的对象
DROP INDEX IF EXISTS idx_old_index ON table_name;

-- 使用事务确保原子性
START TRANSACTION;
-- 迁移操作
COMMIT;
```

#### 4.2 可重复性要求
```sql
-- 使用REPLACE INTO确保数据一致性
REPLACE INTO qms_code (code_type, code, description, category, status, tenant_id, created_by)
VALUES ('DEFECT', 'SOLDER-01', '焊接不良', '焊接缺陷', 'ACTIVE', 'TENANT001', 'SYSTEM');

-- 使用INSERT IGNORE避免重复插入
INSERT IGNORE INTO supplier_master (supplier_id, supplier_code, supplier_name, status, tenant_id, created_by)
VALUES ('SUP-ACME001', 'ACME001', 'ACME电子有限公司', 'ACTIVE', 'TENANT001', 'SYSTEM');
```

#### 4.3 性能考虑
```sql
-- 大表操作使用分批处理
SET @batch_size = 1000;
SET @offset = 0;

WHILE @offset < (SELECT COUNT(*) FROM large_table) DO
    INSERT INTO new_table (col1, col2, col3)
    SELECT col1, col2, col3 
    FROM large_table 
    LIMIT @batch_size OFFSET @offset;
    
    SET @offset = @offset + @batch_size;
END WHILE;
```

## 发布流程

### 1. 开发环境发布

#### 1.1 本地开发
```bash
# 创建新的迁移脚本
touch src/main/resources/db/migration/V$(date +%Y%m%d_%H%M)__add_new_feature.sql

# 编写迁移脚本
vim src/main/resources/db/migration/V20250107_1600__add_new_feature.sql

# 本地测试迁移
mvn flyway:migrate
```

#### 1.2 开发环境部署
```bash
# 构建应用
mvn clean package -DskipTests

# 部署到开发环境
docker build -t mes-backend:dev .
docker run -d --name mes-backend-dev -p 8080:8080 mes-backend:dev

# 验证迁移结果
mvn flyway:info
```

### 2. 测试环境发布

#### 2.1 测试环境准备
```bash
# 创建测试数据库
mysql -u root -p -e "CREATE DATABASE mes_core_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 配置测试环境
export SPRING_PROFILES_ACTIVE=test
export SPRING_DATASOURCE_URL=jdbc:mysql://test-db:3306/mes_core_test
```

#### 2.2 测试环境部署
```bash
# 执行迁移
mvn flyway:migrate -Dspring.profiles.active=test

# 运行测试
mvn test -Dspring.profiles.active=test

# 性能测试
mvn test -Dtest=PerformanceTest -Dspring.profiles.active=test
```

### 3. 生产环境发布

#### 3.1 发布前检查
```bash
# 检查迁移脚本
mvn flyway:validate

# 检查数据库连接
mvn flyway:info

# 备份生产数据库
mysqldump --single-transaction --routines --triggers \
  --all-databases > backup_$(date +%Y%m%d_%H%M%S).sql
```

#### 3.2 生产环境部署
```bash
# 蓝绿部署 - 停止旧版本
docker stop mes-backend-prod

# 启动新版本
docker run -d --name mes-backend-prod-new -p 8081:8080 mes-backend:prod

# 健康检查
curl -f http://localhost:8081/actuator/health || exit 1

# 切换流量
docker stop mes-backend-prod
docker rename mes-backend-prod-new mes-backend-prod
```

#### 3.3 发布后验证
```bash
# 验证迁移结果
mvn flyway:info -Dspring.profiles.active=prod

# 验证应用功能
curl -f http://localhost:8080/api/health

# 验证数据完整性
mysql -u mes_user -p mes_core -e "SELECT COUNT(*) FROM item_master;"
```

## 回滚策略

### 1. 应用回滚
```bash
# 快速回滚到上一个版本
docker stop mes-backend-prod
docker start mes-backend-prod-old

# 验证回滚结果
curl -f http://localhost:8080/api/health
```

### 2. 数据库回滚

#### 2.1 使用Flyway回滚
```bash
# 回滚到指定版本
mvn flyway:undo -Dflyway.target=20250106_1600

# 回滚到上一个版本
mvn flyway:undo
```

#### 2.2 手动回滚脚本
```sql
-- V20250107_1605__rollback_add_new_feature.sql
-- 回滚新增功能

-- 删除新增的表
DROP TABLE IF EXISTS new_feature_table;

-- 删除新增的索引
DROP INDEX IF EXISTS idx_new_feature ON existing_table;

-- 删除新增的列
ALTER TABLE existing_table DROP COLUMN IF EXISTS new_column;

-- 恢复数据
DELETE FROM existing_table WHERE created_at >= '2025-01-07 16:00:00';
```

### 3. 数据恢复
```bash
# 从备份恢复数据库
mysql -u root -p < backup_20250107_160000.sql

# 验证数据完整性
mysql -u mes_user -p mes_core -e "SELECT COUNT(*) FROM item_master;"
```

## 版本管理

### 1. 版本号规范
- **主版本号**：重大架构变更或不兼容变更
- **次版本号**：新功能添加，向后兼容
- **修订版本号**：Bug修复和小幅改进

**示例**：
- v1.0.0：初始版本
- v1.1.0：添加新功能
- v1.1.1：修复Bug
- v2.0.0：重大架构变更

### 2. 版本标签
```bash
# 创建版本标签
git tag -a v1.1.0 -m "Release version 1.1.0"
git push origin v1.1.0

# 查看版本标签
git tag -l

# 切换到指定版本
git checkout v1.1.0
```

### 3. 版本发布说明
```markdown
# Release Notes v1.1.0

## 新增功能
- 添加BI数据大屏功能
- 支持移动端扫码操作
- 新增供应商绩效评估

## 功能改进
- 优化工单查询性能
- 改进用户界面体验
- 增强数据验证规则

## Bug修复
- 修复库存计算错误
- 解决并发访问问题
- 修复数据同步异常

## 数据库变更
- 新增BI聚合表
- 优化索引结构
- 添加数据约束
```

## 环境管理

### 1. 环境配置
```yaml
# application-dev.yml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/mes_core_dev
    username: mes_dev
    password: dev_password
  flyway:
    locations: classpath:db/migration
    baseline-on-migrate: true

# application-test.yml
spring:
  datasource:
    url: jdbc:mysql://test-db:3306/mes_core_test
    username: mes_test
    password: test_password
  flyway:
    locations: classpath:db/migration
    validate-on-migrate: true

# application-prod.yml
spring:
  datasource:
    url: jdbc:mysql://prod-db:3306/mes_core
    username: mes_prod
    password: ${DB_PASSWORD}
  flyway:
    locations: classpath:db/migration
    clean-disabled: true
    out-of-order: false
```

### 2. 环境隔离
```bash
# 开发环境
export SPRING_PROFILES_ACTIVE=dev
export DB_HOST=localhost
export DB_PORT=3306
export DB_NAME=mes_core_dev

# 测试环境
export SPRING_PROFILES_ACTIVE=test
export DB_HOST=test-db
export DB_PORT=3306
export DB_NAME=mes_core_test

# 生产环境
export SPRING_PROFILES_ACTIVE=prod
export DB_HOST=prod-db
export DB_PORT=3306
export DB_NAME=mes_core
```

## 监控与告警

### 1. 迁移监控
```sql
-- 监控迁移状态
SELECT 
    version,
    description,
    type,
    script,
    checksum,
    installed_by,
    installed_on,
    execution_time,
    success
FROM flyway_schema_history 
ORDER BY installed_rank DESC;
```

### 2. 性能监控
```sql
-- 监控迁移性能
SELECT 
    version,
    description,
    execution_time,
    installed_on
FROM flyway_schema_history 
WHERE execution_time > 10000  -- 执行时间超过10秒
ORDER BY execution_time DESC;
```

### 3. 告警配置
```yaml
# 告警规则
alerts:
  - name: "数据库迁移失败"
    condition: "flyway_migration_failed > 0"
    severity: "critical"
    action: "notify_admin"
  
  - name: "迁移执行时间过长"
    condition: "flyway_execution_time > 30000"
    severity: "warning"
    action: "notify_team"
```

## 最佳实践

### 1. 迁移脚本编写
- 保持脚本的原子性和可重复性
- 使用事务确保数据一致性
- 添加适当的注释和说明
- 测试脚本的正确性

### 2. 发布流程
- 遵循开发→测试→生产的发布流程
- 每次发布前进行充分测试
- 准备回滚方案
- 记录发布日志

### 3. 版本管理
- 使用语义化版本号
- 创建详细的发布说明
- 维护版本标签
- 跟踪版本变更历史

### 4. 环境管理
- 保持环境配置的一致性
- 使用环境变量管理敏感信息
- 定期同步环境数据
- 监控环境健康状态

## 故障处理

### 1. 常见问题

#### 1.1 迁移失败
```bash
# 查看迁移历史
mvn flyway:info

# 查看错误日志
tail -f logs/application.log

# 手动修复后重新迁移
mvn flyway:repair
mvn flyway:migrate
```

#### 1.2 版本冲突
```bash
# 检查版本冲突
mvn flyway:validate

# 解决冲突后重新迁移
mvn flyway:migrate
```

#### 1.3 数据不一致
```bash
# 验证数据完整性
mvn flyway:validate

# 修复数据后重新迁移
mvn flyway:repair
```

### 2. 应急处理
```bash
# 紧急回滚
mvn flyway:undo

# 恢复备份
mysql -u root -p < backup_latest.sql

# 联系技术支持
# 发送错误日志和系统状态信息
```