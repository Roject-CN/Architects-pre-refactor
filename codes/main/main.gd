extends Node

const building_scene := preload("uid://vi2ktm4rx1n1")
const employee_scene := preload("uid://5fkp6mfhsu0w")

@onready var function: Node = $Function
#building_index 意味着建造建筑的序列，目前暂时为测试用
var building_index := 0
var current_building : Building
@export var craftsman_manager: CraftsmanManager
@export var pop_up_ui : PopUpUi

# 工匠生成器实例
var craftsman_generator: CraftsmanGenerate

#craftmen是人才市场，基于名气值动态生成
@export var craftsmen : Array[CraftsmanResource]
# 当前名气值，用于控制工匠生成质量
var current_fame: int = 0


@onready var employee_button: Button = $Button/MarginContainer/VBoxContainer/Employee
@onready var building_button: Button = $Button/MarginContainer/VBoxContainer/Building
@onready var review_button: Button = $Button/MarginContainer/VBoxContainer/Review

@onready var main_ui: MainUi = $MainUi


func _ready() -> void:
	assert(craftsman_manager, "main.stcn's craftsman_manager is empty")
	
	# 初始化工匠生成器
	craftsman_generator = CraftsmanGenerate.new()
	
	var dir = DirAccess.open("user://")
	if dir:
		if not dir.dir_exists("building_resource"):
			dir.make_dir_recursive(Global.BUILDING_SAVE_DIR)
	pass #未来需要读取存档中的building_index
	
	#读取存档环节应当在开始界面 这里先放在主场景里
	var resource := preload("uid://c0srmgmp32f54")
	Global.load_save_resource(resource)
	main_ui.init_main_ui(Global.save_resource)
	
	# 初始化工匠市场
	generate_craftsmen_market()

	

func _on_employee_pressed() -> void:
	
	if craftsmen.size() == 0:
		# 如果人才市场为空，重新生成工匠
		generate_craftsmen_market()
		if craftsmen.size() == 0:
			pop_up_ui.pop_up_information("提醒", "当前名气值过低，无法生成可招聘的工匠")
			return
	
	var employee := employee_scene.instantiate() as CraftsmenUi
	employee.craftsman_manager = craftsman_manager
	
	# 将动态生成的工匠资源传递给雇佣界面
	employee.craftsmen = craftsmen
	
	# 连接雇佣完成信号，以便在雇佣完成后更新人才市场
	employee.craftsman_hired.connect(_on_craftsman_hired)
	
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
	
	# 连接信号：完成时截图并保存
	building.building_complete.connect(_on_building_complete)
	

func _on_building_complete(building_res : BuildingResource):
	# 等待一帧确保 RewardUi 的 hide() 被实际绘制到屏幕
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var screenshot = _capture_screenshot()
	
	# 保存为独立tres文件
	building_button.disabled = false
	var dir_path = Global.BUILDING_SAVE_DIR_PATH   
	var file_path = dir_path % building_res.index 
	var err = ResourceSaver.save(building_res, file_path)
	if err != OK:
		push_error("保存失败: ", err)
		return
	
	# 同时记入史册
	SaveBuildings.record(building_res, file_path, screenshot)
	
	# 建筑完成后增加名气值，并刷新人才市场
	set_fame(current_fame + 10)
	generate_craftsmen_market()

func _capture_screenshot() -> ImageTexture:
	var viewport = get_viewport()
	var img = viewport.get_texture().get_image()
	
	# 目标：最长边 320px，保持宽高比，高画质缩放
	var target_max = 320
	var w = img.get_width()
	var h = img.get_height()
	
	if w > target_max or h > target_max:
		var ratio = min(target_max / float(w), target_max / float(h))
		var new_w = int(w * ratio)
		var new_h = int(h * ratio)
		img.resize(new_w, new_h, Image.INTERPOLATE_LANCZOS)
	
	return ImageTexture.create_from_image(img)





func _on_review_pressed() -> void:
	var ui := preload("res://scenes/ui/buildings/flow/save_buildings_ui.tscn").instantiate()
	add_child(ui)

# 设置当前名气值并更新人才市场
func set_fame(fame_value: int) -> void:
	current_fame = clamp(fame_value, 0, 100)
	# 更新UI显示当前名气值
	if main_ui:
		main_ui.update_fame_display(current_fame)

# 生成新的工匠市场
func generate_craftsmen_market() -> void:
	if craftsman_generator:
		# 使用当前名气值生成工匠，并将普通Array转换为Array[CraftsmanResource]
		var generated_craftsmen = craftsman_generator.generate_craftsman(current_fame)
		craftsmen.clear()
		for craftsman in generated_craftsmen:
			if craftsman is CraftsmanResource:
				craftsmen.append(craftsman)
		print("生成工匠市场：当前名气值 ", current_fame, "，生成工匠数量：", craftsmen.size())
	else:
		push_warning("CraftsmanGenerator未初始化")

# 工匠被雇佣后的回调函数
func _on_craftsman_hired(hired_craftsman: CraftsmanResource) -> void:
	# 从人才市场中移除被雇佣的工匠
	for i in range(craftsmen.size() - 1, -1, -1):
		if craftsmen[i] == hired_craftsman:
			craftsmen.remove_at(i)
			break
	
	print("工匠被雇佣，剩余可招聘工匠数量：", craftsmen.size())
	
	# 如果人才市场空了，可以自动刷新或等待下次手动刷新
	if craftsmen.size() == 0:
		pop_up_ui.pop_up_information("提示", "人才市场已空，下次访问时将自动刷新")