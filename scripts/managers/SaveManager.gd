extends Node

const SAVE_PATH = "user://savegame.json"

func save_game():
	var heroes_save = []
	for hero in GameManager.heroes:
		heroes_save.append({
			"level": hero["level"],
			"unlocked": hero["unlocked"]
		})
	
	var save_data = {
		"gold": GameManager.gold,
		"total_gold_earned": GameManager.total_gold_earned,
		"player_dps": GameManager.player_dps,
		"current_stage": GameManager.current_stage,
		"monsters_killed": GameManager.monsters_killed,
		"heroes": heroes_save
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("Game saved!")

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file - starting fresh!")
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		var json = JSON.new()
		if json.parse(json_string) == OK:
			var data = json.data
			GameManager.gold = data.get("gold", 0.0)
			GameManager.total_gold_earned = data.get("total_gold_earned", 0.0)
			GameManager.current_stage = data.get("current_stage", 1)
			GameManager.monsters_killed = data.get("monsters_killed", 0)
			
			# Load heroes
			var heroes_data = data.get("heroes", [])
			for i in range(min(heroes_data.size(), GameManager.heroes.size())):
				GameManager.heroes[i]["level"] = heroes_data[i].get("level", 0)
				GameManager.heroes[i]["unlocked"] = heroes_data[i].get("unlocked", false)
			
			GameManager.recalculate_dps()
			print("Game loaded!")

func delete_save():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("Save deleted!")
