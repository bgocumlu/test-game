extends Node

# Takes a black-and-white outline and builds a region map
func generate_region_map(outline: Image) -> Image:
	var w = outline.get_width()
	var h = outline.get_height()
	var region_map = Image.create(w, h, false, Image.FORMAT_RF)
	var visited := PackedByteArray()
	visited.resize(w * h)
	visited.fill(0)

	var region_id := 0
	for y in range(h):
		for x in range(w):
			var idx = y * w + x
			if visited[idx] != 0:
				continue
			var col = outline.get_pixel(x, y).v # brightness
			if col > 0.8: # white pixel = fillable
				region_id += 1
				_flood_fill(outline, region_map, Vector2i(x, y), region_id, visited)
	print("Generated", region_id, "regions")
	return region_map


func _flood_fill(outline: Image, region_map: Image, start: Vector2i, region_id: int, visited: PackedByteArray) -> void:
	var w = outline.get_width()
	var h = outline.get_height()
	var stack: Array[Vector2i] = [start]
	var threshold := 0.3 # treat anything darker as line / border
	while stack.size() > 0:
		var p = stack.pop_back()
		var x = p.x
		var y = p.y
		if x < 0 or y < 0 or x >= w or y >= h:
			continue
		var idx = y * w + x
		if visited[idx] != 0:
			continue
		visited[idx] = 1
		var val = outline.get_pixel(x, y).v
		if val < threshold:
			continue # hit the black line
		region_map.set_pixel(x, y, Color(float(region_id) / 255.0, 0, 0))
		stack.append(Vector2i(x + 1, y))
		stack.append(Vector2i(x - 1, y))
		stack.append(Vector2i(x, y + 1))
		stack.append(Vector2i(x, y - 1))

func _ready() -> void:
	if false:
		var outline = Image.load_from_file("res://boyama/outline1.png")
		var region_map = generate_region_map(outline)
		region_map.save_png("res://boyama/region_map.png")
	

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")
