extends Node
class_name BaseFlow

@export var initial_ui : BaseUi
@export var current_ui : BaseUi :
	set(new_ui):
		if current_ui:
			current_ui.ui_exit()
		current_ui = new_ui
		current_ui.ui_enter()

var amount_ui : int = 0
var index_ui : int = 0
var uis : Array[BaseUi]

signal flow_changed

func _ready() -> void:
	for i : BaseUi in self.get_children():
		i.ui_changed.connect(ui_transition)
		amount_ui += 1
		uis.append(i)
	
func initialize_current_ui() -> void:
	current_ui = initial_ui
		
	

func ui_transition() -> void:
	if index_ui == (amount_ui - 1):
		flow_change()
		return
	else:
		index_ui += 1
		
	current_ui = uis[index_ui]

func flow_enter() -> void:
	pass

func flow_exit() -> void:
	pass

func flow_process(delta:float) -> void:
	current_ui.ui_process(delta)

func flow_change() -> void:
	flow_changed.emit()
