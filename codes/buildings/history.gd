extends Control
class_name HistoryScene

# 信号
signal closed()

# UI引用
@onready var close_button: Button = $Panel/MarginContainer/VBoxContainer/HBoxContainer/Close
@onready var history_list = $Panel/MarginContainer/VBoxContainer/ScrollContainer/HistoryList

func _ready() -> void:
	# 连接关闭按钮信号
	close_button.pressed.connect(_on_close_pressed)
	
	# 延迟加载数据
	call_deferred("_load_history_data")

# 延迟加载历史数据
func _load_history_data() -> void:
	# 获取历史列表容器
	if not history_list:
		_show_empty_state(history_list)
		return
	
	# 清空现有列表
	for child in history_list.get_children():
		child.queue_free()
	
	# 检查全局存档
	if not Global.save_resource:
		_show_empty_state(history_list)
		return
	
	# 获取建筑数据
	var buildings = Global.save_resource.save_building_resources
	if not buildings or buildings.is_empty():
		_show_empty_state(history_list)
		return
	
	# 显示建筑列表
	for building in buildings:
		var building_item = _create_building_item(building)
		history_list.add_child(building_item)

# 显示空状态
func _show_empty_state(container: VBoxContainer) -> void:
	var empty_label = Label.new()
	empty_label.text = "暂无历史建筑记录"
	empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty_label.add_theme_font_size_override("font_size", 16)
	container.add_child(empty_label)

# 创建建筑项
func _create_building_item(building: BuildingResource) -> Control:
	var container = HBoxContainer.new()
	container.add_theme_constant_override("separation", 15)
	
	# 添加背景样式
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	stylebox.content_margin_left = 10
	stylebox.content_margin_right = 10
	stylebox.content_margin_top = 10
	stylebox.content_margin_bottom = 10
	container.add_theme_stylebox_override("panel", stylebox)
	
	# 建筑图片（略微放大到72x72）
	var texture_rect = TextureRect.new()
	texture_rect.custom_minimum_size = Vector2(72, 72)
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	if building.texture:
		texture_rect.texture = building.texture
	
	container.add_child(texture_rect)
	
	# 建筑信息（垂直排列）
	var info_container = VBoxContainer.new()
	info_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_container.add_theme_constant_override("separation", 5)
	
	# 建筑名称（只在有名称时显示）
	if building.name and building.name.strip_edges() != "":
		var name_label = Label.new()
		name_label.text = building.name
		name_label.add_theme_font_size_override("font_size", 14)
		name_label.modulate = Color.WHITE
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		info_container.add_child(name_label)
	
	# 创建网格布局容器，确保上下对齐
	var grid_container = HBoxContainer.new()
	grid_container.add_theme_constant_override("separation", 10)
	
	var all_names = ["匠心类", "工料类", "设计类", "风水类", "上分", "中分", "下分"]
	
	# 为每个属性创建垂直容器（名称在上，值在下）
	for i in range(all_names.size()):
		var item_vbox = VBoxContainer.new()
		item_vbox.add_theme_constant_override("separation", 2)
		item_vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		item_vbox.custom_minimum_size = Vector2(45, 0)  # 减小最小宽度
		
		# 属性名称（第一行）
		var name_label = Label.new()
		name_label.text = all_names[i]
		name_label.add_theme_font_size_override("font_size", 11)
		name_label.modulate = Color(0.7, 0.7, 0.7)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		item_vbox.add_child(name_label)
		
		# 属性值（第二行）
		var value_label = Label.new()
		if i < 4:
			# 四维属性
			var value = _get_attribute_value(building, i)
			value_label.text = str(value)
			value_label.modulate = Color(0.9, 0.9, 0.9)
		else:
			# 三分主题
			var theme_index = i - 4
			var themes = [building.top_theme, building.middle_theme, building.buttom_theme]
			if themes[theme_index] and themes[theme_index].name:
				value_label.text = themes[theme_index].name
			else:
				value_label.text = "无"
			value_label.modulate = Color(0.9, 0.7, 0.5)  # 金色高亮
		
		value_label.add_theme_font_size_override("font_size", 12)
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		item_vbox.add_child(value_label)
		
		grid_container.add_child(item_vbox)
	
	info_container.add_child(grid_container)
	
	container.add_child(info_container)
	
	return container

# 获取建筑属性值
func _get_attribute_value(building: BuildingResource, index: int) -> int:
	# BuildingResource继承自BaseResource，有values属性
	if building.values and building.values is Dictionary:
		# 属性顺序：匠心类、工料类、设计类、风水类
		var attr_names = ["匠心类", "工料类", "设计类", "风水类"]
		if index < attr_names.size():
			return building.values.get(attr_names[index], 0)
	
	return 0

# 关闭按钮按下
func _on_close_pressed() -> void:
	closed.emit()
	
	# 获取父节点（CanvasLayer）并销毁它
	var parent_node = get_parent()
	if parent_node:
		parent_node.queue_free()
	else:
		# 如果没有父节点，直接销毁自己
		queue_free()

# 处理输入事件（ESC键关闭）
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_close_pressed()
		get_viewport().set_input_as_handled()
