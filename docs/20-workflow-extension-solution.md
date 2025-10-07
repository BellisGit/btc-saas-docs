# MES系统动态流程扩展解决方案

## 📋 概述

本文档专门针对MES系统中的流程扩展需求，设计了一个支持动态添加流程节点、分支流程、流程树结构的完整解决方案。基于**流程树 + 节点元数据 + 状态机**的架构，实现流程的零停机扩展。该方案完全符合现有MES系统的主流程+多分支架构，保持与现有架构的完全兼容性。

## 🔍 流程扩展需求分析

### 1. 现有MES流程架构分析

#### 主流程结构（主干）
```
订单需求发起 → 资源准备 → 生产执行 → 物流仓储 → 品质与出货 → 数据追溯与分析 → 流程闭环归档
```

#### 分支流程结构（子流程）

##### IQC检验子流程
```
物料到货/建GRN → 创建IQC检验单 → AQL抽样与检测
    ↓
    ├── 合格 → 入库登记→可用库存 → 检验报告归档
    └── 不合格 → 不合格隔离 → 特采/退货/立NCR → 供应商评分联动
```

##### 生产+IPQC子流程
```
工单下发 → 备料交付生产 → 装配/组装 → 首件验证FAI
    ↓
    ├── 通过 → 批量生产 → IPQC巡检动态频次
    │   ↓
    │   ├── 合格 → 初测→终测→打包
    │   └── 不合格 → 暂停→返修分析次数上限
    └── 未通过 → 工艺参数调整→重测
```

### 2. 流程扩展场景

#### 主流程扩展
```
原始流程：
订单接收 → 生产计划 → 生产执行 → 质量检验 → 包装发货

扩展后流程：
订单接收 → 风险评估 → 生产计划 → 物料准备 → 生产执行 → 
首件检验 → 过程检验 → 质量检验 → 包装准备 → 包装发货 → 物流配送
```

#### 分支流程扩展
```
主流程：生产执行
├── 分支A：注塑流程
│   ├── 模具预热 → 注塑成型 → 冷却脱模 → 外观检验
├── 分支B：装配流程  
│   ├── 零件准备 → 装配作业 → 功能测试 → 最终检验
└── 分支C：包装流程（新增）
    ├── 包装设计 → 包装制作 → 包装测试 → 包装确认
```

#### 条件分支扩展
```
原始：if (产品类型 == "标准") → 标准流程
扩展：if (产品类型 == "标准") → 标准流程
     if (产品类型 == "定制") → 定制流程  
     if (产品类型 == "紧急") → 紧急流程
     if (客户要求 == "特殊包装") → 特殊包装流程
```

## 🏗️ 动态流程架构设计

### 1. 核心表结构设计

#### 流程定义表
```sql
-- 流程定义表（存储流程树结构）
CREATE TABLE workflow_definition (
    workflow_id VARCHAR(40) PRIMARY KEY COMMENT '流程ID',
    workflow_code VARCHAR(64) NOT NULL UNIQUE COMMENT '流程代码',
    workflow_name VARCHAR(128) NOT NULL COMMENT '流程名称',
    workflow_type ENUM('MAIN', 'SUB', 'BRANCH') NOT NULL COMMENT '流程类型',
    parent_workflow_id VARCHAR(40) COMMENT '父流程ID',
    workflow_level INT DEFAULT 1 COMMENT '流程层级',
    workflow_path VARCHAR(500) COMMENT '流程路径',
    workflow_config JSON COMMENT '流程配置',
    is_active TINYINT(1) DEFAULT 1 COMMENT '是否启用',
    version INT DEFAULT 1 COMMENT '版本号',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (parent_workflow_id) REFERENCES workflow_definition(workflow_id),
    INDEX idx_workflow_code (workflow_code),
    INDEX idx_parent_workflow (parent_workflow_id),
    INDEX idx_workflow_level (workflow_level),
    INDEX idx_tenant (tenant_id)
) COMMENT '流程定义表';

-- 节点定义表（存储流程节点信息）
CREATE TABLE workflow_node_definition (
    node_id VARCHAR(40) PRIMARY KEY COMMENT '节点ID',
    node_code VARCHAR(64) NOT NULL COMMENT '节点代码',
    node_name VARCHAR(128) NOT NULL COMMENT '节点名称',
    workflow_id VARCHAR(40) NOT NULL COMMENT '所属流程ID',
    node_type ENUM('START', 'PROCESS', 'DECISION', 'PARALLEL', 'MERGE', 'END') NOT NULL COMMENT '节点类型',
    node_config JSON COMMENT '节点配置',
    position_x INT DEFAULT 0 COMMENT 'X坐标',
    position_y INT DEFAULT 0 COMMENT 'Y坐标',
    sort_order INT DEFAULT 0 COMMENT '排序',
    is_active TINYINT(1) DEFAULT 1 COMMENT '是否启用',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (workflow_id) REFERENCES workflow_definition(workflow_id),
    UNIQUE KEY uk_node_code_workflow (node_code, workflow_id),
    INDEX idx_workflow_id (workflow_id),
    INDEX idx_node_type (node_type),
    INDEX idx_tenant (tenant_id)
) COMMENT '节点定义表';

-- 节点连接表（存储节点间的关系）
CREATE TABLE workflow_node_connection (
    connection_id VARCHAR(40) PRIMARY KEY COMMENT '连接ID',
    from_node_id VARCHAR(40) NOT NULL COMMENT '源节点ID',
    to_node_id VARCHAR(40) NOT NULL COMMENT '目标节点ID',
    workflow_id VARCHAR(40) NOT NULL COMMENT '所属流程ID',
    connection_type ENUM('SEQUENCE', 'CONDITION', 'PARALLEL', 'MERGE') DEFAULT 'SEQUENCE' COMMENT '连接类型',
    condition_expression TEXT COMMENT '条件表达式',
    connection_config JSON COMMENT '连接配置',
    is_active TINYINT(1) DEFAULT 1 COMMENT '是否启用',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (from_node_id) REFERENCES workflow_node_definition(node_id),
    FOREIGN KEY (to_node_id) REFERENCES workflow_node_definition(node_id),
    FOREIGN KEY (workflow_id) REFERENCES workflow_definition(workflow_id),
    INDEX idx_from_node (from_node_id),
    INDEX idx_to_node (to_node_id),
    INDEX idx_workflow_id (workflow_id),
    INDEX idx_tenant (tenant_id)
) COMMENT '节点连接表';
```

#### MES特定流程表结构
```sql
-- 主流程定义表
CREATE TABLE mes_main_workflow (
    workflow_id VARCHAR(32) PRIMARY KEY,
    workflow_code VARCHAR(64) NOT NULL UNIQUE COMMENT '主流程代码',
    workflow_name VARCHAR(128) NOT NULL COMMENT '主流程名称',
    workflow_order INT DEFAULT 1 COMMENT '流程顺序',
    workflow_config JSON COMMENT '流程配置',
    is_active TINYINT(1) DEFAULT 1,
    tenant_id VARCHAR(32),
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_workflow_code (workflow_code),
    INDEX idx_workflow_order (workflow_order),
    INDEX idx_tenant (tenant_id)
) COMMENT 'MES主流程定义表';

-- 分支流程定义表
CREATE TABLE mes_sub_workflow (
    sub_workflow_id VARCHAR(32) PRIMARY KEY,
    sub_workflow_code VARCHAR(64) NOT NULL COMMENT '分支流程代码',
    sub_workflow_name VARCHAR(128) NOT NULL COMMENT '分支流程名称',
    parent_workflow_id VARCHAR(32) NOT NULL COMMENT '所属主流程ID',
    entry_condition JSON COMMENT '进入条件',
    exit_condition JSON COMMENT '退出条件',
    sub_workflow_config JSON COMMENT '分支流程配置',
    is_active TINYINT(1) DEFAULT 1,
    tenant_id VARCHAR(32),
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (parent_workflow_id) REFERENCES mes_main_workflow(workflow_id),
    INDEX idx_parent_workflow (parent_workflow_id),
    INDEX idx_sub_workflow_code (sub_workflow_code),
    INDEX idx_tenant (tenant_id)
) COMMENT 'MES分支流程定义表';

-- 流程节点定义表
CREATE TABLE mes_workflow_node (
    node_id VARCHAR(32) PRIMARY KEY,
    node_code VARCHAR(64) NOT NULL COMMENT '节点代码',
    node_name VARCHAR(128) NOT NULL COMMENT '节点名称',
    workflow_id VARCHAR(32) COMMENT '所属主流程ID',
    sub_workflow_id VARCHAR(32) COMMENT '所属分支流程ID',
    node_type ENUM('START', 'PROCESS', 'DECISION', 'PARALLEL', 'MERGE', 'END') NOT NULL COMMENT '节点类型',
    processor_class VARCHAR(255) COMMENT '处理器类名',
    node_config JSON COMMENT '节点配置',
    position_x INT DEFAULT 0 COMMENT 'X坐标',
    position_y INT DEFAULT 0 COMMENT 'Y坐标',
    sort_order INT DEFAULT 0 COMMENT '排序',
    is_active TINYINT(1) DEFAULT 1,
    tenant_id VARCHAR(32),
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (workflow_id) REFERENCES mes_main_workflow(workflow_id),
    FOREIGN KEY (sub_workflow_id) REFERENCES mes_sub_workflow(sub_workflow_id),
    INDEX idx_workflow_id (workflow_id),
    INDEX idx_sub_workflow_id (sub_workflow_id),
    INDEX idx_node_type (node_type),
    INDEX idx_tenant (tenant_id)
) COMMENT 'MES流程节点定义表';

-- 流程节点连接表
CREATE TABLE mes_node_connection (
    connection_id VARCHAR(32) PRIMARY KEY,
    from_node_id VARCHAR(32) NOT NULL COMMENT '源节点ID',
    to_node_id VARCHAR(32) NOT NULL COMMENT '目标节点ID',
    connection_type ENUM('SEQUENCE', 'CONDITION', 'PARALLEL', 'MERGE') DEFAULT 'SEQUENCE' COMMENT '连接类型',
    condition_expression TEXT COMMENT '条件表达式',
    connection_config JSON COMMENT '连接配置',
    is_active TINYINT(1) DEFAULT 1,
    tenant_id VARCHAR(32),
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (from_node_id) REFERENCES mes_workflow_node(node_id),
    FOREIGN KEY (to_node_id) REFERENCES mes_workflow_node(node_id),
    INDEX idx_from_node (from_node_id),
    INDEX idx_to_node (to_node_id),
    INDEX idx_tenant (tenant_id)
) COMMENT 'MES节点连接表';
```

#### 流程实例和执行表
```sql
-- 流程实例表
CREATE TABLE workflow_instance (
    instance_id VARCHAR(40) PRIMARY KEY COMMENT '实例ID',
    workflow_id VARCHAR(40) NOT NULL COMMENT '流程ID',
    instance_name VARCHAR(128) COMMENT '实例名称',
    instance_status ENUM('RUNNING', 'COMPLETED', 'FAILED', 'CANCELLED', 'SUSPENDED') DEFAULT 'RUNNING' COMMENT '实例状态',
    start_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '开始时间',
    end_time DATETIME COMMENT '结束时间',
    context_data JSON COMMENT '上下文数据',
    current_node_id VARCHAR(40) COMMENT '当前节点ID',
    parent_instance_id VARCHAR(40) COMMENT '父实例ID',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (workflow_id) REFERENCES workflow_definition(workflow_id),
    FOREIGN KEY (current_node_id) REFERENCES workflow_node_definition(node_id),
    FOREIGN KEY (parent_instance_id) REFERENCES workflow_instance(instance_id),
    INDEX idx_workflow_id (workflow_id),
    INDEX idx_instance_status (instance_status),
    INDEX idx_current_node (current_node_id),
    INDEX idx_tenant (tenant_id)
) COMMENT '流程实例表';

-- 节点执行记录表
CREATE TABLE workflow_node_execution (
    execution_id VARCHAR(40) PRIMARY KEY COMMENT '执行ID',
    instance_id VARCHAR(40) NOT NULL COMMENT '实例ID',
    node_id VARCHAR(40) NOT NULL COMMENT '节点ID',
    execution_status ENUM('PENDING', 'RUNNING', 'COMPLETED', 'FAILED', 'SKIPPED') DEFAULT 'PENDING' COMMENT '执行状态',
    start_time DATETIME COMMENT '开始时间',
    end_time DATETIME COMMENT '结束时间',
    execution_result JSON COMMENT '执行结果',
    error_message TEXT COMMENT '错误信息',
    retry_count INT DEFAULT 0 COMMENT '重试次数',
    assigned_user VARCHAR(64) COMMENT '分配用户',
    tenant_id VARCHAR(32) COMMENT '租户ID',
    created_by VARCHAR(64) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(64),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (instance_id) REFERENCES workflow_instance(instance_id),
    FOREIGN KEY (node_id) REFERENCES workflow_node_definition(node_id),
    INDEX idx_instance_id (instance_id),
    INDEX idx_node_id (node_id),
    INDEX idx_execution_status (execution_status),
    INDEX idx_assigned_user (assigned_user),
    INDEX idx_tenant (tenant_id)
) COMMENT '节点执行记录表';
```

### 2. 流程引擎设计

#### 流程引擎核心类
```java
@Service
public class WorkflowEngine {
    
    @Autowired
    private WorkflowDefinitionRepository workflowDefinitionRepository;
    
    @Autowired
    private WorkflowNodeDefinitionRepository nodeDefinitionRepository;
    
    @Autowired
    private WorkflowNodeConnectionRepository connectionRepository;
    
    @Autowired
    private WorkflowInstanceRepository instanceRepository;
    
    @Autowired
    private WorkflowNodeExecutionRepository executionRepository;
    
    /**
     * 启动流程实例
     */
    public WorkflowInstance startWorkflow(String workflowId, Map<String, Object> contextData) {
        // 1. 获取流程定义
        WorkflowDefinition workflow = workflowDefinitionRepository.findById(workflowId)
            .orElseThrow(() -> new WorkflowException("流程不存在"));
        
        // 2. 创建流程实例
        WorkflowInstance instance = new WorkflowInstance();
        instance.setInstanceId(UUID.randomUUID().toString());
        instance.setWorkflowId(workflowId);
        instance.setInstanceStatus(WorkflowStatus.RUNNING);
        instance.setContextData(contextData);
        
        // 3. 找到开始节点
        WorkflowNodeDefinition startNode = nodeDefinitionRepository
            .findByWorkflowIdAndNodeType(workflowId, NodeType.START)
            .stream()
            .findFirst()
            .orElseThrow(() -> new WorkflowException("流程没有开始节点"));
        
        instance.setCurrentNodeId(startNode.getNodeId());
        instanceRepository.save(instance);
        
        // 4. 执行开始节点
        executeNode(instance, startNode);
        
        return instance;
    }
    
    /**
     * 执行节点
     */
    public void executeNode(WorkflowInstance instance, WorkflowNodeDefinition node) {
        try {
            // 1. 创建执行记录
            WorkflowNodeExecution execution = new WorkflowNodeExecution();
            execution.setExecutionId(UUID.randomUUID().toString());
            execution.setInstanceId(instance.getInstanceId());
            execution.setNodeId(node.getNodeId());
            execution.setExecutionStatus(ExecutionStatus.RUNNING);
            execution.setStartTime(LocalDateTime.now());
            executionRepository.save(execution);
            
            // 2. 执行节点处理器
            NodeProcessor processor = getNodeProcessor(node);
            ExecutionResult result = processor.execute(instance, node);
            
            // 3. 更新执行记录
            execution.setExecutionStatus(ExecutionStatus.COMPLETED);
            execution.setEndTime(LocalDateTime.now());
            execution.setExecutionResult(result.getData());
            executionRepository.save(execution);
            
            // 4. 查找下一个节点
            List<WorkflowNodeConnection> connections = connectionRepository
                .findByFromNodeIdAndIsActive(node.getNodeId(), true);
            
            for (WorkflowNodeConnection connection : connections) {
                if (evaluateCondition(connection, instance.getContextData())) {
                    WorkflowNodeDefinition nextNode = nodeDefinitionRepository
                        .findById(connection.getToNodeId())
                        .orElseThrow(() -> new WorkflowException("目标节点不存在"));
                    
                    // 5. 更新当前节点
                    instance.setCurrentNodeId(nextNode.getNodeId());
                    instanceRepository.save(instance);
                    
                    // 6. 递归执行下一个节点
                    executeNode(instance, nextNode);
                    break;
                }
            }
            
            // 7. 检查是否到达结束节点
            if (node.getNodeType() == NodeType.END) {
                completeWorkflow(instance);
            }
            
        } catch (Exception e) {
            // 处理执行异常
            handleNodeExecutionError(instance, node, e);
        }
    }
    
    /**
     * 完成流程
     */
    private void completeWorkflow(WorkflowInstance instance) {
        instance.setInstanceStatus(WorkflowStatus.COMPLETED);
        instance.setEndTime(LocalDateTime.now());
        instanceRepository.save(instance);
    }
    
    /**
     * 获取节点处理器
     */
    private NodeProcessor getNodeProcessor(WorkflowNodeDefinition node) {
        String processorClass = node.getNodeConfig().getString("processorClass");
        return applicationContext.getBean(processorClass, NodeProcessor.class);
    }
    
    /**
     * 评估连接条件
     */
    private boolean evaluateCondition(WorkflowNodeConnection connection, Map<String, Object> contextData) {
        if (connection.getConnectionType() == ConnectionType.SEQUENCE) {
            return true;
        }
        
        String expression = connection.getConditionExpression();
        if (StringUtils.isEmpty(expression)) {
            return true;
        }
        
        // 使用表达式引擎评估条件
        return expressionEvaluator.evaluate(expression, contextData);
    }
}
```

#### 节点处理器接口
```java
public interface NodeProcessor {
    
    /**
     * 执行节点逻辑
     */
    ExecutionResult execute(WorkflowInstance instance, WorkflowNodeDefinition node);
    
    /**
     * 获取处理器类型
     */
    NodeType getSupportedNodeType();
    
    /**
     * 获取处理器名称
     */
    String getProcessorName();
}

@Component
public class StartNodeProcessor implements NodeProcessor {
    
    @Override
    public ExecutionResult execute(WorkflowInstance instance, WorkflowNodeDefinition node) {
        // 开始节点逻辑
        Map<String, Object> result = new HashMap<>();
        result.put("message", "流程开始执行");
        result.put("timestamp", LocalDateTime.now());
        
        return ExecutionResult.success(result);
    }
    
    @Override
    public NodeType getSupportedNodeType() {
        return NodeType.START;
    }
    
    @Override
    public String getProcessorName() {
        return "StartNodeProcessor";
    }
}

@Component
public class ProcessNodeProcessor implements NodeProcessor {
    
    @Override
    public ExecutionResult execute(WorkflowInstance instance, WorkflowNodeDefinition node) {
        // 处理节点逻辑
        Map<String, Object> contextData = instance.getContextData();
        Map<String, Object> nodeConfig = node.getNodeConfig();
        
        // 执行具体的业务逻辑
        String businessService = nodeConfig.getString("businessService");
        String businessMethod = nodeConfig.getString("businessMethod");
        
        // 调用业务服务
        Object result = businessServiceInvoker.invoke(businessService, businessMethod, contextData);
        
        return ExecutionResult.success(result);
    }
    
    @Override
    public NodeType getSupportedNodeType() {
        return NodeType.PROCESS;
    }
    
    @Override
    public String getProcessorName() {
        return "ProcessNodeProcessor";
    }
}
```

### 3. 流程扩展机制

#### 动态添加节点
```java
@Service
public class WorkflowExtensionService {
    
    /**
     * 添加新节点到现有流程
     */
    public WorkflowNodeDefinition addNodeToWorkflow(String workflowId, NodeDefinitionRequest request) {
        // 1. 验证流程是否存在
        WorkflowDefinition workflow = workflowDefinitionRepository.findById(workflowId)
            .orElseThrow(() -> new WorkflowException("流程不存在"));
        
        // 2. 创建新节点
        WorkflowNodeDefinition newNode = new WorkflowNodeDefinition();
        newNode.setNodeId(UUID.randomUUID().toString());
        newNode.setNodeCode(request.getNodeCode());
        newNode.setNodeName(request.getNodeName());
        newNode.setWorkflowId(workflowId);
        newNode.setNodeType(request.getNodeType());
        newNode.setNodeConfig(request.getNodeConfig());
        newNode.setSortOrder(request.getSortOrder());
        newNode.setIsActive(true);
        
        nodeDefinitionRepository.save(newNode);
        
        // 3. 建立节点连接
        if (request.getFromNodeId() != null) {
            WorkflowNodeConnection connection = new WorkflowNodeConnection();
            connection.setConnectionId(UUID.randomUUID().toString());
            connection.setFromNodeId(request.getFromNodeId());
            connection.setToNodeId(newNode.getNodeId());
            connection.setWorkflowId(workflowId);
            connection.setConnectionType(ConnectionType.SEQUENCE);
            connection.setIsActive(true);
            
            connectionRepository.save(connection);
        }
        
        if (request.getToNodeId() != null) {
            WorkflowNodeConnection connection = new WorkflowNodeConnection();
            connection.setConnectionId(UUID.randomUUID().toString());
            connection.setFromNodeId(newNode.getNodeId());
            connection.setToNodeId(request.getToNodeId());
            connection.setWorkflowId(workflowId);
            connection.setConnectionType(ConnectionType.SEQUENCE);
            connection.setIsActive(true);
            
            connectionRepository.save(connection);
        }
        
        return newNode;
    }
    
    /**
     * 添加分支流程
     */
    public WorkflowDefinition addBranchWorkflow(String parentWorkflowId, WorkflowDefinitionRequest request) {
        // 1. 创建分支流程
        WorkflowDefinition branchWorkflow = new WorkflowDefinition();
        branchWorkflow.setWorkflowId(UUID.randomUUID().toString());
        branchWorkflow.setWorkflowCode(request.getWorkflowCode());
        branchWorkflow.setWorkflowName(request.getWorkflowName());
        branchWorkflow.setWorkflowType(WorkflowType.BRANCH);
        branchWorkflow.setParentWorkflowId(parentWorkflowId);
        branchWorkflow.setWorkflowLevel(getWorkflowLevel(parentWorkflowId) + 1);
        branchWorkflow.setWorkflowConfig(request.getWorkflowConfig());
        branchWorkflow.setIsActive(true);
        
        workflowDefinitionRepository.save(branchWorkflow);
        
        // 2. 创建分支流程的节点
        for (NodeDefinitionRequest nodeRequest : request.getNodes()) {
            addNodeToWorkflow(branchWorkflow.getWorkflowId(), nodeRequest);
        }
        
        return branchWorkflow;
    }
    
    /**
     * 动态修改节点连接
     */
    public void modifyNodeConnection(String connectionId, ConnectionModificationRequest request) {
        WorkflowNodeConnection connection = connectionRepository.findById(connectionId)
            .orElseThrow(() -> new WorkflowException("连接不存在"));
        
        // 更新连接配置
        if (request.getConditionExpression() != null) {
            connection.setConditionExpression(request.getConditionExpression());
        }
        
        if (request.getConnectionType() != null) {
            connection.setConnectionType(request.getConnectionType());
        }
        
        connectionRepository.save(connection);
    }
}
```

### 4. 流程可视化设计器

#### 前端流程设计器组件
```vue
<template>
  <div class="workflow-designer">
    <div class="toolbar">
      <el-button @click="addNode('START')">添加开始节点</el-button>
      <el-button @click="addNode('PROCESS')">添加处理节点</el-button>
      <el-button @click="addNode('DECISION')">添加决策节点</el-button>
      <el-button @click="addNode('END')">添加结束节点</el-button>
      <el-button @click="saveWorkflow">保存流程</el-button>
    </div>
    
    <div class="canvas" ref="canvas">
      <div
        v-for="node in nodes"
        :key="node.nodeId"
        class="workflow-node"
        :class="node.nodeType.toLowerCase()"
        :style="{ left: node.positionX + 'px', top: node.positionY + 'px' }"
        @mousedown="startDrag(node, $event)"
        @click="selectNode(node)"
      >
        <div class="node-header">{{ node.nodeName }}</div>
        <div class="node-content">{{ node.nodeCode }}</div>
        <div class="node-handles">
          <div class="handle handle-top" @click="addConnection(node, 'top')"></div>
          <div class="handle handle-bottom" @click="addConnection(node, 'bottom')"></div>
          <div class="handle handle-left" @click="addConnection(node, 'left')"></div>
          <div class="handle handle-right" @click="addConnection(node, 'right')"></div>
        </div>
      </div>
      
      <svg class="connections">
        <path
          v-for="connection in connections"
          :key="connection.connectionId"
          :d="getConnectionPath(connection)"
          :class="connection.connectionType.toLowerCase()"
          @click="selectConnection(connection)"
        />
      </svg>
    </div>
    
    <div class="properties-panel" v-if="selectedNode">
      <h3>节点属性</h3>
      <el-form :model="selectedNode" label-width="100px">
        <el-form-item label="节点名称">
          <el-input v-model="selectedNode.nodeName" />
        </el-form-item>
        <el-form-item label="节点代码">
          <el-input v-model="selectedNode.nodeCode" />
        </el-form-item>
        <el-form-item label="节点类型">
          <el-select v-model="selectedNode.nodeType">
            <el-option label="开始节点" value="START" />
            <el-option label="处理节点" value="PROCESS" />
            <el-option label="决策节点" value="DECISION" />
            <el-option label="并行节点" value="PARALLEL" />
            <el-option label="合并节点" value="MERGE" />
            <el-option label="结束节点" value="END" />
          </el-select>
        </el-form-item>
        <el-form-item label="处理器类">
          <el-input v-model="selectedNode.nodeConfig.processorClass" />
        </el-form-item>
        <el-form-item label="配置参数">
          <el-input
            type="textarea"
            v-model="selectedNode.nodeConfigJson"
            :rows="4"
          />
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script>
export default {
  name: 'WorkflowDesigner',
  data() {
    return {
      nodes: [],
      connections: [],
      selectedNode: null,
      selectedConnection: null,
      dragging: false,
      dragOffset: { x: 0, y: 0 }
    }
  },
  methods: {
    addNode(nodeType) {
      const node = {
        nodeId: this.generateId(),
        nodeCode: `${nodeType}_${Date.now()}`,
        nodeName: this.getDefaultNodeName(nodeType),
        nodeType: nodeType,
        positionX: 100 + Math.random() * 200,
        positionY: 100 + Math.random() * 200,
        nodeConfig: {
          processorClass: this.getDefaultProcessorClass(nodeType)
        }
      }
      
      this.nodes.push(node)
      this.selectNode(node)
    },
    
    addConnection(fromNode, direction) {
      // 连接逻辑
      this.$message.info('点击目标节点完成连接')
    },
    
    saveWorkflow() {
      const workflowData = {
        nodes: this.nodes,
        connections: this.connections
      }
      
      this.$http.post('/api/workflow/save', workflowData)
        .then(response => {
          this.$message.success('流程保存成功')
        })
        .catch(error => {
          this.$message.error('流程保存失败')
        })
    },
    
    getConnectionPath(connection) {
      const fromNode = this.nodes.find(n => n.nodeId === connection.fromNodeId)
      const toNode = this.nodes.find(n => n.nodeId === connection.toNodeId)
      
      if (!fromNode || !toNode) return ''
      
      const startX = fromNode.positionX + 50
      const startY = fromNode.positionY + 25
      const endX = toNode.positionX + 50
      const endY = toNode.positionY + 25
      
      return `M ${startX} ${startY} L ${endX} ${endY}`
    }
  }
}
</script>
```

## 🔧 流程扩展最佳实践

### 1. 节点设计原则

#### 节点类型设计
- **START节点**：流程入口，只能有一个
- **PROCESS节点**：业务处理逻辑
- **DECISION节点**：条件判断分支
- **PARALLEL节点**：并行执行分支
- **MERGE节点**：并行结果合并
- **END节点**：流程结束，可以有多个

#### 节点配置规范
```json
{
  "processorClass": "com.btc.mes.workflow.processor.ProductionProcessor",
  "businessService": "productionService",
  "businessMethod": "executeProduction",
  "timeout": 30000,
  "retryCount": 3,
  "conditionExpression": "productType == 'STANDARD'",
  "parallelConfig": {
    "maxConcurrent": 5,
    "waitForAll": true
  }
}
```

### 2. 流程版本管理

#### 版本控制策略
```java
@Service
public class WorkflowVersionService {
    
    /**
     * 创建流程版本
     */
    public WorkflowVersion createVersion(String workflowId, String versionName) {
        // 1. 获取当前流程定义
        WorkflowDefinition currentWorkflow = workflowDefinitionRepository.findById(workflowId)
            .orElseThrow(() -> new WorkflowException("流程不存在"));
        
        // 2. 创建新版本
        WorkflowVersion newVersion = new WorkflowVersion();
        newVersion.setVersionId(UUID.randomUUID().toString());
        newVersion.setWorkflowId(workflowId);
        newVersion.setVersionName(versionName);
        newVersion.setVersionNumber(getNextVersionNumber(workflowId));
        newVersion.setIsActive(false);
        
        // 3. 复制流程定义
        copyWorkflowDefinition(currentWorkflow, newVersion);
        
        return workflowVersionRepository.save(newVersion);
    }
    
    /**
     * 发布流程版本
     */
    public void publishVersion(String versionId) {
        WorkflowVersion version = workflowVersionRepository.findById(versionId)
            .orElseThrow(() -> new WorkflowException("版本不存在"));
        
        // 1. 停用当前版本
        deactivateCurrentVersion(version.getWorkflowId());
        
        // 2. 激活新版本
        version.setIsActive(true);
        version.setPublishedAt(LocalDateTime.now());
        workflowVersionRepository.save(version);
        
        // 3. 更新流程定义
        updateWorkflowDefinition(version);
    }
}
```

### 3. 流程监控和分析

#### 流程性能监控
```java
@Component
public class WorkflowMonitor {
    
    /**
     * 监控流程执行性能
     */
    @EventListener
    public void handleNodeExecution(NodeExecutionEvent event) {
        // 记录执行时间
        long executionTime = event.getEndTime() - event.getStartTime();
        
        // 更新性能统计
        updatePerformanceStats(event.getNodeId(), executionTime);
        
        // 检查性能阈值
        if (executionTime > getPerformanceThreshold(event.getNodeId())) {
            // 发送告警
            sendPerformanceAlert(event.getNodeId(), executionTime);
        }
    }
    
    /**
     * 生成流程分析报告
     */
    public WorkflowAnalysisReport generateAnalysisReport(String workflowId, LocalDateTime startTime, LocalDateTime endTime) {
        // 1. 获取执行统计数据
        List<WorkflowInstance> instances = instanceRepository
            .findByWorkflowIdAndStartTimeBetween(workflowId, startTime, endTime);
        
        // 2. 计算关键指标
        long totalInstances = instances.size();
        long completedInstances = instances.stream()
            .mapToLong(i -> i.getInstanceStatus() == WorkflowStatus.COMPLETED ? 1 : 0)
            .sum();
        long failedInstances = instances.stream()
            .mapToLong(i -> i.getInstanceStatus() == WorkflowStatus.FAILED ? 1 : 0)
            .sum();
        
        double successRate = (double) completedInstances / totalInstances * 100;
        double failureRate = (double) failedInstances / totalInstances * 100;
        
        // 3. 计算平均执行时间
        double avgExecutionTime = instances.stream()
            .filter(i -> i.getEndTime() != null)
            .mapToLong(i -> Duration.between(i.getStartTime(), i.getEndTime()).toMinutes())
            .average()
            .orElse(0.0);
        
        // 4. 生成报告
        return WorkflowAnalysisReport.builder()
            .workflowId(workflowId)
            .startTime(startTime)
            .endTime(endTime)
            .totalInstances(totalInstances)
            .completedInstances(completedInstances)
            .failedInstances(failedInstances)
            .successRate(successRate)
            .failureRate(failureRate)
            .avgExecutionTime(avgExecutionTime)
            .build();
    }
}
```

## 📊 总结

### 方案特点

1. **完全动态**：支持运行时添加节点、修改连接、创建分支
2. **零停机扩展**：无需重启系统即可扩展流程
3. **可视化设计**：提供直观的流程设计器
4. **版本管理**：支持流程版本控制和回滚
5. **性能监控**：完整的流程执行监控和分析
6. **MES集成**：完全兼容现有MES系统架构

### 适用场景

- 需要频繁调整业务流程的MES系统
- 多客户定制化需求较多的系统
- 需要可视化流程设计的系统
- 对流程执行性能有要求的系统

### 实施建议

1. **分阶段实施**：先实现核心功能，再逐步添加高级特性
2. **性能优化**：合理设计索引，优化查询性能
3. **监控告警**：建立完善的监控和告警机制
4. **用户培训**：提供流程设计器使用培训
5. **文档完善**：建立完整的流程设计规范文档

通过这个动态流程扩展解决方案，MES系统可以灵活应对各种业务变化，实现真正的"乐高积木式"流程管理。
