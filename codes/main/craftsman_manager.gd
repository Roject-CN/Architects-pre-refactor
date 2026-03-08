extends Node
class_name CraftsmanManager

class Media:
	var resource : CraftsmanResource
	var weight : float = 0.0
	var index : int = 0
	
@export var current_list : Array[CraftsmanResource]

signal current_list_changed()
#添加新的员工
func append_new_craftsman(resource : CraftsmanResource) -> void:
	current_list.append(resource)

func craftsman_manager_is_empty() -> bool :
	return current_list.is_empty()

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
