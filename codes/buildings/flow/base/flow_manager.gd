class_name FlowManager
extends Node

@export var initial_flow : BaseFlow
@export var current_flow : BaseFlow : 
	set(new_flow):
		if current_flow:
			current_flow.flow_exit()
		current_flow = new_flow
		current_flow.initialize_current_ui()
		
		current_flow.flow_enter()

var amount_flow : int = 0
var index_flow : int = 0
var flows : Array[BaseFlow]

func _ready() -> void:
	if current_flow == null:
		initialize_current_flow()

	for i : BaseFlow in self.get_children():
		i.flow_changed.connect(flow_transition)
		amount_flow += 1
		flows.append(i)

func initialize_current_flow() -> void:
	current_flow = initial_flow

func _physics_process(delta: float) -> void:
	current_flow.flow_process(delta)

func flow_transition() -> void:
	print("flow_changed")
	if index_flow == (amount_flow - 1):
		print("The flow runs out")
		current_flow.flow_exit()
		return
	else:
		index_flow += 1
		
	current_flow = flows[index_flow]
