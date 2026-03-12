extends Node
class_name MainTime
#用于游戏时间的一个类，不仅能够增加天数，同时未来还承担比如计算员工精力值等功能
#后面将会更新白天黑夜的效果，_time 在0-_seconds_per_day/2秒为白天 另一半为黑夜
#员工在白天没有工作时会消耗少量精力值 在工作时消耗较多精力值
#然后在黑夜里员工下班后补充精力值 


#在经历 seconds_per_day 秒后过去一天
@export var _seconds_per_day : int = 24
@export var craftsman_manager : CraftsmanManager
var _time : float : 
	set(value):
		_time = value
		if _time > _seconds_per_day:
			_time = 0
			Global.add_days(1)

func _ready() -> void:
	assert(craftsman_manager, "MainTime's craftsman_manager is empty")		
	
func _physics_process(delta: float) -> void:
	_time += delta
