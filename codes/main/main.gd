extends Node

const building_scene := preload("uid://vi2ktm4rx1n1")
const employee_scene := preload("uid://5fkp6mfhsu0w")

@onready var function: Node = $Function
#building_index 意味着建造建筑的序列，目前暂时为测试用
var building_index := 0
var current_building : Building
@export var craftsman_manager: CraftsmanManager

@onready var employee_button: Button = $Button/MarginContainer/VBoxContainer/Employee
@onready var building_button: Button = $Button/MarginContainer/VBoxContainer/Building
@onready var review_button: Button = $Button/MarginContainer/VBoxContainer/Review

@onready var ui: MainUi = $Ui


func _ready() -> void:
	assert(craftsman_manager, "main.stcn's craftsman_manager is empty")
	
	var dir = DirAccess.open("user://")
	if dir:
		if not dir.dir_exists("building_resource"):
			dir.make_dir_recursive(Global.BUILDING_SAVE_DIR)
	pass #未来需要读取存档中的building_index
	
	#读取存档环节应当在开始界面 这里先放在主场景里
	var resource := preload("res://resource/save_resource/start_up.tres")
	Global.load_save_resource(resource)
	ui.init_main_ui(Global.save_resource)

	

func _on_employee_pressed() -> void:
	var employee := employee_scene.instantiate() as CraftsmenUi
	employee.craftsman_manager = craftsman_manager
	#后面需要赋值给craftsman_ui的craftsmen(人才市场) 或者自动生成
	function.add_child(employee)
	employee.ui_enter()

func _on_building_pressed() -> void:
	if craftsman_manager.craftsman_manager_is_empty():
		#后面可以搞个提示ui
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
	var dir_path = Global.BUILDING_SAVE_DIR_PATH   
	var file_path = dir_path % building_resource.index 
	#保存在user://building/x_building_resource.tres
	var err = ResourceSaver.save(building_resource, file_path)
	if err != OK:
		push_error("保存失败: ", err)
		

func _on_review_pressed() -> void:
	pass # Replace with function body.
	
