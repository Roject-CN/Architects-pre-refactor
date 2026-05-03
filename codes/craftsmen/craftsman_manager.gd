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
#signal current_list_changed()
#添加新的员工
# immediate_sync: 是否立即同步到存档（默认为true，恢复数据时设为false）
func append_new_craftsman(resource : CraftsmanResource, immediate_sync: bool = true) -> void:
	
	if current_list.size() >= _max_amount:
		#后面可以增加提醒的ui
		return
	
	#回头搞个Craftsman_manager.tscn 搞个员工列表场景，方便进行升级和解雇人员
	var craftsman_character := _craftsman_character_scene.instantiate() as CraftsmanCharacter
	craftsman_character.craftman_resource = resource
	
	#需要先添加到 current_list 否则返回的都是 -1
	current_list.append(craftsman_character)
	
	# 将员工添加到场景树中，确保员工可见和可操作
	add_child(craftsman_character)
	
	# 安全检查：确保位置引用不为空
	if _workplace_position and _workplace_position.size() > 0:
		craftsman_character.workplaces = _workplace_position
		var index = find_character_index_by_resource(resource)
		if index < _workplace_position.size():
			craftsman_character.workplace = _workplace_position[index]
		else:
			push_warning("CraftsmanManager: workplace index out of bounds, using first position")
			craftsman_character.workplace = _workplace_position[0]
	else:
		push_warning("CraftsmanManager: _workplace_position is empty")
	
	if _spawn_position:
		craftsman_character.restplace = _spawn_position
	else:
		push_warning("CraftsmanManager: _spawn_position is null")
	
	print("员工已添加到场景树: ", resource.name)
	
	# 连接主时间信号
	main_time.request_go_to_rest.connect(craftsman_character.go_to_rest)
	main_time.request_go_to_work.connect(craftsman_character.go_to_work)
	
	# 让员工开始工作
	craftsman_character.go_to_work()
	
	# 根据参数决定是否立即同步员工数据到全局存档
	if immediate_sync:
		_sync_to_global_save()

# 同步员工数据到全局存档
func _sync_to_global_save() -> void:
	if Global.save_resource:
		# 清空存档中的员工列表
		Global.save_resource.start_list.clear()
		
		# 将当前员工列表同步到存档
		for character in current_list:
			if character.craftman_resource:
				Global.save_resource.start_list.append(character.craftman_resource)
		
		print("员工数据已同步到全局存档，数量: ", Global.save_resource.start_list.size())
		
		# 立即保存到文件
		Global.save_save_resource()
		print("员工数据已保存到文件")
	else:
		push_warning("CraftsmanManager: Global.save_resource 为空，无法同步数据")

#删除旧员工
func delete_craftsman(resource : CraftsmanResource) -> void:
	# 使用反向遍历避免数组越界错误
	for i in range(current_list.size() - 1, -1, -1):
		var character = current_list[i]
		if character.craftman_resource == resource:
			# 从场景中移除角色节点
			if character.get_parent():
				character.queue_free()
			# 从列表中移除
			current_list.remove_at(i)
			print("员工已从管理器中移除: ", resource.name)
			break  # 找到后立即退出循环

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