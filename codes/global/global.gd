extends Node

# Global.gd 或任何全局脚本中

# 全局工匠市场数据
var global_craftsmen_market : Array[CraftsmanResource] = []

#加载存档资源
@export var save_resource : SaveResource



#信号
signal request_load_save_resource(SaveResource)
signal request_save_save_resource

func _ready() -> void:
	request_load_save_resource.connect(load_save_resource)
	request_save_save_resource.connect(save_save_resource)

func load_save_resource(resource : SaveResource) -> void:
	save_resource = resource
	save_resource.init_save_resource()

# 游戏启动时加载存档
func load_save_resource_on_start() -> void:
	save_resource = SaveResource.load_complete_game_data()
	save_resource.init_save_resource()
	var save_info = save_resource.get_save_info()
	print("完整存档加载成功：", save_info)

func save_save_resource() -> void:
	if save_resource:
		var result = save_resource.save_complete_game_data()
		if result == OK:
			print("完整存档保存成功")
		else:
			push_error("存档保存失败: ", result)

# 手动保存游戏（供UI调用）
func manual_save_game() -> void:
	if save_resource:
		var result = save_resource.save_complete_game_data()
		if result == OK:
			print("手动存档成功")
		else:
			push_error("手动存档失败: ", result)

# 创建备份存档
func create_backup_save() -> void:
	if save_resource:
		var result = save_resource.create_backup_save()
		if result == OK:
			print("备份存档创建成功")
		else:
			push_error("备份创建失败: ", result)

func add_money(amount: int) -> void:
	save_resource.current_money += amount

func subtract_money(amount: int) -> void:
	save_resource.current_money -= amount

func add_fame(amount: int) -> void:
	save_resource.fame += amount

func subtract_fame(amount: int) -> void:
	save_resource.fame -= amount

func add_research(amount: int) -> void:
	save_resource.research_value += amount

func subtract_research(amount: int) -> void:
	save_resource.research_value -= amount

func add_days(amount : int) -> void:
	save_resource.time_days += amount

func add_building_resource(building_resource : BuildingResource) -> void:
	save_resource.add_building_resource(building_resource)

func themes_empty() -> bool :
	var a1 := save_resource.top_theme_resource.is_empty()
	var a2 := save_resource.middle_theme_resource.is_empty()
	var a3 := save_resource.buttom_theme_resource.is_empty()
	return a1 || a2 || a3
