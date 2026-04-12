@warning_ignore("missing_tool")
extends BaseResource
class_name BuildingResource

@export_group("Attribution")
@export var name : String
@export var index : int
@export var cost : int
#应当还有一个属性用来包含建筑的上中下分的建筑主题

@export_group("Visual")
@export var texture : Texture
@export_multiline var description : String

@export_group("Theme")
@export var top_theme : ThemeResource
@export var middle_theme : ThemeResource
@export var buttom_theme : ThemeResource

func add_theme(type : ThemeResource.TYPE, theme_resource : ThemeResource) -> void:
	if type == ThemeResource.TYPE.上分:
		top_theme = theme_resource
	elif type == ThemeResource.TYPE.中分:
		middle_theme = theme_resource
	elif type == ThemeResource.TYPE.下分:
		buttom_theme = theme_resource

func return_themes_is_full() -> bool:
	return top_theme and middle_theme and buttom_theme
