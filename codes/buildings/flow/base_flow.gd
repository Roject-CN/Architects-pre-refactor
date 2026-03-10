extends Node
class_name BaseFlow

@export var build_prop_config : Array[BuildPropConfig]
var building_resource : BuildingResource
var craftsman_manager : CraftsmanManager

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

func ui_transition() -> void:
	if index_ui == (amount_ui - 1):
		current_ui.ui_exit()   # 清理最后一个 UI
		flow_change()          # 通知 FlowManager 切换流程
		return
	else:
		index_ui += 1
		
	current_ui = uis[index_ui]  # 切换时会自动调用旧 UI 的 ui_exit()（清理）

func flow_enter() -> void:
	#分配prop_config以高亮属性值和计算增值
	for ui : BaseUi in self.get_children():
		ui.prop_configs = build_prop_config
	
	#最后进入
	current_ui = initial_ui

func flow_exit() -> void:
	pass

func flow_process(delta:float) -> void:
	if current_ui:
		current_ui.ui_process(delta)

func flow_change() -> void:
	flow_changed.emit()
