# scripts/ui/HeroUI.gd
extends CanvasLayer

@onready var gold_label = $GoldLabel
@onready var dps_label = $DPSLabel
@onready var sword_btn = $SwordUpgradeBtn
@onready var armor_btn = $ArmorUpgradeBtn

func _ready():
	GameManager.gold_changed.connect(_on_gold_changed)
	GameManager.hero_stats_changed.connect(_refresh_ui)
	_refresh_ui()

func _refresh_ui():
	gold_label.text = "Gold: %s" % _format_number(GameManager.gold)
	dps_label.text = "DPS: %.1f" % GameManager.hero_dps
	sword_btn.text = "⚔ Sword Lv.%d  —  Cost: %sg" % [
		GameManager.sword_level,
		_format_number(GameManager.get_sword_cost())
	]
	armor_btn.text = "🛡 Armor Lv.%d  —  Cost: %sg" % [
		GameManager.armor_level,
		_format_number(GameManager.get_armor_cost())
	]

func _on_gold_changed(new_amount: float):
	gold_label.text = "Gold: %s" % _format_number(new_amount)
	_refresh_ui()  # refresh button costs affordability

func _on_sword_upgrade_pressed():
	GameManager.upgrade_sword()

func _on_armor_upgrade_pressed():
	GameManager.upgrade_armor()

# ── Formats big numbers: 1200 → "1.2K" ───────────────
func _format_number(n: float) -> String:
	if n >= 1_000_000:
		return "%.1fM" % (n / 1_000_000)
	elif n >= 1_000:
		return "%.1fK" % (n / 1_000)
	return "%d" % n
