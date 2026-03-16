extends Node
class_name PreloadedResources

## 预加载资源
## 管理所有需要预加载的场景和资源

const Resources = {
	"bullet": "res://scenes/projectiles/bullet.tscn",
	"shotgun_bullet": "res://scenes/projectiles/shotgun_bullet.tscn",
	"laser_projectile": "res://scenes/projectiles/laser_projectile.tscn",
	"zombie": "res://scenes/enemies/zombie.tscn",
	"player": "res://scenes/player.tscn",
	"shotgun": "res://scenes/weapons/shotgun.tscn",
	"laser_sword": "res://scenes/weapons/laser_sword.tscn",
}

static func _static_init() -> void:
	# 实际项目中在这里预加载
	pass

static func get_resource(path: String) -> PackedScene:
	return load(path)

# 便捷方法
static func bullet() -> PackedScene:
	return load("res://scenes/projectiles/bullet.tscn")

static func shotgun() -> PackedScene:
	return load("res://scenes/weapons/shotgun.tscn")

static func laser_sword() -> PackedScene:
	return load("res://scenes/weapons/laser_sword.tscn")

static func zombie() -> PackedScene:
	return load("res://scenes/enemies/zombie.tscn")

static func player() -> PackedScene:
	return load("res://scenes/player.tscn")
