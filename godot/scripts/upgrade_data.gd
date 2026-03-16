# 词条数据类
# 定义单个升级词条的属性

class_name UpgradeData

# 属性
var name: String = ""              # 名称
var category: String = "attack"    # 类别(attack/defense/special)
var rarity: int = 1                # 星级(1-5)
var description: String = ""        # 描述
var required_upgrades = []          # 前置词条
var condition: String = ""         # 激活条件

func _to_string() -> String:
	return "[" + category + "] " + name + " " + str(rarity) + "星 - " + description
