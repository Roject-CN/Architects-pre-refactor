extends BaseUi

@export var timer : float = 10.0
var time : float = 0.0 

func ui_enter() -> void:
	hide()

func ui_process(delta : float) -> void:
	time += delta
	if time >= timer:
		ui_exit()
		request_next()
