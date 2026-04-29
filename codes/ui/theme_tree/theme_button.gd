extends Control
class_name ThemeButton

@export var next_theme_button : ThemeButton
@export var theme_resource : ThemeResource

@onready var button: Button = $Button
@onready var self_pos: Control = $self_pos
@onready var next_pos: Control = $next_pos
@onready var timer: Timer = $Timer

signal request_open_tooltip(str : String)
signal request_close_tooltip()

var entering := false

func _ready() -> void:
	button.text = theme_resource.name
	# 设置自身连接点的位置（基于按钮尺寸）
	next_pos.position.x = button.size.x / 2
	next_pos.position.y = -button.size.y / 2
	self_pos.position.x = button.size.x / 2
	self_pos.position.y = button.size.y / 2

func _draw() -> void:
	if next_theme_button == null:
		return

	var start := next_pos.position
	# 转换终点到本地坐标
	var end_global := next_theme_button.self_pos.global_position
	var end_local := get_global_transform().affine_inverse() * end_global

	# 绘制虚线贝塞尔曲线（中国风柔线）
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
	button.disabled = false

func _on_button_pressed() -> void:
	#
	match theme_resource.type:
		ThemeResource.TYPE.上分:
			Global.save_resource.top_theme_resource.append(theme_resource)
		
		ThemeResource.TYPE.中分:
			Global.save_resource.middle_theme_resource.append(theme_resource)
		
		ThemeResource.TYPE.下分:
			Global.save_resource.buttom_theme_resource.append(theme_resource)
	
	button.disabled = true
	if next_theme_button:
		next_theme_button.button_enable()




func _on_button_mouse_entered() -> void:
	timer.start()
	entering = true
	timer.timeout.connect(func ():
		if entering :
			request_open_tooltip.emit(theme_resource.description)
		)


func _on_button_mouse_exited() -> void:
	entering = false
	request_close_tooltip.emit()
