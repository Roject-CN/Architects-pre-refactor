extends AttributionUi
class_name CraftsmenUi


var current_craftmen : CraftsmanResource
# 使用全局工匠市场数据
var craftsmen : Array[CraftsmanResource]:
	get:
		return Global.global_craftsmen_market
	set(value):
		Global.global_craftsmen_market = value

const intro_text_temp : String = "%s %s"
const level_text_temp : String = "Level %d"
const assure_text_temp : String = "招聘 %d$"
var array_size : int = 0
var index : int = 0

@onready var introduction: Label = $Left/VBoxContainer/Introduction
@onready var texturect: TextureRect = $Left/VBoxContainer/Texturect
@onready var description: Label = $Left/VBoxContainer/Description
@onready var level: Label = $Left/VBoxContainer/Level
@onready var assure: Button = $Button/Assure
@onready var next: Button = $Button/Next
@onready var craftsman_generator: CraftsmanGenerate = $CraftsmanGenerate

func ui_exit() -> void:
	super()
	# 不再删除自己，只隐藏界面
	visible = false
	# 保存工匠市场数据到存档
	Global.save_save_resource()

func ui_enter() -> void:
	# 显示界面
	visible = true
	
	# 生成或补充员工
	generate()
	
	array_size = craftsmen.size()
	if array_size < 2:
		next.disabled = true
	else:
		next.disabled = false
	
	# 确保index在有效范围内
	if array_size > 0:
		index = index % array_size  # 防止越界
		current_craftmen = craftsmen[index]
		read_craftman_resource(current_craftmen)
	else:
		push_warning("工匠市场为空")
	
	super()

func _on_back_pressed() -> void:
	ui_exit()

func generate() -> void:
	if craftsman_generator:
		# 使用当前名气值生成工匠
		var current_fame : int = Global.save_resource.fame
		var target_count = craftsman_generator._calculate_worker_count(current_fame)
		
		# 计算需要补充的工匠数量
		var current_count = craftsmen.size()
		var need_to_generate = target_count - current_count
		
		# 如果当前工匠数量已经足够，不需要生成新的
		if need_to_generate <= 0:
			print("工匠市场已满，当前数量：", current_count, "，目标数量：", target_count)
			return
		
		# 生成需要补充的工匠
		var generated_craftsmen = craftsman_generator.generate_craftsman(current_fame)
		
		# 只添加新生成的工匠，不删除已有的
		var added_count = 0
		for craftsman in generated_craftsmen:
			if craftsman is CraftsmanResource and added_count < need_to_generate:
				# 检查是否已经存在相同的工匠（避免重复）
				var is_duplicate = false
				for existing_craftsman in craftsmen:
					if existing_craftsman.name == craftsman.name and existing_craftsman.profession == craftsman.profession:
						is_duplicate = true
						break
				
				if not is_duplicate:
					craftsmen.append(craftsman)
					added_count += 1
		
		print("补充工匠市场：当前数量 ", current_count, "，补充数量：", added_count, "，目标数量：", target_count)
	else:
		push_warning("CraftsmanGenerator未初始化")
		
func _on_assure_pressed() -> void:
	#雇佣成功扣钱
	Global.subtract_money(current_craftmen.cost)
	
	craftsman_manager.append_new_craftsman(current_craftmen)
	
	# 从列表中移除被雇佣的工匠
	craftsmen.erase(current_craftmen)
	
	array_size = craftsmen.size()
	if array_size == 0:
		_on_back_pressed()
	else:
		# 更新当前显示的工匠
		if index >= array_size:
			index = array_size - 1
		current_craftmen = craftsmen[index]
		read_craftman_resource(current_craftmen)
	
	


func read_craftman_resource(resource : CraftsmanResource) -> void:
	#visual部分
	var introduction_text = intro_text_temp
	var level_text = level_text_temp
	var assure_text = assure_text_temp
	
	introduction_text %= [resource.profession_name[resource.profession], resource.name]  
	level_text %= resource.level
	assure_text %= resource.cost
	
	texturect.texture = resource.texture
	introduction.text = introduction_text
	level.text = level_text
	assure.text = assure_text
	description.text = resource.description
	
	if Global.save_resource.current_money < resource.cost:
		assure.disabled = true
	else:
		assure.disabled = false
	#attribution部分
	show_resouce_attribution(resource)

func _on_next_pressed() -> void:
	array_size = craftsmen.size()
	if array_size < 2:
		next.disabled = true
		return
	
	if index >= (array_size - 1):
		index = 0
	else:
		index += 1
	current_craftmen = craftsmen[index]
	read_craftman_resource(current_craftmen)
	
	# 更新按钮状态
	if array_size < 2:
		next.disabled = true
