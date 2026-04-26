# craftsman_item.gd
extends Control
class_name CraftsmanItem

signal craftsman_selected(index: int)

var craftsman_data: CraftsmanResource
var item_index: int

@onready var name_label: Label = $HBoxContainer/NameLabel
@onready var profession_label: Label = $HBoxContainer/ProfessionLabel
@onready var level_label: Label = $HBoxContainer/LevelLabel
@onready var cost_label: Label = $HBoxContainer/CostLabel
@onready var selection_highlight: ColorRect = $SelectionHighlight

func set_craftsman_data(craftsman: CraftsmanResource, index: int) -> void:
	craftsman_data = craftsman
	item_index = index
	
	name_label.text = craftsman.name
	profession_label.text = craftsman.profession_name[craftsman.profession]
	level_label.text = "Lv." + str(craftsman.level)
	cost_label.text = "$" + str(craftsman.cost)

func set_selected(selected: bool) -> void:
	selection_highlight.visible = selected

func _on_pressed() -> void:
	craftsman_selected.emit(item_index)
