extends Resource
class_name ThemeResource

enum TYPE {
	上分,
	中分,
	下分
}

enum TIME_TYPE {
	初创,
	成形,
	鼎盛
}


@export var type : TYPE
@export var time : TIME_TYPE
@export var name : String
@export_multiline var description : String
