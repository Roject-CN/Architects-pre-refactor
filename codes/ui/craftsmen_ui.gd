extends AttributionUi
class_name CraftsmenUi


var current_craftmen : CraftsmanResource
#craftmen是人才市场，暂且作为测试使用
@export var craftsmen : Array[CraftsmanResource]

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
	call_deferred("queue_free") #消除自己

func ui_enter() -> void:
	#生成员工
	generate()
	
	array_size = craftsmen.size()
	if array_size < 2:
		next.disabled = true
	current_craftmen  = craftsmen[index]
	read_craftman_resource(current_craftmen)
	
	super()

func _on_back_pressed() -> void:
	ui_exit()

func generate() -> void:
	if craftsman_generator:
		# 使用当前名气值生成工匠，并将普通Array转换为Array[CraftsmanResource]
		var current_fame : int = Global.save_resource.fame
		var generated_craftsmen = craftsman_generator.generate_craftsman(current_fame)
		craftsmen.clear()
		for craftsman in generated_craftsmen:
			if craftsman is CraftsmanResource:
				craftsmen.append(craftsman)
		print("生成工匠市场：当前名气值 ", current_fame, "，生成工匠数量：", craftsmen.size())
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
	
	if Global.save_resource.current_money < resource.cost or Global.save_resource.start_list.size() >= 6:
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
