extends Control
class_name BaseUi

@export var separation_rate : float = 0.7 :
	set(value):
		separation_rate = value
		if is_inside_tree():
			override_separation()

@export var text : String = "测试标题"

#引用节点
@onready var v_box_container: VBoxContainer = $Information/VBoxContainer
@onready var label: Label = $Label

# 初始化
func _ready() -> void:	
	label.text = text
	override_separation()

#覆盖VBoxContainer的间距距离 为infromation_ui的尺寸 * separation_rate
func override_separation() -> void:
	var information_ui :InformationUI= v_box_container.get_child(0)
	var constant_override = information_ui.return_size_y()
	v_box_container.add_theme_constant_override("separation", constant_override * separation_rate)
