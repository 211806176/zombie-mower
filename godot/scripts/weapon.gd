extends Node2D
class_name Weapon

signal fired(position: Vector2, direction: Vector2, damage: int)

@export var weapon_name: String = "Weapon"
@export var damage: int = 10
@export var attack_speed: float = 1.0
@export var weapon_range: float = 300.0
@export var projectile_speed: float = 400.0
@export var ammo: int = -1
@export var penetration: int = 1
@export var spread_count: int = 1
@export var spread_angle: float = 0.0

var can_fire: bool = true
var owner_node: Node2D

func _ready() -> void:
	owner_node = get_parent()

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
	
	await get_tree().create_timer(attack_speed).timeout
	can_fire = true

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
			get_tree().current_scene.add_child(projectile)
			fired.emit(global_position, final_direction, damage)

func create_projectile() -> Projectile:
	return load("res://scenes/projectiles/bullet.tscn").instantiate()

func play_attack_effect(_direction: Vector2) -> void:
	pass
