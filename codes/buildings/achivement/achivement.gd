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
		
	# 使用主题名称比较而不是引用比较（解决存档加载后引用不匹配的问题）
	var themes_match := _themes_are_equal(top_theme, resource.top_theme) && \
		_themes_are_equal(middle_theme, resource.middle_theme) && \
		_themes_are_equal(buttom_theme, resource.buttom_theme)
	
	return (themes_match and
		value_can_achive_times >= 4 and 
		flow_name_is_same
	)

# 比较两个主题是否相等（使用名称比较）
func _themes_are_equal(theme1: ThemeResource, theme2: ThemeResource) -> bool:
	# 两个都为空
	if not theme1 and not theme2:
		return true
	# 其中一个为空
	if not theme1 or not theme2:
		return false
	# 使用名称比较
	return theme1.name == theme2.name