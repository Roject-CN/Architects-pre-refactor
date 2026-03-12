extends BaseResource
class_name CraftsmanResource

const profession_name: Array[String] = ["风水师","设计师","工匠师","会计师"]
const _level_limit := 4
const _energy_limit := 40
const _energy_tired := 10
const _experience_per_level = 100

@export_group("Information")
@export var name : String
@export var profession : PROPERTY
@export var cost :int

@export_group("Effect")
@export_range(1, _level_limit, 1) var level : int = 1
@export var experience : int = 0
@export_range(1, _energy_limit, 1) var max_energy : int = 10
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
	var _experience_effect : float = level + level * float(experience) / _experience_per_level 
	craftsman_effect = energy * _experience_effect / _energy_tired
	var capability := return_value(prop_config.prop) 
	
	craftsman_effect *= capability

	return craftsman_effect
