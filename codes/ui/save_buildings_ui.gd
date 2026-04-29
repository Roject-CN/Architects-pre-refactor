extends Control

var _list: VBoxContainer

func _ready():
	var window_size = get_viewport().get_visible_rect().size
	var panel_width = min(window_size.x * 0.85, 800)
	var panel_height = min(window_size.y * 0.8, 600)
	
	set_anchors_preset(Control.PRESET_FULL_RECT)
	set_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 背景
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.08, 0.92)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.set_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(bg)
	
	# 居中容器
	var outer_center := CenterContainer.new()
	outer_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	outer_center.set_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(outer_center)
	
	# 主面板
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(panel_width, panel_height)
	outer_center.add_child(panel)
	
	# 面板样式
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.18)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	panel.add_theme_stylebox_override("panel", style)
	
	# 边距容器
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)
	
	# 标题
	var title := Label.new()
	title.text = "建筑史册"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", min(window_size.y * 0.04, 24))
	vbox.add_child(title)
	vbox.add_child(HSeparator.new())
	
	# 滚动列表
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)
	
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 12)
	scroll.add_child(_list)
	
	# 关闭按钮区域改为两个按钮
	var btn_hbox := HBoxContainer.new()
	btn_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_hbox.add_theme_constant_override("separation", 20)
	vbox.add_child(btn_hbox)
	
	# 清空按钮
	var clear_btn := Button.new()
	clear_btn.text = "清空历史"
	clear_btn.custom_minimum_size = Vector2(min(panel_width * 0.2, 100), min(window_size.y * 0.06, 40))
	
	var clear_style := StyleBoxFlat.new()
	clear_style.bg_color = Color(0.8, 0.3, 0.3)  # 红色警示
	clear_style.corner_radius_top_left = 6
	clear_style.corner_radius_top_right = 6
	clear_style.corner_radius_bottom_left = 6
	clear_style.corner_radius_bottom_right = 6
	clear_btn.add_theme_stylebox_override("normal", clear_style)
	
	clear_btn.pressed.connect(_on_clear_pressed)
	btn_hbox.add_child(clear_btn)
	
	# 返回按钮
	var close := Button.new()
	close.text = "返回游戏"
	close.custom_minimum_size = Vector2(min(panel_width * 0.25, 140), min(window_size.y * 0.06, 40))
	
	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(0.3, 0.5, 0.8)
	btn_style.corner_radius_top_left = 6
	btn_style.corner_radius_top_right = 6
	btn_style.corner_radius_bottom_left = 6
	btn_style.corner_radius_bottom_right = 6
	close.add_theme_stylebox_override("normal", btn_style)
	
	close.pressed.connect(_close)
	btn_hbox.add_child(close)
	
	refresh()

# 新增：清空确认
func _on_clear_pressed():
	# 创建确认对话框
	var dialog := ConfirmationDialog.new()
	dialog.title = "确认清空"
	dialog.dialog_text = "确定要清空所有建筑历史记录吗？此操作不可恢复。"
	dialog.get_ok_button().text = "确定"
	dialog.get_cancel_button().text = "取消"
	
	dialog.confirmed.connect(func():
		Global.save_resource.save_building_resources.clear()
		refresh()  # 刷新列表显示
	)
	
	add_child(dialog)
	dialog.popup_centered()


func _close():
	queue_free()



func refresh():
	for c in _list.get_children(): 
		c.queue_free()
	
	print(Global.save_resource.save_building_resources.size())
	for resource : BuildingResource  in Global.save_resource.save_building_resources:
		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		# 左侧：截图（如果有）或占位
		var tex := TextureRect.new()
		if resource.texture != null:
			tex.texture = resource.tex
		else:
			# 无截图时显示占位色块
			tex.texture = null
			tex.modulate = Color(0.3, 0.3, 0.3)
		tex.custom_minimum_size = Vector2(120, 120)
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(tex)
		
		# 右侧信息容器
		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		# 名称和编号
		var name_lab := Label.new()
		name_lab.text = "[%d] %s" % [resource.index, resource.name]
		name_lab.add_theme_font_size_override("font_size", 16)
		info.add_child(name_lab)
		
		# 四项数值
		for key in resource.values.keys():
			var lab := Label.new()
			lab.text = "%s：%d" % [key, resource.values[key]]
			info.add_child(lab)
		
		# 上分主题
		var top_lab := Label.new()
		top_lab.text = "上分：%s" % (resource.top_theme.name)
		top_lab.modulate = Color(0.8, 0.8, 0.8)
		info.add_child(top_lab)
		
		# 中分主题
		var mid_lab := Label.new()
		mid_lab.text = "中分：%s" % (resource.middle_theme.name)
		mid_lab.modulate = Color(0.8, 0.8, 0.8)
		info.add_child(mid_lab)
		
		# 下分主题
		var bot_lab := Label.new()
		bot_lab.text = "下分：%s" % (resource.buttom_theme.name)
		bot_lab.modulate = Color(0.8, 0.8, 0.8)
		info.add_child(bot_lab)
		
		row.add_child(info)
		_list.add_child(row)
		_list.add_child(HSeparator.new())
