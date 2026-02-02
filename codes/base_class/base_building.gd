class_name BaseBuilding
extends Node2D

# 显示于building_attributes,range[0,100]
var value_geomancer :int = 0	#堪舆值
var value_designer :int = 0		#设计值
var value_artisan :int = 0		#匠心值
var value_accountant :int = 15	#赚钱速率

# 加载所有工匠场景
@onready var geomancer_scene_1 : PackedScene = preload("res://scenes/craftsmen/mvp_geomancer.tscn")
@onready var designer_scene_1 : PackedScene = preload("res://scenes/craftsmen/mvp_designer.tscn")
@onready var artisan_scene_1 : PackedScene = preload("res://scenes/craftsmen/mvp_artisan.tscn")
@onready var accountant_scene_1 : PackedScene = preload("res://scenes/craftsmen/mvp_accountant.tscn")

# 需要时，在每个building中实例化
var geomancer_array : Array = [
	geomancer_scene_1,
]
var designer_array : Array = [
	designer_scene_1,
]
var artisan_array : Array = [
	artisan_scene_1,
]
var accountant_array : Array = [
	accountant_scene_1,
]

# 基于建筑属性计算赚钱速率
func calculate_accountant() -> float:
	value_accountant = value_geomancer + value_designer + value_artisan
	return value_accountant * 0.1

func change_geomancer(i:int):
	value_geomancer += i

func change_designer(i:int):
	value_designer += i

func change_artisan(i:int):
	value_artisan += i

func change_accountant(i:int):
	value_accountant += i

func show_geomancer_list():
	pass

func show_designer_list():
	pass

func show_artisan_list():
	pass

func show_accountant_list():
	pass
