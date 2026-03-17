extends CanvasLayer

func _ready():
	$PanelContainer/VBoxContainer/PrestigeButton.pressed.connect(_on_prestige_pressed)
	$PanelContainer/VBoxContainer/CloseButton.pressed.connect(_on_close_pressed)
	GameManager.stage_changed.connect(_on_stage_changed)
	visible = false  # ← make sure this line exists!
	update_ui()

func update_ui():
	var can_prestige = GameManager.can_prestige()
	var gems_reward = GameManager.calculate_gems_reward()

	$PanelContainer/VBoxContainer/TitleLabel.text = "✨ PRESTIGE ✨"
	$PanelContainer/VBoxContainer/InfoLabel.text = (
		"Reset everything and gain Soul Gems!\n" +
		"Requires Stage " + str(GameManager.prestige_requirement)
	)
	$PanelContainer/VBoxContainer/GemsLabel.text = (
		"💎 Soul Gems: " + str(GameManager.soul_gems) +
		"\nYou will earn: +" + str(gems_reward) + " gems"
	)
	$PanelContainer/VBoxContainer/MultLabel.text = (
		"Current Bonus: x" + str(snapped(GameManager.gold_multiplier, 0.01)) + " Gold\n" +
		"After Prestige: x" + str(snapped(1.0 + ((GameManager.soul_gems + gems_reward) * 0.10), 0.01)) + " Gold"
	)

	$PanelContainer/VBoxContainer/PrestigeButton.text = (
		"⚡ PRESTIGE NOW" if can_prestige
		else "🔒 Reach Stage " + str(GameManager.prestige_requirement) + " first"
	)
	$PanelContainer/VBoxContainer/PrestigeButton.disabled = !can_prestige

func _on_prestige_pressed():
	GameManager.do_prestige()
	visible = false
	update_ui()

func _on_close_pressed():
	visible = false

func _on_stage_changed(_stage):
	update_ui()

func show_panel():
	update_ui()
	visible = true
