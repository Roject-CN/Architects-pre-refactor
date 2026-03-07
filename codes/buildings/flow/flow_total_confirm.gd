extends BaseFlow

@export var _flows : Array[BaseFlow]
@onready var total_confirm_ui: TotalConfirmUi = $TotalConfirmUi
var _flow_build_prop_config : Array[BuildPropConfig]

func flow_enter() -> void:
	super()
	assert( _flows.size() == 4, _flow_name + "的flows没有处理好")
	var craftsman_manager = total_confirm_ui.craftsman_manager
	for flow : BaseFlow in _flows:
		var props : Array[PropertyResource.PROPERTY]
		for i : BuildPropConfig in flow.build_prop_config:
			props.append(i.prop)
			
		var sort_list := craftsman_manager.sort_list(props)
		craftsman_manager.append_plan_craftsman(sort_list[0], flow.flow_index)
