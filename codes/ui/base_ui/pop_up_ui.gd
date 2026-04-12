extends Control
class_name PopUpUi

@onready var title: Label = $Panel/Title
@onready var content: Label = $Panel/Content
@onready var button: Button = $Panel/Button

func _ready() -> void:
	hide()

func pop_up_information(title_string : String, text_string : String) -> void:
	title.text = title_string
	content.text = text_string
	show()

func _on_button_pressed() -> void:
	hide()
