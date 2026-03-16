# 霰弹枪
# 扇形发射，多子弹，高伤害

extends Weapon

func _ready() -> void:
	super._ready()
	weapon_name = "Shotgun"
	damage = 15
	attack_speed = 0.8
	weapon_range = 250.0
	projectile_speed = 500.0
	spread_count = 5      # 5发散射
	spread_angle = 45.0   # 45度散射角
	penetration = 3       # 穿透3个

func create_projectile() -> Projectile:
	return load("res://scenes/projectiles/bullet.tscn").instantiate()

func play_attack_effect(direction: Vector2) -> void:
	# 后坐力效果
	var recoil = -direction * 20.0
	if owner_node and owner_node.has_method("apply_force"):
		owner_node.apply_force(recoil)
