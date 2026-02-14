extends Control
class_name AnimationUi

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var delta : int = 40
@export var animation_time : float = 0.8

func _ready() -> void:
	self.modulate = Color(1.0, 1.0, 1.0, 1.0)
	await get_tree().process_frame
	#如果节点刚刚被实例化，还没有被添加到场景树中，或者父节点的变换没有立即更新
	#可能会导致局部位置和全局位置不一致。
	#确保在节点被添加到场景树并且父节点的变换更新后再打印位置。
	plus_animation()
	
func plus_animation() -> void:
	var tween := create_tween()
	tween.tween_property(self, "position:x", delta, animation_time)
	animation_player.play("Plus")
	await animation_player.animation_finished
	self.call_deferred("queue_free")
