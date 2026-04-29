class_name BuildPropConfig
extends Resource

const MAX_LIMIT := 15.0
var _max_limit := MAX_LIMIT
var _times_count := 0           # 实际存储次数


@export var prop : BaseResource.PROPERTY
@export_range(0.0, 1.0, 0.1) var weight : float = 0.5
var _build_craftsmen : Array[CraftsmanResource]

signal request_animation_ui_add(prop : BaseResource.PROPERTY)

var _craftsmen_values : Array[float] = []

func append_new_craftsman(resource : CraftsmanResource) -> void:
	_build_craftsmen.append(resource)
	_craftsmen_values.append(0.0)

func build_process(delta : float) -> void:
	for i in _build_craftsmen.size():
		var resource := _build_craftsmen[i]
		_craftsmen_values[i] += delta * weight * resource.return_craftsman_effect(delta, prop)

		if _craftsmen_values[i] >= _max_limit:
			_craftsmen_values[i] = 0.0

			# 触发一次加成
			_times_count += 1
			if _times_count >= 10:
				_times_count = 0
				_max_limit *= 1.1   # 每次点击10次后上限提升10%

			request_animation_ui_add.emit(prop)
			resource.request_craftsman_character_animation_ui_added.emit(prop)
