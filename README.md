# Architects
### 项目规范
#### 命名
命名规范与godot规范基本保持一致

[GDscript风格指南](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html#doc-gdscript-styleguide)

文件命名使用**下划线**命名法

节点命名使用**大驼峰**命名法
#### 提交
消息中应写有说明文本
### 文件介绍
**mvp前缀文件均为确保游戏流程的最小可行性文件，不应在release中显示**
#### codes
存放所有代码文件，其中base_class为基类代码
#### scenes
存放所有非UI的场景文件

在该部分中，buildings存放
- [ ] 为玩家设计好的每个建筑
- [ ] 玩家自行建造的每个建筑
##### craftsmen
存放所有工匠，类似角色列表
##### division
存放“三分”列表：
- bottom_division存放所有地基、台基、地面等模块
- middle_division存放所有构架、斗拱、墙体等模块
- top_division存放所有屋顶等模块
##### environment
每个building对应一个environment，该模块决定背景图片、堪舆结果等
#### ui
##### buildings
building_attributes用以显示每个建筑的详细属性，并
- [ ] 提供按钮以便用户安排工匠
- [ ] 由其他节点在界面其他位置提供按钮

division_list用以显示所有可供选择的“三分”模块
##### craftsmen
显示所有可供选择的工匠
##### start
开始界面。考虑到开发目的，本部分不必过多投入，后续可以考虑完成存档等功能
#### sprits
存放所有素材图片，写在gitignore中