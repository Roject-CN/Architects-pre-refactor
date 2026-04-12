extends Node

const building_scene := preload("uid://vi2ktm4rx1n1")
const employee_scene := preload("uid://5fkp6mfhsu0w")

@onready var function: Node = $Function
#building_index 意味着建造建筑的序列，目前暂时为测试用
var building_index := 0
var current_building : Building
@export var craftsman_manager: CraftsmanManager
@export var pop_up_ui : PopUpUi

#craftmen是人才市场，暂且作为测试使用
@export var craftsmen : Array[CraftsmanResource]


@onready var employee_button: Button = $Button/MarginContainer/VBoxContainer/Employee
@onready var building_button: Button = $Button/MarginContainer/VBoxContainer/Building
@onready var review_button: Button = $Button/MarginContainer/VBoxContainer/Review

@onready var main_ui: MainUi = $MainUi


func _ready() -> void:
	assert(craftsman_manager, "main.stcn's craftsman_manager is empty")
	
	var dir = DirAccess.open("user://")
	if dir:
		if not dir.dir_exists("building_resource"):
			dir.make_dir_recursive(Global.BUILDING_SAVE_DIR)
	pass #未来需要读取存档中的building_index
	
	#读取存档环节应当在开始界面 这里先放在主场景里
	var resource := preload("uid://c0srmgmp32f54")
	Global.load_save_resource(resource)
	main_ui.init_main_ui(Global.save_resource)

	

func _on_employee_pressed() -> void:
	
	if craftsmen.size() == 0:
		pop_up_ui.pop_up_information("提醒", "已经没有员工可以招聘了")
		return
	
	var employee := employee_scene.instantiate() as CraftsmenUi
	employee.craftsman_manager = craftsman_manager
	
	#目前是测试 先暂时给雇佣界面三个资源
	#有意思的是 Godot貌似这种赋值是直接赋值 也就是说在employee里面的craftsmen的修改也会影响这里的craftsmen
	employee.craftsmen = craftsmen
	
	#后面需要赋值给craftsman_ui的craftsmen(人才市场) 或者自动生成
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
	building.request_building_resource_saved.connect(save_building_resource)
	

func save_building_resource(building_resource : BuildingResource) -> void:
	building_button.disabled = false
	return
	var dir_path = Global.BUILDING_SAVE_DIR_PATH   
	var file_path = dir_path % building_resource.index 
	#保存在user://building/x_building_resource.tres
	var err = ResourceSaver.save(building_resource, file_path)
	if err != OK:
		push_error("保存失败: ", err)
		

func _on_review_pressed() -> void:
	pass # Replace with function body.
