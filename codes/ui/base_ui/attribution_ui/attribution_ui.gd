extends BaseUi
class_name AttributionUi

@export var separation_rate : float = 0.7 :
	set(value):
		separation_rate = value
		if is_inside_tree():
			override_separation()

#引用节点
@onready var v_box_container: VBoxContainer = $Right/VBoxContainer

# 初始化
func _ready() -> void:	
	super()
	override_separation()
	
func ui_exit() -> void:
	super()

func ui_enter() -> void:
	super()

func ui_process(delta: float) -> void:
	super(delta)

#覆盖VBoxContainer的间距距离 为infromation_ui的尺寸 * separation_rate
func override_separation() -> void:
	var information_ui :InformationUI= v_box_container.get_child(0)
	var constant_override = information_ui.return_size_y()
	v_box_container.add_theme_constant_override("separation", constant_override * separation_rate)
