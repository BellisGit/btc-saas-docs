<template>
  <view class="container">
    <!-- 头部信息 -->
    <view class="header">
      <view class="user-info">
        <image class="avatar" :src="userInfo.avatar" mode="aspectFill"></image>
        <view class="user-details">
          <text class="username">{{ userInfo.name }}</text>
          <text class="company">{{ userInfo.company }}</text>
        </view>
      </view>
      <view class="notification" @click="goToNotifications">
        <u-icon name="bell" size="24" color="#666"></u-icon>
        <u-badge :value="notificationCount" :max="99" type="error"></u-badge>
      </view>
    </view>

    <!-- 功能菜单 -->
    <view class="menu-grid">
      <view class="menu-item" @click="goToMoldStatus">
        <view class="menu-icon">
          <u-icon name="setting" size="32" color="#007AFF"></u-icon>
        </view>
        <text class="menu-title">模具状态</text>
        <text class="menu-desc">查看模具运行状态</text>
      </view>

      <view class="menu-item" @click="goToDelivery">
        <view class="menu-icon">
          <u-icon name="car" size="32" color="#34C759"></u-icon>
        </view>
        <text class="menu-title">发货管理</text>
        <text class="menu-desc">管理发货订单</text>
      </view>

      <view class="menu-item" @click="goToQuality">
        <view class="menu-icon">
          <u-icon name="checkmark-circle" size="32" color="#FF9500"></u-icon>
        </view>
        <text class="menu-title">质检协同</text>
        <text class="menu-desc">IQC检验协同</text>
      </view>

      <view class="menu-item" @click="goToInventory">
        <view class="menu-icon">
          <u-icon name="grid" size="32" color="#AF52DE"></u-icon>
        </view>
        <text class="menu-title">库存查询</text>
        <text class="menu-desc">查看库存信息</text>
      </view>
    </view>

    <!-- 待办事项 -->
    <view class="todo-section">
      <view class="section-header">
        <text class="section-title">待办事项</text>
        <text class="more-btn" @click="goToTodoList">更多</text>
      </view>
      <view class="todo-list">
        <view class="todo-item" v-for="item in todoList" :key="item.id" @click="handleTodo(item)">
          <view class="todo-icon" :class="item.type">
            <u-icon :name="item.icon" size="20" color="#fff"></u-icon>
          </view>
          <view class="todo-content">
            <text class="todo-title">{{ item.title }}</text>
            <text class="todo-desc">{{ item.description }}</text>
            <text class="todo-time">{{ item.time }}</text>
          </view>
          <view class="todo-badge" v-if="item.count > 0">
            <u-badge :value="item.count" :max="99" type="error"></u-badge>
          </view>
        </view>
      </view>
    </view>

    <!-- 数据统计 -->
    <view class="stats-section">
      <view class="section-header">
        <text class="section-title">数据统计</text>
      </view>
      <view class="stats-grid">
        <view class="stat-item">
          <text class="stat-value">{{ stats.deliveryCount }}</text>
          <text class="stat-label">本月发货</text>
        </view>
        <view class="stat-item">
          <text class="stat-value">{{ stats.qualityRate }}%</text>
          <text class="stat-label">质量通过率</text>
        </view>
        <view class="stat-item">
          <text class="stat-value">{{ stats.onTimeRate }}%</text>
          <text class="stat-label">准时交货率</text>
        </view>
        <view class="stat-item">
          <text class="stat-value">{{ stats.rating }}</text>
          <text class="stat-label">综合评分</text>
        </view>
      </view>
    </view>

    <!-- 最新消息 -->
    <view class="news-section">
      <view class="section-header">
        <text class="section-title">最新消息</text>
        <text class="more-btn" @click="goToNewsList">更多</text>
      </view>
      <view class="news-list">
        <view class="news-item" v-for="item in newsList" :key="item.id" @click="goToNewsDetail(item)">
          <view class="news-icon" :class="item.type">
            <u-icon :name="item.icon" size="16" color="#fff"></u-icon>
          </view>
          <view class="news-content">
            <text class="news-title">{{ item.title }}</text>
            <text class="news-time">{{ item.time }}</text>
          </view>
          <view class="news-status" v-if="!item.read">
            <u-badge type="error" size="mini"></u-badge>
          </view>
        </view>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { onLoad, onShow } from '@dcloudio/uni-app'

// 响应式数据
const userInfo = reactive({
  name: '张三',
  company: 'ACME电子有限公司',
  avatar: '/static/images/avatar.png'
})

const notificationCount = ref(3)

const todoList = ref([
  {
    id: 1,
    type: 'urgent',
    icon: 'clock',
    title: '紧急发货',
    description: '订单PO-20250107-001需要紧急发货',
    time: '2小时前',
    count: 1
  },
  {
    id: 2,
    type: 'quality',
    icon: 'checkmark-circle',
    title: 'IQC检验',
    description: '批次LOT-20250107-001等待IQC检验',
    time: '4小时前',
    count: 0
  },
  {
    id: 3,
    type: 'mold',
    icon: 'setting',
    title: '模具维护',
    description: '模具MLD-SUP-0001需要定期维护',
    time: '1天前',
    count: 0
  }
])

const stats = reactive({
  deliveryCount: 156,
  qualityRate: 98.5,
  onTimeRate: 95.2,
  rating: 4.8
})

const newsList = ref([
  {
    id: 1,
    type: 'system',
    icon: 'info-circle',
    title: '系统维护通知',
    time: '1小时前',
    read: false
  },
  {
    id: 2,
    type: 'quality',
    icon: 'checkmark-circle',
    title: '质量要求更新',
    time: '3小时前',
    read: false
  },
  {
    id: 3,
    type: 'delivery',
    icon: 'car',
    title: '发货流程优化',
    time: '1天前',
    read: true
  }
])

// 方法
const goToNotifications = () => {
  uni.navigateTo({
    url: '/pages/notifications/index'
  })
}

const goToMoldStatus = () => {
  uni.navigateTo({
    url: '/pages/mold/status'
  })
}

const goToDelivery = () => {
  uni.navigateTo({
    url: '/pages/delivery/list'
  })
}

const goToQuality = () => {
  uni.navigateTo({
    url: '/pages/quality/iqc'
  })
}

const goToInventory = () => {
  uni.navigateTo({
    url: '/pages/inventory/list'
  })
}

const goToTodoList = () => {
  uni.navigateTo({
    url: '/pages/todo/list'
  })
}

const goToNewsList = () => {
  uni.navigateTo({
    url: '/pages/news/list'
  })
}

const goToNewsDetail = (item) => {
  uni.navigateTo({
    url: `/pages/news/detail?id=${item.id}`
  })
}

const handleTodo = (item) => {
  switch (item.type) {
    case 'urgent':
      goToDelivery()
      break
    case 'quality':
      goToQuality()
      break
    case 'mold':
      goToMoldStatus()
      break
    default:
      break
  }
}

// 生命周期
onLoad(() => {
  console.log('页面加载')
})

onShow(() => {
  console.log('页面显示')
  // 刷新数据
  refreshData()
})

onMounted(() => {
  // 初始化数据
  initData()
})

// 初始化数据
const initData = () => {
  // 获取用户信息
  getUserInfo()
  // 获取统计数据
  getStats()
  // 获取待办事项
  getTodoList()
  // 获取最新消息
  getNewsList()
}

// 刷新数据
const refreshData = () => {
  // 刷新统计数据
  getStats()
  // 刷新待办事项
  getTodoList()
  // 刷新消息
  getNewsList()
}

// 获取用户信息
const getUserInfo = () => {
  // 模拟API调用
  console.log('获取用户信息')
}

// 获取统计数据
const getStats = () => {
  // 模拟API调用
  console.log('获取统计数据')
}

// 获取待办事项
const getTodoList = () => {
  // 模拟API调用
  console.log('获取待办事项')
}

// 获取最新消息
const getNewsList = () => {
  // 模拟API调用
  console.log('获取最新消息')
}
</script>

<style scoped>
.container {
  padding: 20rpx;
  background-color: #f5f5f5;
  min-height: 100vh;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20rpx;
  background-color: #fff;
  border-radius: 16rpx;
  margin-bottom: 20rpx;
  box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.1);
}

.user-info {
  display: flex;
  align-items: center;
}

.avatar {
  width: 80rpx;
  height: 80rpx;
  border-radius: 50%;
  margin-right: 20rpx;
}

.user-details {
  display: flex;
  flex-direction: column;
}

.username {
  font-size: 32rpx;
  font-weight: bold;
  color: #333;
  margin-bottom: 8rpx;
}

.company {
  font-size: 24rpx;
  color: #666;
}

.notification {
  position: relative;
  padding: 16rpx;
}

.menu-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20rpx;
  margin-bottom: 30rpx;
}

.menu-item {
  background-color: #fff;
  padding: 40rpx 20rpx;
  border-radius: 16rpx;
  text-align: center;
  box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.1);
  transition: transform 0.2s;
}

.menu-item:active {
  transform: scale(0.95);
}

.menu-icon {
  margin-bottom: 20rpx;
}

.menu-title {
  display: block;
  font-size: 28rpx;
  font-weight: bold;
  color: #333;
  margin-bottom: 8rpx;
}

.menu-desc {
  display: block;
  font-size: 24rpx;
  color: #666;
}

.todo-section,
.stats-section,
.news-section {
  background-color: #fff;
  border-radius: 16rpx;
  padding: 30rpx;
  margin-bottom: 20rpx;
  box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.1);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30rpx;
}

.section-title {
  font-size: 32rpx;
  font-weight: bold;
  color: #333;
}

.more-btn {
  font-size: 24rpx;
  color: #007AFF;
}

.todo-list {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}

.todo-item {
  display: flex;
  align-items: center;
  padding: 20rpx;
  background-color: #f8f9fa;
  border-radius: 12rpx;
}

.todo-icon {
  width: 60rpx;
  height: 60rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 20rpx;
}

.todo-icon.urgent {
  background-color: #ff4757;
}

.todo-icon.quality {
  background-color: #ffa502;
}

.todo-icon.mold {
  background-color: #3742fa;
}

.todo-content {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.todo-title {
  font-size: 28rpx;
  font-weight: bold;
  color: #333;
  margin-bottom: 8rpx;
}

.todo-desc {
  font-size: 24rpx;
  color: #666;
  margin-bottom: 8rpx;
}

.todo-time {
  font-size: 22rpx;
  color: #999;
}

.todo-badge {
  margin-left: 20rpx;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20rpx;
}

.stat-item {
  text-align: center;
  padding: 30rpx 20rpx;
  background-color: #f8f9fa;
  border-radius: 12rpx;
}

.stat-value {
  display: block;
  font-size: 36rpx;
  font-weight: bold;
  color: #007AFF;
  margin-bottom: 8rpx;
}

.stat-label {
  display: block;
  font-size: 24rpx;
  color: #666;
}

.news-list {
  display: flex;
  flex-direction: column;
  gap: 20rpx;
}

.news-item {
  display: flex;
  align-items: center;
  padding: 20rpx;
  background-color: #f8f9fa;
  border-radius: 12rpx;
}

.news-icon {
  width: 50rpx;
  height: 50rpx;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 20rpx;
}

.news-icon.system {
  background-color: #007AFF;
}

.news-icon.quality {
  background-color: #34C759;
}

.news-icon.delivery {
  background-color: #FF9500;
}

.news-content {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.news-title {
  font-size: 28rpx;
  color: #333;
  margin-bottom: 8rpx;
}

.news-time {
  font-size: 22rpx;
  color: #999;
}

.news-status {
  margin-left: 20rpx;
}
</style>
