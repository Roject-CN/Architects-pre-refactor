extends Control
class_name PopUpUi

@onready var title: Label = $Panel/Title
@onready var content: Label = $Panel/Content
@onready var cancel: Button = $Panel/Buttons/Cancel
@onready var buttons: HBoxContainer = $Panel/Buttons

signal _pressed

func _ready() -> void:
	hide()

func pop_up_information(title_string : String, text_string : String, can_cancel : bool = true) -> void:
	title.text = title_string
	content.text = text_string
	cancel.visible = not can_cancel
	buttons.reset_size()
	buttons.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	buttons.position.y -= 10
	
	
	show()

func _on_button_pressed() -> void:
	hide()
	_pressed.emit()


func _on_cancel_pressed() -> void:
	hide()
	# 移除 pop_up_ui._pressed 信号上的所有连接
	var connections = self._pressed.get_connections()
	for conn in connections:
		self._pressed.disconnect(conn.callable)
