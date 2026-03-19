extends Node2D

# Positions for up to 5 heroes standing side by side
const HERO_POSITIONS = [
	Vector2(150, 380),   # Mage
	Vector2(260, 380),   # Warrior
	Vector2(370, 380),   # Archer
	Vector2(480, 380),   # Necromancer
	Vector2(590, 380),   # Dragon
]

const HERO_SCALE = Vector2(1.5, 1.5)

var hero_sprites: Array = []

func _ready():
	GameManager.heroes_updated.connect(refresh_party)
	refresh_party()

func refresh_party():
	# Clear existing sprites
	for sprite in hero_sprites:
		if is_instance_valid(sprite):
			sprite.queue_free()
	hero_sprites.clear()
	
	# Spawn sprite for each unlocked hero
	for i in range(GameManager.heroes.size()):
		var hero = GameManager.heroes[i]
		if hero["unlocked"] and hero["level"] > 0:
			spawn_hero_sprite(i, hero)

func spawn_hero_sprite(index: int, hero: Dictionary):
	var sprite = Sprite2D.new()
	add_child(sprite)
	
	# DEBUG - print everything
	print("Spawning hero: " + hero["name"])
	print("Texture path: " + hero.get("texture", "NO TEXTURE"))
	print("Level: " + str(hero["level"]))
	print("Unlocked: " + str(hero["unlocked"]))
	
	var texture_path = hero.get("texture", "")
	if texture_path != "":
		if ResourceLoader.exists(texture_path):
			sprite.texture = load(texture_path)
			print("✅ Texture loaded!")
		else:
			print("❌ Texture NOT found at: " + texture_path)
	
	if index < HERO_POSITIONS.size():
		sprite.position = HERO_POSITIONS[index]
	
	sprite.scale = HERO_SCALE
	hero_sprites.append(sprite)
	bob_hero(sprite, index)

func bob_hero(sprite: Sprite2D, index: int):
	var tween = create_tween()
	tween.set_loops()
	var base_y = sprite.position.y
	
	# Stagger timing so each hero bobs independently
	tween.tween_interval(index * 0.25)
	tween.tween_property(sprite, "position:y", base_y - 12.0, 0.7)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "position:y", base_y, 0.7)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_SINE)
