extends Node
class_name BaseFlow

enum FLOW {
	FLOW_1_DETECTION = 0,
	FLOW_2_DESIGN,
	FLOW_3_BUILD,
	FLOW_4_ACCOUNT,
	TOTAL_CONFIRM,
}

@export var craftsmen_resource : Array[CraftsmanResource]
@export var plan_craftsmen : Array[CraftsmanResource]
@export var flow_name : String
@export var flow_index : FLOW
@export var craftman : CraftsmanResource
@export var initial_ui : BaseUi
@export var current_ui : BaseUi :
	set(new_ui):
		if current_ui:
			current_ui.ui_exit()   # 仅清理，不触发信号
		current_ui = new_ui
		current_ui.ui_enter()

var amount_ui : int = 0
var index_ui : int = 0
var uis : Array[BaseUi]

signal flow_changed

func _ready() -> void:
	for i : BaseUi in self.get_children():
		# 连接 ui_finished 信号
		i.ui_finished.connect(ui_transition)
		amount_ui += 1
		uis.append(i)

func initialize_current_ui() -> void:
	current_ui = initial_ui

func ui_transition() -> void:
	if index_ui == (amount_ui - 1):
		current_ui.ui_exit()   # 清理最后一个 UI
		flow_change()          # 通知 FlowManager 切换流程
		return
	else:
		index_ui += 1
		
	current_ui = uis[index_ui]  # 切换时会自动调用旧 UI 的 ui_exit()（清理）

func flow_enter() -> void:
	print("进入" + self.flow_name + "流程")
	var flow_manager := get_parent()
	if flow_manager and flow_manager is FlowManager:
		flow_manager = flow_manager as FlowManager
		craftsmen_resource = flow_manager.craftsmen_resource
		plan_craftsmen = flow_manager.plan_craftsmen
	
	if not plan_craftsmen.is_empty():
		craftman = plan_craftsmen[flow_index]
		
	initialize_uis_crafts_resource()

func initialize_uis_crafts_resource() -> void:
	for i : Node in self.get_children():
		if i is BaseUi:
			i.craftsmen_resource = craftsmen_resource
			i.plan_craftsmen = plan_craftsmen
			i.craftsman = craftman
			if not i.craftsman_changed.is_connected(initialize_uis_crafts_resource):
				i.craftsman_changed.connect(change_uis_craftsman)

func change_uis_craftsman(resource : CraftsmanResource) -> void:
	craftman = resource
	for i : Node in self.get_children():
		if i is BaseUi:
			i.craftsman = craftman
	
func flow_exit() -> void:
	print("退出" + self.flow_name + "流程")

func flow_process(delta:float) -> void:
	if current_ui:
		current_ui.ui_process(delta)

func flow_change() -> void:
	flow_changed.emit()
