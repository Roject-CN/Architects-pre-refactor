class_name FlowManager
extends Node

@export var craftsmen_resource : Array[CraftsmanResource]
@export var plan_craftsmen : Array[CraftsmanResource]

@export var initial_flow : BaseFlow
@export var current_flow : BaseFlow : 
	set(new_flow):
		if current_flow:
			current_flow.flow_exit()   # 仅清理，不触发信号
		current_flow = new_flow
		current_flow.flow_enter()
		current_flow.initialize_current_ui()

var amount_flow : int = 0
var index_flow : int = 0
var flows : Array[BaseFlow]

func _ready() -> void:
	initialize_current_flow()

	for i : BaseFlow in self.get_children():
		i.flow_changed.connect(flow_transition)
		amount_flow += 1
		flows.append(i)

func initialize_current_flow() -> void:
	current_flow = initial_flow

func _physics_process(delta: float) -> void:
	if current_flow:
		current_flow.flow_process(delta)

func flow_transition() -> void:
	if index_flow == (amount_flow - 1):
		current_flow.flow_exit()   # 清理最后一个流程，可根据需要在此触发结束信号
		return
	else:
		index_flow += 1
		
	current_flow = flows[index_flow]  # 切换流程
