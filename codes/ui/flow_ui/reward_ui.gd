extends AttributionUi
class_name RewardUi

@onready var assure: Button = $Button/Assure
@onready var progress_bar: ProgressBar = $Left/VBoxContainer/ProgressBar
@onready var reward: Label = $Left/VBoxContainer/Reward
@onready var achivement_manager: AchivementManager = $AchivementManager
@onready var texture_rect: TextureRect = $Left/VBoxContainer/TextureRect



const reward_text := "奖励: %d $"
var reward_value := 0   # 累计奖励金钱
var total_v := 0

# 每个资源属性的事件队列结构
var event_queues : Array[Array]   # 每个元素是一个 Array[int]（扣减量序列）
var triggered_indexes : Array[int]  # 每个属性已触发到第几个事件（下一个待触发的索引）
var total_events_per_attr : Array[int]  # 每个属性的事件总数

var elapsed_time : float = 0.0
var value_percent : float = 0.0 : 
	set(new_value):
		value_percent = new_value
		progress_bar.value = value_percent	
		if value_percent >= 1.0:
			assure.disabled = false
			achivement_manager.achive(building_resource)

@export var time : float = 5.0

# 可配置的面额列表（从大到小）
@export var denominations : Array[int] = [50, 10, 5, 1]

# 将数值 amount 分解为 denominations 中的面额组合
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
	Global.add_money(reward_value)   # 你的原有逻辑

func ui_enter() -> void:
	show_resouce_attribution(building_resource)
	
	var values = building_resource.values   # 假设 values 是 Dictionary，值为 int
	event_queues.clear()
	triggered_indexes.clear()
	total_events_per_attr.clear()
	
	for key in values:
		var total_value = values.get(key)   # 例如 212
		var queue = decompose_amount(total_value)   # 得到 [100, 100, 10, 1, 1]
		event_queues.append(queue)
		triggered_indexes.append(0)
		total_events_per_attr.append(queue.size())
	
	elapsed_time = 0.0
	reward_value = 0
	reward.text = reward_text % reward_value
	value_percent = 0.0
	if building_resource.texture:
		texture_rect.texture = building_resource.texture
	super()

func ui_process(delta: float) -> void:
	if value_percent >= 1.0:
		reward.text = reward_text % reward_value
		return
	
	# 更新流逝时间，并限制最大不超过 time
	elapsed_time += delta
	if elapsed_time > time:
		elapsed_time = time
	
	# 更新进度条百分比
	value_percent = elapsed_time / time
	
	# 对每个属性独立处理事件触发
	for i in range(event_queues.size()):
		var queue = event_queues[i]
		var total_events = total_events_per_attr[i]
		if total_events == 0:
			continue
		if triggered_indexes[i] >= total_events:
			continue   # 该属性事件已全部触发完毕
		
		# 根据总时间进度，计算理论上应该触发到的事件索引（从0开始）
		var progress = elapsed_time / time   # 0..1
		var expected_index = int(floor(progress * total_events))
		# 确保索引不会越界
		if expected_index >= total_events:
			expected_index = total_events - 1
		
		# 补发从已触发索引到期望索引之间的事件
		while triggered_indexes[i] <= expected_index:
			var delta_value = queue[triggered_indexes[i]]
			# 获取对应的 InformationUI（假设 r_container 按属性顺序排列）
			var information_ui : InformationUI = r_container.get_child(i)
			information_ui.calculate_value(delta_value)   # 播放对应数值的动画（如 "-100"）
			total_v += delta_value
			reward_value = int(log(total_v + 1) / log(1.5)  *  30)	
			reward.text = reward_text % (reward_value * value_percent)
			building_resource.cost += delta_value   
			triggered_indexes[i] += 1
			
		
func _on_assure_pressed() -> void:
	request_next()
