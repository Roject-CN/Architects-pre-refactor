extends Node
var money :int = 1000
var test_timer_money_increase = 0.0
func _physics_process(delta: float) -> void:
	test_timer_money_increase += delta
	if test_timer_money_increase >= 1.0:
		print("Global测试money增加，当前money："+str(money))
		test_timer_money_increase -= 1
