extends BaseUi
class_name ChoiceUi


@export var l_separation_rate : float = 0.75
@export var r_separation_rate : float = 0.7

func _ready() -> void:
	super()
	override_separation()
	
#覆盖VBoxContainer的间距距离 为infromation_ui的尺寸 * separation_rate
func override_separation() -> void:
	var target_ui :Control
	var constant_override
	if l_container.get_child_count() > 0 : 
		target_ui = l_container.get_child(0)
		constant_override = target_ui.size.y
		l_container.add_theme_constant_override("separation", constant_override * l_separation_rate)
	
	
	if r_container.get_child_count() > 0: 
		target_ui = r_container.get_child(0)
		constant_override = target_ui.size.y
		r_container.add_theme_constant_override("separation", constant_override * r_separation_rate)
	


func _on_assure_pressed() -> void:
	ui_exit()
	ui_finished.emit()
