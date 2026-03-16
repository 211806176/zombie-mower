extends Weapon

var swing_arc: float = 120.0
var swing_duration: float = 0.2

func _ready() -> void:
	super._ready()
	weapon_name = "Laser Sword"
	damage = 25
	attack_speed = 0.5
	weapon_range = 80.0
	projectile_speed = 0.0
	penetration = 999

func attack(direction: Vector2) -> void:
	if not can_fire:
		return
	can_fire = false
	await perform_swing(direction)
	await get_tree().create_timer(attack_speed - swing_duration).timeout
	can_fire = true

func perform_swing(direction: Vector2) -> void:
	var attack_area = Area2D.new()
	attack_area.collision_layer = 2
	attack_area.collision_mask = 2
	
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = weapon_range
	shape.shape = circle
	attack_area.add_child(shape)
	
	if owner_node:
		attack_area.global_position = owner_node.global_position
	else:
		attack_area.global_position = global_position
	
	get_tree().current_scene.add_child(attack_area)
	await get_tree().create_timer(0.05).timeout
	
	var bodies = attack_area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("take_damage"):
			body.take_damage(damage)
	
	attack_area.queue_free()
