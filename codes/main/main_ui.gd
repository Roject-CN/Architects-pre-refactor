extends Panel
class_name MainUi

@export var _save_resource : SaveResource

#一个月有30天 一年有12个月
const MONTH_PER_DAY := 30
const YEAR_PER_MONTH := 12
const TIME_DAYS_TEXT := "%3d年%2d月%2d日"
#主场景的ui
@onready var money_value: Label = $TopInformation/Money/Value
@onready var fame_value: Label = $TopInformation/Fame/Value
@onready var research_value: Label = $TopInformation/Research/Value
@onready var time_days: Label = $TopInformation/Time/Value


func init_main_ui(resource : SaveResource) -> void:
	_save_resource = resource
	
	money_value.text = str(_save_resource.current_money)
	fame_value.text = str(_save_resource.fame)
	research_value.text = str(_save_resource.research_value)
	update_time_days(_save_resource.time_days)
	
	_save_resource.current_money_changed.connect(update_money_value)
	_save_resource.fame_changed.connect(update_fame_value)
	_save_resource.research_value_changed.connect(update_research_value)
	_save_resource.time_days_changed.connect(update_time_days)

func update_money_value(value : int) -> void:
	money_value.text = str(value)
	
func update_fame_value(value : int) -> void:
	money_value.text = str(value)
	
func update_research_value(value : int) -> void:
	money_value.text = str(value)

func update_time_days(value : int) -> void:
	var year := value / YEAR_PER_MONTH / MONTH_PER_DAY 
	value -= year * YEAR_PER_MONTH * MONTH_PER_DAY
	var month := value / MONTH_PER_DAY 
	value -= month * MONTH_PER_DAY
	var days := value 
	time_days.text = TIME_DAYS_TEXT % [year + 1, month + 1, days + 1]
