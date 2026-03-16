extends Weapon

func _ready() -> void:
	super._ready()
	weapon_name = "Shotgun"
	damage = 15
	attack_speed = 0.8
	weapon_range = 250.0
	projectile_speed = 500.0
	spread_count = 5
	spread_angle = 45.0
	penetration = 3

func create_projectile() -> Projectile:
	var bullet = load("res://scenes/projectiles/bullet.tscn").instantiate()
	return bullet

func play_attack_effect(direction: Vector2) -> void:
	var recoil = -direction * 20.0
	if owner_node and owner_node.has_method("apply_force"):
		owner_node.apply_force(recoil)
