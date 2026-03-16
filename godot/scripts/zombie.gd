# 僵尸AI
# 追踪玩家并造成伤害

extends CharacterBody2D
class_name Zombie

# 信号
signal died(points: int)  # 死亡时发出，包含击杀得分

# 属性
var speed: float = 80.0           # 移动速度
var health: int = 30              # 生命值
var damage: int = 10               # 攻击力
var attack_cooldown: float = 1.0   # 攻击间隔
var points_on_death: int = 10      # 死亡得分
var zombie_type: String = "normal" # 僵尸类型

# 运行时变量
var player: Node2D = null          # 玩家引用
var last_attack_time: float = 0.0  # 上次攻击时间
var is_dead: bool = false          # 是否已死亡

func _ready() -> void:
	# 延迟获取玩家引用
	await get_tree().create_timer(0.1).timeout
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	if is_dead or player == null:
		return
	
	# 追踪玩家方向
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	
	# 朝向玩家
	if direction.x != 0.0:
		scale.x = -1.0 if direction.x < 0.0 else 1.0
	
	# 检测与玩家碰撞
	check_player_collision()

# 检测玩家碰撞
func check_player_collision() -> void:
	var now = Time.get_ticks_msec() / 1000.0
	# 冷却中则跳过
	if now - last_attack_time < attack_cooldown:
		return
	
	var hitbox = get_node_or_null("HitboxArea")
	if hitbox and hitbox.has_overlapping_bodies():
		var bodies = hitbox.get_overlapping_bodies()
		for body in bodies:
			if body.has_method("take_damage"):
				body.take_damage(damage)
				last_attack_time = now

# 受伤
func take_damage(amount: int) -> void:
	if is_dead:
		return
	
	health -= amount
	# 受伤闪烁
	modulate = Color.RED
	await get_tree().create_timer(0.05).timeout
	modulate = Color.WHITE
	
	if health <= 0:
		die()

# 死亡
func die() -> void:
	if is_dead:
		return
	
	is_dead = true
	died.emit(points_on_death)
	
	# 死亡动画 - 渐隐
	modulate = Color(0.5, 0.5, 0.5, 0.8)
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)

# 设置僵尸类型
func set_zombie_type(type: String) -> void:
	zombie_type = type
	match type:
		"fast":    # 快速僵尸
			speed = 120.0
			health = 20
			damage = 5
			points_on_death = 15
		"tank":    # 坦克僵尸
			speed = 50.0
			health = 100
			damage = 20
			points_on_death = 30
		"boss":    # Boss
			speed = 40.0
			health = 500
			damage = 30
			points_on_death = 200
			scale = Vector2(2.0, 2.0)
