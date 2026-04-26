class_name BuildPropConfig 
extends Resource

const MAX_LIMIT := 20.0

@export var prop : BaseResource.PROPERTY
#weight代表该属性的权重 权重越小增值越慢
@export_range(0.0, 1.0, 0.1) var weight : float = 0.5
var _build_craftsmen : Array[CraftsmanResource]

#在BuildUi环节连接此信号
signal request_animation_ui_add(prop : BaseResource.PROPERTY)

#_build_craftsmen里的每个员工对应一个_craftsmen_value
var _craftsmen_values : Array[float] = []
			
func append_new_craftsman(resource : CraftsmanResource) -> void:
	_build_craftsmen.append(resource)
	_craftsmen_values.append(0.0)

func build_process(delta : float) -> void :
	for i in _build_craftsmen.size():
		var resource := _build_craftsmen[i]
		_craftsmen_values[i] += delta * weight * resource.return_craftsman_effect(delta, prop)
		if _craftsmen_values[i] >= MAX_LIMIT:
			_craftsmen_values[i] = 0.0
			request_animation_ui_add.emit(prop)
			resource.request_craftsman_character_animation_ui_added.emit(prop)
			
