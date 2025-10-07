# 应用部署手册

## 概述
本手册描述了MES系统各模块的部署流程，包括前端、后端、移动端和BI系统的部署步骤。

## 部署环境

### 环境配置
- **开发环境**: dev.mes.company.com
- **测试环境**: test.mes.company.com  
- **生产环境**: prod.mes.company.com

### 服务器配置
- **Web服务器**: Nginx 1.20+
- **应用服务器**: Node.js 18+, Java 17+
- **数据库**: MySQL 8.0+, Redis 6.0+
- **容器**: Docker 20+, Docker Compose 2.0+

## 部署前准备

### 1. 代码检查
```bash
# 拉取最新代码
git pull origin main

# 运行测试
npm test
npm run lint

# 检查代码质量
npm run audit
```

### 2. 环境变量配置
```bash
# 复制环境配置文件
cp .env.example .env.production

# 编辑生产环境配置
vim .env.production
```

### 3. 数据库迁移
```bash
# 检查待执行的迁移
./flyway info

# 执行数据库迁移
./flyway migrate

# 验证迁移结果
./flyway info
```

## 后端部署 (mes-backend)

### 1. 构建应用
```bash
cd mes-backend

# 安装依赖
npm install

# 构建应用
npm run build

# 运行测试
npm test
```

### 2. Docker部署
```bash
# 构建Docker镜像
docker build -t mes-backend:latest .

# 停止旧容器
docker stop mes-backend
docker rm mes-backend

# 启动新容器
docker run -d \
  --name mes-backend \
  --network mes-network \
  -p 8080:8080 \
  -e NODE_ENV=production \
  -e DB_HOST=mysql \
  -e REDIS_HOST=redis \
  -v /app/logs:/app/logs \
  mes-backend:latest
```

### 3. 健康检查
```bash
# 检查应用状态
curl http://localhost:8080/health

# 检查API接口
curl http://localhost:8080/api/work-orders

# 检查日志
docker logs mes-backend
```

## 前端部署 (mes-frontend)

### 1. 构建前端应用
```bash
cd mes-frontend

# 安装依赖
npm install

# 构建生产版本
npm run build

# 检查构建结果
ls -la dist/
```

### 2. Nginx配置
```nginx
# /etc/nginx/sites-available/mes-frontend
server {
    listen 80;
    server_name mes.company.com;
    
    # 重定向到HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name mes.company.com;
    
    # SSL配置
    ssl_certificate /etc/ssl/certs/mes.crt;
    ssl_certificate_key /etc/ssl/private/mes.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    
    # 静态文件
    root /var/www/mes-frontend/dist;
    index index.html;
    
    # Gzip压缩
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
    
    # 缓存配置
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # API代理
    location /api/ {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # WebSocket代理
    location /ws/ {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
    
    # SPA路由
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

### 3. 部署步骤
```bash
# 备份当前版本
sudo cp -r /var/www/mes-frontend /var/www/mes-frontend.backup.$(date +%Y%m%d_%H%M%S)

# 部署新版本
sudo rm -rf /var/www/mes-frontend/dist
sudo cp -r dist /var/www/mes-frontend/

# 设置权限
sudo chown -R www-data:www-data /var/www/mes-frontend
sudo chmod -R 755 /var/www/mes-frontend

# 重新加载Nginx
sudo nginx -t
sudo systemctl reload nginx
```

## 移动端部署 (mes-mobile)

### 1. 构建移动应用
```bash
cd mes-mobile

# 安装依赖
npm install

# 构建H5版本
npm run build:h5

# 构建微信小程序
npm run build:mp-weixin
```

### 2. 部署H5版本
```bash
# 部署到CDN
rsync -avz dist/build/h5/ cdn-server:/var/www/mes-mobile/

# 更新CDN缓存
curl -X POST "https://api.cdn.com/purge" \
  -H "Authorization: Bearer $CDN_TOKEN" \
  -d '{"urls": ["https://mobile.mes.company.com/*"]}'
```

### 3. 微信小程序发布
```bash
# 上传小程序代码
npx miniprogram-ci upload \
  --project-path dist/build/mp-weixin \
  --version 1.0.0 \
  --desc "MES移动端更新" \
  --appid $WECHAT_APPID \
  --private-key-path $PRIVATE_KEY_PATH \
  --threads 1
```

## BI系统部署 (mes-bi)

### 1. 构建BI应用
```bash
cd mes-bi

# 安装依赖
npm install

# 构建应用
npm run build

# 检查构建结果
ls -la dist/
```

### 2. 部署BI系统
```bash
# 备份当前版本
sudo cp -r /var/www/mes-bi /var/www/mes-bi.backup.$(date +%Y%m%d_%H%M%S)

# 部署新版本
sudo rm -rf /var/www/mes-bi/dist
sudo cp -r dist /var/www/mes-bi/

# 设置权限
sudo chown -R www-data:www-data /var/www/mes-bi
sudo chmod -R 755 /var/www/mes-bi
```

## 数据库部署

### 1. 生产数据库部署
```bash
# 创建数据库用户
mysql -u root -p << EOF
CREATE DATABASE IF NOT EXISTS mes_core CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'mes_app'@'%' IDENTIFIED BY 'secure_password';
GRANT ALL PRIVILEGES ON mes_core.* TO 'mes_app'@'%';
FLUSH PRIVILEGES;
EOF

# 执行数据库迁移
./flyway migrate -url=jdbc:mysql://localhost:3306/mes_core \
  -user=mes_app -password=secure_password \
  -locations=filesystem:./database/migrations
```

### 2. Redis部署
```bash
# 启动Redis容器
docker run -d \
  --name mes-redis \
  --network mes-network \
  -p 6379:6379 \
  -v /data/redis:/data \
  redis:6.0-alpine \
  redis-server --appendonly yes --requirepass redis_password
```

## 蓝绿部署

### 1. 部署脚本
```bash
#!/bin/bash
# blue-green-deploy.sh

set -e

# 配置
APP_NAME="mes-backend"
BLUE_PORT=8080
GREEN_PORT=8081
NGINX_CONFIG="/etc/nginx/sites-available/mes-backend"

# 获取当前运行的端口
get_current_port() {
    if curl -s http://localhost:$BLUE_PORT/health > /dev/null; then
        echo $BLUE_PORT
    else
        echo $GREEN_PORT
    fi
}

# 部署到备用端口
deploy_to_port() {
    local port=$1
    echo "部署到端口 $port"
    
    docker run -d \
        --name ${APP_NAME}-${port} \
        --network mes-network \
        -p ${port}:8080 \
        -e NODE_ENV=production \
        ${APP_NAME}:latest
}

# 切换流量
switch_traffic() {
    local new_port=$1
    echo "切换流量到端口 $new_port"
    
    # 更新Nginx配置
    sed -i "s/proxy_pass http:\/\/localhost:[0-9]*/proxy_pass http:\/\/localhost:$new_port/" $NGINX_CONFIG
    
    # 重新加载Nginx
    nginx -t && systemctl reload nginx
}

# 停止旧版本
stop_old_version() {
    local old_port=$1
    echo "停止旧版本端口 $old_port"
    
    docker stop ${APP_NAME}-${old_port} || true
    docker rm ${APP_NAME}-${old_port} || true
}

# 主流程
main() {
    echo "开始蓝绿部署..."
    
    # 获取当前端口
    CURRENT_PORT=$(get_current_port)
    echo "当前运行端口: $CURRENT_PORT"
    
    # 确定新端口
    if [ "$CURRENT_PORT" = "$BLUE_PORT" ]; then
        NEW_PORT=$GREEN_PORT
    else
        NEW_PORT=$BLUE_PORT
    fi
    
    # 部署新版本
    deploy_to_port $NEW_PORT
    
    # 等待健康检查
    echo "等待健康检查..."
    sleep 30
    
    # 检查新版本健康状态
    if curl -s http://localhost:$NEW_PORT/health | grep -q "healthy"; then
        echo "新版本健康检查通过"
        
        # 切换流量
        switch_traffic $NEW_PORT
        
        # 等待流量切换完成
        sleep 10
        
        # 停止旧版本
        stop_old_version $CURRENT_PORT
        
        echo "蓝绿部署完成"
    else
        echo "新版本健康检查失败，回滚"
        docker stop ${APP_NAME}-${NEW_PORT} || true
        docker rm ${APP_NAME}-${NEW_PORT} || true
        exit 1
    fi
}

main "$@"
```

### 2. 使用蓝绿部署
```bash
# 执行蓝绿部署
chmod +x blue-green-deploy.sh
./blue-green-deploy.sh
```

## 回滚流程

### 1. 应用回滚
```bash
# 回滚到上一个版本
git checkout HEAD~1
npm run build
docker build -t mes-backend:rollback .
docker stop mes-backend
docker rm mes-backend
docker run -d --name mes-backend -p 8080:8080 mes-backend:rollback
```

### 2. 数据库回滚
```bash
# 回滚数据库迁移
./flyway undo -url=jdbc:mysql://localhost:3306/mes_core \
  -user=mes_app -password=secure_password
```

## 部署验证

### 1. 功能验证
```bash
# 验证API接口
curl -X GET http://localhost:8080/api/work-orders
curl -X POST http://localhost:8080/api/work-orders \
  -H "Content-Type: application/json" \
  -d '{"item_id":"ITM-202501-0001","planned_quantity":1000}'

# 验证前端页面
curl -I https://mes.company.com/
curl -I https://mes.company.com/api/health
```

### 2. 性能验证
```bash
# 压力测试
ab -n 1000 -c 10 http://localhost:8080/api/work-orders

# 响应时间检查
curl -w "@curl-format.txt" -o /dev/null -s http://localhost:8080/api/work-orders
```

### 3. 监控检查
```bash
# 检查应用日志
docker logs mes-backend | tail -100

# 检查系统资源
htop
df -h
free -h

# 检查数据库状态
mysql -u mes_app -p -e "SHOW STATUS LIKE 'Threads_connected';"
```

## 自动化部署

### 1. CI/CD Pipeline
```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run tests
        run: npm test
        
      - name: Build application
        run: npm run build
        
      - name: Deploy to server
        uses: appleboy/ssh-action@v0.1.5
        with:
          host: ${{ secrets.HOST }}
          username: ${{ secrets.USERNAME }}
          key: ${{ secrets.SSH_KEY }}
          script: |
            cd /opt/mes-backend
            git pull origin main
            npm ci
            npm run build
            docker build -t mes-backend:latest .
            ./blue-green-deploy.sh
```

### 2. 部署通知
```bash
# 部署成功通知
curl -X POST $SLACK_WEBHOOK \
  -H 'Content-type: application/json' \
  --data '{
    "text": "MES系统部署成功",
    "attachments": [{
      "color": "good",
      "fields": [{
        "title": "版本",
        "value": "'$GIT_COMMIT'",
        "short": true
      }, {
        "title": "环境",
        "value": "生产环境",
        "short": true
      }]
    }]
  }'
```

## 故障处理

### 1. 部署失败处理
```bash
# 检查部署日志
docker logs mes-backend

# 检查系统资源
df -h
free -h

# 检查端口占用
netstat -tlnp | grep :8080

# 回滚到上一个版本
git checkout HEAD~1
./deploy.sh
```

### 2. 性能问题处理
```bash
# 检查CPU使用率
top -p $(pgrep -f mes-backend)

# 检查内存使用
ps aux | grep mes-backend

# 检查网络连接
ss -tulpn | grep :8080

# 重启应用
docker restart mes-backend
```

## 联系信息
- 运维团队: DevOps Team
- 紧急联系: +86-xxx-xxxx-xxxx
- 邮箱: devops@company.com
- 值班电话: +86-xxx-xxxx-xxxx
