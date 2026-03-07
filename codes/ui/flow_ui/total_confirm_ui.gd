extends ChoiceUi
class_name TotalConfirmUi

@export var _current_flow : Button
var _flows : Array[Button]
var _flows_name : Array[String]

const craftsman_text : String = "%-3s:%d"
const craftsman_font_size : int = 12

func ui_enter() -> void:	
	for flow : Button in l_container.get_children():
		flow.pressed.connect(change_current_flow.bind(flow))
		_flows.append(flow)
		_flows_name.append(flow.text)
	
	initialize_assignment()
	
	for resource : CraftsmanResource in craftsman_manager.current_list:
		var button = Button.new()
		button.text = resource.name + " "
		button.pressed.connect(assign_craftsman_to_current_flow.bind(resource))
		for i in resource.values:
			var attribution : String = craftsman_text % [i["name"] ,i["value"]]
			button.text += attribution
			button.add_theme_font_size_override("font_size", craftsman_font_size)
		r_container.add_child(button)
		
	
	super()
	l_container.get_child(0).grab_focus()
	
func change_current_flow(flow : Button) -> void:
	_current_flow = flow	
	_current_flow.grab_focus()
	
func assign_craftsman_to_current_flow(resource : CraftsmanResource) -> void:
	_current_flow.grab_focus()
	
	var index := 0
	for i in _flows:
		if _current_flow == i:
			break
		index+=1
	_current_flow.text = _flows_name[index] + ":" + resource.name
	craftsman_manager.append_plan_craftsman(resource, index)

func initialize_assignment() -> void:
	pass
	#var resource : CraftsmanResource = craftsmen_resource[0]
	#var plan : Array[CraftsmanResource]
	#var index : int = 0
	#
	#for prop in resource.properties:
		#plan = craftsmen_resource
		#plan.sort_custom(func(a : CraftsmanResource, b : CraftsmanResource): 
			#return a.properties[prop] > b.values[index]["value"])
			#
	#for v in resource.values:
		#plan = craftsmen_resource
		#plan.sort_custom(func(a : CraftsmanResource, b : CraftsmanResource): 
			#return a.values[index]["value"] > b.values[index]["value"])
			#
		#_flows[index].text = _flows_name[index] + ":" + plan[0].name
		#plan_craftsmen[index] = plan[0]
		#index += 1
		

func _on_button_pressed() -> void:
	ui_exit()
	request_next()
