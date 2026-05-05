extends Control
class_name StartScene

# 按钮引用
@onready var new_button: Button = $VBoxContainer/New
@onready var continue_button: Button = $VBoxContainer/Continue
@onready var saves_button: Button = $VBoxContainer/Saves
@onready var settings_button: Button = $VBoxContainer/Settings
@onready var quit_button: Button = $VBoxContainer/Quit
@onready var pop_up_ui: PopUpUi = $PopUpUi

# 场景引用
const main_scene: PackedScene = preload("res://scenes/main.tscn")
var save_manager_scene: PackedScene

func _ready() -> void:
	# 连接按钮信号
	new_button.pressed.connect(_on_new_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	saves_button.pressed.connect(_on_saves_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# 加载存档管理场景
	_load_save_manager_scene()
	
	# 检查是否有存档可以继续
	_update_continue_button()
	
	# 扫描可用存档
	_scan_available_saves()
	
	pop_up_ui.hide()
# 加载存档管理场景
func _load_save_manager_scene() -> void:
	var scene_path = "res://scenes/ui/save_manager.tscn"
	
	# 检查场景文件是否存在
	if not FileAccess.file_exists(scene_path):
		push_error("存档管理场景文件不存在: " + scene_path)
		return
	
	# 尝试加载场景
	save_manager_scene = load(scene_path)
	if not save_manager_scene:
		push_error("存档管理场景加载失败: " + scene_path)

# 存档相关
var available_saves: Array[Dictionary] = []

# 更新继续按钮状态
func _update_continue_button() -> void:
	# 获取所有存档并找到最新的
	var saves = SaveResource.list_saves()
	var latest_save = _get_latest_save(saves)
	
	if latest_save:
		continue_button.disabled = false
		continue_button.tooltip_text = "继续游戏 - " + latest_save["name"]
		continue_button.get_tooltip()
	else:
		continue_button.disabled = true
		continue_button.tooltip_text = "没有找到存档文件"

# 获取最新的存档
func _get_latest_save(saves: Array) -> Dictionary:
	if saves.is_empty():
		return {}
	
	# 如果没有多个存档，直接返回第一个
	if saves.size() == 1:
		return saves[0]
	
	# 按目录名称排序（假设目录名称包含时间信息）
	var sorted_saves = saves.duplicate()
	sorted_saves.sort_custom(func(a, b): return a["directory"] > b["directory"])
	
	return sorted_saves[0]

# 扫描可用存档
func _scan_available_saves() -> void:
	available_saves.clear()
	
	# 使用SaveResource的list_saves方法获取所有存档
	var saves = SaveResource.list_saves()
	
	for save_data in saves:
		available_saves.append({
			"name": save_data["name"],
			"directory": save_data["directory"],
			"info": save_data["info"],
			"type": "main"
		})
	
	# 扫描备份存档
	var dir = DirAccess.open("user://saves/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.begins_with("backup_") and dir.current_is_dir():
				var backup_path = "user://saves/" + file_name + "/save.tres"
				if ResourceLoader.exists(backup_path):
					var save_info = _get_save_info(backup_path)
					if save_info:
						available_saves.append({
							"name": file_name.replace("backup_", "备份-"),
							"path": backup_path,
							"info": save_info,
							"type": "backup"
						})
			file_name = dir.get_next()
		dir.list_dir_end()

# 获取存档信息
func _get_save_info(save_path: String) -> Dictionary:
	var save_resource = load(save_path)
	if save_resource and save_resource is SaveResource:
		return save_resource.get_save_info()
	return {}

# 新游戏按钮
func _on_new_pressed() -> void:
	# 生成新存档名称（带时间戳）
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	var new_save_name = "存档_" + timestamp
	
	# 创建新存档
	_start_new_game(new_save_name)

# 开始新游戏（带存档名称）
func _start_new_game(save_name: String = "新存档") -> void:
	# 创建新的SaveResource
	var new_save = SaveResource.create_new_save(save_name)
	
	# 设置全局存档并保存
	Global.save_resource = new_save
	Global.save_save_resource()
	
	# 切换到主场景
	get_tree().change_scene_to_packed(main_scene)

# 继续游戏按钮
func _on_continue_pressed() -> void:
	# 获取所有存档并找到最新的
	var saves = SaveResource.list_saves()
	var latest_save = _get_latest_save(saves)
	
	if not latest_save:
		return
	
	# 使用完整的加载函数加载所有数据
	Global.save_resource = SaveResource.load_complete_game_data(latest_save["name"])
	
	# 切换到主场景
	get_tree().change_scene_to_packed(main_scene)

# 存档管理按钮
func _on_saves_pressed() -> void:
	# 检查场景是否有效
	if not save_manager_scene:
		push_error("save_manager_scene场景加载失败")
		# 尝试重新加载
		_load_save_manager_scene()
		if not save_manager_scene:
			return
	
	# 打开存档管理界面
	var save_manager = save_manager_scene.instantiate()
	
	# 检查实例化是否成功
	if not save_manager:
		push_error("存档管理界面实例化失败")
		return
	
	# 使用类型安全的赋值方式
	var saves_array = []
	for save_data in available_saves:
		saves_array.append(save_data)
	
	save_manager.set("available_saves", saves_array)
	
	# 连接信号
	if save_manager.has_signal("save_selected"):
		save_manager.save_selected.connect(_on_save_selected)
	else:
		push_error("save_selected信号不存在")
	
	if save_manager.has_signal("save_deleted"):
		save_manager.save_deleted.connect(_on_save_deleted)
	else:
		push_error("save_deleted信号不存在")
	
	# 使用CanvasLayer确保界面始终在最上层
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	
	# 添加模态背景效果
	var modal_background = ColorRect.new()
	modal_background.color = Color(0, 0, 0, 0.7)
	modal_background.size = get_viewport_rect().size
	modal_background.mouse_filter = Control.MOUSE_FILTER_STOP
	canvas_layer.add_child(modal_background)
	
	# 设置存档管理界面
	save_manager.z_index = 10
	save_manager.mouse_filter = Control.MOUSE_FILTER_STOP
	canvas_layer.add_child(save_manager)
	
	# 连接关闭信号以移除整个CanvasLayer
	save_manager.closed.connect(func():
		if canvas_layer.get_parent():
			canvas_layer.queue_free()
	)
	
	# 添加到场景
	add_child(canvas_layer)

# 设置按钮
func _on_settings_pressed() -> void:
	# 加载设置场景
	var settings_scene_path = "res://scenes/ui/settings.tscn"
	
	# 检查场景文件是否存在
	if not FileAccess.file_exists(settings_scene_path):
		push_error("设置场景文件不存在: " + settings_scene_path)
		return
	
	# 尝试加载场景
	var settings_scene = load(settings_scene_path)
	if not settings_scene:
		push_error("设置场景加载失败: " + settings_scene_path)
		return
	
	# 实例化设置界面
	var settings_instance = settings_scene.instantiate()
	
	# 使用CanvasLayer确保界面始终在最上层
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100
	
	# 添加模态背景效果
	var modal_background = ColorRect.new()
	modal_background.color = Color(0, 0, 0, 0.7)
	modal_background.size = get_viewport_rect().size
	modal_background.mouse_filter = Control.MOUSE_FILTER_STOP
	canvas_layer.add_child(modal_background)
	
	# 设置设置界面
	settings_instance.z_index = 10
	settings_instance.mouse_filter = Control.MOUSE_FILTER_STOP
	canvas_layer.add_child(settings_instance)
	
	# 连接关闭信号以移除整个CanvasLayer
	if settings_instance.has_signal("closed"):
		settings_instance.closed.connect(func():
			if canvas_layer.get_parent():
				canvas_layer.queue_free()
		)
	else:
		push_error("设置界面缺少closed信号")
	
	# 添加到场景
	add_child(canvas_layer)

# 退出游戏按钮
func _on_quit_pressed() -> void:
	# 显示确认对话框
	_show_quit_confirmation()

# 显示退出确认对话框
func _show_quit_confirmation() -> void:
	pop_up_ui.pop_up_information("退出游戏", "确定要退出游戏吗？", false)
	pop_up_ui._pressed.connect(func():
		get_tree().quit(), CONNECT_ONE_SHOT)


# 存档被选择
func _on_save_selected(save_data: Dictionary) -> void:
	# 加载选中的存档
	if save_data["type"] == "main":
		# 使用完整的加载函数加载所有数据
		Global.save_resource = SaveResource.load_complete_game_data(save_data["name"])
		get_tree().change_scene_to_packed(main_scene)
	else:
		# 备份存档加载
		var save_resource = load(save_data["path"])
		if save_resource and save_resource is SaveResource:
			Global.save_resource = save_resource
			get_tree().change_scene_to_packed(main_scene)

# 存档被删除
func _on_save_deleted(save_data: Dictionary) -> void:
	# 删除存档文件
	var save_dir = "user://saves/" + save_data["directory"] + "/"
	
	# 使用更可靠的删除方法
	_delete_specific_folder(save_dir)
	
	# 重新扫描存档
	_scan_available_saves()
	_update_continue_button()

# 删除特定文件夹（不递归删除整个saves目录）
func _delete_specific_folder(folder_path: String) -> bool:
	# 直接使用现有的_delete_folder函数
	_delete_folder(folder_path)
	
	# 检查是否删除成功
	return not DirAccess.dir_exists_absolute(folder_path)

# 使用命令行方式删除文件夹（更可靠）
func _delete_folder(folder_path: String) -> void:
	var dir = DirAccess.open(folder_path)
	if not dir:
		return
	
	if not dir.dir_exists("."):
		return
	
	# 先删除所有文件和子目录
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue
			
		var full_path = folder_path.path_join(file_name)
		
		if dir.current_is_dir():
			# 递归删除子目录
			_delete_folder(full_path)
		else:
			# 删除文件
			dir.remove(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	# 删除空目录
	var parent_dir = DirAccess.open(folder_path.get_base_dir())
	if parent_dir:
		var folder_name = folder_path.get_file()
		parent_dir.remove(folder_name)

# 清理存档目录
func _clean_save_directory() -> void:
	var dir = DirAccess.open("user://")
	if dir and dir.dir_exists("saves"):
		dir.remove("saves")
