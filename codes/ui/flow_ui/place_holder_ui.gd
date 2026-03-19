extends BaseUi
class_name PlaceHolderUi

@export var timer : float = 24.0
var time : float = 0.0 
var can_time_process : bool = true


func ui_enter() -> void:
	Event.building_quit.emit()
	hide()

func ui_process(delta : float) -> void:
	can_time_process = craftsman_manager.return_craftsman_is_working()
	if can_time_process:
		time += delta 
		
	if time >= timer:
		ui_exit()
		request_next()

func ui_exit() -> void:
	Event.building_enter.emit()
