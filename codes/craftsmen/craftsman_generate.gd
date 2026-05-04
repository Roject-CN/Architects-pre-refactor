extends Node
class_name CraftsmanGenerate


##
#外部调用函数：generate_value(fame_value : int , gender:int = -1 , profession : int = -1)
#外部调用函数：generate_craftsman(fame_value : int)
#参数权重在此调整
const MAX_FAME = 100.0	#限制用于计算等级概率的fame大小
const GENDER_FACTOR = 2	#生成女性（主要是姓名）的概率为(GENDER_FACTOR/10)
const BASE_VALUE = 20	#基础value值，每加一级，一般属性平均增加BASE_VALUE
const VALUE_FACTOR = 1.0	#values值的权重，修改该值可使values等比放大或缩小
const BASE_COST = 100	#基础雇佣成本
const COST_PER_LEVEL = 100	#每level增加的成本
const COST_PER_VALUE = 1	#每点value增加的成本
const BASE_CRAFTSMAN_COUNT = 4	#基础招募数量
const COUNT_SCALE_FACTOR = 6	#缩放因子，值越大最终数量越多
const COUNT_LOG_FACTOR = 5	#对数放大因素，值越大前期增速越快、后期增速越慢
const MAX_CRAFTSMAN_COUNT = 60	#工匠数量上限
const SPECIAL_BASE_PROB = 0.0	#基础特殊工匠概率
const SPECIAL_MAX_PROB = 0.2	#最大特殊工匠概率(20%)
const SPECIAL_PROB_THRESHOLD = 60	#名气≥该值才会触发特殊工匠
const SPECIAL_FAME_SCALE = 80	#概率增长区间(阈值~100名气)
const ALLOW_SPECIAL_REPEAT = false	#是否允许重复生成特殊工匠
##

#图形池
const TEXTURE_PATH = "res://sprits/craftsmen"
static var texture_pool : Dictionary = {}
const GENDER_FOLDERS := ["female", "male"]
const PROFESSION_FOLDERS := ["geomancer", "designer", "artisan", "accountant"]

#记录已生成名字的静态数组
static var generated_male_names: Array[String] = []
static var generated_female_names: Array[String] = []

#特殊工匠生成记录
static var generated_special_names : Array[String] = []

#姓名库
const FIRST_NAMES := [
	"王","李","张","刘","陈","杨","赵","黄","周","吴","徐",
	"孙","胡","朱","高","林","何","郭","马","罗","梁","宋",
	"郑","谢","韩","唐","冯","于","董","萧", "沈"
]
const LAST_NAMES_MALE := [
	"浩","宇","辰","轩","睿","博","昊","阳","航","霖","瑞",
	"铭","俊","杰","文","辉","毅","洋","鑫","龙","健","勇",
	"宁","凯","明","皓","睿","泽","瀚","峰","超","鹏","磊",
	"涛","斌","强","伟","军","雄","飞","虎","翔","宇","御",
	"恒","哲","彬","旭","朗","灿","锐","峻","川","林","森",
	"岳","坤","硕","昱","琛","珅","珩","玺","羿","擎","啸",
	"沧","陌","尘","修","澈","廷", "思"
]
const LAST_NAMES_FEMALE := [
	"汐","诺","涵","桐","怡","妍","瑶","玥","萱","欣","语",
	"雨","若","艺","苡","沫","梦","佳","颖","丹","洁","雯",
	"雅","玲","彤","媛","菲","诗","璐","子","轩","宇","辰",
	"一","泽","睿","可","馨","紫","然","嘉","琪","思","博",
	"心","静","奕","梓","依","沐","宸","茗","阳","瑾","昕",
	"柒","禾","安","臻","芮","枳","乐","悦","明","云","婷",
	"娜","丽","敏","娟","琳", "棋"
]

#名字数量统计
static var first_name_size = FIRST_NAMES.size()
static var last_name_male_size = LAST_NAMES_MALE.size()
static var last_name_female_size = LAST_NAMES_FEMALE.size()
#现有名字库最多能产生的名字数量
static var male_name_number = first_name_size * last_name_male_size * (last_name_male_size + 1)
static var female_name_number = first_name_size * last_name_female_size * (last_name_female_size + 1)

enum PROFESSION {
	geomancer,
	designer,
	artisan,
	accountant
}

#特殊工匠池
const SPECIAL_CRAFTSMAN_POOL : Array[Dictionary] = [
	{
		"name": "鲁班",
		"gender": 1,
		"profession": PROFESSION.artisan,
		"level": 5,
		"description": "工匠师-登峰造极：木匠鼻祖，技艺巧夺天工万世流芳",
		"custom_texture": null # 填写专属贴图路径则覆盖，null用随机职业贴图
	},
	{
		"name": "郭璞",
		"gender": 1,
		"profession": PROFESSION.geomancer,
		"level": 5,
		"description": "风水师-登峰造极：风水鼻祖，堪舆之术冠绝古今",
		"custom_texture": null
	},
	{
		"name": "宇文恺",
		"gender": 1,
		"profession": PROFESSION.designer,
		"level": 5,
		"description": "设计师-登峰造极：隋唐工程巨匠，规划设计千古一绝",
		"custom_texture": null
	},
	{
		"name": "桑弘羊",
		"gender": 1,
		"profession": PROFESSION.accountant,
		"level": 5,
		"description": "会计师-登峰造极：理财圣手，国计民生运筹帷幄",
		"custom_texture": null
	},
	{
		"name": "墨子",
		"gender": 1,
		"profession": PROFESSION.artisan,
		"level": 5,
		"description": "工匠师-登峰造极：墨家机关术，匠心独运通神造化",
		"custom_texture": null
	}
]


#描述模板
const DESCRIPTIONS :={
	PROFESSION.geomancer:[
		"风水师-初窥门径：略懂方位布局",
		"风水师-渐入佳境：了解基础风水格局",
		"风水师-游刃有余：擅长各类空间风水",
		"风水师-炉火纯青：熟稔风水规划",
		"风水师-登峰造极：风水一道莫出其右",
	],
	PROFESSION.designer:[
		"设计师-初窥门径：能完成设计稿",
		"设计师-渐入佳境：作品具有个人特色",
		"设计师-游刃有余：美学眼光独到",
		"设计师-炉火纯青：设计理念超前",
		"设计师-登峰造极：设计之学首屈一指",
	],
	PROFESSION.artisan:[
		"工匠师-初窥门径：能制作基础建筑材料",
		"工匠师-渐入佳境：工艺精细度较高",
		"工匠师-游刃有余：擅长建造各种建筑",
		"工匠师-炉火纯青：作品巧夺天工",
		"工匠师-登峰造极：工匠技艺冠绝一时",
	],
	PROFESSION.accountant:[
		"会计师-初窥门径：会处理简单账目",
		"会计师-渐入佳境：账目处理高效",
		"会计师-游刃有余：熟练规划收支",
		"会计师-炉火纯青：财务分析得心应手",
		"会计师-登峰造极：会计行当超群绝伦",
	]
}

static func _init() -> void:
	randomize()
	_load_all_texture()

#以下AI辅助生成部分
#DeepSeek-R1-0528 2026-03-27

### 外部调用函数，返回一个CraftsmanResource对象

#形参 fame_value : 名气值；
#形参 gender : 期望的工匠性别(1男0女，置其它则20%女)；
#形参 profession : 期望的工匠职业(0-geomancer,1-designer,2-artisan,3-accountant，置其它则随机)

#生成单个对象
func generate_value(fame_value : int , gender:int = -1 , profession : int = -1) -> CraftsmanResource:
	var resource = CraftsmanResource.new()
	
	if not (gender == 1 or gender == 0):	#若未指定，以(GENDER_FACTOR/10)的概率生成女性(姓名须区分男女)
		gender = 1 if randi()%10 + 1 > GENDER_FACTOR else 0
	
	var result : Dictionary = {
		"name" : _generate_name(gender),
		"level" : _generate_level(fame_value),
		"gender" : gender,
		"profession" : 0,
		"values" : {},
		#"energy_limit" : 0,
		#"energy_tired" : 0,
		#"experience_per_level" : 0,
		"cost" : 0,
		"description" : "",
		"texture" : null
	}
	
	#处理profession
	if profession < 0 or profession > 3:
		profession = randi()%4  # 未指定或越界随机0-3
	result.profession = profession
	
	result.texture = _get_random_sprite(gender,profession)
	
	#计算value并赋值
	result.values = _generate_value(result.level,result.profession)
	
	#计算cost
	var total_values = 0
	for i in range(4):
		total_values += result.values[i]
	result.cost = BASE_COST + COST_PER_LEVEL * result.level + COST_PER_VALUE * total_values
	
	#给予描述
	result.description = DESCRIPTIONS[result.profession][result.level-1]
	
	#为CraftsmanResource对象赋值
	resource.name = result.name
	resource.level = result.level
	# 将整数索引转换为PROPERTY枚举值
	resource.profession = result.profession
	# 设置values字典，使用正确的枚举键名
	var prop_keys = resource.PROPERTY.keys()
	for i in range(4):
		if i < prop_keys.size():
			resource.values[prop_keys[i]] = result.values[i]
	resource.cost = result.cost
	resource.description = result.description
	resource.texture = result.texture
	
	return resource

#基于名气计算要生成的工匠数量
func _calculate_worker_count(fame_value: int) -> int:
	var clamped_fame = clamp(fame_value, 0, 100)
	
	#归一化
	var norm_fame = clamped_fame / 100.0
	
	#对数变换
	var log_value = log(COUNT_LOG_FACTOR * norm_fame + 1)
	var raw_count = BASE_CRAFTSMAN_COUNT + COUNT_SCALE_FACTOR * log_value
	
	#取整并限制上限
	var worker_count = floor(raw_count)
	worker_count = clamp(worker_count, BASE_CRAFTSMAN_COUNT, MAX_CRAFTSMAN_COUNT)
	return worker_count

#基于名气值生成多个随机对象，返回一个array
func generate_craftsman(fame_value : int) -> Array:
	var result = []
	var times = _calculate_worker_count(fame_value)
	for i in range(times):
		result.append(generate_value(fame_value))
	return result

#生成不重复名字
func _generate_name(gender : int) -> String:
	
	var new_name: String
	while true:
		var first = FIRST_NAMES[randi()%first_name_size]	#随机取姓氏
		
		var single_character_name = 2 if randi()%10 > 3 else 1	#有30%的概率为单字名
		var last : String = ""
		#随机生成1~2字男女姓名
		if gender == 1:	#男性
			for i in range(single_character_name):
				last += LAST_NAMES_MALE[randi()%last_name_male_size]
		else:
			for i in range(single_character_name):
				last += LAST_NAMES_FEMALE[randi()%last_name_female_size]
		
		new_name = first + last
		
		
		if gender == 1:
			#名字库用尽后，允许重名
			if generated_male_names.size() >= male_name_number:
				generated_male_names.clear()
			#检查已生成名字库，防止重名
			if not generated_male_names.has(new_name):
				generated_male_names.append(new_name)
				break
		else:
			if generated_female_names.size() >= female_name_number:
				generated_female_names.clear()
			if not generated_female_names.has(new_name):
				generated_female_names.append(new_name)
				break
	return new_name
#生成各level概率的分布情况
func generate_level_distribution(fame_value : int) -> Array:
	fame_value = clamp(fame_value,0,MAX_FAME)
	var fame_factor = fame_value / MAX_FAME	#归一化
	var level_probs = [0.6,0.25,0.1,0.05,0]	#基础概率（降低高级工匠概率）
	
	if fame_factor < 0.4:  # 新手阶段（0~40）：主要生成level1，少量level2
		# level1：保持较高概率 [0.6 → 0.5]
		level_probs[0] = 0.6 - 0.25 * fame_factor
		# level2：缓慢增长 [0.25 → 0.3]
		level_probs[1] = 0.25 + 0.125 * fame_factor
		# level3：极低概率 [0.1 → 0.12]
		level_probs[2] = 0.1 + 0.05 * fame_factor
		# level4：极低概率 [0.05 → 0.06]
		level_probs[3] = 0.05 + 0.025 * fame_factor
		# level5：保持0
		level_probs[4] = 0.0

	elif fame_factor < 0.8:  # 中级阶段（40~80）：level1下降，level2/3增长，level4/5开始出现
		# level1：线性下降 [0.5 → 0.25]
		level_probs[0] = 0.6 - 0.875 * fame_factor
		# level2：成为主导 [0.3 → 0.35]
		level_probs[1] = 0.3 + 0.125 * fame_factor
		# level3：稳步增长 [0.12 → 0.2]
		level_probs[2] = 0.12 + 0.2 * fame_factor
		# level4：开始出现 [0.06 → 0.12]
		level_probs[3] = 0.06 + 0.15 * fame_factor
		# level5：极低概率 [0 → 0.08]
		level_probs[4] = 0.2 * fame_factor - 0.08

	else:  # 后期阶段（80~100）：level3/4/5主导
		# level1：快速下降至很低 [0.25 → 0.05]
		level_probs[0] = 0.25 - 1.0 * (fame_factor - 0.8)
		# level2：缓慢下降 [0.35 → 0.15]
		level_probs[1] = 0.35 - 1.0 * (fame_factor - 0.8)
		# level3：成为主导 [0.2 → 0.3]
		level_probs[2] = 0.2 + 0.5 * (fame_factor - 0.8)
		# level4：快速增长 [0.12 → 0.35]
		level_probs[3] = 0.12 + 1.15 * (fame_factor - 0.8)
		# level5：稳步增长 [0.08 → 0.15]
		level_probs[4] = 0.08 + 0.35 * (fame_factor - 0.8)
	
	#归一化
	var total_prob = 0.0
	for i in range(5):
		total_prob += level_probs[i]
	if total_prob > 0:
		for i in range(5):
			level_probs[i] = level_probs[i] / total_prob
	return level_probs
#生成level
func _generate_level(fame_value : int) -> int:
	var distribution = generate_level_distribution(fame_value)
	#计算累计概率分布
	var cumulative_probs = []
	var total = 0.0
	for prob in distribution:
		total += prob
		cumulative_probs.append(total)
	
	#生成0~1的随机数
	var random_val = randf()
	
	#匹配随机数到对应的level
	for i in range(len(cumulative_probs)):
		if random_val < cumulative_probs[i]:
			return i + 1
	return 1
#生成各项value
func _generate_value(level:int,profession : int) -> Array:
	var result = [0,0,0,0]
	for i in range(4):
		#一般value的值为：下一level理论最高value，加不超过BASE_VALUE一半的随机值
		@warning_ignore("integer_division")
		result[i] = floor(BASE_VALUE * (level - 1) + randi()%(BASE_VALUE/2))
	@warning_ignore("integer_division")
	result[profession] += BASE_VALUE/2
	return result

#加载所有texture
static func _load_all_texture():
	# 初始化图形池空结构
	texture_pool = {}
	for gender in GENDER_FOLDERS:
		texture_pool[gender] = {}
		for prof in PROFESSION_FOLDERS:
			texture_pool[gender][prof] = []

	# 遍历文件夹加载图片
	for gender_idx in range(2):
		var gender_name = GENDER_FOLDERS[gender_idx]
		var gender_path = TEXTURE_PATH + "/" + gender_name + "/" # 修复：增加斜杠

		# 判断性别文件夹是否存在
		var gender_dir = DirAccess.open(gender_path)
		if not gender_dir:
			push_warning("文件夹不存在: ", gender_path)
			continue

		 # 遍历职业文件夹
		for prof_idx in range(4):
			var prof_name = PROFESSION_FOLDERS[prof_idx]
			var prof_path = gender_path + prof_name + "/"

			# 判断职业文件夹是否存在
			var prof_dir = DirAccess.open(prof_path)
			if not prof_dir:
				push_warning("文件夹不存在: ", prof_path)
				continue

			# 开始遍历文件夹内文件
			prof_dir.list_dir_begin() # 🔥 修复核心：无参调用
			var file_name = prof_dir.get_next()
			while file_name != "":
				# 仅处理文件
				if not prof_dir.current_is_dir():
					# 仅加载图片格式
					if file_name.ends_with(".png.import") or file_name.ends_with(".jpg.import") or file_name.ends_with(".jpeg.import"):
						# 去掉末尾的 ".import" 得到原始资源路径
						var base_name = file_name.trim_suffix(".import")
						var full_path = prof_path + base_name
						var tex = load(full_path)
						if tex is Texture2D:
							texture_pool[gender_name][prof_name].append(tex)
				
				file_name = prof_dir.get_next()
				
			
			# 结束遍历
			prof_dir.list_dir_end()
static func _get_random_sprite(gender: int, profession: int) -> Texture2D:
	var gender_name = GENDER_FOLDERS[gender]
	var prof_name = PROFESSION_FOLDERS[profession]
	var texture_list = texture_pool[gender_name][prof_name]

	if texture_list.is_empty():
		return null
	return texture_list[randi() % texture_list.size()]

#根据名气计算特殊工匠概率
func _calculate_special_prob(fame_value : int) -> float:
	var clamped_fame = clamp(fame_value, 0, 100)
	if clamped_fame < SPECIAL_PROB_THRESHOLD:
		return SPECIAL_BASE_PROB
	var progress = (clamped_fame - SPECIAL_PROB_THRESHOLD) / SPECIAL_FAME_SCALE
	progress = clamp(progress, 0.0, 1.0)
	return lerp(SPECIAL_BASE_PROB, SPECIAL_MAX_PROB, progress)

#随机获取未生成的特殊工匠
func _get_random_special_craftsman() -> Dictionary:
	var available_specials = []
	for special in SPECIAL_CRAFTSMAN_POOL:
		if not generated_special_names.has(special.name):
			available_specials.append(special)
	if available_specials.is_empty():
		if ALLOW_SPECIAL_REPEAT:
			available_specials = SPECIAL_CRAFTSMAN_POOL
			generated_special_names.clear()
		else:
			return {}
	return available_specials[randi() % available_specials.size()]

#生成特殊工匠属性（更强）
func _generate_special_values(level : int, profession : int) -> Array:
	var result = [0,0,0,0]
	for i in range(4):
		@warning_ignore("integer_division")
		result[i] = floor(BASE_VALUE * (level - 1) + BASE_VALUE + randi()%BASE_VALUE)
	@warning_ignore("integer_division")
	result[profession] += BASE_VALUE
	return result

#生成特殊工匠资源
func _generate_special_craftsman_resource(special_data : Dictionary) -> CraftsmanResource:
	var resource = CraftsmanResource.new()
	generated_special_names.append(special_data.name)

	resource.name = special_data.name
	resource.level = special_data.level
	resource.gender = special_data.gender
	resource.profession = resource.PROPERTY[special_data.profession]
	resource.values = _generate_special_values(special_data.level, special_data.profession)

	# 特殊工匠成本翻倍
	var total_values = 0
	for val in resource.values:
		total_values += val
	resource.cost = BASE_COST * 3 + COST_PER_LEVEL * resource.level * 2 + COST_PER_VALUE * total_values * 2

	resource.description = special_data.description
	# 明确判断非空，兼容性更强
	if special_data.custom_texture and special_data.custom_texture != "":
		resource.texture = load(special_data.custom_texture)
	else:
		resource.texture = _get_random_sprite(special_data.gender, special_data.profession)
	return resource

### 外部调用函数，返回一个CraftsmanResource对象

#单个生成：概率出特殊工匠，否则普通工匠
func generate_special_craftsman(fame_value : int) -> CraftsmanResource:
	var special_prob = _calculate_special_prob(fame_value)
	if randf() < special_prob:
		var special_data = _get_random_special_craftsman()
		if special_data:
			return _generate_special_craftsman_resource(special_data)
	return generate_value(fame_value)

### 外部调用函数，返回一个包含CraftsmanResource对象的Array

#批量生成：混入特殊工匠
func generate_craftsman_with_special(fame_value : int) -> Array:
	var result = []
	var times = _calculate_worker_count(fame_value)
	for i in range(times):
		result.append(generate_special_craftsman(fame_value))
	return result
