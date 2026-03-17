extends Node

# --- RESOURCES ---
var gold: float = 0.0
var total_gold_earned: float = 0.0

# --- COMBAT STATS ---
var player_dps: float = 0.0
var attack_speed: float = 1.0

# --- PROGRESSION ---
var current_stage: int = 1
var monsters_killed: int = 0
var monsters_per_stage: int = 10

# --- HEROES ---
var heroes: Array = []

# --- PRESTIGE ---
var prestige_count: int = 0
var soul_gems: int = 0
var gold_multiplier: float = 1.0
var prestige_requirement: int = 50  # must reach stage 50 to prestige

# --- SIGNALS ---
signal gold_changed(new_amount)
signal stage_changed(new_stage)
signal monster_killed
signal heroes_updated
signal prestige_completed(gems_earned)


func _ready():
	_init_heroes()

func _init_heroes():
	heroes = [
		{
			"name": "Mage",
			"emoji": "🧙",
			"description": "A wise spellcaster",
			"base_dps": 10.0,
			"base_cost": 50.0,
			"cost_multiplier": 1.15,
			"dps_multiplier": 1.20,
			"level": 0,
			"unlocked": false
		},
		{
			"name": "Warrior",
			"emoji": "⚔️",
			"description": "A mighty fighter",
			"base_dps": 40.0,
			"base_cost": 200.0,
			"cost_multiplier": 1.18,
			"dps_multiplier": 1.22,
			"level": 0,
			"unlocked": false
		},
		{
			"name": "Archer",
			"emoji": "🏹",
			"description": "Swift and precise",
			"base_dps": 120.0,
			"base_cost": 800.0,
			"cost_multiplier": 1.20,
			"dps_multiplier": 1.25,
			"level": 0,
			"unlocked": false
		},
		{
			"name": "Necromancer",
			"emoji": "💀",
			"description": "Commands the undead",
			"base_dps": 400.0,
			"base_cost": 3000.0,
			"cost_multiplier": 1.22,
			"dps_multiplier": 1.28,
			"level": 0,
			"unlocked": false
		},
		{
			"name": "Dragon",
			"emoji": "🐉",
			"description": "Devastating power",
			"base_dps": 1500.0,
			"base_cost": 15000.0,
			"cost_multiplier": 1.25,
			"dps_multiplier": 1.30,
			"level": 0,
			"unlocked": false
		}
	]

func get_hero_cost(hero: Dictionary) -> float:
	return hero["base_cost"] * pow(hero["cost_multiplier"], hero["level"])

func get_hero_dps(hero: Dictionary) -> float:
	if hero["level"] == 0:
		return 0.0
	return hero["base_dps"] * pow(hero["dps_multiplier"], hero["level"] - 1)

func buy_or_upgrade_hero(index: int) -> bool:
	var hero = heroes[index]
	var cost = get_hero_cost(hero)
	if spend_gold(cost):
		hero["level"] += 1
		hero["unlocked"] = true
		recalculate_dps()
		emit_signal("heroes_updated")
		return true
	return false

func recalculate_dps():
	player_dps = 0.0
	for hero in heroes:
		player_dps += get_hero_dps(hero)
	if player_dps == 0.0:
		player_dps = 10.0

func spend_gold(amount: float) -> bool:
	if gold >= amount:
		gold -= amount
		emit_signal("gold_changed", gold)
		return true
	return false

func on_monster_killed():
	monsters_killed += 1
	emit_signal("monster_killed")
	if monsters_killed >= monsters_per_stage:
		monsters_killed = 0
		current_stage += 1
		emit_signal("stage_changed", current_stage)

# --- AUTO SAVE ---
var save_timer: float = 0.0
var auto_save_interval: float = 30.0

func _process(delta):
	save_timer += delta
	if save_timer >= auto_save_interval:
		save_timer = 0.0
		SaveManager.save_game()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		SaveManager.save_game()
		get_tree().quit()

# --- FORMAT NUMBERS (1000 = 1K, 1000000 = 1M) ---
func format_number(num: float) -> String:
	if num >= 1_000_000_000:
		return str(snapped(num / 1_000_000_000, 0.1)) + "B"
	elif num >= 1_000_000:
		return str(snapped(num / 1_000_000, 0.1)) + "M"
	elif num >= 1_000:
		return str(snapped(num / 1_000, 0.1)) + "K"
	return str(snapped(num, 0.1))
	
func can_prestige() -> bool:
	return current_stage >= prestige_requirement

func calculate_gems_reward() -> int:
	# More stages = more gems
	return int(sqrt(current_stage) * (prestige_count + 1))

func do_prestige():
	if not can_prestige():
		return

	var gems_earned = calculate_gems_reward()
	soul_gems += gems_earned
	prestige_count += 1

	# Update gold multiplier — each gem = +10% gold
	gold_multiplier = 1.0 + (soul_gems * 0.10)

	# Reset progress
	gold = 0.0
	total_gold_earned = 0.0
	player_dps = 0.0
	current_stage = 1
	monsters_killed = 0

	# Reset all heroes
	for hero in heroes:
		hero["level"] = 0
		hero["unlocked"] = false

	emit_signal("prestige_completed", gems_earned)
	SaveManager.save_game()

# Override add_gold to apply multiplier
func add_gold(amount: float):
	var boosted = amount * gold_multiplier
	gold += boosted
	total_gold_earned += boosted
	emit_signal("gold_changed", gold)
