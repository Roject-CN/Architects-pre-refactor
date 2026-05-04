extends Control
class_name CraftsmenList

# 已招募的员工列表
var recruited_craftsmen: Array[CraftsmanResource] = []

# UI引用
@onready var close_button: Button = $Panel/MarginContainer/VBoxContainer/HBoxContainer/Close
@onready var vlist: VBoxContainer = $Panel/MarginContainer/VBoxContainer/ScrollContainer/Vlist

# 信号
signal closed()

func _ready() -> void:
	# 连接信号
	close_button.pressed.connect(_on_close_pressed)
	
	# 设置容器间距
	_setup_container_spacing()
	
	# 延迟加载数据，确保所有节点都初始化完成
	call_deferred("_deferred_initialize")

# 设置容器间距
func _setup_container_spacing() -> void:
	# 获取所有容器节点
	var panel = $Panel
	var margin_container = $Panel/MarginContainer
	var vbox_container = $Panel/MarginContainer/VBoxContainer
	var scroll_container = $Panel/MarginContainer/VBoxContainer/ScrollContainer
	
	# 设置Panel的填充为0
	panel.add_theme_constant_override("content_margin_left", 0)
	panel.add_theme_constant_override("content_margin_right", 0)
	panel.add_theme_constant_override("content_margin_top", 0)
	panel.add_theme_constant_override("content_margin_bottom", 0)
	
	# 设置MarginContainer的margin为0
	margin_container.add_theme_constant_override("margin_left", 0)
	margin_container.add_theme_constant_override("margin_right", 0)
	margin_container.add_theme_constant_override("margin_top", 0)
	margin_container.add_theme_constant_override("margin_bottom", 0)
	
	# 设置VBoxContainer（外层）的间距为0
	vbox_container.add_theme_constant_override("separation", 0)
	
	# 设置ScrollContainer的填充为0
	scroll_container.add_theme_constant_override("content_margin_left", 0)
	scroll_container.add_theme_constant_override("content_margin_right", 0)
	scroll_container.add_theme_constant_override("content_margin_top", 0)
	scroll_container.add_theme_constant_override("content_margin_bottom", 0)
	
	# 设置内部VBoxContainer（vlist）的间距
	vlist.add_theme_constant_override("separation", 2)
	vlist.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vlist.alignment = BoxContainer.ALIGNMENT_BEGIN

# 延迟初始化
func _deferred_initialize() -> void:
	print("员工列表界面延迟初始化开始")
	
	# 强制同步员工数据
	_sync_craftsmen_data()
	
	# 加载已招募的员工
	_load_recruited_craftsmen()
	
	# 更新UI
	_update_craftsmen_list()
	
	print("员工列表界面初始化完成，显示员工数量: ", recruited_craftsmen.size())

# 强制同步员工数据
func _sync_craftsmen_data() -> void:
	print("强制同步员工数据")
	
	# 获取主场景并触发数据同步
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_method("_sync_craftsmen_to_save"):
		main_scene._sync_craftsmen_to_save()
		print("已触发主场景员工数据同步")
	elif main_scene and main_scene.has_method("refresh_craftsmen_list"):
		main_scene.refresh_craftsmen_list()
		print("已触发主场景员工列表刷新")

# 加载已招募的员工
func _load_recruited_craftsmen() -> void:
	# 方法1：从全局存档数据获取
	if Global.save_resource and Global.save_resource.start_list:
		recruited_craftsmen = Global.save_resource.start_list.duplicate()
		print("从全局存档加载已招募员工数量: ", recruited_craftsmen.size())
		return
	
	# 方法2：从主场景的员工管理器获取
	var craftsman_manager = get_craftsman_manager()
	if craftsman_manager:
		recruited_craftsmen.clear()
		for character in craftsman_manager.current_list:
			if character.craftman_resource:
				recruited_craftsmen.append(character.craftman_resource)
		print("从员工管理器加载已招募员工数量: ", recruited_craftsmen.size())
		
		# 同步到全局存档
		if Global.save_resource:
			Global.save_resource.start_list = recruited_craftsmen.duplicate()
			print("已同步员工数据到全局存档")
		return
	
	# 方法3：检查是否有其他数据源
	print("没有找到已招募的员工数据源")
	recruited_craftsmen.clear()

# 更新工匠列表UI
func _update_craftsmen_list() -> void:
	# 清空现有列表
	for child in vlist.get_children():
		child.queue_free()
	
	if recruited_craftsmen.is_empty():
		# 显示空状态
		var empty_label = Label.new()
		empty_label.text = "暂无已招募的员工"
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vlist.add_child(empty_label)
		return
	
	# 创建二维布局（每行最多显示2个工匠）
	var row_container: HBoxContainer = null
	var craftsman_count = 0
	var card_height = 280  # 卡片固定高度
	
	for craftsman in recruited_craftsmen:
		# 每2个工匠创建一个新的行容器
		if craftsman_count % 2 == 0:
			row_container = HBoxContainer.new()
			row_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			row_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			row_container.custom_minimum_size = Vector2(460, card_height)  # 2*220 + 1*20 = 460
			row_container.add_theme_constant_override("separation", 20)
			row_container.alignment = BoxContainer.ALIGNMENT_BEGIN  # 左对齐
			vlist.add_child(row_container)
		
		# 创建工匠卡片
		var craftsman_card = _create_craftsman_card(craftsman)
		row_container.add_child(craftsman_card)
		
		craftsman_count += 1

# 创建单个工匠卡片
func _create_craftsman_card(craftsman: CraftsmanResource) -> Control:
	# 主容器
	var card_container = VBoxContainer.new()
	card_container.custom_minimum_size = Vector2(220, 280)  # 固定大小
	card_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	card_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	card_container.add_theme_constant_override("separation", 8)
	
	# 名字和等级标签（居中显示）
	var name_container = VBoxContainer.new()
	name_container.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var craftsman_name_label = Label.new()
	craftsman_name_label.text = craftsman.name
	craftsman_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	craftsman_name_label.add_theme_font_size_override("font_size", 16)
	craftsman_name_label.add_theme_color_override("font_color", Color.WHITE)
	name_container.add_child(craftsman_name_label)
	
	# 等级标签
	var level_label = Label.new()
	level_label.text = "等级 " + str(craftsman.level) + "/" + str(CraftsmanResource._LEVEL_LIMIT)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.add_theme_font_size_override("font_size", 12)
	level_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	name_container.add_child(level_label)
	
	card_container.add_child(name_container)
	
	# 形象和属性容器
	var content_container = HBoxContainer.new()
	content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_container.add_theme_constant_override("separation", 15)
	card_container.add_child(content_container)
	
	# 左侧：形象
	var image_container = VBoxContainer.new()
	image_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var texture_rect = TextureRect.new()
	texture_rect.custom_minimum_size = Vector2(80, 80)
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	if craftsman.texture:
		texture_rect.texture = craftsman.texture
	else:
		# 使用默认纹理
		var default_texture = load("res://sprits/tile_0099.png")
		if default_texture:
			texture_rect.texture = default_texture
	
	image_container.add_child(texture_rect)
	content_container.add_child(image_container)
	
	# 右侧：四维属性（竖着显示）
	var attributes_container = VBoxContainer.new()
	attributes_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	attributes_container.add_theme_constant_override("separation", 5)
	
	# 属性名称和值
	var attribute_names = ["匠心类", "工料类", "设计类", "风水类"]
	for i in range(4):
		var attribute_container = HBoxContainer.new()
		attribute_container.add_theme_constant_override("separation", 5)
		
		var attr_name_label = Label.new()
		attr_name_label.text = attribute_names[i] + ":"
		attr_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var value_label = Label.new()
		value_label.text = str(craftsman.values.get(attribute_names[i], 0))
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		
		attribute_container.add_child(attr_name_label)
		attribute_container.add_child(value_label)
		attributes_container.add_child(attribute_container)
	
	content_container.add_child(attributes_container)
	
	# 升级费用提示
	var upgrade_cost_label = Label.new()
	if craftsman.level >= CraftsmanResource._LEVEL_LIMIT:
		upgrade_cost_label.text = "已满级"
		upgrade_cost_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	else:
		var upgrade_cost = craftsman.level * 100
		upgrade_cost_label.text = "升级费用: " + str(upgrade_cost) + " 金币"
		upgrade_cost_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.2))
	upgrade_cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	upgrade_cost_label.add_theme_font_size_override("font_size", 12)
	card_container.add_child(upgrade_cost_label)
	
	# 按钮容器
	var buttons_container = HBoxContainer.new()
	buttons_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buttons_container.add_theme_constant_override("separation", 10)
	buttons_container.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# 升级按钮
	var upgrade_button = Button.new()
	upgrade_button.text = "升级"
	upgrade_button.custom_minimum_size = Vector2(80, 30)
	upgrade_button.pressed.connect(_on_upgrade_pressed.bind(craftsman))
	
	# 如果已满级，禁用升级按钮
	if craftsman.level >= CraftsmanResource._LEVEL_LIMIT:
		upgrade_button.disabled = true
		upgrade_button.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	
	buttons_container.add_child(upgrade_button)
	
	# 解雇按钮
	var fire_button = Button.new()
	fire_button.text = "解雇"
	fire_button.custom_minimum_size = Vector2(80, 30)
	fire_button.pressed.connect(_on_fire_pressed.bind(craftsman))
	buttons_container.add_child(fire_button)
	
	card_container.add_child(buttons_container)
	
	# 添加边框样式
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	stylebox.border_width_bottom = 2
	stylebox.border_width_left = 2
	stylebox.border_width_right = 2
	stylebox.border_width_top = 2
	stylebox.border_color = Color(0.5, 0.5, 0.5)
	stylebox.corner_radius_top_left = 5
	stylebox.corner_radius_top_right = 5
	stylebox.corner_radius_bottom_left = 5
	stylebox.corner_radius_bottom_right = 5
	stylebox.content_margin_left = 10
	stylebox.content_margin_right = 10
	stylebox.content_margin_top = 10
	stylebox.content_margin_bottom = 10
	
	card_container.add_theme_stylebox_override("panel", stylebox)
	
	return card_container

# 升级按钮按下
func _on_upgrade_pressed(craftsman: CraftsmanResource) -> void:
	print("升级按钮按下: ", craftsman.name)
	
	# 检查是否已达最高等级
	if craftsman.level >= CraftsmanResource._LEVEL_LIMIT:
		print("员工", craftsman.name, "已达最高等级")
		return
	
	# 计算升级费用（当前等级 * 100金币）
	var upgrade_cost = craftsman.level * 100
	print("升级费用: ", upgrade_cost, " 金币")
	
	# 检查是否有足够金币
	if not Global.save_resource or Global.save_resource.current_money < upgrade_cost:
		print("金币不足，无法升级")
		return
	
	# 扣除金币
	Global.save_resource.current_money -= upgrade_cost
	print("已扣除金币: ", upgrade_cost)
	
	# 升级逻辑
	_level_up(craftsman)
	
	# 刷新UI显示
	_update_craftsmen_list()
	
	# 保存更改到文件
	Global.save_save_resource()
	print("员工", craftsman.name, "升级完成")

# 执行升级
func _level_up(craftsman: CraftsmanResource) -> void:
	# 等级+1
	craftsman.level += 1
	print("等级提升到: ", craftsman.level)
	
	# 获取职业对应的属性索引
	var profession_index = craftsman.profession
	var attribute_names = ["风水类", "设计类", "匠心类", "工料类"]
	var profession_attr_name = attribute_names[profession_index]
	
	# 属性增强值
	var main_attr_boost = 5  # 职业属性增强值
	var other_attr_boost = 1  # 其他属性增强值
	
	# 增强属性
	for i in range(4):
		var attr_name = attribute_names[i]
		var current_value = craftsman.values.get(attr_name, 0)
		var boost = main_attr_boost if i == profession_index else other_attr_boost
		var new_value = current_value + boost
		
		# 限制最大值
		if new_value > BaseResource.MAX_VALUE:
			new_value = BaseResource.MAX_VALUE
		
		craftsman.values[attr_name] = new_value
		print("  ", attr_name, ": ", current_value, " -> ", new_value)
	
	# 更新最大精力值
	craftsman.max_energy = 10 + craftsman.level * 10
	print("最大精力值更新为: ", craftsman.max_energy)

# 解雇按钮按下
func _on_fire_pressed(craftsman: CraftsmanResource) -> void:
	print("解雇按钮按下: ", craftsman.name)
	
	# 从已招募列表中移除员工
	var index = recruited_craftsmen.find(craftsman)
	if index != -1:
		recruited_craftsmen.remove_at(index)
		print("从已招募列表移除员工: ", craftsman.name)
	else:
		print("警告: 未找到要解雇的员工: ", craftsman.name)
		return
	
	# 从全局存档数据中移除员工
	if Global.save_resource and Global.save_resource.start_list:
		var global_index = Global.save_resource.start_list.find(craftsman)
		if global_index != -1:
			Global.save_resource.start_list.remove_at(global_index)
			print("从全局存档移除员工: ", craftsman.name)
		else:
			print("警告: 未在全局存档中找到员工: ", craftsman.name)
	
	# 从主场景的员工管理器中移除员工
	_fire_craftsman_from_manager(craftsman)
	
	# 刷新UI显示
	_update_craftsmen_list()
	
	# 保存更改到文件
	Global.save_save_resource()
	print("员工解雇完成，数据已保存到存档文件")
	
	# 强制触发主场景的数据同步（确保一致性）
	_trigger_main_scene_sync()

# 触发主场景数据同步
func _trigger_main_scene_sync() -> void:
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_method("_sync_craftsmen_to_save"):
		main_scene._sync_craftsmen_to_save()
		print("已触发主场景员工数据同步")
	elif main_scene and main_scene.has_method("refresh_craftsmen_list"):
		main_scene.refresh_craftsmen_list()
		print("已触发主场景员工列表刷新")

# 从员工管理器中移除员工
func _fire_craftsman_from_manager(craftsman: CraftsmanResource) -> void:
	var craftsman_manager = null
	
	# 方法1：通过主场景获取员工管理器
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_method("_get_craftsman_manager"):
		craftsman_manager = main_scene._get_craftsman_manager()
		if craftsman_manager:
			craftsman_manager.delete_craftsman(craftsman)
			print("从员工管理器移除员工: ", craftsman.name)
			return
	
	# 方法2：通过节点路径查找员工管理器
	craftsman_manager = get_craftsman_manager()
	if craftsman_manager:
		craftsman_manager.delete_craftsman(craftsman)
		print("通过节点查找移除员工: ", craftsman.name)
		return
	
	# 方法3：直接通过全局数据同步
	print("警告: 无法找到员工管理器，仅从数据层移除员工")
	# 数据已经通过start_list同步，游戏逻辑会在下次刷新时生效

# 获取主场景的员工管理器（备用方法）
func get_craftsman_manager():
	# 尝试通过节点路径查找
	var main_scene = get_tree().current_scene
	if main_scene:
		# 查找CraftsmanManager节点
		var craftsman_manager = main_scene.find_child("CraftsmanManager", true, false)
		if craftsman_manager:
			return craftsman_manager
		
		# 查找Function节点下的CraftsmanManager
		var function_node = main_scene.find_child("Function", true, false)
		if function_node:
			craftsman_manager = function_node.find_child("CraftsmanManager", true, false)
			if craftsman_manager:
				return craftsman_manager
	
	return null

# 关闭按钮按下
func _on_close_pressed() -> void:
	closed.emit()

# 刷新列表
func refresh_list() -> void:
	_load_recruited_craftsmen()
	_update_craftsmen_list()
