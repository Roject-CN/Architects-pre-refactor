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


@export var pick_pictires : PicturePick
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
	#读取Global的员工列表
	for i : CraftsmanResource in Global.save_resource.start_list:
		craftsman_manager.append_new_craftsman(i)
	

func _on_employee_pressed() -> void:

	if Global.save_resource.start_list.size() >= 6:
		pop_up_ui.pop_up_information("提醒", "员工数量超过，需要您先辞退其他的员工")
		return
	
	pop_up_ui.pop_up_information("提醒", "每次招募员工需花费100元")
	
	if Global.save_resource.current_money >= 100:
		pop_up_ui._pressed.connect(func():
			Global.save_resource.current_money -= 100
			var employee := employee_scene.instantiate() as CraftsmenUi
			employee.craftsman_manager = craftsman_manager
			
			function.add_child(employee)
			employee.ui_enter(), CONNECT_ONE_SHOT
			)
	else :
		pop_up_ui.pop_up_information("提醒", "您的金钱少于100元，所以无法招募，赚够更多的钱再来吧")

# 员工列表按钮按下
func _on_craftsmen_list_pressed() -> void:
	print("员工列表按钮按下")
	
	# 加载员工列表场景
	var craftsmen_list_scene_path = "res://scenes/ui/craftsmen/craftsmen_list.tscn"
	
	# 检查场景文件是否存在
	if not FileAccess.file_exists(craftsmen_list_scene_path):
		push_error("员工列表场景文件不存在: " + craftsmen_list_scene_path)
		return
	
	# 尝试加载场景
	var craftsmen_list_scene = load(craftsmen_list_scene_path)
	if not craftsmen_list_scene:
		push_error("员工列表场景加载失败: " + craftsmen_list_scene_path)
		return
	
	# 实例化员工列表界面
	var craftsmen_list_instance = craftsmen_list_scene.instantiate()
	
	# 确保员工列表界面渲染在最上层
	# 使用CanvasLayer确保界面始终在最上层
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # 使用CanvasLayer的layer属性确保最上层
	
	# 添加模态背景效果
	var modal_background = ColorRect.new()
	modal_background.color = Color(0, 0, 0, 0.7)  # 更深的半透明黑色背景
	modal_background.size = Vector2(1920, 1080)  # 使用固定尺寸，后续会调整
	modal_background.mouse_filter = Control.MOUSE_FILTER_STOP  # 阻止鼠标事件穿透到底层
	canvas_layer.add_child(modal_background)
	
	# 延迟设置背景尺寸以适应视口
	call_deferred("_set_modal_background_size", modal_background)
	
	# 设置员工列表界面
	craftsmen_list_instance.z_index = 10  # 在CanvasLayer内设置相对层级
	craftsmen_list_instance.mouse_filter = Control.MOUSE_FILTER_STOP
	canvas_layer.add_child(craftsmen_list_instance)
	
	# 连接关闭信号以移除整个CanvasLayer
	if craftsmen_list_instance.has_signal("closed"):
		var close_callback = func():
			print("员工列表界面已关闭")
			if canvas_layer.get_parent():
				canvas_layer.queue_free()
			# 刷新员工数据并保存到文件
			_sync_craftsmen_to_save()
			Global.save_save_resource()
			print("员工数据已保存到存档文件")
		
		craftsmen_list_instance.closed.connect(close_callback)
	else:
		push_error("员工列表界面缺少closed信号")
	
	# 添加到场景
	add_child(canvas_layer)
	print("员工列表界面已添加到CanvasLayer，确保渲染在最上层")

# 设置模态背景尺寸
func _set_modal_background_size(modal_background: ColorRect) -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	modal_background.size = viewport_size
	print("模态背景尺寸已设置为: ", viewport_size)

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
	building.pick = pick_pictires
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
	
	# 立即保存到文件
	Global.save_save_resource()
	print("员工数据已保存到存档文件")

# 从存档恢复员工数据
func _restore_craftsmen_from_save() -> void:
	print("开始恢复员工数据...")
	
	# 检查全局存档状态
	if not Global.save_resource:
		print("错误: Global.save_resource 为空")
		return
	
	if not Global.save_resource.start_list:
		print("警告: Global.save_resource.start_list 为空")
		print("存档中的员工数量: 0")
		print("员工数据恢复完成，共0名员工")
		return
	
	print("存档中的员工数量: ", Global.save_resource.start_list.size())
	
	# 从存档资源恢复员工（使用immediate_sync=false避免重复同步）
	var restored_count = 0
	for resource in Global.save_resource.start_list:
		if resource is CraftsmanResource:
			print("恢复员工: ", resource.name)
			craftsman_manager.append_new_craftsman(resource, false)  # 关键修改：禁用立即同步
			restored_count += 1
		else:
			print("警告: 资源类型不是CraftsmanResource: ", typeof(resource))
	
	print("员工数据恢复完成，共", restored_count, "名员工")
	print("员工管理器中的员工数量: ", craftsman_manager.current_list.size())
	
	# 恢复完成后统一同步一次
	craftsman_manager._sync_to_global_save()
	print("员工数据恢复完成，已统一同步到存档")

# 刷新员工列表数据
func refresh_craftsmen_list() -> void:
	# 同步员工数据到存档
	_sync_craftsmen_to_save()
	
	# 查找并刷新员工列表界面
	for child in get_children():
		if child is CanvasLayer:
			for canvas_child in child.get_children():
				if canvas_child is CraftsmenList and canvas_child.has_method("refresh_list"):
					canvas_child.refresh_list()
					print("员工列表已刷新")
					break

# 获取员工管理器（供其他界面调用）
func _get_craftsman_manager() -> CraftsmanManager:
	return craftsman_manager

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


		
