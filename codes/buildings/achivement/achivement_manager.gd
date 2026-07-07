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
	# 遍历所有成就，触发所有符合条件的成就
	var achievements_to_unlock: Array[Achivement] = []
	
	for achivement : Achivement in building_achievement.get_children():
		# 如果成就未解锁且符合条件
		if achivement.locked and achivement.is_the_same(resource):
			achievements_to_unlock.append(achivement)
	
	# 如果有符合条件的成就
	if achievements_to_unlock.size() > 0:
		# 触发第一个成就的弹窗
		var first_achievement = achievements_to_unlock[0]
		pop_up_ui.pop_up_information("恭喜你解锁 %s 成就" % first_achievement.achievement_name, 
		first_achievement.description)
		pop_up_ui.visible = true
		
		# 记录所有解锁的成就
		for achivement in achievements_to_unlock:
			achivement.locked = false
			
			var new := BuildingResource.new()
			new.top_theme = achivement.top_theme
			new.middle_theme = achivement.middle_theme
			new.buttom_theme = achivement.buttom_theme
			for key in new.values:
				new.values[key] = achivement.compare.values[key] + 1
			
			new.name = achivement.achievement_name
			new.description = achivement.description
			
			Global.save_resource.achievements.append(new)
