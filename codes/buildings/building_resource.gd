extends Resource
class_name BuildingResource

@export_group("Attribution")
@export var name : String
@export var index : int
@export var value_geomancer :int = 0	#堪舆值
@export var value_designer :int = 0		#设计值
@export var value_artisan :int = 0		#匠心值
@export var value_accountant :int = 0	#赚钱速率
@export var building_value : int
#应当还有一个属性用来包含建筑的上中下分的建筑主题

@export_group("Visual")
@export var texture : Texture
@export_multiline var description : String
