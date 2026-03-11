[Toc]
格式： ### 日期 然后后面是日志内容即可（最新的优先写在最上面）
---
### 2026-03-11
主要更新内容

- 新增`CraftsmanGenerate`类：该类1.提供一个外部调用函数`generate_value`，传参`fame_value`（玩家名气值）、`gender`（性别：1-男 0-女，置空随机）、`profession`（职业，0~3，置空随机），该函数返回一个`CraftsmanResource`对象，提供属性：name、level、profession、values、cost、description。（图形池暂未实现）；2.提供一个外部调用函数`generate_craftsman`，传参`fame_value`，基于log函数计算要生成的工匠数量，批量生成多个`CraftsmanResource`对象。该类提供方便修改的const参数以调整游戏数值平衡。
- 修改`CraftsmanResource`类，将_level_limit置为5，对该类中代码无显著影响，最高level5更符合常规游戏等级印象。若不妥可修改删除。

---
### 2026-03-09
主要更新内容
- 更新`BaseResource`并令`BuildingResource`和`CraftsmanResource`继承自它，利用`BaseResource`的`PROPERTY`枚举统一属性定义，同时方便读取属性值。
- 更新`CraftsmanResource`类，新增精力值属性，同时能够返回工匠的影响因子（由精力值和所需的能力值决定）。
- 更新`build_prop_config`脚本，即`BuildPropConfig`类，包括权重配置和属性配置，建筑增值的计算方法，然后搭载到`BaseFlow`上，供建筑流程使用。
- 更新`craftsman_manager.gd`脚本，即`CraftsmanManager`类，完善了工匠管理器的功能，包括工匠的添加、工匠列表的获取和根据`BuildConfig`排列顺序操作。
- 删除`TotalConfirmFlow`流程及其ui场景，重构了流程和ui对于工匠资源的引用，改为引用`CraftsmanManager`节点。
- 更新`main.tscn`主场景的逻辑，目前实现`招募员工`和`建造建筑`的基本功能

---

### 2026-02-16 

主要更新内容

- 主要更新了建筑模块的流程步骤核心模块的脚本结构和交互逻辑。
- 增强了 UI 体验，补充了部分界面元素和资源。
- 修复了部分已知问题，提升了系统稳定性。
---