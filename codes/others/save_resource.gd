extends Resource
class_name SaveResource

#SaveResource类为存档资源类
#在Global类里加载SaveResource类资源 然后可全局获取

#金钱值 初始金钱和当前金钱
@export var init_money : int = 1000
@export var current_money : int = 0 : 
	set(value):
		current_money = value
		current_money_changed.emit(value)
#名气值
@export var fame : int = 0: 
	set(value):
		fame = value
		fame_changed.emit(value)
#研究点
@export var research_value : int = 0: 
	set(value):
		research_value = value
		research_value_changed.emit(value)

var time_days : int = 0 : 
	set(value):
		time_days = value
		time_days_changed.emit(value)

#员工列表
var start_list : Array[CraftsmanResource]

#建筑资源的储存
var save_building_resources : Array[BuildingResource]

#建筑主题资源
var top_theme_resource : Array[ThemeResource]
var middle_theme_resource : Array[ThemeResource]
var buttom_theme_resource : Array[ThemeResource]

#历史建筑成就
var achivements : Array[BuildingResource]

#检测是否为第一次加载
var first_time : bool = true

signal current_money_changed(value : int)
signal fame_changed(value : int)
signal research_value_changed(value : int)
signal time_days_changed(value : int)

func init_save_resource() -> void:
	if first_time:
		first_time = false
		current_money = init_money

func add_building_resource(resource : BuildingResource) -> void:
	save_building_resources.append(resource)
	
	if save_building_resources.size() >= 10:
		save_building_resources.pop_front() 
