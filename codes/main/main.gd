extends Node

const building_scene := preload("uid://vi2ktm4rx1n1")
const employee_scene := preload("uid://5fkp6mfhsu0w")

@onready var function: Node = $Function
#building_index 意味着建造建筑的序列，目前暂时为测试用
var building_index := 0
var current_building : Building
@export var craftsman_manager: CraftsmanManager
@export var pop_up_ui : PopUpUi

@onready var button_menu: Panel = $ButtonMenu


@onready var employee_button: Button = $ButtonMenu/MarginContainer/VBoxContainer/Employee
@onready var building_button: Button = $ButtonMenu/MarginContainer/VBoxContainer/Building
@onready var review_button: Button = $ButtonMenu/MarginContainer/VBoxContainer/Review

@onready var main_ui: MainUi = $MainUiLayer/MainUi


func _ready() -> void:
	assert(craftsman_manager, "main.stcn's craftsman_manager is empty")
	
	#读取存档环节应当在开始界面 这里先放在主场景里
	var resource := preload("uid://c0srmgmp32f54")
	Global.load_save_resource(resource)
	main_ui.init_main_ui(Global.save_resource)
	
	#building退出后让按钮可用
	Event.building_end.connect(func(): building_button.disabled = false	)
	

func _on_employee_pressed() -> void:

	var employee := employee_scene.instantiate() as CraftsmenUi
	employee.craftsman_manager = craftsman_manager
	
	function.add_child(employee)
	employee.ui_enter()

func _on_building_pressed() -> void:
	if craftsman_manager.craftsman_manager_is_empty():
		pop_up_ui.pop_up_information("提醒", "当前没有员工可以供您派遣，所以请先招募员工")
		return
	
	if Global.themes_empty():
		pop_up_ui.pop_up_information("提醒", "请先研究 上分 中分 和下分的建筑主题")
		return
		
	if not craftsman_manager.return_craftsman_is_working():
		pop_up_ui.pop_up_information("提醒", "当前员工还没有在工位上，请在他们正式开始工作后再来吧")
		return
	var building_resource := BuildingResource.new()
	var building := building_scene.instantiate() as Building
	building.building_resource = building_resource
	building.craftsman_manager = craftsman_manager
	building_resource.index = building_index
	building_index += 1
	function.add_child(building)
	building_button.disabled = true


func _on_review_pressed() -> void:
	var ui := preload("res://scenes/ui/buildings/flow/save_buildings_ui.tscn").instantiate()
	add_child(ui)

#主题科技树解锁
func _on_theme_pressed() -> void:
	button_menu.visible = false
	var theme_tree := preload("res://scenes/ui/theme_tree/theme_tree.tscn").instantiate() as ThemeTree
	if not theme_tree.theme_tree_quit.is_connected(theme_tree_quited):
		theme_tree.theme_tree_quit.connect(theme_tree_quited)
	add_child(theme_tree)

func theme_tree_quited() -> void:
	button_menu.visible = true
	
