extends Control
class_name BaseUi


@export var text : String = "测试标题"
@onready var label: Label = $Label
signal ui_changed

# 初始化
func _ready() -> void:	
	label.text = text
	hide()

func ui_exit() -> void:
	hide()

func ui_enter() -> void:
	show()

func ui_process(delta: float) -> void:
	pass
