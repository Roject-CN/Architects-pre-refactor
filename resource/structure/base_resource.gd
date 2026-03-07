extends Resource
class_name BaseResource

enum PROPERTY { 风水类, 设计类, 匠心类, 工料类 }

const MIN_VALUE = 0
const MAX_VALUE = 999

@export var values: Dictionary = {
	"风水类": 1,
	"设计类": 1,
	"匠心类": 1,
	"工料类": 1,
}:
	set(new_dict):
		# 清理无效键，钳制值范围
		var cleaned = {}
		for key in PROPERTY.keys():
			var raw_value = new_dict.get(key, 0)
			cleaned[key] = clampi(raw_value, MIN_VALUE, MAX_VALUE)
		values = cleaned

func return_value(index: PROPERTY) -> int:
	var key = PROPERTY.keys()[index]
	return values.get(key, 0)

func add_value(index : PROPERTY) -> void :
	var key = PROPERTY.keys()[index]  # 获取字符串键名
	values[key] = values.get(key, 0) + 1  # 确保值存在，然后加1
