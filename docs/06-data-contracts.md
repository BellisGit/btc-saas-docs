# MES系统数据契约

## 概述

本文档定义了MES制造执行系统的数据契约，包括API接口契约、数据格式规范、事件契约和Schema注册表。数据契约确保系统各模块之间的数据交换的一致性和兼容性，支持系统的可扩展性和可维护性。

## API接口契约

### 1. 统一响应格式

#### 1.1 成功响应
```json
{
  "code": 200,
  "message": "success",
  "data": {
    // 具体数据内容
  },
  "timestamp": "2025-01-07T10:30:00Z",
  "traceId": "trace-123456789"
}
```

#### 1.2 错误响应
```json
{
  "code": 400,
  "message": "参数错误",
  "errors": [
    {
      "field": "itemId",
      "message": "物料ID不能为空",
      "code": "REQUIRED_FIELD"
    }
  ],
  "timestamp": "2025-01-07T10:30:00Z",
  "traceId": "trace-123456789"
}
```

#### 1.3 分页响应
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "items": [
      // 数据列表
    ],
    "pagination": {
      "page": 1,
      "size": 20,
      "total": 100,
      "pages": 5,
      "hasNext": true,
      "hasPrev": false
    }
  },
  "timestamp": "2025-01-07T10:30:00Z",
  "traceId": "trace-123456789"
}
```

### 2. 状态码规范

| 状态码 | 说明 | 使用场景 |
|--------|------|----------|
| 200 | 成功 | 请求成功处理 |
| 201 | 创建成功 | 资源创建成功 |
| 400 | 请求参数错误 | 参数验证失败 |
| 401 | 未授权 | 用户未登录或token过期 |
| 403 | 禁止访问 | 用户无权限访问 |
| 404 | 资源不存在 | 请求的资源不存在 |
| 409 | 资源冲突 | 资源已存在或状态冲突 |
| 422 | 业务逻辑错误 | 业务规则验证失败 |
| 500 | 服务器内部错误 | 系统内部错误 |

### 3. 错误码规范

| 错误码 | 说明 | 示例 |
|--------|------|------|
| REQUIRED_FIELD | 必填字段为空 | 物料ID不能为空 |
| INVALID_FORMAT | 格式不正确 | 日期格式错误 |
| DUPLICATE_VALUE | 重复值 | 物料代码已存在 |
| NOT_FOUND | 资源不存在 | 工单不存在 |
| BUSINESS_RULE | 业务规则错误 | 工单状态不允许此操作 |
| PERMISSION_DENIED | 权限不足 | 无权限访问此资源 |

## 核心业务API契约

### 1. 物料管理API

#### 1.1 获取物料列表
```http
GET /api/items
```

**请求参数**：
```json
{
  "page": 1,
  "size": 20,
  "sort": "created_at",
  "order": "desc",
  "filters": {
    "itemType": "FINISHED",
    "status": "ACTIVE",
    "supplierId": "SUP-ACME001"
  },
  "search": "验钞机"
}
```

**响应数据**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "items": [
      {
        "itemId": "ITM-202501-0001",
        "itemCode": "RAW-001",
        "itemName": "验钞机",
        "itemType": "FINISHED",
        "uom": "PCS",
        "specification": "便携式验钞机",
        "supplierId": "SUP-ACME001",
        "supplierName": "ACME电子有限公司",
        "status": "ACTIVE",
        "createdAt": "2025-01-07T10:30:00Z",
        "updatedAt": "2025-01-07T10:30:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "size": 20,
      "total": 100,
      "pages": 5
    }
  }
}
```

#### 1.2 创建物料
```http
POST /api/items
```

**请求数据**：
```json
{
  "itemCode": "RAW-002",
  "itemName": "钱箱",
  "itemType": "FINISHED",
  "uom": "PCS",
  "specification": "电子钱箱",
  "supplierId": "SUP-ACME001"
}
```

**响应数据**：
```json
{
  "code": 201,
  "message": "物料创建成功",
  "data": {
    "itemId": "ITM-202501-0002",
    "itemCode": "RAW-002",
    "itemName": "钱箱",
    "itemType": "FINISHED",
    "uom": "PCS",
    "specification": "电子钱箱",
    "supplierId": "SUP-ACME001",
    "status": "ACTIVE",
    "createdAt": "2025-01-07T10:30:00Z"
  }
}
```

### 2. 工单管理API

#### 2.1 获取工单列表
```http
GET /api/work-orders
```

**请求参数**：
```json
{
  "page": 1,
  "size": 20,
  "filters": {
    "status": "IN_PROGRESS",
    "itemId": "ITM-202501-0001",
    "lineId": "L1"
  },
  "dateRange": {
    "startDate": "2025-01-01",
    "endDate": "2025-01-31"
  }
}
```

**响应数据**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "items": [
      {
        "woId": "WO-L1-0001",
        "woNo": "WO-20250107-001",
        "itemId": "ITM-202501-0001",
        "itemName": "验钞机",
        "plannedQuantity": 1000,
        "actualQuantity": 850,
        "progress": 85.0,
        "lineId": "L1",
        "priority": "HIGH",
        "status": "IN_PROGRESS",
        "plannedStartDate": "2025-01-07T08:00:00Z",
        "plannedEndDate": "2025-01-07T18:00:00Z",
        "actualStartDate": "2025-01-07T08:15:00Z",
        "yieldRate": 96.8,
        "createdAt": "2025-01-07T08:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "size": 20,
      "total": 50,
      "pages": 3
    }
  }
}
```

#### 2.2 创建工单
```http
POST /api/work-orders
```

**请求数据**：
```json
{
  "itemId": "ITM-202501-0001",
  "plannedQuantity": 1000,
  "lineId": "L1",
  "priority": "HIGH",
  "plannedStartDate": "2025-01-08T08:00:00Z",
  "plannedEndDate": "2025-01-08T18:00:00Z",
  "routingId": "ROUT-001",
  "remarks": "紧急订单"
}
```

**响应数据**：
```json
{
  "code": 201,
  "message": "工单创建成功",
  "data": {
    "woId": "WO-L1-0002",
    "woNo": "WO-20250108-001",
    "itemId": "ITM-202501-0001",
    "plannedQuantity": 1000,
    "lineId": "L1",
    "priority": "HIGH",
    "status": "DRAFT",
    "plannedStartDate": "2025-01-08T08:00:00Z",
    "plannedEndDate": "2025-01-08T18:00:00Z",
    "routingId": "ROUT-001",
    "createdAt": "2025-01-07T10:30:00Z"
  }
}
```

### 3. 品质管理API

#### 3.1 创建检验单
```http
POST /api/inspections
```

**请求数据**：
```json
{
  "type": "IQC",
  "refId": "GRN-20250107-001",
  "refType": "GRN",
  "sampleSize": 32,
  "aqlLevel": "II",
  "inspector": "INSP001",
  "items": [
    {
      "itemKey": "外观检查",
      "itemName": "外观质量检查",
      "standardValue": "无划痕、无变形",
      "actualValue": "合格",
      "result": "PASS"
    },
    {
      "itemKey": "尺寸检查",
      "itemName": "关键尺寸测量",
      "standardValue": "100±0.1mm",
      "actualValue": "99.95mm",
      "result": "PASS"
    }
  ]
}
```

**响应数据**：
```json
{
  "code": 201,
  "message": "检验单创建成功",
  "data": {
    "inspId": "INSP-IQC-20250107-001",
    "type": "IQC",
    "refId": "GRN-20250107-001",
    "refType": "GRN",
    "result": "PASS",
    "sampleSize": 32,
    "defectQuantity": 0,
    "aqlLevel": "II",
    "inspector": "INSP001",
    "inspectionDate": "2025-01-07T10:30:00Z",
    "createdAt": "2025-01-07T10:30:00Z"
  }
}
```

### 4. 追溯管理API

#### 4.1 正向追溯
```http
GET /api/trace/forward/{entityType}/{entityId}
```

**请求示例**：
```http
GET /api/trace/forward/SN/SN-LOT-20250107-001-0001
```

**响应数据**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "entityType": "SN",
    "entityId": "SN-LOT-20250107-001-0001",
    "tracePath": [
      {
        "entityType": "WO",
        "entityId": "WO-L1-0001",
        "entityName": "验钞机生产工单",
        "timestamp": "2025-01-07T08:00:00Z",
        "action": "START",
        "operator": "OP001",
        "station": "ST001"
      },
      {
        "entityType": "LOT",
        "entityId": "LOT-20250107-001",
        "entityName": "验钞机生产批次",
        "timestamp": "2025-01-07T08:15:00Z",
        "action": "START",
        "operator": "OP001",
        "station": "ST001"
      },
      {
        "entityType": "SN",
        "entityId": "SN-LOT-20250107-001-0001",
        "entityName": "验钞机序列号",
        "timestamp": "2025-01-07T09:00:00Z",
        "action": "COMPLETED",
        "operator": "OP002",
        "station": "ST005"
      }
    ],
    "materials": [
      {
        "itemId": "ITM-202501-0001",
        "itemName": "PCB主板",
        "supplierId": "SUP-ACME001",
        "supplierName": "ACME电子有限公司",
        "grnId": "GRN-20250107-001",
        "quantity": 1
      }
    ],
    "quality": {
      "iqc": "PASS",
      "ipqc": "PASS",
      "oqc": "PASS",
      "testResults": [
        {
          "station": "ST004",
          "testType": "功能测试",
          "result": "PASS",
          "testedAt": "2025-01-07T09:30:00Z"
        }
      ]
    },
    "shipping": {
      "boxNo": "BOX-20250107-001",
      "palletNo": "PLT-20250107-001",
      "shipmentId": "SHP-20250107-001",
      "shippedAt": "2025-01-07T16:00:00Z"
    }
  }
}
```

#### 4.2 反向追溯
```http
GET /api/trace/reverse/{entityType}/{entityId}
```

**请求示例**：
```http
GET /api/trace/reverse/SN/SN-LOT-20250107-001-0001
```

**响应数据**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "entityType": "SN",
    "entityId": "SN-LOT-20250107-001-0001",
    "reverseTrace": {
      "materials": [
        {
          "itemId": "ITM-202501-0001",
          "itemName": "PCB主板",
          "supplierId": "SUP-ACME001",
          "supplierName": "ACME电子有限公司",
          "grnId": "GRN-20250107-001",
          "moldId": "MLD-SUP-0001",
          "moldName": "PCB注塑模具",
          "iqcResult": "PASS",
          "iqcDate": "2025-01-07T07:00:00Z"
        }
      ],
      "processes": [
        {
          "opId": "OP-001",
          "opName": "SMT贴片",
          "station": "ST001",
          "operator": "OP001",
          "startTime": "2025-01-07T08:00:00Z",
          "endTime": "2025-01-07T08:30:00Z",
          "result": "PASS"
        },
        {
          "opId": "OP-002",
          "opName": "DIP插件",
          "station": "ST002",
          "operator": "OP002",
          "startTime": "2025-01-07T08:30:00Z",
          "endTime": "2025-01-07T08:55:00Z",
          "result": "PASS"
        }
      ],
      "quality": {
        "defects": [],
        "testResults": [
          {
            "station": "ST004",
            "testType": "功能测试",
            "result": "PASS",
            "testData": {
              "voltage": "5.0V",
              "current": "0.5A",
              "temperature": "25°C"
            },
            "testedAt": "2025-01-07T09:30:00Z"
          }
        ]
      }
    }
  }
}
```

## BI数据契约

### 1. 实时数据API

#### 1.1 获取生产监控数据
```http
GET /api/bi/production/monitor
```

**响应数据**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "metrics": {
      "totalProduction": 1250,
      "productionTrend": 5.2,
      "yieldRate": 96.8,
      "yieldTrend": 1.2,
      "wipCount": 156,
      "wipTrend": -2.1,
      "efficiency": 87.5,
      "efficiencyTrend": 3.4
    },
    "yieldTrend": [
      {
        "time": "10:00",
        "value": 96.2
      },
      {
        "time": "10:05",
        "value": 96.5
      },
      {
        "time": "10:10",
        "value": 96.8
      }
    ],
    "wipStatus": {
      "assembling": 120,
      "testing": 45,
      "packing": 30,
      "finished": 60
    },
    "alerts": [
      {
        "level": "warning",
        "message": "IPQC不合格率上升至5%（>3%阈值）",
        "timestamp": "2025-01-07T10:25:00Z"
      }
    ],
    "lastUpdateTime": "2025-01-07T10:30:00Z"
  }
}
```

#### 1.2 获取设备状态数据
```http
GET /api/bi/equipment/status
```

**响应数据**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "equipment": [
      {
        "equipmentId": "EQ-001",
        "equipmentName": "SMT贴片机",
        "station": "ST001",
        "status": "RUNNING",
        "efficiency": 95.2,
        "uptime": 98.5,
        "lastMaintenance": "2025-01-01T00:00:00Z",
        "nextMaintenance": "2025-02-01T00:00:00Z"
      },
      {
        "equipmentId": "EQ-002",
        "equipmentName": "DIP插件机",
        "station": "ST002",
        "status": "IDLE",
        "efficiency": 87.3,
        "uptime": 96.2,
        "lastMaintenance": "2025-01-05T00:00:00Z",
        "nextMaintenance": "2025-02-05T00:00:00Z"
      }
    ],
    "summary": {
      "totalEquipment": 10,
      "runningCount": 8,
      "idleCount": 2,
      "maintenanceCount": 0,
      "averageEfficiency": 91.2
    }
  }
}
```

### 2. WebSocket实时推送

#### 2.1 连接建立
```javascript
const ws = new WebSocket('ws://localhost:8080/ws/bi/production');

ws.onopen = function() {
  console.log('WebSocket连接已建立');
};

ws.onmessage = function(event) {
  const data = JSON.parse(event.data);
  console.log('收到实时数据:', data);
};
```

#### 2.2 数据推送格式
```json
{
  "type": "production_update",
  "timestamp": "2025-01-07T10:30:00Z",
  "data": {
    "yieldRate": 96.8,
    "wipCount": 156,
    "efficiency": 87.5,
    "alerts": [
      {
        "level": "warning",
        "message": "IPQC不合格率上升至5%"
      }
    ]
  }
}
```

## 移动端数据契约

### 1. 供应商端API

#### 1.1 获取待办事项
```http
GET /api/mobile/supplier/todos
```

**请求头**：
```http
Authorization: Bearer {token}
X-Tenant-ID: TENANT001
```

**响应数据**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "todos": [
      {
        "id": 1,
        "type": "urgent",
        "icon": "clock",
        "title": "紧急发货",
        "description": "订单PO-20250107-001需要紧急发货",
        "time": "2小时前",
        "count": 1,
        "actionUrl": "/pages/delivery/detail?id=PO-20250107-001"
      },
      {
        "id": 2,
        "type": "quality",
        "icon": "checkmark-circle",
        "title": "IQC检验",
        "description": "批次LOT-20250107-001等待IQC检验",
        "time": "4小时前",
        "count": 0,
        "actionUrl": "/pages/quality/iqc?id=LOT-20250107-001"
      }
    ],
    "stats": {
      "deliveryCount": 156,
      "qualityRate": 98.5,
      "onTimeRate": 95.2,
      "rating": 4.8
    }
  }
}
```

#### 1.2 扫码查询
```http
POST /api/mobile/supplier/scan
```

**请求数据**：
```json
{
  "scanType": "QR_CODE",
  "scanData": "SN-LOT-20250107-001-0001",
  "location": {
    "latitude": 22.5431,
    "longitude": 114.0579
  }
}
```

**响应数据**：
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "entityType": "SN",
    "entityId": "SN-LOT-20250107-001-0001",
    "entityInfo": {
      "itemName": "验钞机",
      "lotId": "LOT-20250107-001",
      "woId": "WO-L1-0001",
      "status": "COMPLETED",
      "qualityStatus": "PASS"
    },
    "actions": [
      {
        "action": "view_detail",
        "label": "查看详情",
        "url": "/pages/trace/detail?sn=SN-LOT-20250107-001-0001"
      },
      {
        "action": "quality_check",
        "label": "质量检查",
        "url": "/pages/quality/check?sn=SN-LOT-20250107-001-0001"
      }
    ]
  }
}
```

## 事件契约

### 1. 事件格式规范

#### 1.1 事件结构
```json
{
  "eventId": "evt-123456789",
  "eventType": "work_order.created",
  "version": "1.0",
  "timestamp": "2025-01-07T10:30:00Z",
  "source": "mes-backend",
  "tenantId": "TENANT001",
  "siteId": "SITE001",
  "correlationId": "corr-123456789",
  "data": {
    // 事件具体数据
  },
  "metadata": {
    "userId": "USER001",
    "sessionId": "sess-123456789",
    "ipAddress": "192.168.1.100"
  }
}
```

#### 1.2 事件类型规范
```
{domain}.{entity}.{action}
```

**示例**：
- `production.work_order.created` - 工单创建
- `production.work_order.updated` - 工单更新
- `production.work_order.completed` - 工单完成
- `quality.inspection.created` - 检验单创建
- `quality.inspection.completed` - 检验完成
- `inventory.stock.updated` - 库存更新
- `trace.event.recorded` - 追溯事件记录

### 2. 核心业务事件

#### 2.1 工单创建事件
```json
{
  "eventId": "evt-wo-created-001",
  "eventType": "production.work_order.created",
  "version": "1.0",
  "timestamp": "2025-01-07T10:30:00Z",
  "source": "mes-backend",
  "tenantId": "TENANT001",
  "data": {
    "woId": "WO-L1-0001",
    "woNo": "WO-20250107-001",
    "itemId": "ITM-202501-0001",
    "itemName": "验钞机",
    "plannedQuantity": 1000,
    "lineId": "L1",
    "priority": "HIGH",
    "status": "DRAFT",
    "plannedStartDate": "2025-01-07T08:00:00Z",
    "plannedEndDate": "2025-01-07T18:00:00Z",
    "createdBy": "USER001"
  }
}
```

#### 2.2 检验完成事件
```json
{
  "eventId": "evt-inspection-completed-001",
  "eventType": "quality.inspection.completed",
  "version": "1.0",
  "timestamp": "2025-01-07T10:30:00Z",
  "source": "mes-backend",
  "tenantId": "TENANT001",
  "data": {
    "inspId": "INSP-IQC-20250107-001",
    "type": "IQC",
    "refId": "GRN-20250107-001",
    "refType": "GRN",
    "result": "PASS",
    "sampleSize": 32,
    "defectQuantity": 0,
    "inspector": "INSP001",
    "inspectionDate": "2025-01-07T10:30:00Z"
  }
}
```

#### 2.3 追溯事件记录
```json
{
  "eventId": "evt-trace-recorded-001",
  "eventType": "trace.event.recorded",
  "version": "1.0",
  "timestamp": "2025-01-07T10:30:00Z",
  "source": "mes-backend",
  "tenantId": "TENANT001",
  "data": {
    "eventId": "evt-123456789",
    "entityType": "SN",
    "entityId": "SN-LOT-20250107-001-0001",
    "action": "COMPLETED",
    "occurredAt": "2025-01-07T10:30:00Z",
    "opId": "OP-005",
    "opName": "终测",
    "operatorId": "OP002",
    "result": "PASS",
    "stationId": "ST005",
    "shiftCode": "DAY",
    "data": {
      "testResults": {
        "voltage": "5.0V",
        "current": "0.5A",
        "temperature": "25°C"
      }
    }
  }
}
```

## Schema注册表

### 1. API Schema定义

#### 1.1 物料Schema
```json
{
  "name": "Item",
  "version": "1.0",
  "description": "物料信息Schema",
  "properties": {
    "itemId": {
      "type": "string",
      "pattern": "^ITM-\\d{6}-\\d{4}$",
      "description": "物料编码"
    },
    "itemCode": {
      "type": "string",
      "maxLength": 64,
      "description": "ERP物料编码"
    },
    "itemName": {
      "type": "string",
      "maxLength": 255,
      "description": "物料名称"
    },
    "itemType": {
      "type": "string",
      "enum": ["RAW", "COMPONENT", "FINISHED", "TOOL", "CONSUMABLE"],
      "description": "物料类型"
    },
    "uom": {
      "type": "string",
      "maxLength": 16,
      "description": "计量单位"
    },
    "status": {
      "type": "string",
      "enum": ["ACTIVE", "INACTIVE", "OBSOLETE"],
      "description": "状态"
    }
  },
  "required": ["itemId", "itemCode", "itemName", "itemType", "uom", "status"]
}
```

#### 1.2 工单Schema
```json
{
  "name": "WorkOrder",
  "version": "1.0",
  "description": "工单信息Schema",
  "properties": {
    "woId": {
      "type": "string",
      "pattern": "^WO-[A-Z0-9]+-\\d{4}$",
      "description": "工单号"
    },
    "woNo": {
      "type": "string",
      "maxLength": 64,
      "description": "工单编号"
    },
    "itemId": {
      "type": "string",
      "pattern": "^ITM-\\d{6}-\\d{4}$",
      "description": "生产物料ID"
    },
    "plannedQuantity": {
      "type": "number",
      "minimum": 0,
      "description": "计划数量"
    },
    "actualQuantity": {
      "type": "number",
      "minimum": 0,
      "description": "实际数量"
    },
    "status": {
      "type": "string",
      "enum": ["DRAFT", "RELEASED", "IN_PROGRESS", "COMPLETED", "CANCELLED", "ON_HOLD"],
      "description": "工单状态"
    },
    "priority": {
      "type": "string",
      "enum": ["LOW", "NORMAL", "HIGH", "URGENT"],
      "description": "优先级"
    }
  },
  "required": ["woId", "woNo", "itemId", "plannedQuantity", "status"]
}
```

### 2. 事件Schema定义

#### 2.1 基础事件Schema
```json
{
  "name": "BaseEvent",
  "version": "1.0",
  "description": "基础事件Schema",
  "properties": {
    "eventId": {
      "type": "string",
      "pattern": "^evt-[a-zA-Z0-9-]+$",
      "description": "事件ID"
    },
    "eventType": {
      "type": "string",
      "pattern": "^[a-z]+\\.[a-z_]+\\.[a-z]+$",
      "description": "事件类型"
    },
    "version": {
      "type": "string",
      "pattern": "^\\d+\\.\\d+$",
      "description": "事件版本"
    },
    "timestamp": {
      "type": "string",
      "format": "date-time",
      "description": "事件时间戳"
    },
    "source": {
      "type": "string",
      "description": "事件来源"
    },
    "tenantId": {
      "type": "string",
      "description": "租户ID"
    },
    "correlationId": {
      "type": "string",
      "description": "关联ID"
    }
  },
  "required": ["eventId", "eventType", "version", "timestamp", "source"]
}
```

### 3. 版本兼容性

#### 3.1 向后兼容规则
- 新增字段必须为可选
- 不能删除现有字段
- 不能修改现有字段类型
- 可以添加新的枚举值

#### 3.2 版本升级策略
```json
{
  "version": "1.1",
  "changes": [
    {
      "type": "add_field",
      "field": "newField",
      "description": "新增字段"
    },
    {
      "type": "add_enum_value",
      "field": "status",
      "value": "NEW_STATUS",
      "description": "新增状态值"
    }
  ],
  "compatibility": {
    "backward": true,
    "forward": false
  }
}
```

## 数据验证

### 1. 输入验证
```json
{
  "validation": {
    "required": ["itemId", "itemName"],
    "format": {
      "itemId": "^ITM-\\d{6}-\\d{4}$",
      "email": "^[\\w\\.-]+@[\\w\\.-]+\\.[a-zA-Z]{2,}$"
    },
    "range": {
      "quantity": {
        "min": 0,
        "max": 999999
      }
    },
    "length": {
      "itemName": {
        "max": 255
      }
    }
  }
}
```

### 2. 业务规则验证
```json
{
  "businessRules": [
    {
      "rule": "work_order_status_transition",
      "description": "工单状态转换规则",
      "allowedTransitions": {
        "DRAFT": ["RELEASED", "CANCELLED"],
        "RELEASED": ["IN_PROGRESS", "CANCELLED"],
        "IN_PROGRESS": ["COMPLETED", "ON_HOLD", "CANCELLED"],
        "ON_HOLD": ["IN_PROGRESS", "CANCELLED"],
        "COMPLETED": [],
        "CANCELLED": []
      }
    }
  ]
}
```

## 安全契约

### 1. 认证授权
```json
{
  "authentication": {
    "type": "JWT",
    "header": "Authorization",
    "format": "Bearer {token}",
    "expiration": 3600
  },
  "authorization": {
    "required": true,
    "scopes": ["read", "write", "admin"],
    "roles": ["user", "admin", "operator"]
  }
}
```

### 2. 数据脱敏
```json
{
  "dataMasking": {
    "sensitiveFields": [
      {
        "field": "phone",
        "mask": "***-****-{last4}"
      },
      {
        "field": "email",
        "mask": "{first2}***@{domain}"
      }
    ]
  }
}
```

## 监控契约

### 1. 健康检查
```http
GET /actuator/health
```

**响应数据**：
```json
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP",
      "details": {
        "database": "MySQL",
        "validationQuery": "isValid()"
      }
    },
    "redis": {
      "status": "UP",
      "details": {
        "version": "6.0.0"
      }
    }
  }
}
```

### 2. 指标监控
```http
GET /actuator/metrics
```

**响应数据**：
```json
{
  "names": [
    "http.server.requests",
    "jvm.memory.used",
    "jvm.gc.pause",
    "hikaricp.connections.active"
  ]
}
```
