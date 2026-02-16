extends AttributionUi
class_name ConfirmUi

@export var flow_index : BaseFlow.FLOW
@onready var craftsmen_container: VBoxContainer = $Left/VBoxContainer/Scroll/VBoxContainer


func ui_enter() -> void:
	if craftsmen_resource == null:
		assert(craftsmen_resource, str(self) + "craftsmen_resource is null")
	
	
	for resource : CraftsmanResource in craftsmen_resource:
		var button = Button.new()
		button.text = resource.name 
		button.pressed.connect(assign_new_craftman.bind(resource))
		craftsmen_container.add_child(button)
		if plan_craftsmen[flow_index].name == resource.name:
			button.grab_focus()
	
	show_craftman_attribution(plan_craftsmen[flow_index])
	super()

func assign_new_craftman(resource : CraftsmanResource) -> void:
	show_craftman_attribution(resource)
	craftsman_changed.emit(resource)

func _on_assure_pressed() -> void:
	ui_exit()
	request_next()
	
