class_name CraftsmanCharacter
extends Node2D

# 对应夜间休息和上班两个状态
enum STATE {
	REST,
	WORK,
	BUSY
}

@export var craftman_resource : CraftsmanResource
@export var speed : float = 100.0

# 导航点 上班的工位和下班的去处 restplace也是出生地
@export var workplaces : Array[Marker2D]
@export var workplace : Marker2D
@export var restplace : Marker2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var aniamtion_ui_marked: Marker2D = $AnimationUi
@onready var energy: ProgressBar = $Energy
#临时表示名字
@onready var label: Label = $Label


const SCALE := 0.2
const ANIMATION_UI := preload("uid://jyoxd75b8pl1")
const TEXTURES : Array[Texture] = [preload("uid://bb1llwn0kn1pm"), preload("uid://bb1llwn0kn1pm"),
preload("uid://bb1llwn0kn1pm"), preload("uid://bb1llwn0kn1pm")]
#占位符 都是属性值的图片

var current_state : STATE = STATE.REST
			
var is_moving : bool = false

func _ready() -> void:
	#信号连接
	craftman_resource.request_craftsman_character_animation_ui_added.connect(
		animation_ui_add
	)
	sprite_2d.texture = craftman_resource.texture
	
	# 安全检查：确保restplace不为空再设置位置
	if restplace:
		self.global_position = restplace.global_position
	else:
		# 如果restplace为空，设置默认位置或等待后续设置
		push_warning("CraftsmanCharacter: restplace is null, position not set")
		nav_agent.target_reached.connect(_on_target_reached)
	
	#精力条
	energy.max_value = craftman_resource.max_energy
	craftman_resource.energy_value_changed.connect(
		func(value : float): energy.value = value
		)
	
	label.text = craftman_resource.name

func animation_ui_add(type : BaseResource.PROPERTY) -> void:
	var animation_ui := ANIMATION_UI.instantiate() as AnimationUi
	animation_ui.direction = animation_ui.DIRECTION.TO_TOP
	animation_ui.texture = TEXTURES[type]
	animation_ui.scale = Vector2(SCALE, SCALE)
	
	aniamtion_ui_marked.add_child(animation_ui)
	

func craftsman_character_process(delta: float) -> void:
	#寻路导航的逻辑
	if is_moving and nav_agent.is_target_reachable():
		var next_path_position := nav_agent.get_next_path_position()
		var target_direction := (next_path_position - global_position).normalized()
		var target_velocity := target_direction * speed

		global_position += target_velocity * delta
		global_position = global_position.round()
		sprite_2d.position = sprite_2d.position.round()
	
	#在工作时消耗一定的精力值 然后在休息时回复
	if current_state == STATE.REST:
		craftman_resource.add_energy(delta)
	elif current_state == STATE.WORK:
		craftman_resource.subtract_energy(delta)
	

func go_to_work() -> void:
	if current_state == STATE.WORK:
		return
	current_state = STATE.WORK
	if workplace:
		_move_to_target(workplace.global_position)
	else:
		push_warning("CraftsmanCharacter: workplace not assigned")

func go_to_rest() -> void:
	if current_state == STATE.REST:
		return
	current_state = STATE.REST
	if restplace:
		_move_to_target(restplace.global_position)
	else:
		push_warning("CraftsmanCharacter: restplace not assigned")

func _move_to_target(target_position: Vector2) -> void:
	nav_agent.target_position = target_position
	is_moving = true

func _on_target_reached() -> void:
	is_moving = false

func is_working() -> bool :
	if current_state != STATE.REST :
		return	true
	return false

func is_resting() -> bool :
	if current_state == STATE.REST:
		return	true
	return false