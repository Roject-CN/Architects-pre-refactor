extends Resource
class_name CraftManResource

enum PROFESSION {
	GEOMANCER,
	DESIGNER,
	ATISAN,
	ACCOUNTANT
} 

var profession_name: Array[String] = ["风水师","设计师","工匠师","会计师"]

@export_group("Attribution")
@export var name : String
@export var profession : PROFESSION
@export var values : Dictionary = {
	"风水值" = 0,
	"设计值" = 0,
	"匠心值" = 0,
	"工料值" = 0,
}
@export var level : int
@export var experience : int
@export var cost :int

@export_group("Visual")
@export var texture : Texture
@export_multiline var description : String

func initialize_resource() -> void:
	pass
