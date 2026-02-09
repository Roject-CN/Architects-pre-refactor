class_name BuildingAttributes
extends Node2D

@export var building : Building = null

func _ready() -> void:
	show_attributes()

# 更新显示的所有建筑属性，在属性有更改时调用或置于物理帧循环中持续调用
func show_attributes():
	$HBoxContainer/Geomancer.text = "堪舆值：" + str(building.value_geomancer)
	$HBoxContainer/Designer.text = "设计值：" + str(building.value_designer)
	$HBoxContainer/Artisan.text = "匠心值：" + str(building.value_artisan)
	$HBoxContainer/Accountant.text = "收益值：" + str(building.value_accountant)
