extends Node

const building_scene := preload("uid://vi2ktm4rx1n1")
const employee_scene := preload("uid://5fkp6mfhsu0w")

@onready var function: Node = $Function
#building_index 意味着建造建筑的序列，目前暂时为测试用
var building_index := 0
var current_building : Building
@export var craftsman_manager: CraftsmanManager
@export var pop_up_ui : PopUpUi


@onready var employee_button: Button = $Button/MarginContainer/VBoxContainer/Employee
@onready var building_button: Button = $Button/MarginContainer/VBoxContainer/Building
@onready var review_button: Button = $Button/MarginContainer/VBoxContainer/Review

@onready var main_ui: MainUi = $MainUi


func _ready() -> void:
	assert(craftsman_manager, "main.stcn's craftsman_manager is empty")
	
	#读取存档环节应当在开始界面 这里先放在主场景里
	var resource := preload("uid://c0srmgmp32f54")
	Global.load_save_resource(resource)
	main_ui.init_main_ui(Global.save_resource)
	
	#building退出后让按钮可用
	Event.building_ui_quit.connect(func(): building_button.disabled = false	)
	

func _on_employee_pressed() -> void:

	var employee := employee_scene.instantiate() as CraftsmenUi
	employee.craftsman_manager = craftsman_manager
	
	function.add_child(employee)
	employee.ui_enter()

func _on_building_pressed() -> void:
	if craftsman_manager.craftsman_manager_is_empty():
		pop_up_ui.pop_up_information("提醒", "当前没有员工可以供您派遣，所以请先招募员工")
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
