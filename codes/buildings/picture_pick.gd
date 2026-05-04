extends Node
class_name PicturePick


const BUILDING_TEXTURE_PATH : String = "res://sprits/buildings/pictures/"
static var building_textures : Dictionary = {}   # 键："攒尖顶素土"，值：Texture2D

# 屋顶全名不变，下分需要从全名中提取简称
var base_short_map: Dictionary = {
	"素土台基": "素土",
	"砖砌台基": "砖砌",
	"石砌台基": "石砌",
	"须弥座台基": "须弥",
	"干栏式": "干栏"
}


	
func _ready() -> void:
	_load_all_building_textures()
	
func _load_all_building_textures():
	building_textures.clear()
	
	var dir := DirAccess.open(BUILDING_TEXTURE_PATH)
	if not dir:
		push_warning("建筑图片文件夹不存在: ", BUILDING_TEXTURE_PATH)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			# 关键：只处理图像资源的 .import 文件（你的工匠代码已验证可行）
			if file_name.ends_with(".png.import") or file_name.ends_with(".jpg.import") or file_name.ends_with(".jpeg.import"):
				var base_name := file_name.trim_suffix(".import")          # "攒尖顶素土.png"
				var key_name := base_name.trim_suffix(".png").trim_suffix(".jpg").trim_suffix(".jpeg")  # "攒尖顶素土"
				var full_path := BUILDING_TEXTURE_PATH + base_name
				var tex := load(full_path)
				if tex is Texture2D:
					building_textures[key_name] = tex
		file_name = dir.get_next()
	
	dir.list_dir_end()
	print("建筑图片加载完成，共加载 ", building_textures.size(), " 张")

func get_building_texture(roof_name: String, base_name: String) -> Texture2D:
	# 如果直接传的是下分简称（如 "素土"），跳过映射
	var base_key: String = base_short_map.get(base_name, base_name)
	var key: String = roof_name + base_key
	return building_textures.get(key, null)
	
func pick_pictures(resource : BuildingResource) -> Texture:
	if resource.middle_theme.name == "干栏式":
		var file := get_building_texture(resource.top_theme.name, resource.middle_theme.name)
		resource.texture = file
		return file
	else :
		var file := get_building_texture(resource.top_theme.name, resource.buttom_theme.name)
		resource.texture = file
		return file
