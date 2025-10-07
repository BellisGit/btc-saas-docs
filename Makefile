# MES系统Makefile
# 基于MES系统全局架构基础文档

.PHONY: help install build test lint clean deploy backup restore

# 默认目标
help:
	@echo "MES系统构建和部署工具"
	@echo ""
	@echo "可用命令:"
	@echo "  install     安装所有依赖"
	@echo "  build       构建所有模块"
	@echo "  test        运行所有测试"
	@echo "  lint        代码质量检查"
	@echo "  clean       清理构建文件"
	@echo "  deploy      部署到生产环境"
	@echo "  backup      备份数据库"
	@echo "  restore     恢复数据库"
	@echo "  dev         启动开发环境"
	@echo "  prod        启动生产环境"
	@echo "  stop        停止所有服务"
	@echo "  logs        查看日志"
	@echo "  migrate     执行数据库迁移"
	@echo "  seed        初始化测试数据"

# 安装依赖
install:
	@echo "安装后端依赖..."
	cd mes-backend && npm install
	@echo "安装前端依赖..."
	cd mes-frontend && npm install
	@echo "安装移动端依赖..."
	cd mes-mobile && npm install
	@echo "安装BI系统依赖..."
	cd mes-bi && npm install
	@echo "安装质量检查工具..."
	npm install -g dbt-core

# 构建所有模块
build:
	@echo "构建后端应用..."
	cd mes-backend && npm run build
	@echo "构建前端应用..."
	cd mes-frontend && npm run build
	@echo "构建移动端H5..."
	cd mes-mobile && npm run build:h5
	@echo "构建BI系统..."
	cd mes-bi && npm run build
	@echo "构建完成!"

# 运行测试
test:
	@echo "运行后端测试..."
	cd mes-backend && npm test
	@echo "运行前端测试..."
	cd mes-frontend && npm test
	@echo "运行移动端测试..."
	cd mes-mobile && npm test
	@echo "运行BI系统测试..."
	cd mes-bi && npm test
	@echo "运行数据质量测试..."
	cd quality && dbt test
	@echo "所有测试完成!"

# 代码质量检查
lint:
	@echo "检查后端代码..."
	cd mes-backend && npm run lint
	@echo "检查前端代码..."
	cd mes-frontend && npm run lint
	@echo "检查移动端代码..."
	cd mes-mobile && npm run lint
	@echo "检查BI系统代码..."
	cd mes-bi && npm run lint
	@echo "代码质量检查完成!"

# 清理构建文件
clean:
	@echo "清理构建文件..."
	rm -rf mes-backend/dist
	rm -rf mes-frontend/dist
	rm -rf mes-mobile/dist
	rm -rf mes-bi/dist
	rm -rf mes-backend/node_modules
	rm -rf mes-frontend/node_modules
	rm -rf mes-mobile/node_modules
	rm -rf mes-bi/node_modules
	@echo "清理完成!"

# 启动开发环境
dev:
	@echo "启动开发环境..."
	docker-compose -f docker-compose.dev.yml up -d
	@echo "开发环境启动完成!"
	@echo "前端: http://localhost:3000"
	@echo "后端API: http://localhost:8080"
	@echo "BI系统: http://localhost:3001"

# 启动生产环境
prod:
	@echo "启动生产环境..."
	docker-compose up -d
	@echo "生产环境启动完成!"

# 停止所有服务
stop:
	@echo "停止所有服务..."
	docker-compose down
	@echo "所有服务已停止!"

# 查看日志
logs:
	@echo "查看服务日志..."
	docker-compose logs -f

# 数据库迁移
migrate:
	@echo "执行数据库迁移..."
	docker-compose exec flyway flyway migrate
	@echo "数据库迁移完成!"

# 初始化测试数据
seed:
	@echo "初始化测试数据..."
	docker-compose exec mysql mysql -u root -p$(MYSQL_ROOT_PASSWORD) mes_core < ./mes-backend/database/seeds/test_data.sql
	@echo "测试数据初始化完成!"

# 备份数据库
backup:
	@echo "备份数据库..."
	mkdir -p backups
	docker-compose exec mysql mysqldump -u root -p$(MYSQL_ROOT_PASSWORD) --all-databases > backups/mes_backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "数据库备份完成!"

# 恢复数据库
restore:
	@echo "恢复数据库..."
	@read -p "请输入备份文件路径: " backup_file; \
	docker-compose exec -T mysql mysql -u root -p$(MYSQL_ROOT_PASSWORD) < $$backup_file
	@echo "数据库恢复完成!"

# 部署到生产环境
deploy:
	@echo "开始部署到生产环境..."
	@echo "1. 拉取最新代码..."
	git pull origin main
	@echo "2. 运行测试..."
	$(MAKE) test
	@echo "3. 构建应用..."
	$(MAKE) build
	@echo "4. 备份数据库..."
	$(MAKE) backup
	@echo "5. 执行数据库迁移..."
	$(MAKE) migrate
	@echo "6. 重新构建Docker镜像..."
	docker-compose build --no-cache
	@echo "7. 重启服务..."
	docker-compose down
	docker-compose up -d
	@echo "8. 健康检查..."
	sleep 30
	curl -f http://localhost:8080/health || (echo "健康检查失败!" && exit 1)
	@echo "部署完成!"

# 蓝绿部署
blue-green-deploy:
	@echo "开始蓝绿部署..."
	./scripts/blue-green-deploy.sh
	@echo "蓝绿部署完成!"

# 性能测试
perf-test:
	@echo "运行性能测试..."
	ab -n 1000 -c 10 http://localhost:8080/api/work-orders
	@echo "性能测试完成!"

# 安全扫描
security-scan:
	@echo "运行安全扫描..."
	cd mes-backend && npm audit
	cd mes-frontend && npm audit
	cd mes-mobile && npm audit
	cd mes-bi && npm audit
	@echo "安全扫描完成!"

# 更新依赖
update-deps:
	@echo "更新后端依赖..."
	cd mes-backend && npm update
	@echo "更新前端依赖..."
	cd mes-frontend && npm update
	@echo "更新移动端依赖..."
	cd mes-mobile && npm update
	@echo "更新BI系统依赖..."
	cd mes-bi && npm update
	@echo "依赖更新完成!"

# 生成文档
docs:
	@echo "生成API文档..."
	cd mes-backend && npm run docs
	@echo "生成前端文档..."
	cd mes-frontend && npm run docs
	@echo "文档生成完成!"

# 数据质量检查
data-quality:
	@echo "运行数据质量检查..."
	cd quality && dbt run
	cd quality && dbt test
	@echo "数据质量检查完成!"

# 监控检查
monitor:
	@echo "检查系统监控..."
	curl -f http://localhost:9090/api/v1/query?query=up || echo "Prometheus不可用"
	curl -f http://localhost:3002/api/health || echo "Grafana不可用"
	@echo "监控检查完成!"

# 清理Docker资源
docker-clean:
	@echo "清理Docker资源..."
	docker system prune -f
	docker volume prune -f
	docker network prune -f
	@echo "Docker资源清理完成!"

# 完整环境重置
reset:
	@echo "重置完整环境..."
	$(MAKE) stop
	$(MAKE) clean
	$(MAKE) docker-clean
	docker-compose down -v
	$(MAKE) install
	$(MAKE) build
	$(MAKE) prod
	$(MAKE) migrate
	$(MAKE) seed
	@echo "环境重置完成!"

# 快速启动（开发）
quick-start:
	@echo "快速启动开发环境..."
	$(MAKE) install
	$(MAKE) build
	$(MAKE) dev
	@echo "快速启动完成!"
	@echo "访问地址:"
	@echo "  前端: http://localhost:3000"
	@echo "  后端: http://localhost:8080"
	@echo "  BI: http://localhost:3001"
	@echo "  Grafana: http://localhost:3002"
	@echo "  Prometheus: http://localhost:9090"
