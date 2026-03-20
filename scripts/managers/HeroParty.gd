extends Node2D

const HERO_POSITIONS = [
	Vector2(150, 380),
	Vector2(260, 380),
	Vector2(370, 380),
	Vector2(480, 380),
	Vector2(590, 380),
]

const HERO_SCALE = Vector2(1.5, 1.5)

var hero_sprites: Array = []

func _ready():
	GameManager.heroes_updated.connect(refresh_party)

func _process(delta):
	# Animate all hero sprites using sine wave — no tweens needed!
	var time = Time.get_ticks_msec() / 1000.0
	for i in range(hero_sprites.size()):
		var sprite = hero_sprites[i]
		if is_instance_valid(sprite):
			# Each hero bobs at slightly different speed/offset
			var bob = sin(time * 2.0 + i * 1.2) * 8.0
			sprite.position.y = HERO_POSITIONS[i].y + bob

func refresh_party():
	# Clear ALL children
	for child in get_children():
		child.queue_free()
	hero_sprites.clear()

	# Spawn sprite for each unlocked hero
	for i in range(GameManager.heroes.size()):
		var hero = GameManager.heroes[i]
		if hero["unlocked"] and hero["level"] > 0:
			spawn_hero_sprite(i, hero)

func spawn_hero_sprite(index: int, hero: Dictionary):
	var sprite = Sprite2D.new()
	add_child(sprite)

	var texture_path = hero.get("texture", "")
	if texture_path != "" and ResourceLoader.exists(texture_path):
		sprite.texture = load(texture_path)

	if index < HERO_POSITIONS.size():
		sprite.position = HERO_POSITIONS[index]

	sprite.scale = HERO_SCALE
	hero_sprites.append(sprite)

	# Add level label above hero
	var label = Label.new()
	label.text = hero["emoji"] + " Lv." + str(hero["level"])
	label.position = Vector2(HERO_POSITIONS[index].x - 30, HERO_POSITIONS[index].y - 80)
	add_child(label)
