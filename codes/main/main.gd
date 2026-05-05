extends Node

const building_scene := preload("uid://vi2ktm4rx1n1")
const employee_scene := preload("uid://5fkp6mfhsu0w")
const achievement_scene := preload("uid://bt2uyax1vxjpb")

@onready var function: Node = $Function
#building_index 意味着建造建筑的序列，目前暂时为测试用
var building_index := 0
var current_building : Building
@export var craftsman_manager: CraftsmanManager
@export var pop_up_ui : PopUpUi

@onready var button_menu: Panel = $ButtonMenu


@onready var employee_button: Button = $ButtonMenu/MarginContainer/VBoxContainer/Employee
@onready var building_button: Button = $ButtonMenu/MarginContainer/VBoxContainer/Building
@onready var review_button: Button = $ButtonMenu/MarginContainer/VBoxContainer/Review
@onready var quit_button: Button = $ButtonMenu/MarginContainer/VBoxContainer/Quit

@onready var main_ui: MainUi = $MainUiLayer/MainUi


@export var pick_pictires : PicturePick
# 场景引用
const start_scene: PackedScene = preload("res://scenes/start.tscn")


func _ready() -> void:
	assert(craftsman_manager, "main.stcn's craftsman_manager is empty")
	
	# 检查全局存档是否已设置（由开始界面设置）
	if not Global.save_resource:
		# 如果没有设置，使用预设资源
		var resource := preload("uid://c0srmgmp32f54")
		Global.load_save_resource(resource)
	
	main_ui.init_main_ui(Global.save_resource)
	
	# 从存档恢复员工数据
	_restore_craftsmen_from_save()
	
	#building退出后让按钮可用
	Event.building_end.connect(func(): building_button.disabled = false	)
	

func _on_employee_pressed() -> void:

	if Global.save_resource.start_list.size() >= 6:
		pop_up_ui.pop_up_information("提醒", "员工数量超过，需要您先辞退其他的员工")
		return
	
	pop_up_ui.pop_up_information("提醒", "每次招募员工需花费100元", false)
	pop_up_ui._pressed.connect(func():
		if Global.save_resource.current_money >= 100:
			Global.save_resource.current_money -= 100
			var employee := employee_scene.instantiate() as CraftsmenUi
			employee.craftsman_manager = craftsman_manager
			
			function.add_child(employee)
			employee.ui_enter()
		else :
			pop_up_ui.pop_up_information("提醒", "您的金钱少于100元，所以无法招募，赚够更多的钱再来吧")
		, CONNECT_ONE_SHOT)
	
	

# 员工列表按钮按下
func _on_craftsmen_list_pressed() -> void:
	# 加载员工列表场景
	var craftsmen_list_scene_path = "res://scenes/ui/craftsmen/craftsmen_list.tscn"
	
	# 检查场景文件是否存在
	if not FileAccess.file_exists(craftsmen_list_scene_path):
		push_error("员工列表场景文件不存在: " + craftsmen_list_scene_path)
		return
	
	# 尝试加载场景
	var craftsmen_list_scene = load(craftsmen_list_scene_path)
	if not craftsmen_list_scene:
		push_error("员工列表场景加载失败: " + craftsmen_list_scene_path)
		return
	
	# 实例化员工列表界面
	var craftsmen_list_instance = craftsmen_list_scene.instantiate()
	
	# 使用CanvasLayer确保界面始终在最上层
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	
	# 添加模态背景效果
	var modal_background = ColorRect.new()
	modal_background.color = Color(0, 0, 0, 0.7)
	modal_background.size = Vector2(1920, 1080)
	modal_background.mouse_filter = Control.MOUSE_FILTER_STOP
	canvas_layer.add_child(modal_background)
	
	# 延迟设置背景尺寸以适应视口
	call_deferred("_set_modal_background_size", modal_background)
	
	canvas_layer.add_child(craftsmen_list_instance)
	
	# 连接关闭信号以移除整个CanvasLayer
	if craftsmen_list_instance.has_signal("closed"):
		var close_callback = func():
			if canvas_layer.get_parent():
				canvas_layer.queue_free()
			# 刷新员工数据并保存到文件
			_sync_craftsmen_to_save()
			Global.save_save_resource()
		
		craftsmen_list_instance.closed.connect(close_callback)
	
	# 添加到场景
	add_child(canvas_layer)

# 设置模态背景尺寸
func _set_modal_background_size(modal_background: ColorRect) -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	modal_background.size = viewport_size

func _on_building_pressed() -> void:
	if craftsman_manager.craftsman_manager_is_empty():
		pop_up_ui.pop_up_information("提醒", "当前没有员工可以供您派遣，所以请先招募员工")
		return
	
	if Global.themes_empty():
		pop_up_ui.pop_up_information("提醒", "请先研究 上分 中分 和下分的建筑主题")
		return
		
	if not craftsman_manager.return_craftsman_is_working():
		pop_up_ui.pop_up_information("提醒", "当前员工还没有在工位上，请在他们正式开始工作后再来吧")
		return
	var building_resource := BuildingResource.new()
	var building := building_scene.instantiate() as Building
	building.building_resource = building_resource
	building.craftsman_manager = craftsman_manager
	building_resource.index = building_index
	building_index += 1
	building.pick = pick_pictires
	function.add_child(building)
	building_button.disabled = true


func _on_review_pressed() -> void:
	# 加载history场景
	var history_scene_path = "res://scenes/ui/history.tscn"
	
	# 检查场景文件是否存在
	if not FileAccess.file_exists(history_scene_path):
		push_error("history场景文件不存在: " + history_scene_path)
		return
	
	# 尝试加载场景
	var history_scene = load(history_scene_path)
	if not history_scene:
		push_error("history场景加载失败: " + history_scene_path)
		return
	
	# 实例化场景
	var history_ui = history_scene.instantiate()
	if not history_ui:
		push_error("history场景实例化失败")
		return
	
	# 使用CanvasLayer确保界面始终在最上层
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	
	# 添加模态背景效果
	var modal_background = ColorRect.new()
	modal_background.color = Color(0, 0, 0, 0.7)
	modal_background.size = Vector2(1920, 1080)
	modal_background.mouse_filter = Control.MOUSE_FILTER_STOP
	canvas_layer.add_child(modal_background)

	canvas_layer.add_child(history_ui)
	
	# 添加到场景树
	get_tree().root.add_child(canvas_layer)

#主题科技树解锁
func _on_theme_pressed() -> void:
	button_menu.visible = false
	var theme_tree := preload("res://scenes/ui/theme_tree/theme_tree.tscn").instantiate() as ThemeTree
	if not theme_tree.theme_tree_quit.is_connected(theme_tree_quited):
		theme_tree.theme_tree_quit.connect(theme_tree_quited)
	add_child(theme_tree)

func theme_tree_quited() -> void:
	button_menu.visible = true

# 同步员工数据到存档资源
func _sync_craftsmen_to_save() -> void:
	# 清空存档中的员工列表
	Global.save_resource.start_list.clear()
	
	# 将工匠管理器中的员工数据同步到存档
	for character in craftsman_manager.current_list:
		if character.craftman_resource:
			Global.save_resource.start_list.append(character.craftman_resource)
	
	# 立即保存到文件
	Global.save_save_resource()

# 从存档恢复员工数据
func _restore_craftsmen_from_save() -> void:
	# 检查全局存档状态
	if not Global.save_resource or not Global.save_resource.start_list:
		return
	
	# 从存档资源恢复员工（使用immediate_sync=false避免重复同步）
	for resource in Global.save_resource.start_list:
		if resource is CraftsmanResource:
			craftsman_manager.append_new_craftsman(resource, false)
	
	# 恢复完成后统一同步一次
	craftsman_manager._sync_to_global_save()

# 刷新员工列表数据
func refresh_craftsmen_list() -> void:
	# 同步员工数据到存档
	_sync_craftsmen_to_save()
	
	# 查找并刷新员工列表界面
	for child in get_children():
		if child is CanvasLayer:
			for canvas_child in child.get_children():
				if canvas_child is CraftsmenList and canvas_child.has_method("refresh_list"):
					canvas_child.refresh_list()
					break

# 获取员工管理器（供其他界面调用）
func _get_craftsman_manager() -> CraftsmanManager:
	return craftsman_manager

# 退出游戏按钮 - 返回主菜单并保存游戏
func _on_quit_pressed() -> void:
	
	pop_up_ui.pop_up_information("退出游戏", "确定要退出游戏吗？", false)
	pop_up_ui._pressed.connect(
		func():
			# 同步员工数据到存档资源
			_sync_craftsmen_to_save()
			# 更新存档名称为当前时间（用于按最后打开时间排序）
			_update_save_name_with_timestamp()
			# 保存当前游戏进度（包括建筑历史）
			Global.save_save_resource()
			pop_up_ui.pop_up_information("游戏保存", "游戏进度已保存，即将返回主菜单")
			pop_up_ui._pressed.connect(func() :
				var start_scene_path = "res://scenes/start.tscn"
				if FileAccess.file_exists(start_scene_path):
					get_tree().change_scene_to_file(start_scene_path)
				, CONNECT_ONE_SHOT)	
	, CONNECT_ONE_SHOT)
	
	

# 更新存档名称为当前时间戳
func _update_save_name_with_timestamp() -> void:
	if not Global.save_resource:
		return
	
	# 生成新的存档名称（带当前时间戳）
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	var old_save_name = Global.save_resource.save_name
	var new_save_name = "存档_" + timestamp
	
	# 如果名称已经是时间戳格式，直接更新
	if old_save_name.begins_with("存档_"):
		Global.save_resource.save_name = new_save_name
	
	# 更新存档目录名称（如果需要）
	_update_save_directory(old_save_name, new_save_name)

# 更新存档目录名称
func _update_save_directory(old_name: String, new_name: String) -> void:
	if old_name == new_name:
		return
	
	var old_dir = "user://saves/" + old_name + "/"
	var new_dir = "user://saves/" + new_name + "/"
	
	# 如果旧目录存在且新目录不存在，尝试重命名
	if DirAccess.dir_exists_absolute(old_dir) and not DirAccess.dir_exists_absolute(new_dir):
		var dir = DirAccess.open("user://saves/")
		if dir:
			var result = dir.rename(old_name, new_name)
			if result != OK:
				# 如果重命名失败，继续使用旧目录，但更新save_name
				Global.save_resource.save_name = new_name



func _on_achievement_pressed() -> void:
	
	var ach_ui = achievement_scene.instantiate()
		
	# 使用CanvasLayer确保界面始终在最上层
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	
	# 添加模态背景效果
	var modal_background = ColorRect.new()
	modal_background.color = Color(0, 0, 0, 0.7)
	modal_background.size = Vector2(1920, 1080)
	modal_background.mouse_filter = Control.MOUSE_FILTER_STOP
	canvas_layer.add_child(modal_background)
	
	canvas_layer.add_child(ach_ui)
	# 添加到场景树
	get_tree().root.add_child(canvas_layer)