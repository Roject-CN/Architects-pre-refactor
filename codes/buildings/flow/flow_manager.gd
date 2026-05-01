class_name FlowManager
extends Node

@onready var building: Building = $".."
@export var building_resource : BuildingResource

@export var initial_flow : BaseFlow
@export var current_flow : BaseFlow : 
	set(new_flow):
		if current_flow:
			current_flow.flow_exit()   # 仅清理，不触发信号
		current_flow = new_flow
		current_flow.flow_enter()

var amount_flow : int = 0
var index_flow : int = 0
var flows : Array[BaseFlow]

#放慢的倍数
@export_range(0, 5, 1) var slow_times := 2
var count := 0 :
	set(value):
		count = value
		var max_count := slow_times - 1
		if count >= (max_count - 1):
			count = 0
			
func _ready() -> void:
	assert(initial_flow, "flow_manager的initial_flow没有设定")
	for i : BaseFlow in self.get_children():
		i.flow_changed.connect(flow_transition)
		amount_flow += 1
		flows.append(i)

#在Building类中调用
func open_flow_manager() -> void:
	#initialize_current_flow
	current_flow = initial_flow

#执行当前flow的flow_process
func _physics_process(delta: float) -> void:
	if current_flow:
		if count == 0:
			current_flow.flow_process(delta * (slow_times - 1))
		count += 1
		
func flow_transition() -> void:
	if index_flow == (amount_flow - 1):
		current_flow.flow_exit()   # 清理最后一个流程，可根据需要在此触发结束信号
		save_building_resource()   #保存 building_resource到用户文件
		return
	else:
		index_flow += 1
		
	current_flow = flows[index_flow]  # 切换流程

# 设置到指定阶段（用于存档恢复）
func set_flow_to_index(target_index: int) -> void:
	if target_index >= 0 and target_index < amount_flow:
		index_flow = target_index
		current_flow = flows[index_flow]
		current_flow.flow_enter()
		print("已设置到建造阶段: ", target_index)
	else:
		print("无效的阶段索引: ", target_index)

func save_building_resource() -> void:
	# 建筑建造流程全部完成，调用Building类的保存函数
	# Building类中的save_builiding_resource()会发射building_complete信号
	if building and building.has_method("save_builiding_resource"):
		building.save_builiding_resource()