extends Weapon

## 霰弹枪
## 扇形AOE，爆炸火花

func _ready() -> void:
	super._ready()
	weapon_name = "霰弹枪"
	damage = 15
	attack_speed = 0.8
	range_ = 250.0
	projectile_speed = 500.0
	spread_count = 5
	spread_angle = 45.0
	penetration = 3

func create_projectile() -> Projectile:
	var bullet = PreloadedResources.shotgun_bullet.instantiate()
	bullet.set_meta("effect", "explosion")
	return bullet

func play_attack_effect(direction: Vector2) -> void:
	# 霰弹枪后坐力
	var recoil = -direction * 20
	if owner_node and owner_node.has_method("apply_force"):
		owner_node.apply_force(recoil)
	
	# 火花粒子
	var particles = GPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.amount = 10
	particles.explosiveness = 1.0
	particles.process_material = create_spark_material()
	particles.global_position = global_position
	get_tree().current_scene.add_child(particles)

func create_spark_material() -> ParticleProcessMaterial:
	var mat = ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 5.0
	mat.direction = Vector3(0, 0, 0)
	mat.spread_angle = 180
	mat.initial_velocity_min = 100
	mat.initial_velocity_max = 200
	mat.gravity = Vector3(0, 200, 0)
	mat.color = Color(1, 0.5, 0)
	mat.scale_min = 0.5
	mat.scale_max = 1.5
	return mat
