# 营造司物语游戏开发文档
[Toc]

 



## 二、功能需求



### 1. 建筑系统

四个流程
风水勘探
- confirm_ui
- build_ui

设计建筑
- confirm_ui
- theme_ui
- build_ui
- placeholder_ui

建造建筑
- confirm_ui
- build_ui
- placeholder_ui

计算工料
- confirm_ui
- build_ui
- reward_ui

 1.2 人选确认环节（Confirm）
  - 左侧为员工名单，按能力、状态排序，根据`大致人选`结果高亮员工
  - 右侧显示员工能力值和状态（高亮需求能力）

 1.3 主题选取环节
  - 左侧上、中、下三个位置选取可选主题
  - 右侧显示主题属性和加成，支持预览效果
  -  引入“契合度”概念，影响 Reward 结果和奖励发放

 1.4 Build 工作环节
  - 文本框显示随机文本
  - 播放对应动画
  - 根据员工能力值、精力值及流程权重，计算建筑增值

 1.5 Placeholder 环节（集体工作）
  - 激活所有员工共同参与工作
  - 根据员工表现等因素，计算建筑增值

 1.6 Reward 奖励环节
  - 计算和发放公司名气值和金币等奖励


