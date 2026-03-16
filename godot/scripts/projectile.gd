# 子弹/投射物基类
# 处理移动、碰撞、伤害

extends Area2D
class_name Projectile

# 属性
var velocity: Vector2              # 速度向量
var damage: int = 10                # 伤害值
var penetration: int = 1            # 穿透数
var max_distance: float = 500.0     # 最大距离
var distance_traveled: float = 0.0  # 已飞行距离
var hit_list = []                   # 已命中列表
var effect_type: String = ""        # 特效类型

# 设置参数
func setup(vel: Vector2, dmg: int, pen: int, max_dist: float) -> void:
	velocity = vel
	damage = dmg
	penetration = pen
	max_distance = max_dist

# 每帧移动
func _physics_process(delta: float) -> void:
	var movement = velocity * delta
	distance_traveled += movement.length()
	
	# 超过最大距离则销毁
	if distance_traveled >= max_distance:
		queue_free()
		return
	
	global_position += movement
	
	# 朝向飞行方向
	if velocity.length() > 0:
		rotation = velocity.angle()

# 区域进入
func _on_area_entered(area: Area2D) -> void:
	check_hit(area)

# 物体进入
func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		check_hit(body)

# 检查命中
func check_hit(target: Node) -> void:
	# 避免重复命中
	if target in hit_list:
		return
	hit_list.append(target)
	
	# 造成伤害
	if target.has_method("take_damage"):
		target.take_damage(damage)
	
	# 播放命中特效
	play_impact_effect(target.global_position)
	
	# 穿透消耗
	penetration -= 1
	if penetration <= 0:
		queue_free()

# 播放命中特效(子类重写)
func play_impact_effect(_pos: Vector2) -> void:
	pass
