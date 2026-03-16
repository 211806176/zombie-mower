extends Node
class_name UpgradeManager

signal upgrade_selected(upgrade: UpgradeData)

var upgrades_pool: Array[UpgradeData] = []

func _ready() -> void:
	load_upgrade_pool()

func load_upgrade_pool() -> void:
	upgrades_pool.append(create_upgrade("穿透", "attack", 2, "Bullet penetrates 1 more target"))
	upgrades_pool.append(create_upgrade("暴击率+", "attack", 2, "Crit rate +10%"))
	upgrades_pool.append(create_upgrade("暴击伤害+", "attack", 2, "Crit damage +25%"))
	upgrades_pool.append(create_upgrade("溅射", "attack", 3, "Damage spreads"))
	upgrades_pool.append(create_upgrade("火焰附加", "attack", 2, "Fire damage"))
	upgrades_pool.append(create_upgrade("冰霜附加", "attack", 2, "Ice slow"))
	upgrades_pool.append(create_upgrade("闪电附加", "attack", 2, "Chain lightning"))
	upgrades_pool.append(create_upgrade("护盾", "defense", 2, "Shield"))
	upgrades_pool.append(create_upgrade("闪避", "defense", 2, "Dodge +10%"))
	upgrades_pool.append(create_upgrade("生命偷取", "defense", 3, "Lifesteal"))
	upgrades_pool.append(create_upgrade("生命+", "defense", 1, "Max HP +20"))
	upgrades_pool.append(create_upgrade("冰火两重天", "special", 4, "Fire+Ice = vulnerability", ["火焰附加", "冰霜附加"]))
	upgrades_pool.append(create_upgrade("闪电风暴", "special", 4, "Lightning+Crit = extra", ["闪电附加", "暴击率+"]))
	upgrades_pool.append(create_upgrade("无限火力", "special", 3, "AtkSpeed 2.0 = CD -50%"))

func create_upgrade(name: String, category: String, rarity: int, description: String, required: Array = []) -> UpgradeData:
	var upg = UpgradeData.new()
	upg.name = name
	upg.category = category
	upg.rarity = rarity
	upg.description = description
	upg.required_upgrades = required
	return upg

func get_random_upgrades(count: int, current_upgrades: Array[UpgradeData]) -> Array[UpgradeData]:
	var available = []
	
	for upgrade in upgrades_pool:
		var already_has = false
		for current in current_upgrades:
			if current.name == upgrade.name:
				already_has = true
				break
		
		if already_has:
			continue
		
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
	
	available.shuffle()
	return available.slice(0, min(count, available.size()))

func apply_upgrade(upgrade: UpgradeData, player: Player) -> void:
	match upgrade.name:
		"穿透":
			for weapon in player.weapons:
				weapon.penetration += 1
		"生命+":
			player.max_health += 20
			player.heal(20)
