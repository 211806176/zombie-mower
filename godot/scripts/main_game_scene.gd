extends Node2D

var current_upgrades: Array[UpgradeData] = []
var game_manager: GameManager = null
var upgrade_manager: UpgradeManager = null
var player: Player = null

@onready var score_label = $UI/ScoreLabel
@onready var wave_label = $UI/WaveLabel
@onready var health_bar = $UI/HealthBar
@onready var upgrade_panel = $UI/UpgradePanel
@onready var game_over_panel = $UI/GameOverPanel
@onready var final_score_label = $UI/GameOverPanel/VBoxContainer/FinalScoreLabel

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
	# Setup GameManager
	game_manager = GameManager.new()
	game_manager.name = "GameManager"
	add_child(game_manager)
	
	# Setup UpgradeManager
	upgrade_manager = UpgradeManager.new()
	upgrade_manager.name = "UpgradeManager"
	add_child(upgrade_manager)
	
	# Connect signals
	game_manager.score_changed.connect(_on_score_changed)
	game_manager.wave_started.connect(_on_wave_started)
	game_manager.level_completed.connect(_on_level_completed)
	game_manager.game_over.connect(_on_game_over)
	
	if player:
		player.health_changed.connect(_on_health_changed)
		player.died.connect(_on_player_died)
	
	upgrade_panel.visible = false
	game_over_panel.visible = false
	
	game_manager.start_game()

func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score

func _on_wave_started(wave_num: int) -> void:
	wave_label.text = "Wave: %d" % wave_num

func _on_level_completed(level: int) -> void:
	show_upgrade_panel()

func _on_health_changed(current: int, max_hp: int) -> void:
	health_bar.value = float(current) / float(max_hp) * 100.0

func _on_player_died() -> void:
	game_over_panel.visible = true

func _on_game_over() -> void:
	game_over_panel.visible = true
	final_score_label.text = "Final Score: %d" % game_manager.score

func show_upgrade_panel() -> void:
	upgrade_panel.visible = true
	
	var options = upgrade_manager.get_random_upgrades(3, current_upgrades)
	
	var option1 = upgrade_panel.get_node("VBoxContainer/Option1")
	var option2 = upgrade_panel.get_node("VBoxContainer/Option2")
	var option3 = upgrade_panel.get_node("VBoxContainer/Option3")
	
	if options.size() > 0:
		option1.text = options[0].description
		option1.pressed.connect(func(): select_upgrade(options[0]))
	else:
		option1.text = ""
		option1.disabled = true
	
	if options.size() > 1:
		option2.text = options[1].description
		option2.pressed.connect(func(): select_upgrade(options[1]))
	else:
		option2.text = ""
		option2.disabled = true
	
	if options.size() > 2:
		option3.text = options[2].description
		option3.pressed.connect(func(): select_upgrade(options[2]))
	else:
		option3.text = ""
		option3.disabled = true

func select_upgrade(upgrade: UpgradeData) -> void:
	current_upgrades.append(upgrade)
	upgrade_panel.visible = false
	
	upgrade_manager.apply_upgrade(upgrade, player)
	
	game_manager.start_next_wave()

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
