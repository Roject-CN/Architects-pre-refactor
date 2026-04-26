extends AttributionUi
class_name RewardUi

@onready var assure: Button = $Button/Assure
@onready var progress_bar: ProgressBar = $Left/VBoxContainer/ProgressBar
@onready var reward: Label = $Left/VBoxContainer/Reward

const reward_text := "奖励: %d $"
var reward_value := 0

var values_deltas : Array[float] = [0.0, 0.0, 0.0, 0.0]
var temp_deltas : Array[float] = [0.0, 0.0, 0.0, 0.0] 

var value_pecent : float = 0.0 : 
	set(new_value):
		value_pecent = new_value
		progress_bar.value = value_pecent	
		if value_pecent >= 1.0:
			assure.disabled = false
		
@export var time : float = 5.0

func _ready() -> void:
	super()
	assure.disabled = true
	progress_bar.value = 0.0

func ui_exit() -> void:
	super()
	Global.add_money(reward_value * 2)

func ui_enter() -> void:
	show_resouce_attribution(building_resource)
	var index := 0
	var values := building_resource.values
	for key in values:
		values_deltas[index] = time / float(values.get(key))
		index += 1
	
	super()

func ui_process(delta: float) -> void:
	if value_pecent >= 1.1:
		return
	value_pecent += 1.0 / time * delta 
	
	var index := 0
	for i in values_deltas:
		temp_deltas[index] += delta
		if temp_deltas[index] >= i:
			temp_deltas[index] = 0
			var information_ui : InformationUI = r_container.get_child(index)
			information_ui.calculate_value(1)		
			reward_value += 1
			reward.text = reward_text % reward_value
			building_resource.cost += 1
		index += 1
	
func _on_assure_pressed() -> void:
	ui_exit()
	request_next()
