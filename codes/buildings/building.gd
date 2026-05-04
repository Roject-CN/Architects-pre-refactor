class_name Building
extends Node2D

@export var building_resource : BuildingResource
@onready var flow_manager: FlowManager = $FlowManager
@export var craftsman_manager : CraftsmanManager
var pick : PicturePick
@export var need_pick : RewardUi

func _ready() -> void:
	assert(craftsman_manager, str(self.name) + "'s craftsman_manager is empty")
	
	#_load_environment()	#加载预设环境
	#对每个flow和ui的building_resource赋值
	flow_manager.building_resource = building_resource
	
	for flow : BaseFlow in flow_manager.get_children():
		flow.craftsman_manager = craftsman_manager
		for ui in flow.get_children():
			if ui is BaseUi:
				ui.building_resource = building_resource
				ui.craftsman_manager = craftsman_manager
	
	need_pick.pick_pictures = pick
		
	#保证先赋值再开始启动状态机
	flow_manager.open_flow_manager()
	
	#使 MainTime停止计时
	Event.building_ui_enter.emit()

#flow_manager再检测到已经运行到最后一个流程并结束的时候， 执行此函数
func save_builiding_resource() -> void:
	
	Global.add_building_resource(building_resource)
	
	#使 MainTime开始计时
	Event.building_ui_quit.emit()
	#使建造建筑的按钮复原
	Event.building_end.emit()
	call_deferred("queue_free")

## 环境部分
@export var folder_environments : Array[PackedScene] = []	#存放预设的环境场景
@export var parent_environments : Node = null	#环境加载后的父节点
var environment_instance

# 从预设环境中随机加载一个环境
func _load_environment():
	var random_environment = folder_environments[randi() % folder_environments.size()]
	environment_instance = random_environment.instantiate()
	parent_environments.add_child(environment_instance)
