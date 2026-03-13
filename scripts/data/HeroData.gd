extends Resource
class_name HeroData

@export var hero_name: String = ""
@export var base_dps: float = 0.0
@export var base_cost: float = 0.0
@export var cost_multiplier: float = 1.15
@export var dps_multiplier: float = 1.20
@export var description: String = ""
@export var level: int = 0
@export var unlocked: bool = false

func get_current_dps() -> float:
	if level == 0:
		return 0.0
	return base_dps * pow(dps_multiplier, level - 1)

func get_upgrade_cost() -> float:
	return base_cost * pow(cost_multiplier, level)

func get_total_dps_contribution() -> float:
	return get_current_dps()
