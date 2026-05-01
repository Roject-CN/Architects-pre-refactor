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
@onready var quit_button: Button = $ButtonMenu/MarginContainer/VBoxContainer/Quit

@onready var main_ui: MainUi = $MainUiLayer/MainUi

# 场景引用
const start_scene: PackedScene = preload("res://scenes/start.tscn")


func _ready() -> void:
	assert(craftsman_manager, "main.stcn's craftsman_manager is empty")
	
	# 检查全局存档是否已设置（由开始界面设置）
	if not Global.save_resource:
		# 如果没有设置，使用预设资源
		var resource := preload("uid://c0srmgmp32f54")
		Global.load_save_resource(resource)
		print("使用预设资源初始化全局存档")
	else:
		print("全局存档已设置，跳过初始化")
	
	main_ui.init_main_ui(Global.save_resource)
	
	# 从存档恢复员工数据
	_restore_craftsmen_from_save()
	
	#building退出后让按钮可用
	Event.building_end.connect(func(): building_button.disabled = false	)
	
	# 连接退出按钮信号
	quit_button.pressed.connect(_on_quit_pressed)
	

func _on_employee_pressed() -> void:
	# 检查是否已经存在招募界面
	var existing_ui = null
	for child in function.get_children():
		if child is CraftsmenUi:
			existing_ui = child
			break
	
	if existing_ui:
		# 如果存在，直接显示并刷新
		existing_ui.visible = true
		existing_ui.ui_enter()
	else:
		# 如果不存在，创建新的
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

# 同步员工数据到存档资源
func _sync_craftsmen_to_save() -> void:
	# 清空存档中的员工列表
	Global.save_resource.start_list.clear()
	
	# 将工匠管理器中的员工数据同步到存档
	for character in craftsman_manager.current_list:
		if character.craftman_resource:
			Global.save_resource.start_list.append(character.craftman_resource)
			print("同步员工: ", character.craftman_resource.name)
	
	print("员工数据同步完成，共", Global.save_resource.start_list.size(), "名员工")

# 从存档恢复员工数据
func _restore_craftsmen_from_save() -> void:
	# 从存档资源恢复员工
	for resource in Global.save_resource.start_list:
		if resource is CraftsmanResource:
			craftsman_manager.append_new_craftsman(resource)
			print("恢复员工: ", resource.name)
	
	print("员工数据恢复完成，共", craftsman_manager.current_list.size(), "名员工")

# 退出游戏按钮 - 返回主菜单并保存游戏
func _on_quit_pressed() -> void:
	print("Quit按钮被点击")
	
	# 同步员工数据到存档资源
	_sync_craftsmen_to_save()
	
	# 保存当前游戏进度（包括建筑历史）
	print("正在保存游戏进度...")
	Global.save_save_resource()
	
	# 显示保存成功提示
	if pop_up_ui:
		pop_up_ui.pop_up_information("游戏保存", "游戏进度已保存，即将返回主菜单")
	else:
		print("pop_up_ui未找到")
	
	# 等待短暂时间让玩家看到提示
	print("等待1秒...")
	await get_tree().create_timer(1.0).timeout
	
	# 切换到开始场景
	print("尝试切换到开始场景...")
	
	# 使用场景文件路径直接切换（更可靠的方式）
	var start_scene_path = "res://scenes/start.tscn"
	if FileAccess.file_exists(start_scene_path):
		print("start.tscn文件存在，准备切换")
		get_tree().change_scene_to_file(start_scene_path)
		print("已切换到start.tscn场景")
	else:
		push_error("start.tscn文件不存在: " + start_scene_path)
		# 备用方案：使用资源加载
		var start_scene_resource = load(start_scene_path)
		if start_scene_resource:
			get_tree().change_scene_to_packed(start_scene_resource)
			print("备用方案成功")
		else:
			push_error("所有切换方案都失败")
