extends BaseUi
class_name AttributionUi

@export var separation_rate : float = 0.7 :
	set(value):
		separation_rate = value
		if is_inside_tree():
			override_separation()



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

func show_resouce_attribution(resource : BaseResource) -> void:
	#attribution部分
	var index := 0
	for node : InformationUI in r_container.get_children():
		node.set_value(resource.return_value(index))
		index += 1 

func show_build_config(configs : Array[BuildPropConfig]) -> void:
	for config in configs:
		for node : InformationUI in r_container.get_children():
			if int(config.prop) == node.property:
				node.highlight()
				break
		

#覆盖VBoxContainer的间距距离 为infromation_ui的尺寸 * separation_rate
func override_separation() -> void:
	var information_ui :InformationUI= r_container.get_child(0)
	var constant_override = information_ui.return_size_y()
	r_container.add_theme_constant_override("separation", constant_override * separation_rate)
