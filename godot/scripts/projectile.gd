extends Area2D
class_name Projectile

## 子弹/投射物基类

var velocity: Vector2
var damage: int = 10
var penetration: int = 1
var max_distance: float = 500.0
var distance_traveled: float = 0.0
var hit_list: Array[Node] = []

var effect_type: String = ""  # explosion, lightning, etc.

func setup(vel: Vector2, dmg: int, pen: int, max_dist: float) -> void:
	velocity = vel
	damage = dmg
	penetration = pen
	max_distance = max_dist

func _physics_process(delta: float) -> void:
	var movement = velocity * delta
	distance_traveled += movement.length()
	
	# 检查距离
	if distance_traveled >= max_distance:
		queue_free()
		return
	
	global_position += movement
	
	# 旋转朝向
	if velocity.length() > 0:
		rotation = velocity.angle()

func _on_area_entered(area: Area2D) -> void:
	check_hit(area)

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		check_hit(body)

func check_hit(target: Node) -> void:
	# 避免重复击中
	if target in hit_list:
		return
	
	hit_list.append(target)
	
	# 造成伤害
	if target.has_method("take_damage"):
		target.take_damage(damage)
	
	# 特效
	play_impact_effect(target.global_position)
	
	# 穿透消耗
	penetration -= 1
	if penetration <= 0:
		queue_free()

func play_impact_effect(_pos: Vector2) -> void:
	# 子类重写实现具体特效
	pass
