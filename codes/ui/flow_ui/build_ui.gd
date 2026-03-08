extends AttributionUi
class_name BuildUi

@onready var assure: Button = $Button/Assure
@onready var progress_bar: ProgressBar = $Left/VBoxContainer/ProgressBar
@onready var craftsman_label: Label = $Left/VBoxContainer/craftsman_label

@export var _progress_curve : Curve = preload("uid://c735f8cwhf5gy")

var value_pecent : float = 0.0 : 
	set(new_value):
		value_pecent = new_value
		progress_bar.value = value_pecent	
		if value_pecent >= 1.0:
			assure.disabled = false
		
@export var time : float = 5.0
var craftsman : CraftsmanResource

	
func _ready() -> void:
	super()
	assure.disabled = true
	progress_bar.value = 0.0

func ui_exit() -> void:
	super()

func ui_enter() -> void:
	assert(craftsman, str(self) + "craftsman is empty")
	craftsman_label.text = craftsman.name + "正在努力中"
	show_resouce_attribution(building_resource)
	
	#连接prop_config的信号 
	for prop_config in prop_configs:
		prop_config.request_animation_ui_add.connect(animation_ui_add)
			
	super()

func ui_process(delta: float) -> void:
	if value_pecent >= 1.0:
		return
	value_pecent += (1.0 / time * delta * _progress_curve.sample(value_pecent))
	
	for i in prop_configs:
		i.build_process(delta, craftsman.return_craftsman_effect(delta))
	

func animation_ui_add(index : int) -> void:
	var resource := building_resource
	resource.add_value(index)
	var information_ui : InformationUI = r_container.get_child(index)
	information_ui.update_value()

	
func _on_assure_pressed() -> void:
	ui_exit()
	request_next()
	
