extends Weapon

## 激光剑
## 挥砍+穿透，蓝色光刃拖尾

var swing_arc: float = 120.0  # 挥砍角度
var swing_duration: float = 0.2

func _ready() -> void:
	super._ready()
	weapon_name = "激光剑"
	damage = 25
	attack_speed = 0.5
	range_ = 80.0
	projectile_speed = 0  # 近战不需要投射物
	penetration = 999  # 无穿透限制

func attack(direction: Vector2) -> void:
	if not can_fire:
		return
	
	can_fire = false
	
	# 执行挥砍动画
	await perform_swing(direction)
	
	await get_tree().create_timer(attack_speed - swing_duration).timeout
	can_fire = true

func perform_swing(direction: Vector2) -> void:
	var start_angle = direction.angle() - deg_to_rad(swing_arc / 2)
	var end_angle = direction.angle() + deg_to_rad(swing_arc / 2)
	
	# 挥砍判定
	var hit_enemies = []
	var attack_area = Area2D.new()
	attack_area.collision_layer = 2  # 假设僵尸在第2层
	attack_area.collision_mask = 2
	
	var shape = CollisionShape2D.new()
	var sector = WorldShape.new()
	sector.angle = deg_to_rad(swing_arc)
	sector.radius = range_
	shape.shape = sector
	attack_area.add_child(shape)
	
	global_position = owner_node.global_position if owner_node else global_position
	get_tree().current_scene.add_child(attack_area)
	
	# 等待一小段时间让判定生效
	await get_tree().create_timer(0.05).timeout
	
	# 检测击中
	var bodies = attack_area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("take_damage"):
			body.take_damage(damage)
	
	attack_area.queue_free()
	
	# 挥砍拖尾特效
	create_sword_trail(direction)

func create_sword_trail(direction: Vector2) -> void:
	# 创建光刃拖尾
	var trail = Line2D.new()
	trail.width = 20
	trail.default_color = Color(0, 0.8, 1, 0.8)
	trail.joint_mode = Line2D.JOINT_ROUND
	trail.begin_cap_mode = Line2D.LINE_CAP_ROUND
	trail.end_cap_mode = Line2D.LINE_CAP_ROUND
	
	var points_count = 10
	for i in range(points_count):
		trail.add_point(direction * (range_ * float(i) / points_count))
	
	trail.global_position = global_position
	get_tree().current_scene.add_child(trail)
	
	# 淡出
	var tween = create_tween()
	tween.tween_property(trail, "modulate:a", 0.0, 0.3)
	tween.tween_callback(trail.queue_free)
