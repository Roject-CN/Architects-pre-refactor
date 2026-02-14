[1mdiff --git a/Resource/test.tres b/Resource/test.tres[m
[1mindex 40f3c93..5b8ebc2 100644[m
[1m--- a/Resource/test.tres[m
[1m+++ b/Resource/test.tres[m
[36m@@ -13,7 +13,7 @@[m [mvalues = {[m
 &"风水值": 1[m
 }[m
 level = 1[m
[31m-cost = 1[m
[32m+[m[32mcost = 211[m
 texture = ExtResource("2_uhslf")[m
 description = "相信我，我会好好工作的"[m
 metadata/_custom_type_script = "uid://bcfvld13usfs"[m
[1mdiff --git a/Resource/test2.tres b/Resource/test2.tres[m
[1mindex 7c71426..5486502 100644[m
[1m--- a/Resource/test2.tres[m
[1m+++ b/Resource/test2.tres[m
[36m@@ -14,7 +14,7 @@[m [mvalues = {[m
 &"风水值": 1[m
 }[m
 level = 2[m
[31m-cost = 1[m
[32m+[m[32mcost = 110[m
 texture = ExtResource("2_d4bqi")[m
 description = "我是你老豆"[m
 metadata/_custom_type_script = "uid://bcfvld13usfs"[m
[1mdiff --git a/codes/ui/craftsmen_ui.gd b/codes/ui/craftsmen_ui.gd[m
[1mindex cf21f53..de5f1f4 100644[m
[1m--- a/codes/ui/craftsmen_ui.gd[m
[1m+++ b/codes/ui/craftsmen_ui.gd[m
[36m@@ -7,6 +7,7 @@[m [mextends BaseUi[m
 @export var craftmen : Array[CraftsmanResource][m
 const intro_text_temp : String = "%s %s"[m
 const level_text_temp : String = "Level %d"[m
[32m+[m[32mconst assure_text_temp : String = "招聘 %d$"[m
 var array_size : int = 0[m
 var index : int = 0[m
 [m
[36m@@ -14,7 +15,7 @@[m [mvar index : int = 0[m
 @onready var texturect: TextureRect = $Visual/VBoxContainer/Texturect[m
 @onready var description: Label = $Visual/VBoxContainer/Description[m
 @onready var level: Label = $Visual/VBoxContainer/Level[m
[31m-[m
[32m+[m[32m@onready var assure: Button = $Button/Assure[m
 @onready var next: Button = $Button/Next[m
 [m
 func _ready() -> void:[m
[36m@@ -29,12 +30,16 @@[m [mfunc read_craftman_resource(resource : CraftsmanResource) -> void:[m
 	#visual部分[m
 	var introduction_text = intro_text_temp[m
 	var level_text = level_text_temp[m
[32m+[m	[32mvar assure_text = assure_text_temp[m
[32m+[m[41m	[m
 	introduction_text %= [resource.profession_name[resource.profession], resource.name]  [m
 	level_text %= resource.level[m
[32m+[m	[32massure_text %= resource.cost[m
 	[m
 	texturect.texture = resource.texture[m
 	introduction.text = introduction_text[m
 	level.text = level_text[m
[32m+[m	[32massure.text = assure_text[m
 	description.text = resource.description[m
 	[m
 	#attribution部分[m
[1mdiff --git a/codes/ui/information_ui.gd b/codes/ui/information_ui.gd[m
[1mindex 755450e..1788419 100644[m
[1m--- a/codes/ui/information_ui.gd[m
[1m+++ b/codes/ui/information_ui.gd[m
[36m@@ -17,7 +17,6 @@[m [mfunc _ready() -> void:[m
 	label.text = text + " : " + str(value)[m
 	var plus_node : AnimationUi = plus.instantiate()[m
 	animation.custom_minimum_size = plus_node.size[m
[31m-	[m
 [m
 func set_texture(new_value : Texture) -> void:[m
 	texture = new_value[m
[36m@@ -40,3 +39,6 @@[m [mfunc return_size_y() -> int:[m
 	for i : Control in h_box_container.get_children():[m
 		size_y += int(i.size.y)[m
 	return size_y[m
[32m+[m
[32m+[m[32mfunc _on_button_pressed() -> void:[m
[32m+[m	[32mupdate_value()[m
[1mdiff --git a/scenes/ui/base_ui/information_ui.tscn b/scenes/ui/base_ui/information_ui.tscn[m
[1mindex 7e70b6c..2bd73fc 100644[m
[1m--- a/scenes/ui/base_ui/information_ui.tscn[m
[1m+++ b/scenes/ui/base_ui/information_ui.tscn[m
[36m@@ -30,3 +30,13 @@[m [mlayout_mode = 2[m
 [m
 [node name="Animation" type="Container" parent="HBoxContainer/CenterContainer" unique_id=2060529596][m
 layout_mode = 2[m
[32m+[m
[32m+[m[32m[node name="Button" type="Button" parent="." unique_id=1815842208][m
[32m+[m[32mlayout_mode = 0[m
[32m+[m[32moffset_left = -76.0[m
[32m+[m[32moffset_top = 5.0[m
[32m+[m[32moffset_right = -4.0[m
[32m+[m[32moffset_bottom = 36.0[m
[32m+[m[32mtext = "测试增加"[m
[32m+[m
[32m+[m[32m[connection signal="pressed" from="Button" to="." method="_on_button_pressed"][m
[1mdiff --git a/scenes/ui/craftsmen/craftsmen_ui.tscn b/scenes/ui/craftsmen/craftsmen_ui.tscn[m
[1mindex 14298a6..735224c 100644[m
[1m--- a/scenes/ui/craftsmen/craftsmen_ui.tscn[m
[1m+++ b/scenes/ui/craftsmen/craftsmen_ui.tscn[m
[36m@@ -67,14 +67,14 @@[m [manchor_left = 0.4[m
 anchor_right = 0.4[m
 offset_right = 8.0[m
 offset_bottom = 8.0[m
[31m-text = "招聘"[m
[32m+[m[32mtext = "招聘 xxxx"[m
 [m
 [node name="Next" type="Button" parent="Button" parent_id_path=PackedInt32Array(883134600) index="2" unique_id=397307005][m
 custom_minimum_size = Vector2(60, 0)[m
 layout_mode = 1[m
 anchors_preset = -1[m
[31m-anchor_left = 0.6[m
[31m-anchor_right = 0.6[m
[32m+[m[32manchor_left = 0.65[m
[32m+[m[32manchor_right = 0.65[m
 offset_right = 8.0[m
 offset_bottom = 8.0[m
 text = "下一个"[m
