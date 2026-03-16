# 僵尸割草大作战 - Godot 4.x 项目

## 项目结构

```
godot/
├── project.godot          # Godot项目配置
├── scripts/
│   ├── player.gd          # 玩家控制器
│   ├── weapon.gd          # 武器基类
│   ├── weapons/
│   │   ├── shotgun.gd     # 霰弹枪
│   │   └── laser_sword.gd # 激光剑
│   ├── projectile.gd      # 子弹基类
│   ├── zombie.gd          # 僵尸AI
│   ├── game_manager.gd    # 游戏管理器
│   ├── upgrade_manager.gd # 词条系统
│   ├── upgrade_data.gd    # 词条数据
│   ├── preloaded_resources.gd # 资源预加载
│   └── main_game_scene.gd # 主场景
├── scenes/
│   ├── player.tscn        # 玩家场景
│   ├── enemies/
│   │   └── zombie.tscn    # 僵尸场景
│   ├── weapons/
│   │   ├── shotgun.tscn   # 霰弹枪
│   │   └── laser_sword.tscn
│   ├── projectiles/
│   │   ├── bullet.tscn    # 普通子弹
│   │   └── shotgun_bullet.tscn
│   └── main.tscn          # 主游戏场景
└── resources/
    └── sprites/           # 精灵图资源
```

## 使用方法

1. 下载 Godot 4.x: https://godotengine.org/
2. 打开本项目目录
3. 运行 `main.tscn` 场景

## 操作说明

- **移动**: 方向键 / WASD
- **攻击**: 空格键 / 鼠标左键
- **切换武器**: 1, 2, 3 数字键

## 核心系统

1. **玩家系统** - 移动、攻击、武器切换
2. **武器系统** - 霰弹枪、激光剑、更多武器待实现
3. **僵尸AI** - 追踪玩家、多种类型（普通、快速、坦克、Boss）
4. **波次系统** - 逐渐增加的难度
5. **词条系统** - Roguelike随机升级

## 后续开发

- [ ] 添加更多武器（榴弹炮、闪电链、回旋镖）
- [ ] 完善词条联动效果
- [ ] 添加音效和粒子特效
- [ ] 制作UI界面
- [ ] 添加敌人类型
