extends Control
class_name BaseUi

signal ui_finished  # 新增：UI 主动完成时发出

@export var craftsman_manager : CraftsmanManager
@export var building_resource : BuildingResource
@export var text : String = "测试标题"
@onready var label: Label = $Label
@export var prop_configs : Array[BuildPropConfig]
#引用节点
@onready var l_container: VBoxContainer = $Left/VBoxContainer
@onready var r_container: VBoxContainer = $Right/VBoxContainer

func _ready() -> void:	
	label.text = text
	hide()
	
func ui_enter() -> void:
	show()
	
# 被动退出（由流程调用），只做清理，不发射信号
func ui_exit() -> void:
	hide()

func ui_process(_delta : float) -> void:
	pass

# 主动请求切换到下一个 UI（例如按钮点击时调用）
func request_next() -> void:
	ui_finished.emit()

func respond_current_list_changed() -> void:
	pass

func respond_plan_list_changed() -> void:
	pass
