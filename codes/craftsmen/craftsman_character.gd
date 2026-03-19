class_name CraftsmanCharacter
extends Node2D

# 对应夜间休息和上班两个状态
enum STATE {
	REST,
	WORK,
}

@export var craftman_resource : CraftsmanResource
@export var speed : float = 100.0

# 导航点 上班的工位和下班的去处 restplace也是出生地
@export var workplaces : Array[Marker2D]
@export var workplace : Marker2D
@export var restplace : Marker2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

var current_state : STATE = STATE.REST
			
var is_moving : bool = false

func _ready() -> void:
	sprite_2d.texture = craftman_resource.texture
	self.global_position = restplace.global_position
	nav_agent.target_reached.connect(_on_target_reached)

func _physics_process(delta: float) -> void:
	if is_moving and nav_agent.is_target_reachable():
		var next_path_position := nav_agent.get_next_path_position()
		var target_direction := (next_path_position - global_position).normalized()
		var target_velocity := target_direction * speed

		global_position += target_velocity * delta
		global_position = global_position.round()
		sprite_2d.position = sprite_2d.position.round()

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
	if current_state == STATE.WORK:
		return	true
	return false

func is_resting() -> bool :
	if current_state == STATE.REST:
		return	true
	return false
