# 武器基类
# 所有武器继承此类

extends Node2D
class_name Weapon

# 信号
signal fired(position: Vector2, direction: Vector2, damage: int)  # 开火

# 属性
var weapon_name: String = "Weapon"     # 武器名称
var damage: int = 10                  # 伤害值
var attack_speed: float = 1.0          # 攻击间隔(秒)
var weapon_range: float = 300.0        # 射程
var projectile_speed: float = 400.0    # 弹速
var ammo: int = -1                    # 弹药(-1无限)
var penetration: int = 1               # 穿透数
var spread_count: int = 1             # 散射数
var spread_angle: float = 0.0          # 散射角度

# 运行时变量
var can_fire: bool = true              # 可否开火
var owner_node: Node2D                 # 持有者

func _ready() -> void:
	owner_node = get_parent()

# 攻击
func attack(direction: Vector2) -> void:
	if not can_fire:
		return
	if ammo == 0:
		return
	
	can_fire = false
	play_attack_effect(direction)
	fire_projectile(direction)
	
	if ammo > 0:
		ammo -= 1
	
	# 冷却
	await get_tree().create_timer(attack_speed).timeout
	can_fire = true

# 发射投射物
func fire_projectile(direction: Vector2) -> void:
	var base_angle = direction.angle()
	
	for i in range(spread_count):
		var angle_offset = 0.0
		if spread_count > 1:
			angle_offset = lerp(-spread_angle / 2.0, spread_angle / 2.0, float(i) / float(spread_count - 1))
		
		var final_direction = Vector2.from_angle(base_angle + angle_offset)
		var projectile = create_projectile()
		
		if projectile:
			projectile.setup(final_direction * projectile_speed, damage, penetration, weapon_range)
			projectile.global_position = global_position
			get_tree().root.add_child(projectile)
			fired.emit(global_position, final_direction, damage)

# 创建投射物(子类重写)
func create_projectile():
	return load("res://scenes/projectiles/bullet.tscn").instantiate()

# 播放攻击特效(子类重写)
func play_attack_effect(_direction: Vector2) -> void:
	pass
