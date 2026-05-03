extends Node
class_name Achivement

@export var achievement_name : String

@export var top_theme : ThemeResource
@export var middle_theme : ThemeResource
@export var buttom_theme : ThemeResource

@export_multiline var description : String

var locked := true

@export var compare : BaseResource

func is_the_same(resource : BuildingResource) -> bool :
	
	var value_can_achive_times := 0
	
	for i : BaseResource.PROPERTY in BaseResource.PROPERTY.values():
		if resource.return_value(i) >= compare.return_value(i):
			value_can_achive_times += 1
	
	
	
	return (top_theme == resource.top_theme and 
	middle_theme == resource.middle_theme and
	buttom_theme == resource.buttom_theme and
	value_can_achive_times >= 4
	)
