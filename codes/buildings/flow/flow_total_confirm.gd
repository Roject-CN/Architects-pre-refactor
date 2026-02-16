extends BaseFlow
class_name FlowTotalConfirm

@onready var total_confirm_ui: TotalConfirmUi = $TotalConfirmUi

func flow_enter() -> void:
	super()

func flow_exit() -> void:
	super()
	plan_craftsmen = total_confirm_ui.plan_craftsmen
	var flow_manager := get_parent()
	if flow_manager and flow_manager is FlowManager:
		flow_manager = flow_manager as FlowManager
		flow_manager.plan_craftsmen =  total_confirm_ui.plan_craftsmen
