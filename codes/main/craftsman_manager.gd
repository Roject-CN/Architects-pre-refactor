extends Node
class_name CraftsmanManager

class Media:
	var resource : CraftsmanResource
	var weight : float = 0.0
	var index : int = 0
#var _amount := 0

@export var current_list : Array[CraftsmanResource]
var plan_list : Array[CraftsmanResource]

signal current_list_changed()
signal plan_list_changed()

func _ready() -> void:
	for i in BaseResource.PROPERTY:
		plan_list.append(null)
#添加新的员工
func append_new_craftsman(resource : CraftsmanResource) -> void:
	current_list.append(resource)
	current_list_changed.emit()

func append_plan_craftsman(resource : CraftsmanResource, flow_index : int) -> void:
	plan_list[flow_index] = resource
	plan_list_changed.emit()

#func change_plan_craftsman(resource : CraftsmanResource, flow_index : int) -> void:
	#plan_list[flow_index] = resource	
	#plan_list_changed.emit()
	
#依照 某项能力值 给当前员工列表排序 从大到小
func sort_list(prop_configs : Array[BuildPropConfig]) -> Array[CraftsmanResource]:
	var target_list : Array[CraftsmanResource]
	var media_list : Array[Media] 
	for resource : CraftsmanResource in current_list.duplicate():
		var media := Media.new()
		media.resource = resource
		media_list.append(media)
	
	for prop_config in prop_configs:
		for media : Media in media_list:
			var value := media.resource.return_value(prop_config.prop) 
			@warning_ignore("narrowing_conversion")
			media.weight += value * prop_config.weight
	
	media_list.sort_custom(func(a : Media, b : Media):
		return a.weight > b.weight
		)
	
	for media in media_list:
		target_list.append(media.resource)
	
	return target_list
