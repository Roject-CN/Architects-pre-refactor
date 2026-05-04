extends AttributionUi
class_name RewardUi

@onready var assure: Button = $Button/Assure
@onready var progress_bar: ProgressBar = $Left/VBoxContainer/ProgressBar
@onready var reward: Label = $Left/VBoxContainer/Reward
@onready var reward_2: Label = $Left/VBoxContainer/Reward2
@onready var achivement_manager: AchivementManager = $AchivementManager
@onready var texture_rect: TextureRect = $Left/VBoxContainer/TextureRect
var pick_pictures : PicturePick


const reward_text := "奖励: %d $"
const reward_text2 := "奖励: %d 名气值"
var reward_value : int = 0   
var reward_fame : int = 0
var total_v := 0

var event_queues : Array[Array]   
var triggered_indexes : Array[int]  
var total_events_per_attr : Array[int]  

var elapsed_time : float = 0.0
var value_percent : float = 0.0 : 
	set(new_value):
		value_percent = new_value
		progress_bar.value = value_percent	
		if value_percent >= 1.0:
			assure.disabled = false
			achivement_manager.achive(building_resource)
			

@export var per_fame_need : int = 15
@export var time : float = 5.0

@export var denominations : Array[int] = [50, 10, 5, 1]

func decompose_amount(amount: int) -> Array[int]:
	var result : Array[int] = []
	var remaining = amount
	for denom in denominations:
		@warning_ignore("integer_division")
		var count = remaining / denom
		for _i in range(count):
			result.append(denom)
		remaining -= count * denom
	return result

func _ready() -> void:
	super()
	assure.disabled = true
	progress_bar.value = 0.0
	

func ui_exit() -> void:
	super()
	Global.add_money(reward_value)   
	Global.add_fame(reward_fame)

func ui_enter() -> void:
	show_resouce_attribution(building_resource)
	
	var values = building_resource.values   
	event_queues.clear()
	triggered_indexes.clear()
	total_events_per_attr.clear()
	
	for key in values:
		var total_value = values.get(key)   
		var queue = decompose_amount(total_value)   
		event_queues.append(queue)
		triggered_indexes.append(0)
		total_events_per_attr.append(queue.size())
	
	elapsed_time = 0.0
	reward_value = 0
	reward.text = reward_text % reward_value
	value_percent = 0.0
	
	#寻找相应的照片
	pick_pictures.pick_pictures(building_resource)
	if building_resource.texture:
		texture_rect.texture = building_resource.texture
	super()

func ui_process(delta: float) -> void:
	if value_percent >= 1.0:
		reward.text = reward_text % reward_value
		reward_2.text = reward_text2 % reward_fame
		return
	
	# 更新流逝时间
	elapsed_time += delta
	if elapsed_time > time:
		elapsed_time = time
	
	# 更新进度条百分比
	value_percent = elapsed_time / time
	
	for i in range(event_queues.size()):
		var queue = event_queues[i]
		var total_events = total_events_per_attr[i]
		if total_events == 0:
			continue
		if triggered_indexes[i] >= total_events:
			continue   
		
		# 根据总时间进度，计算理论上应该触发到的事件索引（从0开始）
		var progress = elapsed_time / time   
		var expected_index = int(floor(progress * total_events))
		
		if expected_index >= total_events:
			expected_index = total_events - 1
		
		while triggered_indexes[i] <= expected_index:
			var delta_value = queue[triggered_indexes[i]]
			var information_ui : InformationUI = r_container.get_child(i)
			information_ui.calculate_value(delta_value)  
			total_v += delta_value
			reward_value = int(log(total_v + 1) / log(1.5)  *  30)	
			
			reward_fame = int(total_v) / int(per_fame_need)
			reward.text = reward_text % (reward_value * value_percent)
			reward_2.text = reward_text2 % (reward_fame * value_percent)
			building_resource.cost += delta_value   
			triggered_indexes[i] += 1
			
		
func _on_assure_pressed() -> void:
	request_next()
