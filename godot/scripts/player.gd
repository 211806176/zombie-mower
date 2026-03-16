extends CharacterBody2D
class_name Player

signal health_changed(current: int, max: int)
signal died

@export var speed: float = 200.0
@export var max_health: int = 100
@export var max_weapons: int = 3

var current_health: int
var current_weapon_index: int = 0
var weapons: Array[Weapon] = []
var is_attacking: bool = false
var facing_direction: Vector2 = Vector2.RIGHT

@onready var sprite: Sprite2D = $Sprite2D
@onready var weapon_holder: Node2D = $WeaponHolder
@onready var hitbox_area: Area2D = $HitboxArea
@onready var shotgun_scene = preload("res://scenes/weapons/shotgun.tscn")

func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)
	add_weapon(shotgun_scene.instantiate())

func _physics_process(_delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()
	
	if direction.x != 0:
		facing_direction = Vector2.RIGHT if direction.x > 0 else Vector2.LEFT
		scale.x = facing_direction.x
	
	if Input.is_action_just_pressed("attack"):
		attack()
	
	if Input.is_action_just_pressed("weapon_1"):
		switch_weapon(0)
	elif Input.is_action_just_pressed("weapon_2"):
		switch_weapon(1)
	elif Input.is_action_just_pressed("weapon_3"):
		switch_weapon(2)

func attack() -> void:
	if weapons.is_empty() or is_attacking:
		return
	
	is_attacking = true
	weapons[current_weapon_index].attack(facing_direction)
	await get_tree().create_timer(0.3).timeout
	is_attacking = false

func switch_weapon(index: int) -> void:
	if index >= weapons.size() or index == current_weapon_index:
		return
	
	current_weapon_index = index
	for i in range(weapon_holder.get_child_count()):
		weapon_holder.get_child(i).visible = (i == current_weapon_index)

func add_weapon(weapon: Weapon) -> void:
	if weapons.size() >= max_weapons:
		return
	
	weapons.append(weapon)
	weapon_holder.add_child(weapon)
	
	if weapons.size() == 1:
		switch_weapon(0)

func take_damage(amount: int) -> void:
	current_health = max(0, current_health - amount)
	health_changed.emit(current_health, max_health)
	
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if current_health <= 0:
		died.emit()
		queue_free()

func heal(amount: int) -> void:
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)
