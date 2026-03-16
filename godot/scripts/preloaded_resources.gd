class_name PreloadedResources

static func get_bullet() -> PackedScene:
	return load("res://scenes/projectiles/bullet.tscn")

static func get_shotgun() -> PackedScene:
	return load("res://scenes/weapons/shotgun.tscn")

static func get_zombie() -> PackedScene:
	return load("res://scenes/enemies/zombie.tscn")

static func get_player() -> PackedScene:
	return load("res://scenes/player.tscn")
