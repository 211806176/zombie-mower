extends Node2D
class_name MainGameScene

## 主游戏场景

@onready var player: Player = $Player
@onready var game_manager: GameManager = $GameManager
@onready var ui: CanvasLayer = $UI
@onready var upgrade_panel: Control = $UI/UpgradePanel

var current_upgrades: Array[UpgradeData] = []

func _ready() -> void:
	# 添加玩家到组
	player.add_to_group("player")
	
	# 连接信号
	game_manager.score_changed.connect(_on_score_changed)
	game_manager.wave_started.connect(_on_wave_started)
	game_manager.level_completed.connect(_on_level_completed)
	game_manager.game_over.connect(_on_game_over)
	player.health_changed.connect(_on_health_changed)
	player.died.connect(_on_player_died)
	
	# 隐藏升级面板
	upgrade_panel.visible = false
	
	# 开始游戏
	game_manager.start_game()

func _on_score_changed(new_score: int) -> void:
	$UI/ScoreLabel.text = "分数: %d" % new_score

func _on_wave_started(wave_num: int) -> void:
	$UI/WaveLabel.text = "波次: %d" % wave_num

func _on_level_completed(level: int) -> void:
	show_upgrade_panel()

func _on_health_changed(current: int, max_hp: int) -> void:
	$UI/HealthBar.value = float(current) / max_hp * 100

func _on_player_died() -> void:
	$UI/GameOverPanel.visible = true

func _on_game_over() -> void:
	$UI/GameOverPanel.visible = true
	$UI/GameOverPanel/VBoxContainer/FinalScoreLabel.text = "最终分数: %d" % game_manager.score

func show_upgrade_panel() -> void:
	upgrade_panel.visible = true
	
	var upgrade_manager = UpgradeManager.new()
	var options = upgrade_manager.get_random_upgrades(3, current_upgrades)
	
	# 更新UI显示
	for i in range(3):
		var btn = upgrade_panel.get_node("VBoxContainer/Option%d" % i)
		if i < options.size():
			btn.text = options[i].description
			btn.disabled = false
			btn.pressed.connect(func(): select_upgrade(options[i]))
		else:
			btn.text = ""
			btn.disabled = true

func select_upgrade(upgrade: UpgradeData) -> void:
	current_upgrades.append(upgrade)
	upgrade_panel.visible = false
	
	# 应用词条效果
	var upgrade_manager = UpgradeManager.new()
	upgrade_manager.apply_upgrade(upgrade, player)
	
	# 继续下一关
	game_manager.start_next_wave()

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
