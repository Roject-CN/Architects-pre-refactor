extends Node
class_name CraftsmanManager

class Media:
	var resource : CraftsmanResource
	var weight : float = 0.0
	var index : int = 0


const _craftsman_character_scene := preload("uid://drpfqa35ayqn8")

@export var _spawn_position : Marker2D
@export var _workplace_position : Array[Marker2D]
@export var main_time : MainTime
var current_list : Array[CraftsmanCharacter]


@onready var _max_amount := _workplace_position.size()

#CraftsmanCharacter实体是添加到 CraftsmanManager节点下
		
#添加新的员工
func append_new_craftsman(resource : CraftsmanResource) -> void:
	
	if current_list.size() >= _max_amount:
		return
	
	#回头搞个Craftsman_manager.tscn 搞个员工列表场景，方便进行升级和解雇人员
	var craftsman_character := _craftsman_character_scene.instantiate() as CraftsmanCharacter
	craftsman_character.craftman_resource = resource
	
	#需要先添加到 current_list 否则返回的都是 -1
	current_list.append(craftsman_character)
	Global.save_resource.start_list.append(craftsman_character.craftman_resource)
	
	craftsman_character.workplaces = _workplace_position
	craftsman_character.workplace = _workplace_position[find_character_index_by_resource(resource)]
	craftsman_character.restplace = _spawn_position
	main_time.request_go_to_rest.connect(craftsman_character.go_to_rest)
	main_time.request_go_to_work.connect(craftsman_character.go_to_work)
	
	self.add_child(craftsman_character)
	
	if main_time.can_go_to_work():
		craftsman_character.go_to_work()
	else :
		craftsman_character.go_to_rest()
#删除旧员工
func delete_craftsman(resource : CraftsmanResource) -> void:
	for i in current_list.size():
		var character:= current_list[i]
		if character.craftman_resource == resource:
			current_list.erase(character)

#返回员工们当前的状态（在工作还是在休息中）
func return_craftsman_is_working() -> bool :
	var working := false	
	if current_list.size() != 0 :
		var craftsman = current_list[0] as CraftsmanCharacter
		working = craftsman.is_working() and not craftsman.is_moving
	return working
	
func craftsman_manager_is_empty() -> bool :
	return current_list.is_empty()

#依照 某项能力值 给当前员工列表排序 从大到小
func sort_list(prop_configs : Array[BuildPropConfig]) -> Array[CraftsmanResource]:
	var target_list : Array[CraftsmanResource]
	var media_list : Array[Media] 
	for chracter : CraftsmanCharacter in current_list.duplicate():
		var media := Media.new()
		media.resource = chracter.craftman_resource
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

func craftsmans_character_process(delta : float) -> void:
	for craftsman_character : CraftsmanCharacter in self.get_children():
		#执行craftsman_character的逻辑 比如寻路导航 消耗精力值
		craftsman_character.craftsman_character_process(delta)

func find_character_index_by_resource(resource: CraftsmanResource) -> int:
	for i in current_list.size():
		var character:= current_list[i]
		if character.craftman_resource == resource:
			return i
	assert(true, "character_index is -1")
	return -1
