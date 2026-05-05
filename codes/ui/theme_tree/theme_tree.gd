extends Control
class_name ThemeTree

var top_themes : Array[ThemeButton]
var middle_themes : Array[ThemeButton]
var buttom_themes : Array[ThemeButton]

@onready var panel: Panel = $CanvasLayer/Panel
@onready var label: Label = $CanvasLayer/Panel/Label


@onready var themes: Control = $CanvasLayer/Themes
@onready var top: Control = $CanvasLayer/Themes/TopTheme
@onready var middle: Control = $CanvasLayer/Themes/MiddleTheme
@onready var buttom: Control = $CanvasLayer/Themes/ButtomTheme

var LIMIT_TOP := -100.0
var LIMIT_BUTTOM := 200.0

signal theme_tree_quit()

func _ready():
	#使相应的主题科技树能够解锁 开启第一个科技树
	for i : ThemeButton in top.get_children():
		top_themes.append(i)
		i.request_close_tooltip.connect(close_tooltip)
		i.request_open_tooltip.connect(open_tooltip)
		$CanvasLayer/Quit.pressed.connect(i.cease_animation)
	
	for i : ThemeButton in middle.get_children():
		middle_themes.append(i)
		i.request_close_tooltip.connect(close_tooltip)
		i.request_open_tooltip.connect(open_tooltip)
		$CanvasLayer/Quit.pressed.connect(i.cease_animation)
	
	for i : ThemeButton in buttom.get_children():
		buttom_themes.append(i)
		i.request_close_tooltip.connect(close_tooltip)
		i.request_open_tooltip.connect(open_tooltip)
		$CanvasLayer/Quit.pressed.connect(i.cease_animation)
	#读取Global的数据 因为是按时间顺序解锁的，所以如果上分解锁了x个
	#那么Global的相应数组就会有x个，而此时我们需要让 第 x + 1(索引值为x)个主题资源解锁
	#绘制可以解锁的
	if Global.save_resource.top_theme_resource.size() < top_themes.size():
		top_themes[Global.save_resource.top_theme_resource.size()].button_enable()
	if Global.save_resource.middle_theme_resource.size() < middle_themes.size():
		middle_themes[Global.save_resource.middle_theme_resource.size()].button_enable()
	if Global.save_resource.buttom_theme_resource.size() < buttom_themes.size():
		buttom_themes[Global.save_resource.buttom_theme_resource.size()].button_enable()
	
	#这里的 i 是从0开始的 如果size为2 则循环到1就截止了
	#这里是绘制已经解锁过的
	for i in Global.save_resource.top_theme_resource.size():
		top_themes[i].button_pressed()
	for i in Global.save_resource.middle_theme_resource.size():
		middle_themes[i].button_pressed()
	for i in Global.save_resource.buttom_theme_resource.size():
		buttom_themes[i].button_pressed()
	
		
	close_tooltip()
	
	assert(not top_themes.is_empty(), "top_themes.is_empty()")
	#懒得做适配了
	LIMIT_TOP = top_themes.back().position.y - 100.0

func open_tooltip(text : String) -> void:
	label.text = text
	panel.modulate.a = 1.0

func close_tooltip() -> void:
	label.text = "鼠标停留建筑主题按钮一会，会出现文本介绍"
	panel.modulate.a = 0.6
	

func _input(event):
	# 滚轮缩放
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if themes.position.y <= LIMIT_TOP :
				return
			themes.position.y -= 10
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if themes.position.y >= LIMIT_BUTTOM :
				return
			themes.position.y += 10

func _on_quit_pressed() -> void:
	theme_tree_quit.emit()
	call_deferred("queue_free")
