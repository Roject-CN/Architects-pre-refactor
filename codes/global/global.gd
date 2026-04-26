extends Node

# Global.gd 或任何全局脚本中

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

func save_save_resource() -> void:
	pass

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
	save_resource.save_building_resources.append(building_resource)
