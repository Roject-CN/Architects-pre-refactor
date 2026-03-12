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
const BASE_CRAFTSMAN_COUNT = 12	#基础招募数量
const COUNT_SCALE_FACTOR = 6	#缩放因子，值越大最终数量越多
const COUNT_LOG_FACTOR = 5	#对数放大因素，值越大前期增速越快、后期增速越慢
const MAX_CRAFTSMAN_COUNT = 60	#工匠数量上限
##


#记录已生成名字的静态数组
static var generated_male_names: Array[String] = []
static var generated_female_names: Array[String] = []

#姓名库
const FIRST_NAMES := [
	"王","李","张","刘","陈","杨","赵","黄","周","吴","徐",
	"孙","胡","朱","高","林","何","郭","马","罗","梁","宋",
	"郑","谢","韩","唐","冯","于","董","萧"
]
const LAST_NAMES_MALE := [
	"浩","宇","辰","轩","睿","博","昊","阳","航","霖","瑞",
	"铭","俊","杰","文","辉","毅","洋","鑫","龙","健","勇",
	"宁","凯","明","皓","睿","泽","瀚","峰","超","鹏","磊",
	"涛","斌","强","伟","军","雄","飞","虎","翔","宇","御",
	"恒","哲","彬","旭","朗","灿","锐","峻","川","林","森",
	"岳","坤","硕","昱","琛","珅","珩","玺","羿","擎","啸",
	"沧","陌","尘","修","澈","廷",
]
const LAST_NAMES_FEMALE := [
	"汐","诺","涵","桐","怡","妍","瑶","玥","萱","欣","语",
	"雨","若","艺","苡","沫","梦","佳","颖","丹","洁","雯",
	"雅","玲","彤","媛","菲","诗","璐","子","轩","宇","辰",
	"一","泽","睿","可","馨","紫","然","嘉","琪","思","博",
	"心","静","奕","梓","依","沐","宸","茗","阳","瑾","昕",
	"柒","禾","安","臻","芮","枳","乐","悦","明","云","婷",
	"娜","丽","敏","娟","琳"
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
	}
	
	#处理profession
	if profession < 0 or profession > 3:
		profession = randi()%4  # 未指定或越界随机0-3
	result.profession = profession
	
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
	resource.profession = resource.PROPERTY[result.profession]
	for i in range(4):
		resource.values[i] = result.values[i]
	resource.cost = result.cost
	resource.description = result.description
	
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
	var level_probs = [0.45,0.3,0.15,0.1,0]	#基础概率
	if fame_factor < 0.4:  # 新手阶段（0~40）：level2快速增长，其他等级温和增长/下降
		# level1：线性下降 [0.45 → 0.27]
		level_probs[0] = 0.45 - 0.45 * fame_factor
		# level2：线性上升 [0.3 → 0.42]（增速最快）
		level_probs[1] = 0.3 + 0.3 * fame_factor
		# level3：线性上升 [0.15 → 0.19]
		level_probs[2] = 0.15 + 0.1 * fame_factor
		# level4：线性上升 [0.1 → 0.12]
		level_probs[3] = 0.1 + 0.05 * fame_factor
		# level5：保持0
		level_probs[4] = 0.0

	elif fame_factor < 0.8:  # 中级阶段（40~80）：level2开始下降，level3/4/5继续增长
		# level1：线性下降 [0.27 → 0.09]
		level_probs[0] = 0.45 - 0.45 * fame_factor
		# level2：线性下降 [0.42 → 0.34]（先增后减的转折点）
		level_probs[1] = 0.5 - 0.2 * fame_factor
		# level3：线性上升 [0.19 → 0.27]
		level_probs[2] = 0.11 + 0.2 * fame_factor
		# level4：线性上升 [0.12 → 0.20]
		level_probs[3] = 0.04 + 0.2 * fame_factor
		# level5：线性上升 [0 → 0.10]
		level_probs[4] = 0.25 * fame_factor - 0.1

	else:  # 后期阶段（80~100）：level2/3下降，level4/5主导
		# level1：线性下降至0 [0.09 → 0]
		level_probs[0] = 0.09 - 0.45 * (fame_factor - 0.8)
		# level2：快速下降 [0.34 → 0.05]（先增后减）
		level_probs[1] = 0.34 - 1.45 * (fame_factor - 0.8)
		# level3：缓慢下降 [0.27 → 0.25]（先增后减）
		level_probs[2] = 0.27 - 0.1 * (fame_factor - 0.8)
		# level4：快速上升 [0.20 → 0.50]（核心等级）
		level_probs[3] = 0.20 + 1.5 * (fame_factor - 0.8)
		# level5：稳步上升 [0.10 → 0.20]
		level_probs[4] = 0.10 + 0.5 * (fame_factor - 0.8)
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
