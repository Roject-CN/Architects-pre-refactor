extends Control
class_name AnimationUi

enum DIRECTION{
	TO_TOP,
	TO_RIGHT
}
@onready var sprite_2d: TextureRect = $Sprite2D
@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $Label/AnimationPlayer


@export var delta : int = 40
@export var animation_time : float = 0.8
@export var value := 1
@export var texture : Texture
@export var direction : DIRECTION = DIRECTION.TO_RIGHT

func _ready() -> void:
	#sprite是想此场景更加通用 从原来的在建筑建造过程中用于播放+1动画 拓展到能够在员工在公司工作时头上冒出
	sprite_2d.visible = false
	
	if texture and direction == DIRECTION.TO_TOP:
		sprite_2d.texture = texture
		sprite_2d.visible = true
	self.modulate = Color(1.0, 1.0, 1.0, 1.0)
	await get_tree().process_frame
	#如果节点刚刚被实例化，还没有被添加到场景树中，或者父节点的变换没有立即更新
	#可能会导致局部位置和全局位置不一致。
	#确保在节点被添加到场景树并且父节点的变换更新后再打印位置。
	plus_animation()
	
func plus_animation() -> void:
	if value > 0:
		label.text = "+" + str(value)
	else :
		label.text = "-" + str(value)
	var tween := create_tween()
	
	if direction == DIRECTION.TO_TOP:
		tween.tween_property(self, "position:y", -delta, animation_time)
	else:
		tween.tween_property(self, "position:x", delta, animation_time)
	animation_player.play("Plus")
	await animation_player.animation_finished
	self.call_deferred("queue_free")
