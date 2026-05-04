extends Control
class_name AchievementDisplay

signal closed()

@export var achievements: Array[Achivement]

@onready var close_button: Button = $Panel/MarginContainer/VBoxContainer/HBoxContainer/Close
@onready var achievement_list: VBoxContainer = $Panel/MarginContainer/VBoxContainer/ScrollContainer/achievement_list

func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)

## 加载已解锁成就
func ui_enter() -> void:
	achievements.clear()
	for i : BuildingResource in Global.save_resource.achivements:
		var ach := Achivement.new()
		ach.achievement_name = i.name
		ach.description = i.description
		ach.texture = i.texture
		achievements.append(ach)
		
	# 清空现有列表
	for child in achievement_list.get_children():
		child.queue_free()

	if achievements.size() <= 0:
		_show_empty_state()
		return
		
	for ach in achievements:
		var item := _create_achievement_item(ach)
		achievement_list.add_child(item)

## 显示空状态
func _show_empty_state() -> void:
	var empty_label = Label.new()
	empty_label.text = "暂无已解锁成就"
	empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty_label.add_theme_font_size_override("font_size", 16)
	achievement_list.add_child(empty_label)

## 创建单个成就项
func _create_achievement_item(ach: Achivement) -> Control:
	var container = HBoxContainer.new()
	container.add_theme_constant_override("separation", 15)

	# 背景样式（与History类似，深色半透明）
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color(0.18, 0.18, 0.28, 0.8)
	stylebox.content_margin_left = 10
	stylebox.content_margin_right = 10
	stylebox.content_margin_top = 10
	stylebox.content_margin_bottom = 10
	container.add_theme_stylebox_override("panel", stylebox)

	# 左侧图标区域
	var icon_rect = TextureRect.new()
	icon_rect.custom_minimum_size = Vector2(64, 64)
	icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	# 如果以后Achivement有icon属性，可自动加载
	if ach.texture:
		icon_rect.texture = ach.texture
	container.add_child(icon_rect)

	# 右侧信息
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 5)

	# 成就名称
	var name_label = Label.new()
	name_label.text = ach.achievement_name
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.modulate = Color.WHITE
	info_vbox.add_child(name_label)

	# 成就描述
	var desc_label = Label.new()
	desc_label.text = ach.description
	desc_label.add_theme_font_size_override("font_size", 13)
	desc_label.modulate = Color(0.9, 0.9, 0.9)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.custom_minimum_size = Vector2(250, 0)
	info_vbox.add_child(desc_label)

	container.add_child(info_vbox)
	return container

func _on_close_pressed() -> void:
	closed.emit()
	call_deferred("queue_free")

## ESC键关闭
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_close_pressed()
		get_viewport().set_input_as_handled()
