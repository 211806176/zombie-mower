# 游戏管理器
# 负责波次生成、分数统计、关卡流程控制

extends Node

# 信号定义
signal score_changed       # 分数变化
signal wave_started        # 波次开始
signal level_completed     # 关卡完成
signal game_over           # 游戏结束

# 游戏数值
var current_level: int = 1         # 当前关卡
var current_wave: int = 0          # 当前波次
var current_score: int = 0          # 当前分数
var levels_count: int = 10         # 总关卡数
var waves_per_level: int = 5        # 每关卡波次数
var base_zombies_per_wave: int = 10 # 每波基础僵尸数
var zombie_hp_multiplier: float = 1.2 # 僵尸血量增长系数
var spawn_interval: float = 1.5     # 僵尸生成间隔(秒)

# 运行时变量
var is_game_running: bool = false  # 游戏是否运行中
var zombies_to_spawn: int = 0      # 剩余待生成僵尸数
var spawn_timer: float = 0.0        # 生成计时器
var player = null                   # 玩家引用
var zombie_scene                    # 僵尸场景资源

func _ready() -> void:
	# 加载僵尸场景
	zombie_scene = load("res://scenes/enemies/zombie.tscn")
	# 查找玩家
	player = get_tree().get_first_node_in_group("player")
	if player and player.has_signal("died"):
		player.died.connect(_on_player_died)

# 开始新游戏
func start_game() -> void:
	is_game_running = true
	current_level = 1
	current_wave = 0
	current_score = 0
	score_changed.emit(current_score)
	start_next_wave()

# 开始下一波
func start_next_wave() -> void:
	current_wave += 1
	# 计算本波僵尸数量 = 基础值 * (1 + 波次 * 0.3)
	zombies_to_spawn = int(base_zombies_per_wave * (1.0 + current_wave * 0.3))
	spawn_timer = 0.0
	wave_started.emit(current_wave)

# 每帧处理
func _process(delta: float) -> void:
	if not is_game_running:
		return
	# 生成僵尸
	if zombies_to_spawn > 0:
		spawn_timer -= delta
		if spawn_timer <= 0:
			spawn_zombie()
			spawn_timer = spawn_interval

# 生成一个僵尸
func spawn_zombie() -> void:
	if zombies_to_spawn <= 0:
		return
	
	# 实例化僵尸
	var zombie = zombie_scene.instantiate()
	
	# 根据波次随机决定僵尸类型
	var rand_val = randf()
	if current_wave >= 3 and rand_val < 0.2:
		zombie.set_zombie_type("fast")      # 快速僵尸
	elif current_wave >= 5 and rand_val < 0.15:
		zombie.set_zombie_type("tank")      # 坦克僵尸
	elif current_wave % 5 == 0 and current_wave > 0:
		zombie.set_zombie_type("boss")      # Boss
	else:
		zombie.set_zombie_type("normal")    # 普通僵尸
	
	# 根据波次增加血量
	var hp_scale = pow(zombie_hp_multiplier, float(current_wave - 1))
	zombie.health = int(zombie.health * hp_scale)
	
	# 设置生成位置
	zombie.global_position = get_spawn_position()
	
	# 连接死亡信号
	zombie.died.connect(_on_zombie_died)
	
	# 添加到场景
	get_tree().current_scene.add_child(zombie)
	zombies_to_spawn -= 1

# 获取随机生成位置(屏幕边缘)
func get_spawn_position() -> Vector2:
	var viewport = get_viewport().get_visible_rect()
	var side = randi() % 4
	var pos = Vector2.ZERO
	match side:
		0: pos = Vector2(randf() * viewport.size.x, -50.0)   # 上
		1: pos = Vector2(viewport.size.x + 50.0, randf() * viewport.size.y)  # 右
		2: pos = Vector2(randf() * viewport.size.x, viewport.size.y + 50.0)  # 下
		3: pos = Vector2(-50.0, randf() * viewport.size.y)   # 左
	return pos

# 僵尸死亡回调
func _on_zombie_died(points: int) -> void:
	current_score += points
	score_changed.emit(current_score)
	# 检查是否本波全部消灭
	if zombies_to_spawn <= 0:
		var zombies = get_tree().get_nodes_in_group("zombies")
		if zombies.size() == 0:
			on_wave_completed()

# 波次完成处理
func on_wave_completed() -> void:
	# 每5波完成一个关卡
	if current_wave % waves_per_level == 0:
		level_completed.emit(current_level)
		current_level += 1
		# 全部关卡完成
		if current_level > levels_count:
			game_over.emit()
			is_game_running = false
	else:
		# 2秒后开始下一波
		await get_tree().create_timer(2.0)
		start_next_wave()

# 玩家死亡回调
func _on_player_died() -> void:
	game_over.emit()
	is_game_running = false
