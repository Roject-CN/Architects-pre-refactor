class_name CraftsmanCharacter
extends Node2D

#对应夜间休息 上班中和忙碌三个状态
enum STATE {
	REST,
	WORK,
	BUSY
}
@export var craftman_resource : CraftsmanResource
@onready var sprite_2d: Sprite2D = $Sprite2D

#导航点 上班的工位和下班的去处 restplace也是出生地
@export var workplace : Marker2D
@export var restplace : Marker2D

func _ready() -> void:
	sprite_2d.texture = craftman_resource.texture
	
