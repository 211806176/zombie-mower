extends CharacterBody2D
class_name Zombie

## 僵尸AI
## 追踪玩家并造成伤害

signal died(points: int)

@export var speed: float = 80.0
@export var health: int = 30
@export var damage: int = 10
@export var attack_cooldown: float = 1.0
@export var points_on_death: int = 10
@export var zombie_type: String = "normal"  # normal, fast, tank, boss

var player: Node2D
var last_attack_time: float = 0.0
var is_dead: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox_area: Area2D = $HitboxArea

func _ready() -> void:
	# 查找玩家
	await get_tree().create_timer(0.1).timeout
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if is_dead or not player:
		return
	
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	
	# 朝向玩家
	if direction.x != 0:
		scale.x = -1 if direction.x < 0 else 1
	
	# 检测与玩家碰撞
	check_player_collision()

func check_player_collision() -> void:
	var now = Time.get_ticks_msec() / 1000.0
	if now - last_attack_time < attack_cooldown:
		return
	
	if hitbox_area.has_overlapping_bodies():
		var bodies = hitbox_area.get_overlapping_bodies()
		for body in bodies:
			if body.has_method("take_damage"):
				body.take_damage(damage)
				last_attack_time = now

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

func die() -> void:
	if is_dead:
		return
	
	is_dead = true
	died.emit(points_on_death)
	
	# 死亡动画
	modulate = Color(0.5, 0.5, 0.5, 0.8)
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)

func set_zombie_type(type: String) -> void:
	zombie_type = type
	match type:
		"fast":
			speed = 120.0
			health = 20
			damage = 5
			points_on_death = 15
		"tank":
			speed = 50.0
			health = 100
			damage = 20
			points_on_death = 30
		"boss":
			speed = 40.0
			health = 500
			damage = 30
			points_on_death = 200
			scale = Vector2(2, 2)
