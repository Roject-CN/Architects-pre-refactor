class_name CraftsmenUi
extends BaseUi


#后续可以讲craftman 的属性值和信息打包成resource之类的东西搭载到Ui上读取
#然后在进一步读取
@export var craftmen : Array[CraftsmanResource]
const intro_text_temp : String = "%s %s"
const level_text_temp : String = "Level %d"
const assure_text_temp : String = "招聘 %d$"
var array_size : int = 0
var index : int = 0

@onready var introduction: Label = $Visual/VBoxContainer/Introduction
@onready var texturect: TextureRect = $Visual/VBoxContainer/Texturect
@onready var description: Label = $Visual/VBoxContainer/Description
@onready var level: Label = $Visual/VBoxContainer/Level
@onready var assure: Button = $Button/Assure
@onready var next: Button = $Button/Next

func _ready() -> void:
	super()
	array_size = craftmen.size()
	if array_size < 2:
		next.disabled = true
	read_craftman_resource(craftmen[index])
	#执行BaseUi的ready()

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
	
	#attribution部分
	for node : InformationUI in v_box_container.get_children():
		node.set_value(resource.values[node.text]) 
	
func craftmen_ui_hide() -> void:
	hide()

func craftmen_ui_show() -> void:
	show()

func _on_back_pressed() -> void:
	craftmen_ui_hide()

func _on_assure_pressed() -> void:
	craftmen_ui_hide()

func _on_next_pressed() -> void:
	if index == (array_size - 1):
		index = 0
	else:
		index += 1
	read_craftman_resource(craftmen[index])
