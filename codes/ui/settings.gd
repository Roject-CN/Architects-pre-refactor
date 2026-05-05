extends Control
class_name Settings

# 信号
signal closed()

# UI引用
@onready var close_button: Button = $Panel/MarginContainer/VBoxContainer/HBoxContainer/Close
@onready var music_slider: HSlider = $Panel/MarginContainer/VBoxContainer/ScrollContainer/settings/MarginContainer/Music/HSlider
@onready var music_label: Label =$Panel/MarginContainer/VBoxContainer/ScrollContainer/settings/MarginContainer/Music
@onready var music_toggle: CheckButton = $Panel/MarginContainer/VBoxContainer/ScrollContainer/settings/MarginContainer/Music/Button

func _ready() -> void:
	# 连接信号
	close_button.pressed.connect(_on_close_pressed)
	music_slider.value_changed.connect(_on_music_volume_changed)
	music_toggle.toggled.connect(_on_music_toggle_changed)
	
	# 初始化设置
	_initialize_settings()

# 初始化设置
func _initialize_settings() -> void:
	# 获取当前音乐状态
	var music_status = Global.get_music_status()
	
	# 设置音乐音量滑块
	music_slider.value = music_status["volume"] * 100
	_update_music_label(music_slider.value)
	
	# 设置音乐开关
	music_toggle.button_pressed = music_status["enabled"]
	_update_music_toggle_text(music_status["enabled"])

# 更新音乐音量标签
func _update_music_label(value: float) -> void:
	music_label.text = "背景音乐:" + str(int(value)) + "%"

# 更新音乐开关按钮文本
func _update_music_toggle_text(enabled: bool) -> void:
	music_toggle.text = "启用" if enabled else "禁用"

# 音乐音量改变
func _on_music_volume_changed(value: float) -> void:
	_update_music_label(value)
	Global.set_music_volume(value / 100.0)

# 音乐开关切换
func _on_music_toggle_changed(toggled: bool) -> void:
	Global.set_music_enabled(toggled)
	_update_music_toggle_text(toggled)
	
	# 如果启用音乐且当前没有播放，则开始播放
	if toggled and not Global.background_music.playing:
		Global.play_background_music()

# 关闭设置界面
func _on_close_pressed() -> void:
	closed.emit()
	queue_free()
