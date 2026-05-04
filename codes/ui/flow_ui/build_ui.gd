extends AttributionUi
class_name BuildUi

@onready var assure: Button = $Button/Assure
@onready var progress_bar: ProgressBar = $Left/VBoxContainer/ProgressBar
@onready var craftsman_label: Label = $Left/VBoxContainer/craftsman_label
@onready var texture_rect: TextureRect = $Left/VBoxContainer/TextureRect



@export var _progress_curve : Curve = preload("uid://c735f8cwhf5gy")

@export var flow_pic : Texture
signal build_props_clear

var value_pecent : float = 0.0 : 
	set(new_value):
		value_pecent = new_value
		progress_bar.value = value_pecent	
		if value_pecent >= 1.0:
			assure.disabled = false
		
@export var time : float = 5.0
var craftsman_resource : CraftsmanResource

	
func _ready() -> void:
	super()
	assure.disabled = true
	progress_bar.value = 0.0
	
	
func ui_exit() -> void:
	super()
	build_props_clear.emit()

func ui_enter() -> void:
	assert(craftsman_resource, str(self) + "craftsman is empty")
	craftsman_label.text = craftsman_resource.name + "正在努力中"
	show_resouce_attribution(building_resource)
	
	#连接prop_config的信号 
	for prop_config in prop_configs:
		prop_config.request_animation_ui_add.connect(animation_ui_add)
		#prop_config增加工作的员工
		prop_config.append_new_craftsman(craftsman_resource)
		#恢复prop_config的_max_limits为默认值
		build_props_clear.connect(prop_config.clear_max_limits, CONNECT_ONE_SHOT)
	
	texture_rect.texture = flow_pic
	
	super()

func ui_process(delta: float) -> void:
	if value_pecent >= 1.0:
		return
	value_pecent += (1.0 / time * delta * _progress_curve.sample(value_pecent))
	
	#prop_configs执行自己相应的逻辑
	for i in prop_configs:
		i.build_process(delta)
	

func animation_ui_add(prop : BaseResource.PROPERTY) -> void:
	var resource := building_resource
	resource.add_value(prop)
	var information_ui : InformationUI = r_container.get_child(prop)
	information_ui.update_value()

	
func _on_assure_pressed() -> void:
	request_next()
	
