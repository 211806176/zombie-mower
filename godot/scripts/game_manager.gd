extends Node
class_name GameManager

signal score_changed(new_score: int)
signal wave_started(wave_num: int)
signal level_completed(level: int)
signal game_over

@export var current_level: int = 1
@export var current_wave: int = 0
@export var score: int = 0
@export var levels_count: int = 10
@export var waves_per_level: int = 5
@export var base_zombies_per_wave: int = 10
@export var zombie_hp_multiplier: float = 1.2
@export var spawn_interval: float = 1.5

var is_game_running: bool = false
var zombies_killed_in_wave: int = 0
var zombies_to_spawn: int = 0
var spawn_timer: float = 0.0
var player: Player = null
var zombie_scene: PackedScene

func _ready() -> void:
	zombie_scene = load("res://scenes/enemies/zombie.tscn")
	player = get_tree().get_first_node_in_group("player")
	if player:
		player.died.connect(_on_player_died)

func start_game() -> void:
	is_game_running = true
	current_level = 1
	current_wave = 0
	score = 0
	score_changed.emit(score)
	start_next_wave()

func start_next_wave() -> void:
	current_wave += 1
	zombies_killed_in_wave = 0
	zombies_to_spawn = calculate_zombies_for_wave()
	spawn_timer = 0.0
	wave_started.emit(current_wave)

func _process(delta: float) -> void:
	if not is_game_running:
		return
	
	if zombies_to_spawn > 0:
		spawn_timer -= delta
		if spawn_timer <= 0:
			spawn_zombie()
			spawn_timer = spawn_interval

func calculate_zombies_for_wave() -> int:
	return int(base_zombies_per_wave * (1.0 + current_wave * 0.3) * zombie_hp_multiplier)

func spawn_zombie() -> void:
	if zombies_to_spawn <= 0:
		return
	
	var zombie = zombie_scene.instantiate()
	
	var rand_val = randf()
	if current_wave >= 3 and rand_val < 0.2:
		zombie.set_zombie_type("fast")
	elif current_wave >= 5 and rand_val < 0.15:
		zombie.set_zombie_type("tank")
	elif current_wave % 5 == 0 and current_wave > 0:
		zombie.set_zombie_type("boss")
	else:
		zombie.set_zombie_type("normal")
	
	var hp_scale = pow(zombie_hp_multiplier, float(current_wave - 1))
	zombie.health = int(zombie.health * hp_scale)
	zombie.global_position = get_spawn_position()
	zombie.died.connect(_on_zombie_died)
	
	get_tree().current_scene.add_child(zombie)
	zombies_to_spawn -= 1

func get_spawn_position() -> Vector2:
	var viewport = get_viewport_rect()
	var side = randi() % 4
	var pos = Vector2.ZERO
	
	match side:
		0:
			pos = Vector2(randf() * viewport.size.x, -50.0)
		1:
			pos = Vector2(viewport.size.x + 50.0, randf() * viewport.size.y)
		2:
			pos = Vector2(randf() * viewport.size.x, viewport.size.y + 50.0)
		3:
			pos = Vector2(-50.0, randf() * viewport.size.y)
	
	return pos

func _on_zombie_died(points: int) -> void:
	score += points
	score_changed.emit(score)
	zombies_killed_in_wave += 1
	
	if zombies_to_spawn <= 0:
		var zombies = get_tree().get_nodes_in_group("zombies")
		if zombies.size() == 0:
			on_wave_completed()

func on_wave_completed() -> void:
	if current_wave % waves_per_level == 0:
		level_completed.emit(current_level)
		current_level += 1
		
		if current_level > levels_count:
			game_over.emit()
			is_game_running = false
	else:
		await get_tree().create_timer(2.0).timeout
		start_next_wave()

func _on_player_died() -> void:
	game_over.emit()
	is_game_running = false
