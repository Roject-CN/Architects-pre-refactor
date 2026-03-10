class_name CraftsmanCharacter
extends Node2D


@export var craftman_resource : CraftsmanResource
@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	sprite_2d.texture = craftman_resource.texture
	
