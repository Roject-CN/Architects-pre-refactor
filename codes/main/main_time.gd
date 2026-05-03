extends Node
class_name MainTime
#用于游戏时间的一个类，不仅能够增加天数，同时未来还承担比如计算员工精力值等功能
#后面将会更新白天黑夜的效果，_time 在0-_seconds_per_day/2秒为白天 另一半为黑夜
#员工在白天没有工作时会消耗少量精力值 在工作时消耗较多精力值
#然后在黑夜里员工下班后补充精力值 


#在经历 seconds_per_day 秒后过去一天
@export var _seconds_per_day : int = 24
@export var craftsman_manager : CraftsmanManager
@export var canvas_modulate : CanvasModulate
var can_time_process := true
signal request_go_to_work
signal request_go_to_rest

var count : int = 0
var working := true
var _time : float  = 0: 
	set(value):
		_time = value
		count = int(_time)
		if _time > _seconds_per_day:
			_time = 0
			Global.add_days(1)
			working = true	
			request_go_to_work.emit()
			
		if count == int(_seconds_per_day / 2):
			request_go_to_rest.emit()
			working = false
		_update_lighting()

func _update_lighting():
	var time_ratio : float = _time / float(_seconds_per_day)

	# 使用正弦函数创建平滑过渡
	var brightness : float = sin(time_ratio * PI * 2.0) * 0.5 + 0.5
	brightness = clamp(brightness, 0.3, 1.0)

	# 颜色插值
	var day_color : Color = Color(1.0, 1.0, 0.9)    # 白天：暖黄色
	var night_color : Color = Color(0.227, 0.227, 0.227, 1.0)  # 夜晚：冷蓝色

	# 根据时间混合颜色
	var color_mix : float
	if time_ratio < 0.5:
		color_mix = time_ratio * 2.0  # 0.0 -> 1.0
	else:
		color_mix = 1.0 - (time_ratio - 0.5) * 2.0  # 1.0 -> 0.0

	var final_rgb : Color = day_color.lerp(night_color, 1.0 - color_mix)

	# 应用亮度
	final_rgb.r *= brightness
	final_rgb.g *= brightness
	final_rgb.b *= brightness

	# 保持Alpha不变
	var current_color : Color = canvas_modulate.color
	final_rgb.a = current_color.a
	canvas_modulate.color = final_rgb

func can_go_to_work() -> bool:
	return working


func _ready() -> void:
	assert(craftsman_manager, "MainTime's craftsman_manager is empty")		
	
	#通过全局的 Event 脚本连接信号 当建筑页面出现时停止时间的计时和天气的变化，在 PlaceHolder和被销毁后又开始计时
	Event.building_ui_enter.connect(func() : can_time_process = false)
	Event.building_ui_quit.connect(func() : can_time_process = true)
func _physics_process(delta: float) -> void:
	if can_time_process:
		_time += delta
		craftsman_manager.craftsmans_character_process(delta)
