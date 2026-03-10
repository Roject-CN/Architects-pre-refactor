class_name BuildPropConfig 
extends Resource

const max_limit := 2.0
const add_value := 1 

@export var prop : BaseResource.PROPERTY
#weight代表该属性的权重 权重越小增值越慢
@export_range(0.0, 1.0, 0.1) var weight : float = 0.5

signal request_animation_ui_add(prop)

var _value := 0.0 :
	set(new_value):
		if new_value >= max_limit:
			_value = 0.0
			request_animation_ui_add.emit(prop)
		else :
			_value = new_value

func build_process(delta : float, effect : float) -> void :
	_value += delta * weight * effect
