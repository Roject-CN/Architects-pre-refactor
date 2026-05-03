extends Resource
class_name SaveResource

# 信号声明
signal current_money_changed(value : int)
signal fame_changed(value : int)
signal research_value_changed(value : int)
signal time_days_changed(value : int)

#SaveResource类为存档资源类
#在Global类里加载SaveResource类资源 然后可全局获取

#金钱值 初始金钱和当前金钱
@export var init_money : int = 1000
@export var current_money : int = 0 : 
	set(value):
		current_money = value
		current_money_changed.emit(value)
#名气值
@export var fame : int = 0: 
	set(value):
		fame = value
		fame_changed.emit(value)
#研究点
@export var research_value : int = 0: 
	set(value):
		research_value = value
		research_value_changed.emit(value)

@export var time_days : int = 0 : 
	set(value):
		time_days = value
		time_days_changed.emit(value)

#员工列表
var start_list : Array[CraftsmanResource]

#建筑资源的储存
var save_building_resources : Array[BuildingResource]

#建筑主题资源
var top_theme_resource : Array[ThemeResource]
var middle_theme_resource : Array[ThemeResource]
var buttom_theme_resource : Array[ThemeResource]

#历史建筑成就
var achivements : Array[BuildingResource]

#检测是否为第一次加载（需要导出才能保存到文件）
@export var first_time : bool = true

# 存档名称（用于区分多个存档）
@export var save_name : String = "主存档"

#存档相关
const SAVE_DIR := "user://saves/"
const BUILDINGS_SAVE_DIR := "buildings/"
const CRAFTSMEN_SAVE_DIR := "craftsmen/"
const THEMES_SAVE_DIR := "themes/"

# 获取存档信息
func get_save_info() -> Dictionary:
	return {
		"name": save_name,
		"money": current_money,
		"fame": fame,
		"building_count": save_building_resources.size(),
		"craftsman_count": start_list.size(),
		"days": time_days
	}

# 创建新存档（带名称）
static func create_new_save(save_name: String = "新存档") -> SaveResource:
	var new_save = SaveResource.new()
	new_save.save_name = save_name
	new_save.init_save_resource()
	return new_save

func init_save_resource() -> void:
	if first_time:
		first_time = false
		current_money = init_money
		print("初始化新存档: 金钱=", current_money)
	else:
		print("存档已初始化过，跳过初始化")

func add_building_resource(resource : BuildingResource) -> void:
	save_building_resources.append(resource)
	
	if save_building_resources.size() >= 10:
		save_building_resources.pop_front()

# === 完整存档功能 ===

# 获取存档目录路径
func _get_save_directory() -> String:
	return SAVE_DIR + save_name + "/"

# 保存完整游戏数据到文件系统
func save_complete_game_data() -> int:
	var result = OK
	
	# 获取存档目录（每个存档使用独立文件夹）
	var save_dir = _get_save_directory()
	
	# 确保存档目录存在
	var dir = DirAccess.open("user://")
	if not dir:
		return ERR_CANT_CREATE
	
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")
	
	if not dir.dir_exists(save_dir):
		dir.make_dir_recursive(save_dir)
	
	# 创建子目录
	var sub_dirs = [BUILDINGS_SAVE_DIR, CRAFTSMEN_SAVE_DIR, THEMES_SAVE_DIR]
	for sub_dir in sub_dirs:
		if not dir.dir_exists(save_dir + sub_dir):
			dir.make_dir(save_dir + sub_dir)
	
	# 保存主存档数据
	result = ResourceSaver.save(self, save_dir + "save.tres")
	if result != OK:
		push_error("保存存档失败: ", result)
		return result
	
	# 保存建筑资源（单独文件）
	for i in range(save_building_resources.size()):
		var building = save_building_resources[i]
		var building_path = save_dir + BUILDINGS_SAVE_DIR + "building_%d.tres" % i
		var building_result = ResourceSaver.save(building, building_path)
		if building_result != OK:
			push_error("保存建筑资源失败: ", building_path)
			result = building_result
	
	# 保存建筑主题资源
	result = _save_theme_resources(save_dir + THEMES_SAVE_DIR)
	
	# 保存工匠数据
	result = _save_craftsmen_data(save_dir + CRAFTSMEN_SAVE_DIR)
	
	print("完整游戏数据已保存到: ", save_dir)
	return result

# 从文件系统加载完整游戏数据
static func load_complete_game_data(save_name: String = "主存档") -> SaveResource:
	var save_dir = SAVE_DIR + save_name + "/"
	var save_path = save_dir + "save.tres"
	
	print("===========================================")
	print("尝试加载存档: ", save_name)
	print("存档目录: ", save_dir)
	print("存档文件路径: ", save_path)
	
	# 检查存档文件是否存在
	if not ResourceLoader.exists(save_path):
		print("错误: 存档文件不存在!")
		print("创建新存档: ", save_name)
		# 创建新的存档
		var new_save = SaveResource.create_new_save(save_name)
		return new_save
	
	print("存档文件存在，开始加载...")
	
	# 加载存档
	var save_resource = load(save_path)
	if not save_resource:
		push_error("加载存档失败: ", save_path)
		return SaveResource.create_new_save(save_name)
	
	print("存档加载成功，类型: ", save_resource.get_class())
	
	# 确保是正确的类型
	if not save_resource is SaveResource:
		push_error("存档类型不正确")
		return SaveResource.create_new_save(save_name)
	
	# 初始化存档资源（设置first_time为false，避免重置数据）
	save_resource.init_save_resource()
	
	# 加载建筑资源
	save_resource._load_building_resources(save_dir + BUILDINGS_SAVE_DIR)
	print("建筑资源加载完成，数量: ", save_resource.save_building_resources.size())
	
	# 加载主题资源
	save_resource._load_theme_resources(save_dir + THEMES_SAVE_DIR)
	print("主题资源加载完成")
	
	# 加载工匠数据
	print("开始调用_load_craftsmen_data函数...")
	var craftsmen_dir = save_dir + CRAFTSMEN_SAVE_DIR
	print("工匠数据目录路径: ", craftsmen_dir)
	save_resource._load_craftsmen_data(craftsmen_dir)
	print("工匠数据加载完成")
	
	# 强制验证员工数据加载结果
	if save_resource.start_list.size() == 0:
		print("严重警告: 员工数据加载后start_list仍然为空!")
		print("可能原因: 工匠数据目录不存在或加载失败")
		
		# 尝试手动检查目录和文件
		print("手动检查工匠数据目录...")
		var dir = DirAccess.open(craftsmen_dir)
		if dir:
			var files = dir.get_files()
			print("工匠目录中的文件数量: ", files.size())
			print("文件列表: ", files)
		else:
			print("无法打开工匠数据目录")
	else:
		print("员工数据加载成功，共", save_resource.start_list.size(), "名员工")
	
	# 显示存档信息
	print("存档数据: 名称=", save_resource.save_name, ", 金钱=", save_resource.current_money, ", 名气=", save_resource.fame, ", 建筑数=", save_resource.save_building_resources.size(), ", 员工数=", save_resource.start_list.size())
	
	print("完整游戏数据已从文件加载")
	return save_resource

# 列出所有可用存档
static func list_saves() -> Array[Dictionary]:
	var saves: Array[Dictionary] = []
	var dir = DirAccess.open(SAVE_DIR)
	
	if not dir:
		return saves
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir() and not file_name.begins_with("backup_"):
			var save_path = SAVE_DIR + file_name + "/save.tres"
			if ResourceLoader.exists(save_path):
				var save_resource = load(save_path)
				if save_resource and save_resource is SaveResource:
					saves.append({
						"name": save_resource.save_name,
						"directory": file_name,
						"info": save_resource.get_save_info()
					})
		file_name = dir.get_next()
	dir.list_dir_end()
	
	return saves

# 保存主题资源
func _save_theme_resources(themes_dir: String) -> int:
	var result = OK
	
	# 保存上分主题
	for i in range(top_theme_resource.size()):
		var theme = top_theme_resource[i]
		var theme_path = themes_dir + "top_theme_%d.tres" % i
		var theme_result = ResourceSaver.save(theme, theme_path)
		if theme_result != OK:
			result = theme_result
	
	# 保存中分主题
	for i in range(middle_theme_resource.size()):
		var theme = middle_theme_resource[i]
		var theme_path = themes_dir + "middle_theme_%d.tres" % i
		var theme_result = ResourceSaver.save(theme, theme_path)
		if theme_result != OK:
			result = theme_result
	
	# 保存下分主题
	for i in range(buttom_theme_resource.size()):
		var theme = buttom_theme_resource[i]
		var theme_path = themes_dir + "buttom_theme_%d.tres" % i
		var theme_result = ResourceSaver.save(theme, theme_path)
		if theme_result != OK:
			result = theme_result
	
	return result

# 加载主题资源
func _load_theme_resources(themes_dir: String) -> void:
	top_theme_resource.clear()
	middle_theme_resource.clear()
	buttom_theme_resource.clear()
	
	var dir = DirAccess.open(themes_dir)
	if not dir:
		return
	
	# 加载上分主题
	var i = 0
	while true:
		var theme_path = themes_dir + "top_theme_%d.tres" % i
		if ResourceLoader.exists(theme_path):
			var theme = load(theme_path)
			if theme:
				top_theme_resource.append(theme)
			i += 1
		else:
			break
	
	# 加载中分主题
	i = 0
	while true:
		var theme_path = themes_dir + "middle_theme_%d.tres" % i
		if ResourceLoader.exists(theme_path):
			var theme = load(theme_path)
			if theme:
				middle_theme_resource.append(theme)
			i += 1
		else:
			break
	
	# 加载下分主题
	i = 0
	while true:
		var theme_path = themes_dir + "buttom_theme_%d.tres" % i
		if ResourceLoader.exists(theme_path):
			var theme = load(theme_path)
			if theme:
				buttom_theme_resource.append(theme)
			i += 1
		else:
			break

# 加载建筑资源
func _load_building_resources(buildings_dir: String) -> void:
	save_building_resources.clear()
	
	var dir = DirAccess.open(buildings_dir)
	if not dir:
		return
	
	var i = 0
	while true:
		var building_path = buildings_dir + "building_%d.tres" % i
		if ResourceLoader.exists(building_path):
			var building = load(building_path)
			if building:
				save_building_resources.append(building)
			i += 1
		else:
			break

# 保存工匠数据
func _save_craftsmen_data(craftsmen_dir: String) -> int:
	var result = OK
	
	# 保存员工列表
	for i in range(start_list.size()):
		var craftsman = start_list[i]
		var craftsman_path = craftsmen_dir + "craftsman_%d.tres" % i
		var craftsman_result = ResourceSaver.save(craftsman, craftsman_path)
		if craftsman_result != OK:
			push_error("保存工匠数据失败: ", craftsman_path)
			result = craftsman_result
	
	print("工匠数据保存完成，数量: ", start_list.size())
	return result

# 加载工匠数据
func _load_craftsmen_data(craftsmen_dir: String) -> void:
	start_list.clear()
	
	print("开始加载工匠数据，目录: ", craftsmen_dir)
	
	# 确保目录路径正确
	if not craftsmen_dir.ends_with("/"):
		craftsmen_dir += "/"
	
	print("处理后的目录路径: ", craftsmen_dir)
	
	# 检查目录是否存在
	if not DirAccess.dir_exists_absolute(craftsmen_dir):
		print("警告: 工匠数据目录不存在: ", craftsmen_dir)
		print("可能这是新存档，没有工匠数据")
		return
	
	var dir = DirAccess.open(craftsmen_dir)
	if not dir:
		print("错误: 无法打开工匠数据目录")
		print("目录访问错误代码: ", DirAccess.get_open_error())
		return
	
	print("成功打开工匠数据目录")
	
	var file_list = dir.get_files()
	print("工匠目录中的文件数量: ", file_list.size())
	print("文件列表: ", file_list)
	
	# 按文件名排序加载，确保顺序正确
	var craftsman_files = []
	for file_name in file_list:
		if file_name.begins_with("craftsman_") and file_name.ends_with(".tres"):
			craftsman_files.append(file_name)
	
	# 按数字顺序排序
	craftsman_files.sort()
	print("排序后的工匠文件: ", craftsman_files)
	
	var loaded_count = 0
	for file_name in craftsman_files:
		var craftsman_path = craftsmen_dir + file_name
		print("加载工匠文件: ", craftsman_path)
		
		if ResourceLoader.exists(craftsman_path):
			var craftsman = load(craftsman_path)
			if craftsman:
				if craftsman is CraftsmanResource:
					print("成功加载工匠: ", craftsman.name)
					start_list.append(craftsman)
					loaded_count += 1
				else:
					print("警告: 文件不是CraftsmanResource类型: ", typeof(craftsman))
			else:
				print("警告: 加载工匠文件失败: ", craftsman_path)
		else:
			print("工匠文件不存在: ", craftsman_path)
	
	print("工匠数据加载完成，数量: ", loaded_count, "/", start_list.size())
	
	# 强制验证加载结果
	if loaded_count > 0 and start_list.size() == 0:
		print("严重错误: 加载了", loaded_count, "个工匠，但start_list为空!")
		print("尝试重新加载...")
		
		# 重新尝试加载
		for file_name in craftsman_files:
			var craftsman_path = craftsmen_dir + file_name
			var craftsman = ResourceLoader.load(craftsman_path)
			if craftsman and craftsman is CraftsmanResource:
				start_list.append(craftsman)
				print("重新加载成功: ", craftsman.name)
		
		print("重新加载后数量: ", start_list.size())

# 创建备份存档
func create_backup_save() -> int:
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	var backup_dir = SAVE_DIR + "backup_" + timestamp + "/"
	
	var dir = DirAccess.open("user://")
	if dir:
		dir.make_dir_recursive(backup_dir)
		# 复制当前存档到备份目录
		# 这里可以扩展备份功能
		print("备份存档已创建: ", backup_dir)
		return OK
	
	return ERR_CANT_CREATE