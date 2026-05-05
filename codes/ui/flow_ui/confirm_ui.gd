extends AttributionUi
class_name ConfirmUi

@onready var craftsmen_container: VBoxContainer = $Left/VBoxContainer/Scroll/VBoxContainer

#暂时的
@onready var cancel: Button = $Button/Cancel


@export var build_ui : BuildUi
#暂时的
@export var building : Building
var current_craftman : CraftsmanResource : 
	set(value):
		current_craftman = value
		build_ui.craftsman_resource = current_craftman
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
		button.custom_minimum_size.x = 100
		button.text = resource.name 
		button.pressed.connect(assign_new_craftman.bind(resource))
		button.pressed.connect((func (b : Button): b.grab_focus()).bind(button))
		craftsmen_container.add_child(button)
		if current_craftman.name == resource.name:
			button.grab_focus() #默认员工
			
	#高亮属性
	show_build_config(prop_configs)
	super()
	
	#暂时的
	if not  building:
		cancel.visible = false
		

func assign_new_craftman(resource : CraftsmanResource) -> void:
	current_craftman = resource

func _on_assure_pressed() -> void:
	request_next()

func _on_cancel_pressed() -> void:
	#现在这个取消只是暂时的
	building.save_builiding_resource()
