extends Node

const PATH := "user://buildings.res"
var _db: Resource

func _ready():
	if ResourceLoader.exists(PATH):
		_db = load(PATH)
	else:
		_db = Resource.new()
		_db.set_meta("data", [])
		_save()

func _save():
	ResourceSaver.save(_db, PATH)

func record(building: BuildingResource, file_path: String, screenshot: ImageTexture = null):
	var arr: Array = _db.get_meta("data")
	arr.append({
		"name": building.name,
		"index": building.index,
		"tex": screenshot,
		"val": building.values.duplicate(true),
		"top": building.top_theme,
		"mid": building.middle_theme,
		"bot": building.buttom_theme,
		"path": file_path
	})
	_db.set_meta("data", arr)
	_save()

func all() -> Array:
	return _db.get_meta("data", []).duplicate()

# 新增：清空所有历史记录
func clear():
	_db.set_meta("data", [])
	_save()
	print("建筑史册已清空")

# 新增：删除单条记录（按索引）
func remove_at(index: int):
	var arr: Array = _db.get_meta("data")
	if index >= 0 and index < arr.size():
		arr.remove_at(index)
		_db.set_meta("data", arr)
		_save()
