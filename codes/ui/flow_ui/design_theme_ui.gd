extends ChoiceUi
class_name DesignUi

# 测试主题数组（在场景编辑器中设置）
@export var test_top_themes : Array[ThemeResource]
@export var test_middle_themes : Array[ThemeResource]
@export var test_buttom_themes : Array[ThemeResource]

var top_themes : Array[ThemeResource]
var middle_themes : Array[ThemeResource]
var buttom_themes : Array[ThemeResource]

const TEXT := ["上分", "中分", "下分"]

@onready var top: Button = $Left/VBoxContainer/Top
@onready var middle: Button = $Left/VBoxContainer/Middle
@onready var buttom: Button = $Left/VBoxContainer/Buttom
@onready var assure: Button = $Button/Assure


func ui_enter()-> void:
	#后续应当获取 主题资源 （会有科技树系统）
	
	#连接按钮的信号
	top.pressed.connect(top_button_pressed)
	middle.pressed.connect(middle_button_pressed)
	buttom.pressed.connect(buttom_button_pressed)
	#获取焦点
	top_button_pressed()
	
	#只有选择好所有的主题资源才可以进入下一步 所以先设置不可按
	assure.disabled = true
	
	#
	top_themes = Global.save_resource.top_theme_resource.duplicate(true)
	middle_themes = Global.save_resource.middle_theme_resource.duplicate(true)
	buttom_themes = Global.save_resource.buttom_theme_resource.duplicate(true)
	
	super()

func top_button_pressed() -> void:
	top.grab_focus()
	clear_theme_resources()
	show_theme_resources(top_themes)
	
func middle_button_pressed() -> void:
	middle.grab_focus()
	clear_theme_resources()
	show_theme_resources(middle_themes)
	
func buttom_button_pressed() -> void:
	buttom.grab_focus()
	clear_theme_resources()
	show_theme_resources(buttom_themes)

#根据主题资源显示按钮选项
func show_theme_resources(resources : Array[ThemeResource]) -> void:
	for resource in resources:
		var button := Button.new()
		button.text = resource.name
		button.custom_minimum_size.x = 100
		button.pressed.connect(assign_theme_resource.bind(resource.type, resource))
		r_container.add_child(button)
	
	override_separation()

#清除右侧的所有按钮选项
func clear_theme_resources() -> void:
	for i : Button in r_container.get_children():
		i.pressed.disconnect(assign_theme_resource)
		i.call_deferred("queue_free")	

func assign_theme_resource(type : ThemeResource.TYPE, resource : ThemeResource) -> void:
	building_resource.add_theme(type, resource)
	var left_button := l_container.get_child(type) as Button
	left_button.text = TEXT[type] + " : " + resource.name
	
	#如果building_resource的主题都选择好了 则可以进入下一步了
	if building_resource.return_themes_is_full():
		assure.disabled = false
