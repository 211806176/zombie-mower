# 主游戏场景
# 负责游戏初始化、UI更新、升级系统

extends Node2D

# 变量声明
var current_upgrades = []          # 当前拥有的升级
var game_manager = null             # 游戏管理器
var upgrade_manager = null          # 升级管理器
var player = null                   # 玩家节点

# UI组件引用
var score_label = null              # 分数显示
var wave_label = null               # 波次显示
var health_bar = null               # 血量条
var upgrade_panel = null            # 升级选择面板
var game_over_panel = null          # 游戏结束面板
var final_score_label = null        # 最终分数显示

func _ready() -> void:
	# 初始化UI引用
	setup_ui_references()
	
	# 获取玩家节点
	player = get_tree().get_first_node_in_group("player")
	
	# 动态创建游戏管理器
	game_manager = ClassDB.instantiate("Node")
	game_manager.set_script(load("res://scripts/game_manager.gd"))
	game_manager.name = "GameManager"
	add_child(game_manager)
	
	# 动态创建升级管理器
	upgrade_manager = ClassDB.instantiate("Node")
	upgrade_manager.set_script(load("res://scripts/upgrade_manager.gd"))
	upgrade_manager.name = "UpgradeManager"
	add_child(upgrade_manager)
	
	# 连接游戏管理器信号
	game_manager.score_changed.connect(_on_score_changed)
	game_manager.wave_started.connect(_on_wave_started)
	game_manager.level_completed.connect(_on_level_completed)
	game_manager.game_over.connect(_on_game_over)
	
	# 连接玩家信号 - 使用get方法避免类型错误
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node and player_node.has_signal("health_changed"):
		player_node.health_changed.connect(_on_health_changed)
	if player_node and player_node.has_signal("died"):
		player_node.died.connect(_on_player_died)
	
	# 隐藏面板
	if upgrade_panel:
		upgrade_panel.visible = false
	if game_over_panel:
		game_over_panel.visible = false
	
	# 开始游戏
	game_manager.start_game()

# 初始化UI组件引用
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

# 分数变化回调
func _on_score_changed(new_score: int) -> void:
	if score_label:
		score_label.text = "Score: " + str(new_score)

# 波次开始回调
func _on_wave_started(wave_num: int) -> void:
	if wave_label:
		wave_label.text = "Wave: " + str(wave_num)

# 关卡完成回调 - 显示升级面板
func _on_level_completed(level: int) -> void:
	show_upgrade_panel()

# 玩家血量变化回调
func _on_health_changed(current: int, max_hp: int) -> void:
	if health_bar:
		health_bar.value = (float(current) / float(max_hp)) * 100.0

# 玩家死亡回调
func _on_player_died() -> void:
	if game_over_panel:
		game_over_panel.visible = true

# 游戏结束回调
func _on_game_over() -> void:
	if game_over_panel:
		game_over_panel.visible = true
	if final_score_label and game_manager:
		final_score_label.text = "Final Score: " + str(game_manager.current_score)

# 显示升级选择面板
func show_upgrade_panel() -> void:
	if upgrade_panel == null or upgrade_manager == null or player == null:
		return
	
	upgrade_panel.visible = true
	# 获取随机升级选项
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
