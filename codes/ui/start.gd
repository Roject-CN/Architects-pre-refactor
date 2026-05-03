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
	var main_save_path = "user://saves/main_save.tres"
	if ResourceLoader.exists(main_save_path):
		continue_button.disabled = false
		continue_button.tooltip_text = "继续上次的游戏进度"
	else:
		continue_button.disabled = true
		continue_button.tooltip_text = "没有找到存档文件"

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
	# 加载最近的存档
	print("正在加载存档...")
	
	# 获取所有存档
	var saves = SaveResource.list_saves()
	
	if saves.size() > 0:
		# 加载第一个存档（可以根据需要修改为加载最新的）
		var latest_save = saves[0]
		Global.save_resource = SaveResource.load_complete_game_data(latest_save["directory"])
		
		if Global.save_resource:
			print("存档加载成功: 名称=", Global.save_resource.save_name, ", 金钱=", Global.save_resource.current_money)
			get_tree().change_scene_to_packed(main_scene)
		else:
			_show_error_dialog("存档加载失败", "无法加载存档文件。")
	else:
		# 没有存档，开始新游戏
		_show_error_dialog("没有存档", "没有找到存档文件，将开始新游戏。")
		_start_new_game()

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
	if save_data["type"] == "main":
		print("尝试加载主存档: ", save_data["name"])
		# 使用完整的加载函数加载所有数据
		Global.save_resource = SaveResource.load_complete_game_data(save_data["name"])
		print("主存档加载成功")
		get_tree().change_scene_to_packed(main_scene)
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
	
	if save_data["type"] == "main":
		# 删除主存档目录（使用FileAccess删除整个目录）
		var saves_path = "user://saves"
		_delete_folder(saves_path)
		print("主存档目录已删除")
	elif save_data["type"] == "backup":
		# 删除备份存档目录
		var backup_name = save_data["name"].replace("备份-", "backup_")
		var backup_path = "user://saves/" + backup_name
		_delete_folder(backup_path)
		print("备份存档目录已删除: ", backup_path)
	
	# 重新扫描存档
	_scan_available_saves()
	_update_continue_button()

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
	
	# 删除所有内容
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			# 递归删除子目录
			_delete_folder(folder_path + "/" + file_name)
		else:
			# 删除文件
			var file_path = folder_path + "/" + file_name
			var file_access = FileAccess.open(file_path, FileAccess.WRITE)
			if file_access:
				file_access.close()
				if dir.remove(file_name) == OK:
					print("删除文件成功: ", file_name)
				else:
					print("删除文件失败: ", file_name)
			else:
				print("无法打开文件: ", file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	# 返回上级目录并删除空目录
	var parent_dir = DirAccess.open("user://")
	if parent_dir:
		var folder_name = folder_path.get_file()
		if parent_dir.dir_exists(folder_name):
			if parent_dir.remove(folder_name) == OK:
				print("删除目录成功: ", folder_path)
			else:
				print("删除目录失败: ", folder_path)

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
