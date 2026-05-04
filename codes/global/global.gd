extends Node

# Global.gd

# 全局工匠市场数据
var global_craftsmen_market : Array[CraftsmanResource] = []

#加载存档资源
@export var save_resource : SaveResource

# 背景音乐相关
@onready var background_music: AudioStreamPlayer = AudioStreamPlayer.new()
var music_volume: float = 0.5
var is_music_enabled: bool = true

# 设置文件路径
const SETTINGS_FILE := "user://game_settings.cfg"



#信号
signal request_load_save_resource(SaveResource)
signal request_save_save_resource

func _ready() -> void:
	request_load_save_resource.connect(load_save_resource)
	request_save_save_resource.connect(save_save_resource)
	
	# 加载设置
	_load_settings()
	
	# 初始化背景音乐
	_setup_background_music()

func load_save_resource(resource : SaveResource) -> void:
	save_resource = resource
	save_resource.init_save_resource()

# 游戏启动时加载存档
func load_save_resource_on_start() -> void:
	save_resource = SaveResource.load_complete_game_data()
	save_resource.init_save_resource()

func save_save_resource() -> void:
	if save_resource:
		var result = save_resource.save_complete_game_data()
		if result != OK:
			push_error("存档保存失败: ", result)

# 手动保存游戏（供UI调用）
func manual_save_game() -> void:
	if save_resource:
		var result = save_resource.save_complete_game_data()
		if result != OK:
			push_error("手动存档失败: ", result)

# 创建备份存档
func create_backup_save() -> void:
	if save_resource:
		var result = save_resource.create_backup_save()
		if result != OK:
			push_error("备份创建失败: ", result)

func add_money(amount: int) -> void:
	save_resource.current_money += amount

func subtract_money(amount: int) -> void:
	save_resource.current_money -= amount

func add_fame(amount: int) -> void:
	save_resource.fame += amount

func subtract_fame(amount: int) -> void:
	save_resource.fame -= amount

func add_research(amount: int) -> void:
	save_resource.research_value += amount

func subtract_research(amount: int) -> void:
	save_resource.research_value -= amount

func add_days(amount : int) -> void:
	save_resource.time_days += amount

func add_building_resource(building_resource : BuildingResource) -> void:
	save_resource.add_building_resource(building_resource)

func themes_empty() -> bool :
	var a1 := save_resource.top_theme_resource.is_empty()
	var a2 := save_resource.middle_theme_resource.is_empty()
	var a3 := save_resource.buttom_theme_resource.is_empty()
	return a1 || a2 || a3

# 背景音乐功能

# 初始化背景音乐
func _setup_background_music() -> void:
	# 添加AudioStreamPlayer到场景
	add_child(background_music)
	background_music.volume_db = linear_to_db(music_volume)
	
	# 加载背景音乐（m4a格式）
	_load_background_music()

# 加载背景音乐文件
func _load_background_music() -> void:
	var music_paths = [
		"res://music/background.ogg"
	]
	
	var music_stream: AudioStream
	
	for path in music_paths:
			if FileAccess.file_exists(path):
				music_stream = load(path)
				if music_stream:
					break
	
	if music_stream:
		background_music.stream = music_stream
		background_music.autoplay = true
		
		# 在Godot 4.x中，loop属性在AudioStream上设置
		if music_stream is AudioStreamWAV:
			music_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		elif music_stream is AudioStreamOggVorbis:
			music_stream.loop = true
		elif music_stream is AudioStreamMP3:
			music_stream.loop = true
		
		if is_music_enabled:
			background_music.play()

# 播放背景音乐
func play_background_music() -> void:
	if is_music_enabled and background_music.stream:
		background_music.play()

# 暂停背景音乐
func pause_background_music() -> void:
	if background_music.playing:
		background_music.pause()

# 停止背景音乐
func stop_background_music() -> void:
	if background_music.playing:
		background_music.stop()

# 设置音乐音量 (0.0 - 1.0)
func set_music_volume(volume: float) -> void:
	music_volume = clamp(volume, 0.0, 1.0)
	background_music.volume_db = linear_to_db(music_volume)
	_save_settings()  # 保存设置

# 启用/禁用背景音乐
func set_music_enabled(enabled: bool) -> void:
	is_music_enabled = enabled
	if enabled:
		if not background_music.playing:
			background_music.play()
	else:
		if background_music.playing:
			background_music.stop()
	_save_settings()

# 获取当前音乐状态
func get_music_status() -> Dictionary:
	return {
		"enabled": is_music_enabled,
		"volume": music_volume,
		"playing": background_music.playing,
		"has_music": background_music.stream != null
	}

# 设置持久化功能

# 加载设置
func _load_settings() -> void:
	var config = ConfigFile.new()
	var error = config.load(SETTINGS_FILE)
	
	if error == OK:
		# 加载音乐设置
		if config.has_section_key("audio", "music_volume"):
			music_volume = config.get_value("audio", "music_volume")
		
		if config.has_section_key("audio", "music_enabled"):
			is_music_enabled = config.get_value("audio", "music_enabled")

# 保存设置
func _save_settings() -> void:
	var config = ConfigFile.new()
	
	# 保存音乐设置
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "music_enabled", is_music_enabled)
	
	var error = config.save(SETTINGS_FILE)
	if error != OK:
		push_error("设置保存失败: ", error)
