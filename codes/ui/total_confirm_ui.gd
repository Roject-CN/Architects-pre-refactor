extends ChoiceUi
class_name TotalConfirmUi

@export var current_flow : Button
var flows : Array[Button]
var flows_name : Array[String]


const craftsman_text : String = "%-3s:%d"
const craftsman_font_size : int = 12
func ui_enter() -> void:
	for flow : Button in l_container.get_children():
		flow.pressed.connect(change_current_flow.bind(flow))
		flows.append(flow)
		flows_name.append(flow.text)
		plan_craftsmen.append(null)
	
	initialize_assignment()
	
	for resource : CraftsmanResource in craftsmen_resource:
		var button = Button.new()
		button.text = resource.name + " "
		button.pressed.connect(assign_craftsman_to_current_flow.bind(resource))
		for i in resource.values:
			var attribution : String = craftsman_text % [i ,resource.values[i]]
			button.text += attribution
			button.add_theme_font_size_override("font_size", craftsman_font_size)
		r_container.add_child(button)
	super()		
	
	l_container.get_child(0).grab_focus()
	
func change_current_flow(flow : Button) -> void:
	current_flow = flow	
	current_flow.grab_focus()
	
func assign_craftsman_to_current_flow(craftsman_resource : CraftsmanResource) -> void:
	current_flow.grab_focus()
	
	var index := 0
	for i in flows:
		if current_flow == i:
			break
		index+=1
	current_flow.text = flows_name[index] + ":" + craftsman_resource.name
	plan_craftsmen[index] = craftsman_resource

func initialize_assignment() -> void:
	var resource : CraftsmanResource = craftsmen_resource[0]
	var plan : Array[CraftsmanResource]
	var index : int = 0
	for value_name in resource.values_name:
		plan = craftsmen_resource
		plan.sort_custom(func(a : CraftsmanResource, b : CraftsmanResource): 
			return a.values[value_name] > b.values[value_name])
			
		flows[index].text = flows_name[index] + ":" + plan[0].name
		plan_craftsmen[index] = plan[0]
		index += 1
		

func _on_button_pressed() -> void:
	ui_exit()
	request_next()
