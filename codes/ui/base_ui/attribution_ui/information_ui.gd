extends Control
class_name InformationUI

@onready var h_box_container: HBoxContainer = $HBoxContainer
@onready var texture_rect: TextureRect = $HBoxContainer/TextureRect
@onready var label: Label = $HBoxContainer/Value
@onready var animation: Container = $HBoxContainer/CenterContainer/Animation

var plus := preload("res://scenes/ui/base_ui/animation_ui.tscn")
var value : int = 0

@export var property : BaseResource.PROPERTY
@export var texture : Texture
@export var text : String


func _ready() -> void:
	texture_rect.texture = texture
	label.text = text + " : " + str(value)
	var plus_node : AnimationUi = plus.instantiate()
	animation.custom_minimum_size = plus_node.size

func set_texture(new_value : Texture) -> void:
	texture = new_value
	
func set_text(new_value : String) -> void:
	text = new_value
	
func set_value(new_value : int) -> void:
	value = new_value
	label.text = text + " : " + str(value)

func update_value() -> void:
	var animation_node : AnimationUi = plus.instantiate()
	animation_node.value = 1
	animation.add_child(animation_node)
	value += 1
	label.text = text + " : " + str(value)

func calculate_value() -> void:
	if value <= 0 :
		return
	var animation_node : AnimationUi = plus.instantiate()
	animation_node.value = -1
	animation.add_child(animation_node)
	value -= 1
	label.text = text + " : " + str(value)

func highlight() -> void:
	label.modulate = Color.BLUE

func return_size_y() -> int:
	var size_y : int = 0
	for i : Control in h_box_container.get_children():
		size_y += int(i.size.y)
	return size_y
