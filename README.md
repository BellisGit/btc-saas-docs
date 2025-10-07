# MES制造执行系统

## 项目概述

MES（Manufacturing Execution System）制造执行系统是一个基于现代微服务架构的智能制造管理平台，集成了生产管理、质量管理、库存管理、追溯系统等核心功能模块。

## 系统架构

### 技术栈
- **前端**: Vue3 + Element Plus + ECharts
- **后端**: Node.js + Express + TypeScript
- **移动端**: uniapp + uview-plus
- **数据库**: MySQL 8.0 + Redis 6.0
- **BI系统**: Vue3 + ECharts + Element Plus
- **容器化**: Docker + Docker Compose
- **监控**: Prometheus + Grafana
- **CI/CD**: GitHub Actions

### 核心模块
- **生产管理**: 工单管理、生产计划、进度跟踪
- **质量管理**: 检验管理、缺陷分析、NCR处理
- **库存管理**: 物料管理、库存跟踪、ABC分析
- **追溯系统**: 全链路追溯、正反向追溯
- **BI仪表板**: 实时监控、数据分析、报表生成

## 快速开始

### 环境要求
- Node.js 18+
- MySQL 8.0+
- Redis 6.0+
- Docker 20+
- Docker Compose 2.0+

### 安装步骤

1. **克隆项目**
```bash
git clone https://github.com/company/mes-system.git
cd mes-system
```

2. **配置环境变量**
```bash
cp env.example .env
# 编辑 .env 文件，配置数据库、Redis等连接信息
```

3. **安装依赖**
```bash
make install
```

4. **启动开发环境**
```bash
make dev
```

5. **访问系统**
- 前端管理界面: http://localhost:3000
- 后端API: http://localhost:8080
- BI仪表板: http://localhost:3001
- 监控面板: http://localhost:3002

### Docker部署

```bash
# 构建并启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

## 项目结构

```
mes-system/
├── docs/                    # 项目文档
│   ├── 00-overview.md      # 系统概述
│   ├── 01-standards-and-conventions.md  # 标准规范
│   ├── 02-domain-glossary.md           # 领域词汇
│   ├── 03-logical-model.md             # 逻辑模型
│   ├── 04-physical-layout.md           # 物理设计
│   └── 05-migrations-and-release.md    # 迁移发布
├── mes-backend/            # 后端服务
│   ├── src/               # 源代码
│   ├── database/          # 数据库脚本
│   └── Dockerfile         # Docker配置
├── mes-frontend/          # 前端应用
│   ├── src/              # 源代码
│   ├── public/           # 静态资源
│   └── Dockerfile        # Docker配置
├── mes-mobile/           # 移动端应用
│   ├── src/             # 源代码
│   ├── pages/           # 页面组件
│   └── Dockerfile       # Docker配置
├── mes-bi/              # BI系统
│   ├── src/            # 源代码
│   ├── components/     # 图表组件
│   └── Dockerfile      # Docker配置
├── contracts/          # 数据契约
│   ├── events/        # 事件定义
│   ├── schema-registry/ # Schema注册
│   └── views/         # 视图定义
├── models/            # 数据模型
│   └── logical_model.yaml
├── quality/           # 数据质量
│   └── dbt_project.yml
├── operations/        # 运维管理
│   ├── dashboards/   # 监控面板
│   └── runbooks/     # 运维手册
├── decisions/        # 架构决策
│   └── ADR-0001.md
├── docker-compose.yml # Docker编排
├── Makefile          # 构建脚本
└── README.md         # 项目说明
```

## 开发指南

### 代码规范
- 使用ESLint进行代码检查
- 使用Prettier进行代码格式化
- 遵循Vue3 Composition API规范
- 采用TypeScript进行类型检查

### 提交规范
使用Conventional Commits规范：
- `feat`: 新功能
- `fix`: 修复问题
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建过程或辅助工具的变动

### 测试规范
```bash
# 运行所有测试
make test

# 运行单元测试
npm test

# 运行集成测试
npm run test:integration

# 运行E2E测试
npm run test:e2e
```

## 部署指南

### 生产环境部署
```bash
# 完整部署流程
make deploy

# 蓝绿部署
make blue-green-deploy

# 回滚部署
make rollback
```

### 环境配置
- **开发环境**: dev.mes.company.com
- **测试环境**: test.mes.company.com
- **生产环境**: prod.mes.company.com

## 监控运维

### 系统监控
- **Prometheus**: 指标收集
- **Grafana**: 监控面板
- **ELK Stack**: 日志分析

### 告警配置
- CPU使用率 > 80%
- 内存使用率 > 85%
- 磁盘使用率 > 90%
- 数据库连接数 > 150
- 慢查询数 > 10/min

### 备份策略
- **数据库备份**: 每日全量备份 + 每小时增量备份
- **文件备份**: 每日备份到OSS
- **配置备份**: 版本控制管理

## API文档

### 认证方式
使用JWT Token进行API认证：
```bash
curl -H "Authorization: Bearer <token>" \
     http://localhost:8080/api/work-orders
```

### 统一响应格式
```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": "2025-01-07T10:30:00Z",
  "traceId": "trace-123456"
}
```

### 主要API端点
- `GET /api/work-orders` - 获取工单列表
- `POST /api/work-orders` - 创建工单
- `GET /api/inspections` - 获取检验单列表
- `POST /api/inspections` - 创建检验单
- `GET /api/trace/reverse` - 反向追溯
- `GET /api/stock` - 获取库存信息

## 数据模型

### 核心实体
- **物料主数据** (item_master)
- **供应商主数据** (supplier_master)
- **工单** (work_order)
- **生产批次** (production_lot)
- **序列号** (serial_number)
- **检验单** (inspection)
- **追溯事件** (trace_event)

### 标识符规范
- 物料ID: `ITM-YYYYMM-XXXX`
- 供应商ID: `SUP-XXXXX`
- 工单号: `WO-LINE-SEQ`
- 批次号: `LOT-YYYYMMDD-SEQ`
- 序列号: `SN-LOT-YYYYMMDD-SEQ-XXXX`

## 质量保证

### 数据质量
使用dbt进行数据质量测试：
```bash
cd quality
dbt run
dbt test
```

### 质量标准
- 准确性: ≥ 99.9%
- 完整性: ≥ 99.5%
- 一致性: ≥ 99.0%
- 及时性: ≤ 5分钟
- 有效性: ≥ 99.5%
- 唯一性: ≥ 99.9%

## 安全规范

### 数据安全
- 敏感数据加密存储
- 传输过程HTTPS加密
- 数据库访问权限控制
- 审计日志完整记录

### 访问控制
- 基于角色的权限管理(RBAC)
- JWT Token认证
- API访问频率限制
- 跨域访问控制

## 故障处理

### 常见问题
1. **数据库连接失败**: 检查MySQL服务状态和连接配置
2. **Redis连接超时**: 检查Redis服务状态和网络连接
3. **前端页面空白**: 检查API服务状态和CORS配置
4. **移动端无法登录**: 检查JWT配置和网络连接

### 故障排查
```bash
# 查看服务状态
docker-compose ps

# 查看服务日志
docker-compose logs -f mes-backend

# 检查数据库状态
mysql -u root -p -e "SHOW STATUS LIKE 'Threads_connected';"

# 检查Redis状态
redis-cli ping
```

## 贡献指南

### 开发流程
1. Fork项目到个人仓库
2. 创建功能分支
3. 提交代码变更
4. 创建Pull Request
5. 代码审查
6. 合并到主分支

### 代码审查
- 功能完整性检查
- 代码质量检查
- 性能影响评估
- 安全性检查
- 文档更新检查

## 许可证

本项目采用MIT许可证，详见[LICENSE](LICENSE)文件。

## 联系我们

- 项目负责人: MES Team
- 邮箱: mes@company.com
- 技术支持: +86-xxx-xxxx-xxxx
- 项目地址: https://github.com/company/mes-system

## 更新日志

### v1.0.0 (2025-01-07)
- 初始版本发布
- 核心功能模块完成
- 基础架构搭建
- 文档体系建立

---

**注意**: 本系统为内部使用，请勿在生产环境中使用默认密码和配置。