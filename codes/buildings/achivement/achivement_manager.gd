extends Node
class_name AchivementManager

@onready var building_achievement: Node = $BuildingAchievement

@onready var pop_up_ui: PopUpUi = $PopUpUi

func _ready() -> void:
	#已经被解锁的成就
	for i : BuildingResource in Global.save_resource.achievements:
		for j : Achivement in building_achievement.get_children():
			if j.is_the_same(i):
				j.locked = false

func return_achivement(resource : BuildingResource) -> Achivement:
	
	for i : Achivement in building_achievement.get_children():
		if i.is_the_same(resource) and i.locked:
			#如果建筑资源的主题和成就一致且符合数值 并且成就还未解锁(locked == true)
			return i
	
	return null	


func achieve(resource : BuildingResource) -> void:
	
	var achivement := return_achivement(resource)
	if achivement :
		print(achivement.achievement_name)
		print(achivement.description)
		pop_up_ui.pop_up_information("恭喜你解锁 %s 成就" % achivement.achievement_name, 
		achivement.description)
		pop_up_ui.visible = true
		
		var new := BuildingResource.new()
		new.top_theme = achivement.top_theme
		new.middle_theme = achivement.middle_theme
		new.buttom_theme = achivement.buttom_theme
		for key in new.values:
			new.values[key] = achivement.compare.values[key] + 1
		
		new.name = achivement.achievement_name
		new.description = achivement.description
		
		Global.save_resource.achievements.append(new)
