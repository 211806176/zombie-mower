# 升级/词条管理器
# 负责词条池管理、随机抽取、效果应用

extends Node
class_name UpgradeManager

# 信号
signal upgrade_selected(upgrade)  # 选择了升级

# 词条池
var upgrades_pool = []

func _ready() -> void:
	load_upgrade_pool()

# 加载词条池
func load_upgrade_pool() -> void:
	# 攻击类词条
	upgrades_pool.append(create_upgrade("穿透", "attack", 2, "子弹穿透额外1个目标"))
	upgrades_pool.append(create_upgrade("暴击率+", "attack", 2, "暴击率+10%"))
	upgrades_pool.append(create_upgrade("暴击伤害+", "attack", 2, "暴击伤害+25%"))
	upgrades_pool.append(create_upgrade("溅射", "attack", 3, "伤害范围扩散"))
	upgrades_pool.append(create_upgrade("火焰附加", "attack", 2, "攻击附带火焰伤害"))
	upgrades_pool.append(create_upgrade("冰霜附加", "attack", 2, "攻击附带冰霜减速"))
	upgrades_pool.append(create_upgrade("闪电附加", "attack", 2, "攻击附带连锁闪电"))
	
	# 防御类词条
	upgrades_pool.append(create_upgrade("护盾", "defense", 2, "获得护盾"))
	upgrades_pool.append(create_upgrade("闪避", "defense", 2, "闪避率+10%"))
	upgrades_pool.append(create_upgrade("生命偷取", "defense", 3, "攻击回复生命"))
	upgrades_pool.append(create_upgrade("生命+", "defense", 1, "最大生命+20"))
	
	# 特殊词条(联动)
	upgrades_pool.append(create_upgrade("冰火两重天", "special", 4, "冰+火同时存在时敌人易伤30%", ["火焰附加", "冰霜附加"]))
	upgrades_pool.append(create_upgrade("闪电风暴", "special", 4, "闪电+暴击触发额外闪电", ["闪电附加", "暴击率+"]))
	upgrades_pool.append(create_upgrade("无限火力", "special", 3, "攻速达到2.0减少技能冷却50%"))

# 创建词条数据
func create_upgrade(name: String, category: String, rarity: int, description: String, required: Array = []):
	var upg = UpgradeData.new()
	upg.name = name
	upg.category = category
	upg.rarity = rarity
	upg.description = description
	upg.required_upgrades = required
	return upg

# 获取随机升级选项
func get_random_upgrades(count: int, current_upgrades) -> Array:
	var available = []
	
	for upgrade in upgrades_pool:
		# 已有的跳过
		var already_has = false
		for current in current_upgrades:
			if current.name == upgrade.name:
				already_has = true
				break
		if already_has:
			continue
		
		# 检查前置词条
		if upgrade.required_upgrades.size() > 0:
			var has_prereq = false
			for req in upgrade.required_upgrades:
				for current in current_upgrades:
					if current.name == req:
						has_prereq = true
						break
			if not has_prereq:
				continue
		
		available.append(upgrade)
	
	# 随机打乱并返回
	available.shuffle()
	return available.slice(0, min(count, available.size()))

# 应用词条效果
func apply_upgrade(upgrade, player) -> void:
	match upgrade.name:
		"穿透":
			for weapon in player.weapons:
				weapon.penetration += 1
		"生命+":
			player.max_health += 20
			player.heal(20)
