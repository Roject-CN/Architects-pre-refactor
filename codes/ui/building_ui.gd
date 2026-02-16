extends AttributionUi
class_name BuildingUi

@onready var assure: Button = $Button/Assure
@onready var progress_bar: ProgressBar = $Left/VBoxContainer/ProgressBar
@onready var craftsman_label: Label = $Left/VBoxContainer/craftsman_label

@export var progress_curve : Curve


signal assure_pressed()
var value_pecent : float = 0.0 : 
	set(new_value):
		value_pecent = new_value
		progress_bar.value = value_pecent	
		if value_pecent >= 1.0:
			assure.disabled = false
		
@export var time : float = 5.0

func _ready() -> void:
	super()
	assure.disabled = true
	progress_bar.value = 0.0

func ui_exit() -> void:
	super()

func ui_enter() -> void:
	craftsman_label.text = craftsman.name + "正在努力中"
	super()

func ui_process(delta: float) -> void:
	if value_pecent >= 1.0:
		return
	value_pecent += (1.0 / time * delta * progress_curve.sample(value_pecent))

func _on_assure_pressed() -> void:
	ui_exit()
	request_next()
	
