extends Node2D

var current_upgrades = []
var game_manager: GameManager = null
var upgrade_manager: UpgradeManager = null
var player: Player = null

@onready var score_label = null
@onready var wave_label = null
@onready var health_bar = null
@onready var upgrade_panel = null
@onready var game_over_panel = null
@onready var final_score_label = null

func _ready() -> void:
	setup_ui_references()
	player = get_tree().get_first_node_in_group("player")
	game_manager = GameManager.new()
	game_manager.name = "GameManager"
	add_child(game_manager)
	upgrade_manager = UpgradeManager.new()
	upgrade_manager.name = "UpgradeManager"
	add_child(upgrade_manager)
	game_manager.score_changed.connect(_on_score_changed)
	game_manager.wave_started.connect(_on_wave_started)
	game_manager.level_completed.connect(_on_level_completed)
	game_manager.game_over.connect(_on_game_over)
	if player:
		player.health_changed.connect(_on_health_changed)
		player.died.connect(_on_player_died)
	if upgrade_panel:
		upgrade_panel.visible = false
	if game_over_panel:
		game_over_panel.visible = false
	game_manager.start_game()

func setup_ui_references() -> void:
	var ui = get_node_or_null("UI")
	if ui:
		score_label = ui.get_node_or_null("ScoreLabel")
		wave_label = ui.get_node_or_null("WaveLabel")
		health_bar = ui.get_node_or_null("HealthBar")
		upgrade_panel = ui.get_node_or_null("UpgradePanel")
		var up = ui.get_node_or_null("GameOverPanel")
		if up:
			game_over_panel = up
			final_score_label = up.get_node_or_null("VBoxContainer/FinalScoreLabel")

func _on_score_changed(new_score: int) -> void:
	if score_label:
		score_label.text = "Score: " + str(new_score)

func _on_wave_started(wave_num: int) -> void:
	if wave_label:
		wave_label.text = "Wave: " + str(wave_num)

func _on_level_completed(level: int) -> void:
	show_upgrade_panel()

func _on_health_changed(current: int, max_hp: int) -> void:
	if health_bar:
		health_bar.value = (float(current) / float(max_hp)) * 100.0

func _on_player_died() -> void:
	if game_over_panel:
		game_over_panel.visible = true

func _on_game_over() -> void:
	if game_over_panel:
		game_over_panel.visible = true
	if final_score_label and game_manager:
		final_score_label.text = "Final Score: " + str(game_manager.current_score)

func show_upgrade_panel() -> void:
	if upgrade_panel == null or upgrade_manager == null or player == null:
		return
	upgrade_panel.visible = true
	var options = upgrade_manager.get_random_upgrades(3, current_upgrades)
	var vbox = upgrade_panel.get_node_or_null("VBoxContainer")
	if vbox:
		var option1 = vbox.get_node_or_null("Option1")
		var option2 = vbox.get_node_or_null("Option2")
		var option3 = vbox.get_node_or_null("Option3")
		if option1 and options.size() > 0:
			option1.text = options[0].description
			option1.disabled = false
		if option2 and options.size() > 1:
			option2.text = options[1].description
			option2.disabled = false
		if option3 and options.size() > 2:
			option3.text = options[2].description
			option3.disabled = false

func select_upgrade(upgrade) -> void:
	current_upgrades.append(upgrade)
	if upgrade_panel:
		upgrade_panel.visible = false
	if upgrade_manager and player:
		upgrade_manager.apply_upgrade(upgrade, player)
	if game_manager:
		game_manager.start_next_wave()
