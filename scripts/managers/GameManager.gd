extends Node

# --- RESOURCES ---
var gold: float = 0.0
var total_gold_earned: float = 0.0

# --- COMBAT STATS ---
var player_dps: float = 10.0
var attack_speed: float = 1.0  # attacks per second

# --- PROGRESSION ---
var current_stage: int = 1
var monsters_killed: int = 0
var monsters_per_stage: int = 10

# --- UPGRADES ---
var upgrade_level: int = 0
var upgrade_base_cost: float = 50.0
var upgrade_dps_bonus: float = 5.0

# --- SIGNALS ---
signal gold_changed(new_amount)
signal stage_changed(new_stage)
signal monster_killed

func add_gold(amount: float):
	gold += amount
	total_gold_earned += amount
	emit_signal("gold_changed", gold)

func spend_gold(amount: float) -> bool:
	if gold >= amount:
		gold -= amount
		emit_signal("gold_changed", gold)
		return true
	return false  # not enough gold

func get_upgrade_cost() -> float:
	return upgrade_base_cost * pow(1.15, upgrade_level)

func buy_upgrade() -> bool:
	var cost = get_upgrade_cost()
	if spend_gold(cost):
		upgrade_level += 1
		player_dps += upgrade_dps_bonus * upgrade_level
		return true
	return false

func on_monster_killed():
	monsters_killed += 1
	emit_signal("monster_killed")
	if monsters_killed >= monsters_per_stage:
		monsters_killed = 0
		current_stage += 1
		emit_signal("stage_changed", current_stage)
