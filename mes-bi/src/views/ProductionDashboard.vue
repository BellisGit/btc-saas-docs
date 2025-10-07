<template>
  <div class="production-dashboard">
    <!-- 头部标题 -->
    <div class="dashboard-header">
      <h1>MES生产监控大屏</h1>
      <div class="header-info">
        <span>最后更新: {{ lastUpdateTime }}</span>
        <span>数据刷新间隔: 30秒</span>
      </div>
    </div>

    <!-- 关键指标卡片 -->
    <div class="metrics-cards">
      <el-card class="metric-card">
        <div class="metric-content">
          <div class="metric-value">{{ metrics.totalProduction }}</div>
          <div class="metric-label">今日产量</div>
          <div class="metric-trend" :class="metrics.productionTrend > 0 ? 'up' : 'down'">
            <el-icon><ArrowUp v-if="metrics.productionTrend > 0" /><ArrowDown v-else /></el-icon>
            {{ Math.abs(metrics.productionTrend) }}%
          </div>
        </div>
      </el-card>

      <el-card class="metric-card">
        <div class="metric-content">
          <div class="metric-value">{{ metrics.yieldRate }}%</div>
          <div class="metric-label">良品率</div>
          <div class="metric-trend" :class="metrics.yieldTrend > 0 ? 'up' : 'down'">
            <el-icon><ArrowUp v-if="metrics.yieldTrend > 0" /><ArrowDown v-else /></el-icon>
            {{ Math.abs(metrics.yieldTrend) }}%
          </div>
        </div>
      </el-card>

      <el-card class="metric-card">
        <div class="metric-content">
          <div class="metric-value">{{ metrics.wipCount }}</div>
          <div class="metric-label">在制品数量</div>
          <div class="metric-trend" :class="metrics.wipTrend > 0 ? 'up' : 'down'">
            <el-icon><ArrowUp v-if="metrics.wipTrend > 0" /><ArrowDown v-else /></el-icon>
            {{ Math.abs(metrics.wipTrend) }}%
          </div>
        </div>
      </el-card>

      <el-card class="metric-card">
        <div class="metric-content">
          <div class="metric-value">{{ metrics.efficiency }}%</div>
          <div class="metric-label">设备效率</div>
          <div class="metric-trend" :class="metrics.efficiencyTrend > 0 ? 'up' : 'down'">
            <el-icon><ArrowUp v-if="metrics.efficiencyTrend > 0" /><ArrowDown v-else /></el-icon>
            {{ Math.abs(metrics.efficiencyTrend) }}%
          </div>
        </div>
      </el-card>
    </div>

    <!-- 图表区域 -->
    <div class="charts-container">
      <!-- 良率趋势图 -->
      <el-card class="chart-card">
        <template #header>
          <div class="card-header">
            <span>良率趋势</span>
            <el-select v-model="yieldTimeRange" size="small" style="width: 120px">
              <el-option label="1小时" value="1h" />
              <el-option label="4小时" value="4h" />
              <el-option label="24小时" value="24h" />
            </el-select>
          </div>
        </template>
        <v-chart :option="yieldChartOption" style="height: 300px" />
      </el-card>

      <!-- WIP状态分布 -->
      <el-card class="chart-card">
        <template #header>
          <div class="card-header">
            <span>WIP状态分布</span>
          </div>
        </template>
        <v-chart :option="wipChartOption" style="height: 300px" />
      </el-card>

      <!-- 生产进度 -->
      <el-card class="chart-card">
        <template #header>
          <div class="card-header">
            <span>生产进度</span>
          </div>
        </template>
        <v-chart :option="progressChartOption" style="height: 300px" />
      </el-card>

      <!-- 设备状态 -->
      <el-card class="chart-card">
        <template #header>
          <div class="card-header">
            <span>设备状态</span>
          </div>
        </template>
        <v-chart :option="equipmentChartOption" style="height: 300px" />
      </el-card>
    </div>

    <!-- 实时数据表格 -->
    <div class="table-container">
      <el-card>
        <template #header>
          <div class="card-header">
            <span>实时生产数据</span>
            <el-button type="primary" size="small" @click="refreshData">刷新数据</el-button>
          </div>
        </template>
        <el-table :data="realTimeData" style="width: 100%" height="300">
          <el-table-column prop="woId" label="工单号" width="120" />
          <el-table-column prop="itemName" label="产品名称" width="150" />
          <el-table-column prop="plannedQty" label="计划数量" width="100" />
          <el-table-column prop="actualQty" label="实际数量" width="100" />
          <el-table-column prop="progress" label="进度" width="120">
            <template #default="{ row }">
              <el-progress :percentage="row.progress" :color="getProgressColor(row.progress)" />
            </template>
          </el-table-column>
          <el-table-column prop="status" label="状态" width="100">
            <template #default="{ row }">
              <el-tag :type="getStatusType(row.status)">{{ row.status }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="yieldRate" label="良品率" width="100">
            <template #default="{ row }">
              <span :class="getYieldClass(row.yieldRate)">{{ row.yieldRate }}%</span>
            </template>
          </el-table-column>
          <el-table-column prop="updateTime" label="更新时间" width="150" />
        </el-table>
      </el-card>
    </div>

    <!-- 告警信息 -->
    <div class="alerts-container" v-if="alerts.length > 0">
      <el-card>
        <template #header>
          <div class="card-header">
            <span>系统告警</span>
            <el-badge :value="alerts.length" type="danger" />
          </div>
        </template>
        <el-timeline>
          <el-timeline-item
            v-for="alert in alerts"
            :key="alert.id"
            :timestamp="alert.timestamp"
            :type="alert.type"
          >
            <el-alert
              :title="alert.title"
              :description="alert.description"
              :type="alert.level"
              :closable="false"
            />
          </el-timeline-item>
        </el-timeline>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, onUnmounted, computed } from 'vue'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { LineChart, PieChart, BarChart, GaugeChart } from 'echarts/charts'
import {
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent
} from 'echarts/components'
import VChart from 'vue-echarts'
import { ArrowUp, ArrowDown } from '@element-plus/icons-vue'
import dayjs from 'dayjs'

// 注册ECharts组件
use([
  CanvasRenderer,
  LineChart,
  PieChart,
  BarChart,
  GaugeChart,
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent
])

// 响应式数据
const lastUpdateTime = ref(dayjs().format('HH:mm:ss'))
const yieldTimeRange = ref('4h')
const refreshTimer = ref(null)

// 关键指标数据
const metrics = reactive({
  totalProduction: 1250,
  productionTrend: 5.2,
  yieldRate: 96.8,
  yieldTrend: 1.2,
  wipCount: 156,
  wipTrend: -2.1,
  efficiency: 87.5,
  efficiencyTrend: 3.4
})

// 实时生产数据
const realTimeData = ref([
  {
    woId: 'WO-L1-0001',
    itemName: '验钞机',
    plannedQty: 1000,
    actualQty: 850,
    progress: 85,
    status: '进行中',
    yieldRate: 96.8,
    updateTime: '14:30:25'
  },
  {
    woId: 'WO-L2-0002',
    itemName: '钱箱',
    plannedQty: 500,
    actualQty: 500,
    progress: 100,
    status: '已完成',
    yieldRate: 98.2,
    updateTime: '14:25:10'
  },
  {
    woId: 'WO-L1-0003',
    itemName: '验钞机',
    plannedQty: 800,
    actualQty: 320,
    progress: 40,
    status: '进行中',
    yieldRate: 94.5,
    updateTime: '14:28:45'
  }
])

// 告警信息
const alerts = ref([
  {
    id: 1,
    title: '设备异常',
    description: 'L1产线设备E001出现异常，需要维护',
    level: 'warning',
    type: 'warning',
    timestamp: '14:25:30'
  },
  {
    id: 2,
    title: '良品率告警',
    description: 'L2产线良品率低于95%阈值',
    level: 'error',
    type: 'danger',
    timestamp: '14:20:15'
  }
])

// 良率趋势图配置
const yieldChartOption = computed(() => ({
  title: {
    text: '良率趋势',
    left: 'center',
    textStyle: { color: '#fff' }
  },
  tooltip: {
    trigger: 'axis',
    backgroundColor: 'rgba(0,0,0,0.8)',
    textStyle: { color: '#fff' }
  },
  xAxis: {
    type: 'category',
    data: ['10:00', '10:30', '11:00', '11:30', '12:00', '12:30', '13:00', '13:30', '14:00', '14:30'],
    axisLine: { lineStyle: { color: '#666' } },
    axisLabel: { color: '#999' }
  },
  yAxis: {
    type: 'value',
    min: 90,
    max: 100,
    axisLine: { lineStyle: { color: '#666' } },
    axisLabel: { color: '#999' },
    splitLine: { lineStyle: { color: '#333' } }
  },
  series: [{
    data: [96.2, 95.8, 96.5, 97.1, 96.8, 97.2, 96.9, 97.0, 96.8, 96.8],
    type: 'line',
    smooth: true,
    lineStyle: { color: '#00d4ff', width: 3 },
    itemStyle: { color: '#00d4ff' },
    areaStyle: {
      color: {
        type: 'linear',
        x: 0, y: 0, x2: 0, y2: 1,
        colorStops: [
          { offset: 0, color: 'rgba(0,212,255,0.3)' },
          { offset: 1, color: 'rgba(0,212,255,0.1)' }
        ]
      }
    }
  }]
}))

// WIP状态分布图配置
const wipChartOption = computed(() => ({
  title: {
    text: 'WIP状态分布',
    left: 'center',
    textStyle: { color: '#fff' }
  },
  tooltip: {
    trigger: 'item',
    backgroundColor: 'rgba(0,0,0,0.8)',
    textStyle: { color: '#fff' }
  },
  series: [{
    type: 'pie',
    radius: ['40%', '70%'],
    data: [
      { value: 45, name: '装配中', itemStyle: { color: '#00d4ff' } },
      { value: 32, name: '测试中', itemStyle: { color: '#ffd700' } },
      { value: 28, name: '包装中', itemStyle: { color: '#32cd32' } },
      { value: 25, name: '待投产', itemStyle: { color: '#ff6b6b' } },
      { value: 26, name: '返修中', itemStyle: { color: '#ff8c00' } }
    ],
    label: {
      color: '#fff',
      formatter: '{b}: {c}'
    }
  }]
}))

// 生产进度图配置
const progressChartOption = computed(() => ({
  title: {
    text: '生产进度',
    left: 'center',
    textStyle: { color: '#fff' }
  },
  tooltip: {
    trigger: 'axis',
    backgroundColor: 'rgba(0,0,0,0.8)',
    textStyle: { color: '#fff' }
  },
  xAxis: {
    type: 'category',
    data: ['验钞机', '钱箱', '配件A', '配件B'],
    axisLine: { lineStyle: { color: '#666' } },
    axisLabel: { color: '#999' }
  },
  yAxis: {
    type: 'value',
    max: 100,
    axisLine: { lineStyle: { color: '#666' } },
    axisLabel: { color: '#999' },
    splitLine: { lineStyle: { color: '#333' } }
  },
  series: [{
    data: [85, 100, 65, 78],
    type: 'bar',
    itemStyle: {
      color: {
        type: 'linear',
        x: 0, y: 0, x2: 0, y2: 1,
        colorStops: [
          { offset: 0, color: '#00d4ff' },
          { offset: 1, color: '#0099cc' }
        ]
      }
    }
  }]
}))

// 设备状态图配置
const equipmentChartOption = computed(() => ({
  title: {
    text: '设备状态',
    left: 'center',
    textStyle: { color: '#fff' }
  },
  series: [{
    type: 'gauge',
    center: ['50%', '60%'],
    startAngle: 200,
    endAngle: -20,
    min: 0,
    max: 100,
    splitNumber: 10,
    itemStyle: {
      color: '#00d4ff'
    },
    progress: {
      show: true,
      width: 18
    },
    pointer: {
      show: false
    },
    axisLine: {
      lineStyle: {
        width: 18
      }
    },
    axisTick: {
      distance: -30,
      splitNumber: 5,
      lineStyle: {
        width: 2,
        color: '#999'
      }
    },
    splitLine: {
      distance: -30,
      length: 30,
      lineStyle: {
        width: 4,
        color: '#999'
      }
    },
    axisLabel: {
      distance: -20,
      color: '#999',
      fontSize: 12
    },
    detail: {
      valueAnimation: true,
      formatter: '{value}%',
      color: '#fff',
      fontSize: 20
    },
    data: [{
      value: 87.5,
      name: '设备效率'
    }]
  }]
}))

// 方法
const refreshData = () => {
  lastUpdateTime.value = dayjs().format('HH:mm:ss')
  // 这里可以调用API刷新数据
  console.log('刷新数据')
}

const getProgressColor = (progress) => {
  if (progress >= 80) return '#67c23a'
  if (progress >= 60) return '#e6a23c'
  return '#f56c6c'
}

const getStatusType = (status) => {
  const statusMap = {
    '已完成': 'success',
    '进行中': 'primary',
    '暂停': 'warning',
    '异常': 'danger'
  }
  return statusMap[status] || 'info'
}

const getYieldClass = (yieldRate) => {
  if (yieldRate >= 95) return 'yield-good'
  if (yieldRate >= 90) return 'yield-warning'
  return 'yield-danger'
}

// 生命周期
onMounted(() => {
  // 启动定时刷新
  refreshTimer.value = setInterval(() => {
    refreshData()
  }, 30000) // 30秒刷新一次
})

onUnmounted(() => {
  if (refreshTimer.value) {
    clearInterval(refreshTimer.value)
  }
})
</script>

<style scoped>
.production-dashboard {
  padding: 20px;
  background: linear-gradient(135deg, #0c1426 0%, #1a2332 100%);
  min-height: 100vh;
  color: #fff;
}

.dashboard-header {
  text-align: center;
  margin-bottom: 30px;
}

.dashboard-header h1 {
  font-size: 2.5rem;
  margin: 0 0 10px 0;
  background: linear-gradient(45deg, #00d4ff, #0099cc);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.header-info {
  display: flex;
  justify-content: center;
  gap: 30px;
  color: #999;
  font-size: 14px;
}

.metrics-cards {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 30px;
}

.metric-card {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
}

.metric-content {
  text-align: center;
  padding: 20px;
}

.metric-value {
  font-size: 2.5rem;
  font-weight: bold;
  color: #00d4ff;
  margin-bottom: 10px;
}

.metric-label {
  font-size: 14px;
  color: #999;
  margin-bottom: 10px;
}

.metric-trend {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 5px;
  font-size: 12px;
}

.metric-trend.up {
  color: #67c23a;
}

.metric-trend.down {
  color: #f56c6c;
}

.charts-container {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
  margin-bottom: 30px;
}

.chart-card {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: #fff;
}

.table-container {
  margin-bottom: 30px;
}

.table-container .el-card {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
}

.alerts-container .el-card {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
}

.yield-good {
  color: #67c23a;
  font-weight: bold;
}

.yield-warning {
  color: #e6a23c;
  font-weight: bold;
}

.yield-danger {
  color: #f56c6c;
  font-weight: bold;
}

/* 响应式设计 */
@media (max-width: 1200px) {
  .metrics-cards {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .charts-container {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .metrics-cards {
    grid-template-columns: 1fr;
  }
  
  .dashboard-header h1 {
    font-size: 2rem;
  }
  
  .header-info {
    flex-direction: column;
    gap: 10px;
  }
}
</style>
