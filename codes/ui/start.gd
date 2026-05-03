extends Control
class_name StartScene

# 按钮引用
@onready var new_button: Button = $VBoxContainer/New
@onready var continue_button: Button = $VBoxContainer/Continue
@onready var saves_button: Button = $VBoxContainer/Saves
@onready var settings_button: Button = $VBoxContainer/Settings
@onready var quit_button: Button = $VBoxContainer/Quit

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

# 加载存档管理场景
func _load_save_manager_scene() -> void:
	var scene_path = "res://scenes/ui/save_manager.tscn"
	
	# 检查场景文件是否存在
	if not FileAccess.file_exists(scene_path):
		push_error("存档管理场景文件不存在: " + scene_path)
		return
	
	# 尝试加载场景
	save_manager_scene = load(scene_path)
	if save_manager_scene:
		print("存档管理场景加载成功: " + scene_path)
	else:
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
		print("找到最新存档: ", latest_save["name"], "，继续按钮已启用")
	else:
		continue_button.disabled = true
		continue_button.tooltip_text = "没有找到存档文件"
		print("未找到存档，继续按钮已禁用")

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
			file_name = dir.get_next()  # 正确：应该在while循环内更新文件名
		dir.list_dir_end()
	
	print("扫描到存档数量：", available_saves.size())

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
	
	print("新游戏存档已创建: ", save_name)
	
	# 切换到主场景
	get_tree().change_scene_to_packed(main_scene)

# 继续游戏按钮
func _on_continue_pressed() -> void:
	print("继续按钮按下")
	
	# 获取所有存档并找到最新的
	var saves = SaveResource.list_saves()
	var latest_save = _get_latest_save(saves)
	
	if not latest_save:
		print("没有找到可用的存档，无法继续")
		return
	
	print("加载最新存档: ", latest_save["name"])
	
	# 使用完整的加载函数加载所有数据（包括工匠数据）
	print("调用 SaveResource.load_complete_game_data()...")
	Global.save_resource = SaveResource.load_complete_game_data(latest_save["name"])
	print("主存档加载成功")
	print("Global.save_resource.start_list 大小: ", Global.save_resource.start_list.size())
	
	# 切换到主场景
	get_tree().change_scene_to_packed(main_scene)

# 存档管理按钮
func _on_saves_pressed() -> void:
	print("点击存档按钮，准备打开存档管理界面")
	
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
	
	print("存档管理界面实例化成功")
	
	# 修复类型错误：使用类型安全的赋值方式
	var saves_array = []
	for save_data in available_saves:
		saves_array.append(save_data)
	
	save_manager.set("available_saves", saves_array)
	
	# 修复信号连接问题
	if save_manager.has_signal("save_selected"):
		save_manager.save_selected.connect(_on_save_selected)
		print("save_selected信号连接成功")
	else:
		push_error("save_selected信号不存在")
	
	if save_manager.has_signal("save_deleted"):
		save_manager.save_deleted.connect(_on_save_deleted)
		print("save_deleted信号连接成功")
	else:
		push_error("save_deleted信号不存在")
	
	# 确保存档界面渲染在最上层
	# 使用CanvasLayer确保界面始终在最上层
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # 使用CanvasLayer的layer属性确保最上层
	
	# 添加模态背景效果
	var modal_background = ColorRect.new()
	modal_background.color = Color(0, 0, 0, 0.7)  # 更深的半透明黑色背景
	modal_background.size = get_viewport_rect().size
	modal_background.mouse_filter = Control.MOUSE_FILTER_STOP  # 阻止鼠标事件穿透到底层
	canvas_layer.add_child(modal_background)
	
	# 设置存档管理界面
	save_manager.z_index = 10  # 在CanvasLayer内设置相对层级
	save_manager.mouse_filter = Control.MOUSE_FILTER_STOP
	canvas_layer.add_child(save_manager)
	
	# 连接关闭信号以移除整个CanvasLayer
	save_manager.closed.connect(func():
		if canvas_layer.get_parent():
			canvas_layer.queue_free()
	)
	
	# 添加到场景
	add_child(canvas_layer)
	
	print("存档管理界面已添加到CanvasLayer，确保渲染在最上层")
	
	# 调试信息：显示当前打开的界面类型
	print("当前打开的界面类型: ", save_manager.get_class())
	print("界面节点路径: ", save_manager.get_path())

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
	
	# 确保设置界面渲染在最上层
	# 使用CanvasLayer确保界面始终在最上层
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # 使用CanvasLayer的layer属性确保最上层
	
	# 添加模态背景效果
	var modal_background = ColorRect.new()
	modal_background.color = Color(0, 0, 0, 0.7)  # 更深的半透明黑色背景
	modal_background.size = get_viewport_rect().size
	modal_background.mouse_filter = Control.MOUSE_FILTER_STOP  # 阻止鼠标事件穿透到底层
	canvas_layer.add_child(modal_background)
	
	# 设置设置界面
	settings_instance.z_index = 10  # 在CanvasLayer内设置相对层级
	settings_instance.mouse_filter = Control.MOUSE_FILTER_STOP
	canvas_layer.add_child(settings_instance)
	
	# 连接关闭信号以移除整个CanvasLayer
	if settings_instance.has_signal("closed"):
		settings_instance.closed.connect(func():
			print("设置界面已关闭")
			if canvas_layer.get_parent():
				canvas_layer.queue_free()
		)
	else:
		push_error("设置界面缺少closed信号")
	
	# 添加到场景
	add_child(canvas_layer)
	print("设置界面已添加到CanvasLayer，确保渲染在最上层")

# 退出游戏按钮
func _on_quit_pressed() -> void:
	# 显示确认对话框
	_show_quit_confirmation()

# 显示退出确认对话框
func _show_quit_confirmation() -> void:
	var dialog = AcceptDialog.new()
	dialog.title = "退出游戏"
	dialog.dialog_text = "确定要退出游戏吗？"
	
	dialog.confirmed.connect(func():
		print("退出游戏")
		get_tree().quit()
	)
	
	add_child(dialog)
	dialog.popup_centered()

# 存档被选择
func _on_save_selected(save_data: Dictionary) -> void:
	# 加载选中的存档
	print("===========================================")
	print("存档选择处理开始")
	print("存档数据: ", save_data)
	
	if save_data["type"] == "main":
		print("尝试加载主存档: ", save_data["name"])
		print("存档名称: ", save_data["name"])
		print("存档路径: ", save_data.get("path", "未知"))
		
		# 使用完整的加载函数加载所有数据
		print("调用 SaveResource.load_complete_game_data()...")
		Global.save_resource = SaveResource.load_complete_game_data(save_data["name"])
		
		print("主存档加载成功")
		print("Global.save_resource.start_list 大小: ", Global.save_resource.start_list.size())
		
		get_tree().change_scene_to_packed(main_scene)
		print("场景切换完成")
		print("===========================================")
	else:
		print("尝试加载备份存档: ", save_data["path"])
		# 备份存档加载（可以扩展）
		var save_resource = load(save_data["path"])
		if save_resource and save_resource is SaveResource:
			Global.save_resource = save_resource
			get_tree().change_scene_to_packed(main_scene)
			print("备份存档加载成功")

# 存档被删除
func _on_save_deleted(save_data: Dictionary) -> void:
	# 删除存档文件
	print("开始删除存档: ", save_data["name"])
	
	# 构建正确的存档目录路径
	var save_dir = "user://saves/" + save_data["directory"] + "/"
	print("删除存档目录: ", save_dir)
	
	# 使用更可靠的删除方法
	if _delete_specific_folder(save_dir):
		print("存档目录删除成功: ", save_data["name"])
	else:
		print("存档目录删除失败: ", save_data["name"])
	
	# 重新扫描存档
	_scan_available_saves()
	_update_continue_button()
	
	print("存档删除完成，继续按钮状态已更新")

# 删除特定文件夹（不递归删除整个saves目录）
func _delete_specific_folder(folder_path: String) -> bool:
	print("尝试删除特定文件夹: ", folder_path)
	
	# 直接使用现有的_delete_folder函数
	_delete_folder(folder_path)
	
	# 检查是否删除成功
	if not DirAccess.dir_exists_absolute(folder_path):
		print("删除目录成功: ", folder_path)
		return true
	else:
		print("删除目录失败: ", folder_path)
		return false

# 使用命令行方式删除文件夹（更可靠）
func _delete_folder(folder_path: String) -> void:
	print("尝试删除文件夹: ", folder_path)
	
	var dir = DirAccess.open(folder_path)
	if not dir:
		print("无法打开目录: ", folder_path)
		return
	
	if not dir.dir_exists("."):
		print("目录不存在: ", folder_path)
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
			if dir.remove(file_name) == OK:
				print("删除文件成功: ", file_name)
			else:
				print("删除文件失败: ", file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	# 删除空目录
	var parent_dir = DirAccess.open(folder_path.get_base_dir())
	if parent_dir:
		var folder_name = folder_path.get_file()
		if parent_dir.remove(folder_name) == OK:
			print("删除空目录成功: ", folder_path)
		else:
			print("删除空目录失败: ", folder_path)
	else:
		print("无法打开父目录: ", folder_path.get_base_dir())

# 清理存档目录
func _clean_save_directory() -> void:
	var dir = DirAccess.open("user://")
	if dir and dir.dir_exists("saves"):
		dir.remove("saves")

# 显示确认对话框
func _show_confirmation_dialog(title: String, message: String, callback: String) -> void:
	# 这里可以添加自定义确认对话框
	# 暂时使用控制台确认
	print(title + ": " + message)
	call(callback)

# 显示错误对话框
func _show_error_dialog(title: String, message: String) -> void:
	# 这里可以添加自定义错误对话框
	# 暂时使用控制台显示错误
	push_error(title + ": " + message)
	print(title + ": " + message)
