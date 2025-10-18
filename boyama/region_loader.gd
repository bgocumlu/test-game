extends Sprite2D

@export var region_scene: PackedScene = preload("res://boyama/region_sprite.tscn")
@export var regions_folder := "res://boyama/assets/regions/"
@export var region_positions_path := "res://boyama/assets/regions/positions.json"

func _ready():
	# Base sprite (this node) stays centered = true
	var base_tex = texture
	if base_tex == null:
		push_error("No texture assigned to base Sprite2D!")
		return

	var base_half = Vector2(base_tex.get_width() / 2.0, base_tex.get_height() / 2.0)

	# Load JSON
	var file = FileAccess.open(region_positions_path, FileAccess.READ)
	if not file:
		push_error("Cannot open region_positions.json")
		return
	var region_positions = JSON.parse_string(file.get_as_text())
	file.close()

	# Spawn region scenes
	for region_name in region_positions.keys():
		var pos_data = region_positions[region_name]
		var region_path = regions_folder + region_name + ".png"
		if not ResourceLoader.exists(region_path):
			push_warning("Missing region image: " + region_path)
			continue

		var region_instance = region_scene.instantiate()
		region_instance.texture = load(region_path)
		region_instance.region_id = region_name
		# Both parent and child centered → offset by base_half, then re-add region_half
		var region_half = Vector2(
			region_instance.texture.get_width() / 2.0,
			region_instance.texture.get_height() / 2.0
		)
		region_instance.position = Vector2(pos_data["x"], pos_data["y"]) - base_half + region_half
		add_child(region_instance)

	print("✅ All centered sprites aligned correctly.")
