extends BaseResource
class_name CraftsmanResource

#职业的名称
const profession_name: Array[String] = ["风水师","设计师","工匠师","会计师"]

#一些常量
#等级的最大值
const _LEVEL_LIMIT := 5	#changed	#最高5级更符合常规游戏等级印象，craftsman_generate.gd中因此预设了5个等级和文案，如不妥可删除
#精力值的最大值
const _ENERGY_LIMIT := 40
#当低于该值时表明员工陷入疲惫状态
const _ENERGY_TIRED := 10
#每升一级员工所需要的经验值
const _EXPERIENCE_PER_LEVEL := 100

#在集体工作环节用以连接animation_ui节点（CraftsmanCharacter类里）
signal request_craftsman_character_animation_ui_added(prop : BaseResource.PROPERTY)
#精力值显示的组件与此信号相连接，在精力值改变的时候发送该信号
signal energy_value_changed(value : float)


@export_group("Information")
@export var name : String
@export var profession : PROPERTY
#花费
@export var cost :int

#影响因子，用于建造建筑的各个环节
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
		energy_value_changed.emit(energy)

var craftsman_effect : float

@export_group("Visual")
@export var texture : Texture
@export_multiline var description : String

func return_craftsman_effect(delta : float, prop_config : BaseResource.PROPERTY) -> float:
	energy -= delta 
	var _experience_effect : float = level + level * float(experience) / _EXPERIENCE_PER_LEVEL 
	craftsman_effect = energy * _experience_effect / _ENERGY_TIRED
	var capability := return_value(prop_config) 
	
	craftsman_effect *= capability

	return craftsman_effect

#增加精力值
func add_energy(delta : float) -> void:
	energy += delta * 0.5

#减少精力值
func subtract_energy(delta : float) -> void:
	energy -= delta * 0.1
