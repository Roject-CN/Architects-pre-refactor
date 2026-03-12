extends BaseResource
class_name CraftsmanResource

const profession_name: Array[String] = ["风水师","设计师","工匠师","会计师"]
const _LEVEL_LIMIT := 5	#changed	#最高5级更符合常规游戏等级印象，craftsman_generate.gd中因此预设了5个等级和文案，如不妥可删除
const _ENERGY_LIMIT := 40
const _ENERGY_TIRED := 10
const _EXPERIENCE_PER_LEVEL := 100


@export_group("Information")
@export var name : String
@export var profession : PROPERTY
@export var cost :int


@export_group("Effect")
@export_range(1, _LEVEL_LIMIT, 1) var level : int = 1
@export var experience : int = 0
@export_range(1, _ENERGY_LIMIT, 1) var max_energy : int = 10
var energy : float = max_energy :
	set (value) : 
		if value <= 1 :
			energy = 1
		elif value >= max_energy:
			energy = max_energy
		else:
			energy = value

var craftsman_effect : float
		


@export_group("Visual")
@export var texture : Texture
@export_multiline var description : String

func return_craftsman_effect(delta : float, prop_config : BuildPropConfig) -> float:
	energy -= delta 
	var _experience_effect : float = level + level * float(experience) / _EXPERIENCE_PER_LEVEL 
	craftsman_effect = energy * _experience_effect / _ENERGY_TIRED
	var capability := return_value(prop_config.prop) 
	
	craftsman_effect *= capability

	return craftsman_effect
