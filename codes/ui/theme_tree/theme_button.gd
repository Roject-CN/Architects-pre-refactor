extends Control
class_name ThemeButton

@export var next_theme_button : ThemeButton
@export var theme_resource : ThemeResource
@export var unlock_need_fame : int = 0
@export var cost_money : int = 100

@onready var button: TextureRect = $Button
@onready var label: Label = $Button/Label
@onready var label_2: RichTextLabel = $Button/Label2


@onready var self_pos: Control = $self_pos
@onready var next_pos: Control = $next_pos
@onready var timer: Timer = $Timer

signal request_open_tooltip(str : String)
signal request_close_tooltip()

var entering := false
const tip_text := "%3s名气值 %3s金钱解锁"
var tween : Tween

func _ready() -> void:
	label.text = theme_resource.name
	# 设置自身连接点的位置（基于按钮尺寸）
	next_pos.position.x = button.size.x / 2
	next_pos.position.y = -button.size.y / 2
	self_pos.position.x = button.size.x / 2
	self_pos.position.y = button.size.y / 2
	
	button_disable()
	
	label_2.hide()
	label_2.text = tip_text % [unlock_need_fame, cost_money]

func _draw() -> void:
	if next_theme_button == null:
		return

	var start := next_pos.position
	var end_global := next_theme_button.self_pos.global_position
	var end_local := get_global_transform().affine_inverse() * end_global

	draw_dashed_bezier(start, end_local, 8.0, 4.0, Color.BLACK, 2.0)

# 辅助函数：绘制带控制点的三次贝塞尔虚线
func draw_dashed_bezier(start: Vector2, end: Vector2,
						dash_length: float = 8.0, gap_length: float = 4.0,
						color: Color = Color.BLACK, width: float = 2.0):
	# 计算两个控制点，使曲线呈现平缓的S形或弧线
	var mid_x := (start.x + end.x) * 0.5
	var ctrl1 := Vector2(mid_x, start.y)
	var ctrl2 := Vector2(mid_x, end.y)

	# 将曲线离散为折线段
	var segments := 30
	var points: PackedVector2Array = []
	for i in range(segments + 1):
		var t := float(i) / segments
		var p := start * (1-t)*(1-t)*(1-t) + ctrl1 * 3 * (1-t)*(1-t) * t \
				 + ctrl2 * 3 * (1-t) * t * t + end * t*t*t
		points.append(p)

	# 沿折线绘制虚线
	var remaining := 0.0
	var drawing := true

	for i in range(points.size() - 1):
		var p1 := points[i]
		var p2 := points[i+1]
		var seg_vector := p2 - p1
		var seg_length := seg_vector.length()
		if seg_length == 0:
			continue
		var direction := seg_vector.normalized()
		var pos := p1

		while seg_length > 0:
			if drawing:
				var draw_len := minf(seg_length, dash_length - remaining)
				draw_line(pos, pos + direction * draw_len, color, width)
				pos += direction * draw_len
				seg_length -= draw_len
				remaining += draw_len
				if remaining >= dash_length:
					remaining = 0.0
					drawing = false
			else:
				var skip_len := minf(seg_length, gap_length - remaining)
				pos += direction * skip_len
				seg_length -= skip_len
				remaining += skip_len
				if remaining >= gap_length:
					remaining = 0.0
					drawing = true

func button_enable() -> void:
	button.modulate = Color("ffffffff")
	cease_animation()
		
	var blink_tween = get_tree().create_tween()
	blink_tween.set_ease(Tween.EASE_IN_OUT)
	blink_tween.set_trans(Tween.TRANS_SINE)

	blink_tween.tween_property(button, "modulate:a", 0.7, 0.8)
	blink_tween.parallel().tween_property(button, "scale", Vector2.ONE * 0.95, 0.8)

	blink_tween.tween_property(button, "modulate:a", 1.0, 0.8)
	blink_tween.parallel().tween_property(button, "scale", Vector2.ONE * 1.1, 0.8)

	blink_tween.set_loops()
	#blink_tween.tween_interval(0)
	
	tween = blink_tween
	
func button_disable() -> void:
	cease_animation()
	button.modulate = Color("595959ff")
	button.scale = Vector2(1.0, 1.0)
func button_pressed() -> void:
	cease_animation()
	button.modulate = Color("aeaeaeff")
	button.scale = Vector2(1.0, 1.0)

func _on_button_pressed() -> void:
	
	if Global.save_resource.current_money < cost_money:
		return
	if Global.save_resource.fame < unlock_need_fame:
		return
	
	Global.subtract_money(cost_money)
	
	#
	match theme_resource.type:
		ThemeResource.TYPE.上分:
			Global.save_resource.top_theme_resource.append(theme_resource)
		
		ThemeResource.TYPE.中分:
			Global.save_resource.middle_theme_resource.append(theme_resource)
		
		ThemeResource.TYPE.下分:
			Global.save_resource.buttom_theme_resource.append(theme_resource)
	
	button_pressed()
	if next_theme_button:
		next_theme_button.button_enable()

func cease_animation() -> void:
	if tween and tween.is_valid():
		tween.kill()

func _on_button_mouse_entered() -> void:
	var fame_str : String
	var money_str : String
	if Global.save_resource.fame < unlock_need_fame:
		fame_str = "[color=red]" + str(unlock_need_fame) + "[/color]"
	else:
		fame_str = "[color=green]" + str(unlock_need_fame) + "[/color]"
	if Global.save_resource.current_money < cost_money:
		money_str = "[color=red]" + str(cost_money) + "[/color]"
	else:
		money_str = "[color=green]" + str(cost_money) + "[/color]"
	
	label_2.reset_size()
	label_2.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	label_2.position.y -= (label_2.size.y + 5)
	label_2.text = tip_text % [fame_str, money_str]
	label_2.show()
	
	timer.start()
	entering = true
	timer.timeout.connect(func ():
		if entering :
			request_open_tooltip.emit(theme_resource.description)
		)


func _on_button_mouse_exited() -> void:
	label_2.hide()
	
	entering = false
	request_close_tooltip.emit()


func _on_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_on_button_pressed()
