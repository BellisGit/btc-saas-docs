# MES系统文档目录

## 概述

本文档目录包含了MES制造执行系统的完整技术文档，涵盖系统架构、开发规范、数据模型、部署指南等各个方面。

## 文档结构

### 基础架构文档
- **00-overview.md** - 项目概览和系统架构
- **01-standards-and-conventions.md** - 开发标准和规范
- **02-domain-glossary.md** - 业务领域术语表
- **03-logical-model.md** - 逻辑数据模型
- **04-physical-layout.md** - 物理数据库设计
- **05-migrations-and-release.md** - 数据库迁移和发布管理

### 数据架构文档
- **06-data-contracts.md** - 数据契约和API规范
- **07-database-architecture-complete.md** - 数据库架构完整设计
- **08-data-quality.md** - 数据质量管理
- **09-database-deployment-guide.md** - 数据库部署指南

### 业务扩展文档
- **10-business-extension-complete.md** - 业务扩展完整指南
- **11-security-and-compliance.md** - 安全与合规
- **12-backup-restore-archive.md** - 备份恢复与归档

### 高级架构文档
- **14-flexible-trace-architecture.md** - 灵活追踪架构设计
- **15-slo-and-observability.md** - SLO与可观测性
- **16-adr-index.md** - 架构决策记录索引
- **17-auto-crud-framework.md** - 自动化CRUD框架
- **18-mysql-dynamic-extension-solution.md** - MySQL动态字段扩展解决方案
- **20-workflow-extension-solution.md** - 动态流程扩展解决方案

## 快速导航

### 新手上路
1. 先阅读 [项目概览](00-overview.md) 了解系统整体架构
2. 学习 [开发标准](01-standards-and-conventions.md) 掌握开发规范
3. 查看 [数据库架构完整设计](07-database-architecture-complete.md) 理解数据设计

### 开发人员
- **架构设计**: 参考 [逻辑数据模型](03-logical-model.md) 和 [物理数据库设计](04-physical-layout.md)
- **开发规范**: 遵循 [开发标准和规范](01-standards-and-conventions.md)
- **业务术语**: 查阅 [业务领域术语表](02-domain-glossary.md)
- **数据契约**: 了解 [数据契约和API规范](06-data-contracts.md)

### 运维人员
- **部署指南**: 按照 [数据库部署指南](09-database-deployment-guide.md) 进行部署
- **迁移管理**: 使用 [数据库迁移和发布管理](05-migrations-and-release.md) 进行版本控制
- **数据质量**: 关注 [数据质量管理](08-data-quality.md)
- **备份恢复**: 参考 [备份恢复与归档](12-backup-restore-archive.md)

### 业务人员
- **业务扩展**: 了解 [业务扩展完整指南](10-business-extension-complete.md)
- **追踪系统**: 学习 [灵活追踪架构设计](14-flexible-trace-architecture.md)
- **流程管理**: 查看 [动态流程扩展解决方案](20-workflow-extension-solution.md)

### 架构师
- **自动化开发**: 研究 [自动化CRUD框架](17-auto-crud-framework.md)
- **架构决策**: 查看 [架构决策记录索引](16-adr-index.md)
- **可观测性**: 了解 [SLO与可观测性](15-slo-and-observability.md)
- **动态扩展**: 学习 [MySQL动态字段扩展解决方案](18-mysql-dynamic-extension-solution.md)
- **流程扩展**: 了解 [动态流程扩展解决方案](20-workflow-extension-solution.md)
- **业务扩展**: 研究 [业务扩展完整指南](10-business-extension-complete.md)

## 文档维护

### 更新原则
- 所有架构变更必须同步更新相关文档
- 新增功能需要补充相应的技术文档
- 定期审查文档的准确性和完整性

### 版本控制
- 文档版本与系统版本保持同步
- 重大变更需要记录变更日志
- 保持文档的可追溯性

## 联系方式

如有文档相关问题，请联系MES开发团队。
