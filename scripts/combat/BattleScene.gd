extends Node2D

# Monster stats (scale with stage)
var monster_max_hp: float = 100.0
var monster_current_hp: float = 100.0
var gold_reward: float = 10.0

func _ready():
	# Load saved game FIRST before anything else
	SaveManager.load_game()
	
	GameManager.gold_changed.connect(_on_gold_changed)
	GameManager.stage_changed.connect(_on_stage_changed)
	$AttackTimer.timeout.connect(_on_AttackTimer_timeout)
	$AttackTimer.wait_time = 1.0 / GameManager.attack_speed
	$AttackTimer.start()
	$UI/SaveButton.pressed.connect(_on_SaveButton_pressed)
	
	spawn_monster()
	update_ui()

func spawn_monster():
	var stage = GameManager.current_stage
	monster_max_hp = 100.0 * pow(1.15, stage - 1)
	monster_current_hp = monster_max_hp
	gold_reward = 10.0 * pow(1.12, stage - 1)
	update_monster_healthbar()

func _on_AttackTimer_timeout():
	deal_damage(GameManager.player_dps)

func deal_damage(amount: float):
	monster_current_hp -= amount
	update_monster_healthbar()
	
	# Flash effect (optional but satisfying!)
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

func update_ui():
	$UI/GoldLabel.text = "Gold: " + str(snapped(GameManager.gold, 0.1))
	$UI/StageLabel.text = "Stage: " + str(GameManager.current_stage)
	$UI/DPSLabel.text = "DPS: " + str(GameManager.player_dps)

func _on_gold_changed(_new_amount):
	update_ui()

func _on_stage_changed(_new_stage):
	update_ui()

func _on_SaveButton_pressed():
	SaveManager.save_game()
	# Flash the button text as confirmation
	$UI/SaveButton.text = "Saved! ✓"
	await get_tree().create_timer(1.5).timeout
	$UI/SaveButton.text = "Save Game"

func _on_attack_timer_timeout() -> void:
	pass # Replace with function body.
