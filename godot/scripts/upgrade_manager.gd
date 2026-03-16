extends Node
class_name UpgradeManager

## 词条/升级系统
## 随机词条生成、效果应用、词条联动

signal upgrade_selected(upgrade: UpgradeData)

@export var upgrades_pool: Array[UpgradeData]

func _ready() -> void:
	load_upgrade_pool()

func load_upgrade_pool() -> void:
	# 基础攻击类词条
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
	
	# 特殊词条
	upgrades_pool.append(create_upgrade("冰火两重天", "special", 4, "冰+火同时存在时，敌人易伤30%", ["火焰附加", "冰霜附加"]))
	upgrades_pool.append(create_upgrade("闪电风暴", "special", 4, "闪电+暴击触发额外闪电", ["闪电附加", "暴击率+"]))
	upgrades_pool.append(create_upgrade("无限火力", "special", 3, "攻速达到2.0减少技能冷却50%", [], "attack_speed >= 2.0"))

func create_upgrade(name: String, category: String, rarity: int, description: String, required_upgrades: Array = [], condition: String = "") -> UpgradeData:
	var upg = UpgradeData.new()
	upg.name = name
	upg.category = category
	upg.rarity = rarity
	upg.description = description
	upg.required_upgrades = required_upgrades
	upg.condition = condition
	return upg

func get_random_upgrades(count: int, current_upgrades: Array[UpgradeData]) -> Array[UpgradeData]:
	var available = []
	
	for upgrade in upgrades_pool:
		# 检查是否已拥有
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
	
	# 随机选择
	available.shuffle()
	return available.slice(0, min(count, available.size()))

func apply_upgrade(upgrade: UpgradeData, player: Player) -> void:
	match upgrade.name:
		"穿透":
			for weapon in player.weapons:
				weapon.penetration += 1
		"暴击率+":
			# 需要扩展武器系统支持暴击率
			pass
		"暴击伤害+":
			# 需要扩展武器系统支持暴击伤害
			pass
		"护盾":
			# 添加护盾逻辑
			pass
		"生命+":
			player.max_health += 20
			player.heal(20)
		"生命偷取":
			# 添加生命偷取逻辑
			pass

# 词条联动检查
func check_synergy(current_upgrades: Array[UpgradeData]) -> Array[String]:
	var synergies = []
	var upgrade_names = []
	
	for upg in current_upgrades:
		upgrade_names.append(upg.name)
	
	for upg in current_upgrades:
		if upg.category == "special":
			synergies.append(upg.name + "已激活!")
	
	return synergies
