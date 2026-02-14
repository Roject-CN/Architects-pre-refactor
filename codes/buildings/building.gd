class_name Building
extends Node2D

@export var building_resource : BuildingResource


func _ready() -> void:
	_load_environment()	#加载预设环境



## 属性部分

# 显示于building_attributes,range[0,100]
var value_geomancer :int = 0	#堪舆值
var value_designer :int = 0		#设计值
var value_artisan :int = 0		#匠心值
var value_accountant :int = 5	#赚钱速率

# 由geomancer提供的乘数，在计算value_geomancer时提供加成,range[1,10]
var multiply_geomancer :float = 1.0
# 由accountant提供的乘数，在计算赚钱速率时提供加成,range[1,10]
var multiply_accountant :float = 1.0


# 基于建筑属性计算赚钱速率
func _calculate_accountant():
	value_accountant = value_geomancer + value_designer + value_artisan
	value_accountant = int(round(value_accountant * multiply_accountant))



# 修改各项属性。method为ADD时，该属性值增加value；为DELETE时，该属性值减少value；为REPLACE时，该属性值替换为value
# 其中，change_geomancer、change_accountant修改属性值multiply_geomancer、multiply_account，仅接受REPLACE

enum METHOD {ADD,DELETE,REPLACE}

#修改全部属性
func change_value(v_geomancer:int,v_designer:int,v_artisan:int,v_accountant:float,method:METHOD = METHOD.ADD):
	change_value_geomancer(v_geomancer,method)
	change_value_designer(v_designer,method)
	change_value_artisan(v_artisan,method)
	change_value_accountant(v_accountant)

#修改具体属性
func change_value_geomancer(value:int,method:METHOD = METHOD.REPLACE):
	if not method == METHOD.REPLACE:
		push_error("change_value_geomancer函数不接受非REPLACE方法")
		method = METHOD.REPLACE
	if value < 1:
		value = 1
		push_error("multiply_geomancer属性操作异常，multiply值应不小于1")
	multiply_geomancer = value
	value_geomancer = environment_instance.calculate_value_geomancer(multiply_geomancer)
	_calculate_accountant()

func change_value_designer(value:int,method:METHOD = METHOD.ADD):
	var v = value_designer
	match method:
		METHOD.ADD:
			v += value
		METHOD.DELETE:
			v -= value
		METHOD.REPLACE:
			v = value
	if v < 0:
		v = 0
		push_error("value_designer属性操作异常，attribute值应不小于0")
	value_designer = v
	_calculate_accountant()

func change_value_artisan(value:int,method:METHOD = METHOD.ADD):
	var v = value_artisan
	match method:
		METHOD.ADD:
			v += value
		METHOD.DELETE:
			v -= value
		METHOD.REPLACE:
			v = value
	if v < 0:
		v = 0
		push_error("value_artisan属性操作异常，attribute值应不小于0")
	value_artisan = v
	_calculate_accountant()

func change_value_accountant(value:float,method:METHOD = METHOD.REPLACE):
	if not method == METHOD.REPLACE:
		push_error("change_value_accountant函数不接受非REPLACE方法")
		method = METHOD.REPLACE
	if value < 1:
		value = 1
		push_error("multiply_accountant属性操作异常，multiply值应不小于1")
	multiply_accountant = value
	_calculate_accountant()




## 环境部分
@export var folder_environments : Array[PackedScene] = []	#存放预设的环境场景
@export var parent_environments : Node = null	#环境加载后的父节点
var environment_instance

# 从预设环境中随机加载一个环境
func _load_environment():
	var random_environment = folder_environments[randi() % folder_environments.size()]
	environment_instance = random_environment.instantiate()
	parent_environments.add_child(environment_instance)




## 三分部分
@export var folder_divisions_bottom : Array[PackedScene] = []	#下分
@export var folder_divisions_middle : Array[PackedScene] = []	#中分
@export var folder_divisions_top    : Array[PackedScene] = []	#上分
@export var parent_divisions : Node = null	#父节点

# 加载指定的division
func add_division(folder:Array[PackedScene],index:int):
	var division_instance = folder[index].instantiate()
	parent_divisions.add_child(division_instance)
