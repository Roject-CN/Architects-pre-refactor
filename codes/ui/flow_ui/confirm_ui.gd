extends AttributionUi
class_name ConfirmUi

@onready var craftsmen_container: VBoxContainer = $Left/VBoxContainer/Scroll/VBoxContainer


func ui_enter() -> void:
	var craftsmen_resource := craftsman_manager.current_list
	var plan_list := craftsman_manager.plan_list
	
	if craftsmen_resource == null:
		assert(craftsmen_resource, str(self) + "craftsmen_resource is null")
	
	
	for resource : CraftsmanResource in craftsmen_resource:
		var button = Button.new()
		button.text = resource.name 
		button.pressed.connect(assign_new_craftman.bind(resource))
		button.pressed.connect((func (b : Button): b.grab_focus()).bind(button))
		craftsmen_container.add_child(button)
		if plan_list[flow_index].name == resource.name:
			button.grab_focus()
	
	show_resouce_attribution(plan_list[flow_index])
	show_build_config(prop_configs)
	super()

func assign_new_craftman(resource : CraftsmanResource) -> void:
	var plan_list := craftsman_manager.plan_list
	show_resouce_attribution(resource)
	craftsman_manager.change_plan_craftsman(plan_list[flow_index], flow_index)

func _on_assure_pressed() -> void:
	ui_exit()
	request_next()

func respond_plan_list_changed() -> void:	
	for i in craftsmen_container.get_children():
		i.call_deferred("queue_free")
	
	ui_enter()
