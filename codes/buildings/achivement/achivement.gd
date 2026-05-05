extends Node
class_name Achivement

enum ACHIVEMENT_TYPE{
	BUILDING,
	FLOW
}

@export var achievement_name : String

@export var top_theme : ThemeResource
@export var middle_theme : ThemeResource
@export var buttom_theme : ThemeResource

@export_multiline var description : String

var locked := true
@export var texture : Texture
@export var compare : BaseResource

@export var achievement_type : ACHIVEMENT_TYPE = ACHIVEMENT_TYPE.BUILDING
func is_the_same(resource : BuildingResource) -> bool :
	
	var value_can_achive_times := 0
	var flow_name_is_same := true
	
	for i : BaseResource.PROPERTY in BaseResource.PROPERTY.values():
		if resource.return_value(i) >= compare.return_value(i):
			value_can_achive_times += 1
	
	if resource.name:
		if resource.name != achievement_name:
			flow_name_is_same = false
		
	
	return (top_theme == resource.top_theme and 
	middle_theme == resource.middle_theme and
	buttom_theme == resource.buttom_theme and
	value_can_achive_times >= 4 and 
	flow_name_is_same
	)
