extends Node2D

@onready var prestige_panel = $PrestigePanel

var monster_max_hp: float = 100.0
var monster_current_hp: float = 100.0
var gold_reward: float = 10.0
var current_monster: Dictionary = {}
var is_boss: bool = false

func _ready():
	SaveManager.load_game()
	GameManager.gold_changed.connect(_on_gold_changed)
	GameManager.stage_changed.connect(_on_stage_changed)
	GameManager.prestige_completed.connect(_on_prestige_completed)
	$AttackTimer.timeout.connect(_on_AttackTimer_timeout)
	$AttackTimer.wait_time = 1.0 / GameManager.attack_speed
	$AttackTimer.start()
	$UI/SaveButton.pressed.connect(_on_SaveButton_pressed)
	$UI/PrestigeButton.pressed.connect(_on_PrestigeButton_pressed)
	spawn_monster()
	update_ui()

func spawn_monster():
	var stage = GameManager.current_stage
	is_boss = MonsterData.is_boss_stage(stage)
	current_monster = MonsterData.get_monster_for_stage(stage)

	var base_hp = 100.0 * pow(1.15, stage - 1)
	var base_gold = 10.0 * pow(1.12, stage - 1)
	monster_max_hp = base_hp * current_monster["hp_mult"]
	gold_reward = base_gold * current_monster["gold_mult"]

	if is_boss:
		monster_max_hp *= 3.0
		gold_reward *= 3.0

	monster_current_hp = monster_max_hp

	# Scale Sprite2D directly — boss gets bigger
	if is_boss:
		$Monster/Sprite2D.scale = Vector2(1.5, 1.5)
	else:
		$Monster/Sprite2D.scale = Vector2(1.0, 1.0)

	# Load monster texture dynamically
	var texture_path = current_monster.get("texture", "")
	if texture_path != "" and ResourceLoader.exists(texture_path):
		$Monster/Sprite2D.texture = load(texture_path)

	update_monster_ui()
	update_monster_healthbar()

# Hero bobs up and down gently
func start_hero_animation():
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property($Hero, "position:y", 340.0, 0.8)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property($Hero, "position:y", 360.0, 0.8)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_SINE)

# Monster pulses slightly
func start_monster_animation():
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property($Monster, "scale", Vector2(1.05, 1.05), 0.6)\
		.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Monster, "scale", Vector2(1.0, 1.0), 0.6)\
		.set_ease(Tween.EASE_IN_OUT)

func _on_AttackTimer_timeout():
	deal_damage(GameManager.player_dps)

func deal_damage(amount: float):
	monster_current_hp -= amount
	update_monster_healthbar()

	# Flash Sprite2D red on hit
	var tween = create_tween()
	tween.tween_property($Monster/Sprite2D, "modulate", Color.RED, 0.05)
	tween.tween_property($Monster/Sprite2D, "modulate", Color.WHITE, 0.05)

	if monster_current_hp <= 0:
		monster_died()

func monster_died():
	GameManager.add_gold(gold_reward)
	GameManager.on_monster_killed()
	spawn_monster()

func update_monster_healthbar():
	$Monster/HealthBar.max_value = monster_max_hp
	$Monster/HealthBar.value = monster_current_hp

func update_monster_ui():
	var monster_name = current_monster["emoji"] + " "
	if is_boss:
		monster_name += "⚠️ BOSS: "
	monster_name += current_monster["name"]
	$UI/MonsterNameLabel.text = monster_name

func update_ui():
	$UI/GoldLabel.text = "Gold: " + GameManager.format_number(GameManager.gold)
	$UI/StageLabel.text = "Stage: " + str(GameManager.current_stage)
	$UI/DPSLabel.text = "DPS: " + GameManager.format_number(GameManager.player_dps)

func _on_gold_changed(_new_amount):
	update_ui()

func _on_stage_changed(_new_stage):
	update_ui()
	# Flash stage label yellow on new stage
	var tween = create_tween()
	tween.tween_property($UI/StageLabel, "modulate", Color.YELLOW, 0.1)
	tween.tween_property($UI/StageLabel, "modulate", Color.WHITE, 0.5)

func _on_SaveButton_pressed():
	SaveManager.save_game()
	$UI/SaveButton.text = "Saved! ✓"
	await get_tree().create_timer(1.5).timeout
	$UI/SaveButton.text = "Save Game"
	
func _on_PrestigeButton_pressed():
	if prestige_panel:
		prestige_panel.show_panel()
	else:
		print("ERROR: PrestigePanel not found!")

func _on_prestige_completed(gems_earned: int):
	# Flash the whole screen gold!
	var tween = create_tween()
	tween.tween_property($Hero, "modulate", Color.GOLD, 0.2)
	tween.tween_property($Hero, "modulate", Color.WHITE, 0.5)
	spawn_monster()
	update_ui()
