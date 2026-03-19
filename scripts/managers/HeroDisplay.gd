extends Sprite2D

var hero_index: int = 0

func setup(index: int, hero: Dictionary):
	hero_index = index
	
	# Load texture
	var texture_path = hero.get("texture", "")
	if texture_path != "" and ResourceLoader.exists(texture_path):
		texture = load(texture_path)
	
	# Start bobbing animation
	start_bob_animation(index)

func start_bob_animation(index: int):
	# Offset timing so heroes don't all bob in sync
	var tween = create_tween()
	tween.set_loops()
	
	# Small delay per hero so they look independent
	var offset = index * 0.3
	await get_tree().create_timer(offset).timeout
	
	tween.tween_property(self, "position:y", position.y - 15.0, 0.7)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position:y", position.y, 0.7)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_SINE)
