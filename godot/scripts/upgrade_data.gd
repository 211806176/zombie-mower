class_name UpgradeData

var name: String = ""
var category: String = "attack"
var rarity: int = 1
var description: String = ""
var required_upgrades = []
var condition: String = ""

func _to_string() -> String:
	return "[" + category + "] " + name + " " + str(rarity) + " - " + description
