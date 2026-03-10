# Architects
## 项目规范
### 环境
版本：Godot Engine v4.6.stable.official [89cea1439]

语言：GDscript

渲染器：兼容
### 命名
命名规范与godot规范基本保持一致

[GDscript风格指南](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html#doc-gdscript-styleguide)

文件命名使用**下划线**命名法

节点命名使用**大驼峰**命名法

类命名使用**大驼峰**命名法

变量命名使用**下划线**命名法
>注：变量名开头前缀为`_`表示私有变量
### 提交
消息中应写明修改内容
### 代码编写
变量名与函数名均使用完整英文单词，除特别常用的缩写外，不使用缩写
>规定缩写 可用可不用
res - resource
cft - craftsman
bld - building 


写注释

## 项目结构概览
主要目录结构如下：
### 1. 代码目录（codes/）
- **buildings/**：建筑相关逻辑，包括：
  - `building_resource.gd`：建筑资源
  - `building.gd`：建筑实体与操作
  - flow/建筑流程的实现
  - theme/：建筑主题相关逻辑
- **craftsmen/**：工匠相关逻辑，包括工匠角色、资源和工匠管理器等。
- **environments/**：环境相关逻辑
- **global/**：全局逻辑, 自动加载。
- **main/**: 主场景相关逻辑
- **ui/**：各类ui相关逻辑
  - **base_ui/**：基类代码
  - 继承基类的各类ui代码
- **others/**:其他
### 2. 场景目录（scenes/）
- **main.tscn**：主场景入口。
- **buildings/**：建筑及其流程相关场景。
- **environments/**：环境场景。
- **ui/**：各类ui场景

### 3. 素材目录（sprites/）

### 4. 开发日志目录（log/）
- **document.md**：开发文档，包含项目结构、功能需求等。
- **log.md**：开发日志，记录每次开发的主要内容和变更细节。
- **issues.md**：问题记录，跟踪已知问题和待解决事项。
- **todo.md**：待办事项，列出未来需要完成的任务和功能。

### 5. 资源文件目录(resource/)
- 存放各种Resource类的资源文件

---

## 文件介绍
### codes
存放所有代码文件，其中base_class为基类代码
### scenes
存放所有非UI的场景文件

在该部分中，buildings存放
- [ ] 为玩家设计好的每个建筑
- [x] 玩家自行建造的每个建筑
#### craftsmen
存放所有工匠，类似角色列表
#### division
存放“三分”列表：
- bottom_division存放所有地基、台基、地面等模块
- middle_division存放所有构架、斗拱、墙体等模块
- top_division存放所有屋顶等模块
#### environment
每个building对应一个environment，该模块决定背景图片、堪舆结果等
### ui
#### buildings
building_attributes用以显示每个建筑的详细属性，并
- [x] 提供按钮以便用户安排工匠
- [ ] 由其他节点在界面其他位置提供按钮

division_list用以显示所有可供选择的“三分”模块
#### craftsmen
显示所有可供选择的工匠
#### start
开始界面。考虑到开发目的，本部分不必过多投入，后续可以考虑完成存档等功能
### sprits
存放所有素材图片，写在gitignore中
