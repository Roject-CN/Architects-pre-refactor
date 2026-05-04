extends Control
class_name SaveManager

# 信号
signal save_selected(save_data: Dictionary)
signal save_deleted(save_data: Dictionary)
signal closed()

# 存档数据
var available_saves: Array = []

# UI引用
@onready var save_list: VBoxContainer = $Panel/MarginContainer/VBoxContainer/ScrollContainer/SaveList
@onready var close_button: Button = $Panel/MarginContainer/VBoxContainer/HBoxContainer/Close

func _ready() -> void:
	# 连接信号
	close_button.pressed.connect(_on_close_pressed)
	
	# 刷新存档列表
	_refresh_save_list()

# 刷新存档列表
func _refresh_save_list() -> void:
	# 清空现有列表
	for child in save_list.get_children():
		child.queue_free()
	
	# 按时间排序存档（最新的在前）
	_sort_saves_by_time()
	
	# 添加存档项
	for save_data in available_saves:
		if save_data is Dictionary:
			var save_item = _create_save_item(save_data)
			save_list.add_child(save_item)
	
	# 如果没有存档，显示提示
	if available_saves.is_empty():
		var empty_label = Label.new()
		empty_label.text = "没有找到存档文件"
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.add_theme_font_size_override("font_size", 16)
		save_list.add_child(empty_label)

# 按时间排序存档（最新的在前）
func _sort_saves_by_time() -> void:
	available_saves.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var time_a = _extract_timestamp_from_name(a["name"])
		var time_b = _extract_timestamp_from_name(b["name"])
		return time_a > time_b
	)
	print("存档列表已按时间排序")

# 从存档名称提取时间戳
func _extract_timestamp_from_name(name: String) -> float:
	# 存档名称格式: 存档_2026-05-04T14-49-20
	if name.begins_with("存档_"):
		var timestamp_str = name.substr(3)  # 去掉"存档_"
		return _parse_timestamp(timestamp_str)
	
	# 非时间戳格式的存档，返回0（排在最后）
	return 0

# 解析时间戳字符串
func _parse_timestamp(timestamp_str: String) -> float:
	# 格式: 2026-05-04T14-49-20
	var parts = timestamp_str.replace("T", "-").split("-")
	if parts.size() >= 6:
		var year = parts[0].to_int()
		var month = parts[1].to_int()
		var day = parts[2].to_int()
		var hour = parts[3].to_int()
		var minute = parts[4].to_int()
		var second = parts[5].to_int()
		
		# 计算总秒数作为排序依据
		return year * 31536000 + month * 2592000 + day * 86400 + hour * 3600 + minute * 60 + second
	
	return 0

# 创建存档项
func _create_save_item(save_data: Dictionary) -> HBoxContainer:
	var container = HBoxContainer.new()
	container.add_theme_constant_override("separation", 10)
	
	# 存档信息
	var info_container = VBoxContainer.new()
	info_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# 存档名称
	var name_label = Label.new()
	name_label.text = save_data["name"]
	name_label.add_theme_font_size_override("font_size", 16)
	info_container.add_child(name_label)
	
	# 存档详细信息
	var info = save_data["info"]
	if not info.is_empty():
			var details_label = Label.new()
			details_label.text = "金钱: %d | 名气: %d | 建筑: %d | 天数: %d天" % [
				info.get("money", 0),
				info.get("fame", 0),
				info.get("building_count", 0),
				info.get("days", 0)
			]
			details_label.add_theme_font_size_override("font_size", 12)
			details_label.modulate = Color(0.8, 0.8, 0.8)
			info_container.add_child(details_label)
	
	container.add_child(info_container)
	
	# 操作按钮容器
	var button_container = HBoxContainer.new()
	button_container.add_theme_constant_override("separation", 5)
	
	# 加载按钮
	var load_button = Button.new()
	load_button.text = "加载"
	load_button.custom_minimum_size = Vector2(60, 30)
	load_button.pressed.connect(_on_load_pressed.bind(save_data))
	button_container.add_child(load_button)
	
	# 删除按钮
	var delete_button = Button.new()
	delete_button.text = "删除"
	delete_button.custom_minimum_size = Vector2(60, 30)
	
	# 删除按钮样式（红色警示）
	var delete_style = StyleBoxFlat.new()
	delete_style.bg_color = Color(0.8, 0.3, 0.3)
	delete_style.corner_radius_top_left = 4
	delete_style.corner_radius_top_right = 4
	delete_style.corner_radius_bottom_left = 4
	delete_style.corner_radius_bottom_right = 4
	delete_button.add_theme_stylebox_override("normal", delete_style)
	
	delete_button.pressed.connect(_on_delete_pressed.bind(save_data))
	button_container.add_child(delete_button)
	
	container.add_child(button_container)
	
	return container

# 加载存档
func _on_load_pressed(save_data: Dictionary) -> void:
	save_selected.emit(save_data)
	queue_free()

# 删除存档
func _on_delete_pressed(save_data: Dictionary) -> void:
	print("点击删除按钮，存档数据: ", save_data["name"])
	# 显示确认对话框
	_show_delete_confirmation(save_data)

# 显示删除确认
func _show_delete_confirmation(save_data: Dictionary) -> void:
	var dialog = AcceptDialog.new()
	dialog.title = "确认删除"
	dialog.dialog_text = "确定要删除存档 '%s' 吗？此操作不可恢复。" % save_data["name"]
	
	# 连接确认信号（使用闭包确保正确传递数据）
	dialog.confirmed.connect(func():
		_on_delete_confirmed(save_data)
		dialog.queue_free()
	)
	
	add_child(dialog)
	dialog.popup_centered()

# 删除确认处理
func _on_delete_confirmed(save_data: Dictionary) -> void:
	print("确认删除存档: ", save_data["name"])
	
	# 发出删除信号
	save_deleted.emit(save_data)
	
	# 使用名称查找并删除（更可靠）
	var found_index = -1
	for i in range(available_saves.size()):
		if available_saves[i]["name"] == save_data["name"]:
			found_index = i
			break
	
	if found_index != -1:
		available_saves.remove_at(found_index)
		print("已从列表中移除存档")
	
	# 刷新列表
	_refresh_save_list()
	
	print("删除操作完成")

# 关闭按钮
func _on_close_pressed() -> void:
	closed.emit()
	queue_free()

# 处理输入事件（ESC键关闭）
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_close_pressed()
		get_viewport().set_input_as_handled()