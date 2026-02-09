class_name BaseEnvironment
extends Node2D

# 此处设一些影响value_geomancer的环境因素range[1,10]，分数越高越宜居
@export var factor_terrain :int = 5		#地形，指依山傍水的自然地势
@export var factor_rain :int = 5		#降水情况
@export var factor_wind :int = 5		#通风、风速等
@export var factor_sunlight :int = 5	#日照
@export var factor_water :int = 5		#水源
@export var factor_association :int = 5	#社群，指靠近群居地的社会环境
@export var factor_geology :int = 5		#地质，指土质、自然灾害区域等

# 基于环境因素计算value_geomancer，堪舆师可以设一乘数，对该值进行加成
func calculate_value_geomancer(multiply_geomancer : float = 1.0) -> int:
	var temp = factor_terrain + factor_rain + factor_wind + factor_sunlight + factor_water + factor_association + factor_geology
	return int(round(temp * 1.43 * multiply_geomancer))
