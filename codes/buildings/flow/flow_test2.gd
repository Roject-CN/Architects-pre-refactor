extends BaseFlow

@export var building_ui : BuildingUi

func flow_enter() -> void:
	print("Test 2 enter")
	building_ui.ui_enter()
	
func flow_exit() -> void:
	print("Test 2 exit")
	building_ui.ui_exit()
