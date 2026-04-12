extends BaseUi
class_name PlaceHolderUi

@export var timer : float = 24.0
var time : float = 0.0 
var can_time_process : bool = true


func ui_enter() -> void:
	Event.building_ui_quit.emit()
	#Event.craftsman_become_busy.emit()
	hide()
	
	#连接prop_config的信号 
	for prop_config in prop_configs:
		#下面一行不用添加 因为这一个页面没有ui 不需要展示
		#prop_config.request_animation_ui_add.connect(animation_ui_add)
		#prop_config增加工作的员工
		for craftsman_character : CraftsmanCharacter in craftsman_manager.current_list:
			prop_config.append_new_craftsman(craftsman_character.craftman_resource)
	

func ui_process(delta : float) -> void:
	can_time_process = craftsman_manager.return_craftsman_is_working()
	if can_time_process:
		time += delta 
		#prop_configs执行自己相应的逻辑
		for i in prop_configs:
			i.build_process(delta / 10)
			
	if time >= timer:
		ui_exit()
		request_next()

func ui_exit() -> void:
	Event.building_ui_enter.emit()
	#Event.craftsman_become_lazy.emit()
	
