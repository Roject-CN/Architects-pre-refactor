extends Control
class_name BaseUi

signal ui_finished  # 新增：UI 主动完成时发出
signal craftsman_changed(craftsman : CraftsmanResource) #craftsman 改变时发出

@export var craftsmen_resource : Array[CraftsmanResource]
@export var plan_craftsmen : Array[CraftsmanResource]
@export var craftsman : CraftsmanResource
@export var text : String = "测试标题"
@onready var label: Label = $Label

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

func ui_process(delta : float) -> void:
	pass

# 主动请求切换到下一个 UI（例如按钮点击时调用）
func request_next() -> void:
	ui_finished.emit()
