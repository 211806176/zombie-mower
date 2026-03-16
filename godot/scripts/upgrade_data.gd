class_name UpgradeData

## 词条数据

var name: String = ""
var category: String = "attack"  # attack, defense, special
var rarity: int = 1  # 1-5星
var description: String = ""
var required_upgrades: Array[String] = []  # 前置词条
var condition: String = ""  # 激活条件

func _to_string() -> String:
	return "[%s] %s ★%d - %s" % [category, name, rarity, description]
