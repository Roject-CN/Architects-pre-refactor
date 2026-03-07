@warning_ignore("missing_tool")
extends BaseResource
class_name BuildingResource

@export_group("Attribution")
@export var name : String
@export var index : int
@export var cost : int
#应当还有一个属性用来包含建筑的上中下分的建筑主题

@export_group("Visual")
@export var texture : Texture
@export_multiline var description : String
