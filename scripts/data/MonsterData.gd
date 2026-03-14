extends Node

# Each monster type: name, emoji, hp_multiplier, gold_multiplier, color
const MONSTER_TYPES = [
	{
		"name": "Rat",
		"emoji": "🐀",
		"stages": [1, 5],
		"hp_mult": 1.0,
		"gold_mult": 1.0,
		"color": Color(0.6, 0.6, 0.6)
	},
	{
		"name": "Wolf",
		"emoji": "🐺",
		"stages": [6, 10],
		"hp_mult": 1.5,
		"gold_mult": 1.5,
		"color": Color(0.4, 0.3, 0.2)
	},
	{
		"name": "Zombie",
		"emoji": "🧟",
		"stages": [11, 15],
		"hp_mult": 2.0,
		"gold_mult": 2.0,
		"color": Color(0.2, 0.5, 0.2)
	},
	{
		"name": "Drake",
		"emoji": "🐉",
		"stages": [16, 20],
		"hp_mult": 3.0,
		"gold_mult": 3.0,
		"color": Color(0.8, 0.2, 0.2)
	},
	{
		"name": "Demon",
		"emoji": "👹",
		"stages": [21, 30],
		"hp_mult": 5.0,
		"gold_mult": 5.0,
		"color": Color(0.5, 0.0, 0.5)
	},
	{
		"name": "Dragon",
		"emoji": "🔥",
		"stages": [31, 999],
		"hp_mult": 10.0,
		"gold_mult": 10.0,
		"color": Color(1.0, 0.3, 0.0)
	}
]

func get_monster_for_stage(stage: int) -> Dictionary:
	for monster in MONSTER_TYPES:
		# Repeat every 30 stages
		var adjusted_stage = ((stage - 1) % 30) + 1
		if adjusted_stage >= monster["stages"][0] and adjusted_stage <= monster["stages"][1]:
			return monster
	return MONSTER_TYPES[0]

func is_boss_stage(stage: int) -> bool:
	return stage % 10 == 0
