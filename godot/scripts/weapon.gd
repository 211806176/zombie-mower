extends Node2D
class_name Weapon

## 武器基类
## 所有武器继承此类

signal fired(position: Vector2, direction: Vector2, damage: int)

@export var weapon_name: String = "武器"
@export var damage: int = 10
@export var attack_speed: float = 1.0  # 攻击间隔(秒)
@export var range_: float = 300.0
@export var projectile_speed: float = 400.0
@export var ammo: int = -1  # -1为无限
@export var penetration: int = 1  # 穿透敌人数量
@export var spread_count: int = 1  # 散射数量
@export var spread_angle: float = 0  # 散射角度

var can_fire: bool = true
var owner_node: Node2D

func _ready() -> void:
	# 尝试获取父节点作为持有者
	owner_node = get_parent()

func attack(direction: Vector2) -> void:
	if not can_fire:
		return
	
	if ammo == 0:
		return
	
	can_fire = false
	
	# 播放攻击动画/特效
	play_attack_effect(direction)
	
	# 发射子弹
	fire_projectile(direction)
	
	# 消耗弹药
	if ammo > 0:
		ammo -= 1
	
	# 冷却
	await get_tree().create_timer(attack_speed).timeout
	can_fire = true

func fire_projectile(direction: Vector2) -> void:
	var base_angle = direction.angle()
	
	for i in range(spread_count):
		var angle_offset = 0.0
		if spread_count > 1:
			angle_offset = lerp(-spread_angle / 2, spread_angle / 2, float(i) / (spread_count - 1))
		
		var final_direction = Vector2.from_angle(base_angle + angle_offset)
		var projectile = create_projectile()
		
		if projectile:
			projectile.setup(final_direction * projectile_speed, damage, penetration, range_)
			projectile.global_position = global_position
			get_tree().current_scene.add_child(projectile)
			fired.emit(global_position, final_direction, damage)

func create_projectile() -> Projectile:
	# 子类重写此方法返回具体子弹
	return PreloadedResources.bullet.instantiate()

func play_attack_effect(_direction: Vector2) -> void:
	# 子类重写实现具体特效
	pass
