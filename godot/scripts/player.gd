# 玩家角色控制器
# 负责移动、攻击、武器切换

extends CharacterBody2D
class_name Player

# 信号
signal health_changed(current: int, max: int)  # 血量变化
signal died                                          # 死亡

# 属性
@export var speed: float = 200.0      # 移动速度
@export var max_health: int = 100     # 最大生命值
@export var max_weapons: int = 3      # 最大武器槽位

# 运行时变量
var current_health: int               # 当前生命值
var current_weapon_index: int = 0     # 当前武器索引
var weapons = []                       # 武器列表
var is_attacking: bool = false        # 是否正在攻击
var facing_direction: Vector2 = Vector2.RIGHT  # 朝向

# 节点引用
@onready var weapon_holder: Node2D = $WeaponHolder
@onready var hitbox_area: Area2D = $HitboxArea
@onready var shotgun_scene = preload("res://scenes/weapons/shotgun.tscn")

func _ready() -> void:
	# 初始化生命值
	current_health = max_health
	health_changed.emit(current_health, max_health)
	# 默认装备霰弹枪
	add_weapon(shotgun_scene.instantiate())

func _physics_process(_delta: float) -> void:
	# 直接检测按键
	var direction = Vector2.ZERO
	
	# 检测方向键
	if Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		direction.x = -1
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		direction.x = 1
	if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W):
		direction.y = -1
	if Input.is_key_pressed(KEY_DOWN) or Input.is_key_pressed(KEY_S):
		direction.y = 1
	
	# 归一化
	if direction.length() > 0:
		direction = direction.normalized()
	
	# 设置速度
	velocity = direction * speed
	
	# 移动
	move_and_slide()
	
	# 朝向
	if direction.x != 0:
		facing_direction = Vector2.RIGHT if direction.x > 0 else Vector2.LEFT
		scale.x = facing_direction.x
	
	# 攻击
	if Input.is_key_pressed(KEY_SPACE):
		attack()

# 攻击
func attack() -> void:
	if weapons.is_empty() or is_attacking:
		return
	
	is_attacking = true
	weapons[current_weapon_index].attack(facing_direction)
	get_tree().create_timer(0.3)
	is_attacking = false

# 切换武器
func switch_weapon(index: int) -> void:
	if index >= weapons.size() or index == current_weapon_index:
		return
	current_weapon_index = index
	for i in range(weapon_holder.get_child_count()):
		weapon_holder.get_child(i).visible = (i == current_weapon_index)

# 添加武器
func add_weapon(weapon) -> void:
	if weapons.size() >= max_weapons:
		return
	weapons.append(weapon)
	weapon_holder.add_child(weapon)
	if weapons.size() == 1:
		switch_weapon(0)

# 受伤
func take_damage(amount: int) -> void:
	current_health = max(0, current_health - amount)
	health_changed.emit(current_health, max_health)
	modulate = Color.RED
	get_tree().create_timer(0.1)
	modulate = Color.WHITE
	if current_health <= 0:
		died.emit()
		queue_free()

# 治疗
func heal(amount: int) -> void:
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)
