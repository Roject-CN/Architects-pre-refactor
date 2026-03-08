extends AttributionUi
class_name ConfirmUi

@onready var craftsmen_container: VBoxContainer = $Left/VBoxContainer/Scroll/VBoxContainer
@export var build_ui : BuildUi
var current_craftman : CraftsmanResource : 
	set(value):
		current_craftman = value
		build_ui.craftsman = current_craftman
		show_resouce_attribution(current_craftman)

func ui_enter() -> void:
	
	#寻找当前流程的最优人选
	var sort_list := craftsman_manager.sort_list(prop_configs)
	current_craftman = sort_list[0]
	
	var craftsmen_resource := sort_list
	if craftsmen_resource == null:
		assert(craftsmen_resource, str(self) + "craftsmen_resource is null")
	
	#生成左边容器的员工列表
	for resource : CraftsmanResource in craftsmen_resource:
		var button = Button.new()
		button.text = resource.name 
		button.pressed.connect(assign_new_craftman.bind(resource))
		button.pressed.connect((func (b : Button): b.grab_focus()).bind(button))
		craftsmen_container.add_child(button)
		if current_craftman.name == resource.name:
			button.grab_focus() #默认员工
			
	#高亮属性
	show_build_config(prop_configs)
	super()

func assign_new_craftman(resource : CraftsmanResource) -> void:
	current_craftman = resource

func _on_assure_pressed() -> void:
	ui_exit()
	request_next()

func respond_plan_list_changed() -> void:	
	for i in craftsmen_container.get_children():
		i.call_deferred("queue_free")
	
	ui_enter()
