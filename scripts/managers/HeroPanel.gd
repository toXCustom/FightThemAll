extends CanvasLayer

func _ready():
	GameManager.gold_changed.connect(_on_gold_changed)
	GameManager.heroes_updated.connect(refresh_heroes)
	build_hero_list()

func build_hero_list():
	var hero_list = $PanelContainer/ScrollContainer/HeroList
	
	# Clear existing buttons
	for child in hero_list.get_children():
		child.queue_free()
	
	# Build one row per hero
	for i in range(GameManager.heroes.size()):
		var hero = GameManager.heroes[i]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(230, 200)
		btn.text = _get_hero_text(hero, i)
		btn.pressed.connect(_on_hero_button_pressed.bind(i))
		
		# Grey out if cant afford
		var cost = GameManager.get_hero_cost(hero)
		btn.disabled = GameManager.gold < cost
		
		hero_list.add_child(btn)

func _get_hero_text(hero: Dictionary, _index: int) -> String:
	var cost = GameManager.get_hero_cost(hero)
	var dps = GameManager.get_hero_dps(hero)
	var level_text = "Lv." + str(hero["level"]) if hero["level"] > 0 else "LOCKED"
	
	return (hero["emoji"] + " " + hero["name"] + 
		"  [" + level_text + "]" +
		"\nDPS: " + GameManager.format_number(dps) + 
		"   Cost: " + GameManager.format_number(cost) + "g")

func _on_hero_button_pressed(index: int):
	if GameManager.buy_or_upgrade_hero(index):
		refresh_heroes()

func refresh_heroes():
	build_hero_list()

func _on_gold_changed(_amount):
	refresh_heroes()
