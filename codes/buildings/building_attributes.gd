class_name BuildingAttributes
extends BaseBuilding

func show_update():
	$VBoxContainer/FengShui.text = value_geomancer
	$VBoxContainer/Design.text = value_designer
	$VBoxContainer/Artisan.text = value_artisan
	$VBoxContainer/Money.text = super.calculate_accountant()

func _on_geomancer_pressed() -> void:
	pass # Replace with function body.

func _on_designer_pressed() -> void:
	pass # Replace with function body.

func _on_artisan_pressed() -> void:
	pass # Replace with function body.

func _on_accountant_pressed() -> void:
	pass # Replace with function body.
