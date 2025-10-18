extends Sprite2D

@export var paint_color: Color = Color.RED
@export var img_size := Vector2i(1024, 1024)
@export var brush_size := 10
@onready var outline_sprite: Sprite2D = $"../OutlineSprite"
@onready var region_map: Sprite2D = $"../RegionMap"

var img: Image
var brush_mask: Image
var current_region_color: Color = Color.TRANSPARENT
var is_painting: bool = false
var excluded_color: Color = Color(0.9608, 0.2588, 0.8824, 1.0)  # Pink color to exclude
var needs_texture_update: bool = false

func _ready() -> void:
	img = Image.create_empty(img_size.x, img_size.y, false, Image.FORMAT_RGB8)
	img.fill(Color.WHITE)
	texture = ImageTexture.create_from_image(img)
	generate_brush_mask()
	
	# Set region map to match outline sprite transform
	region_map.position = outline_sprite.position
	region_map.scale = outline_sprite.scale
	region_map.offset = outline_sprite.offset
	region_map.visible = false
	
	print("=== REGION MAP TRANSFORM SET ===")
	print("Outline sprite position: ", outline_sprite.position)
	print("Region map position: ", region_map.position)
	print("Region map scale: ", region_map.scale)
	print("Region map offset: ", region_map.offset)

func _process(_delta: float) -> void:
	# Only update texture when needed, not on every paint stroke
	if needs_texture_update:
		texture.update(img)
		needs_texture_update = false

func generate_brush_mask() -> void:
	brush_mask = Image.create(brush_size * 2, brush_size * 2, false, Image.FORMAT_RF)
	var radius = brush_size
	for y in range(brush_mask.get_height()):
		for x in range(brush_mask.get_width()):
			var dx = x - radius
			var dy = y - radius
			var dist = sqrt(dx * dx + dy * dy) / radius
			var alpha = pow(clamp(1.0 - dist, 0.0, 1.0), 2.0)
			brush_mask.set_pixel(x, y, Color(alpha, 0, 0))

func _paint_tex(pos: Vector2i) -> void:
	var radius := int(brush_mask.get_width() / 2.0)
	var img_w := img.get_width()
	var img_h := img.get_height()

	var min_x = max(pos.x - radius, 0)
	var max_x = min(pos.x + radius, img_w - 1)
	var min_y = max(pos.y - radius, 0)
	var max_y = min(pos.y + radius, img_h - 1)

	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			# Additional bounds check for safety
			if x >= img_w or y >= img_h or x < 0 or y < 0:
				continue

			var bx = x - pos.x + radius
			var by = y - pos.y + radius
			if bx < 0 or by < 0 or bx >= brush_mask.get_width() or by >= brush_mask.get_height():
				continue # safety net

			var alpha = brush_mask.get_pixel(bx, by).r
			if alpha <= 0.0:
				continue

			var existing = img.get_pixel(x, y)
			img.set_pixel(x, y, existing.lerp(paint_color, alpha))


func set_brush_size(new_size: int) -> void:
	if new_size != brush_size:
		brush_size = new_size
		generate_brush_mask()

func is_color_similar(color1: Color, color2: Color, tolerance: float = 0.01) -> bool:
	return (abs(color1.r - color2.r) < tolerance and
			abs(color1.g - color2.g) < tolerance and
			abs(color1.b - color2.b) < tolerance and
			abs(color1.a - color2.a) < tolerance)

func check_region_at_position(pos: Vector2) -> void:
	print("=== REGION MAP DEBUG INFO ===")
	
	# Debug region map properties
	print("Region Map Node Info:")
	print("  - Global position: ", region_map.global_position)
	print("  - Local position: ", region_map.position)
	print("  - Scale: ", region_map.scale)
	print("  - Offset: ", region_map.offset)
	print("  - Visible: ", region_map.visible)
	
	# Debug this sprite (painting) properties for comparison
	print("This Sprite (Painting) Info:")
	print("  - Global position: ", global_position)
	print("  - Local position: ", position)
	print("  - Scale: ", scale)
	print("  - Offset: ", offset)
	print("  - Rect size: ", get_rect().size)
	
	# Debug outline sprite properties
	print("Outline Sprite Info:")
	print("  - Global position: ", outline_sprite.global_position)
	print("  - Local position: ", outline_sprite.position)
	print("  - Scale: ", outline_sprite.scale)
	print("  - Offset: ", outline_sprite.offset)
	
	# Get the region map texture
	var region_texture = region_map.texture
	if region_texture == null:
		print("ERROR: Region map texture is null")
		return
	
	# Get the image from the texture
	var region_image = region_texture.get_image()
	if region_image == null:
		print("ERROR: Could not get image from region map texture")
		return
	
	print("Region Map Texture Info:")
	print("  - Image size: ", region_image.get_width(), "x", region_image.get_height())
	print("  - Format: ", region_image.get_format())
	
	# Input position analysis
	print("Input Position Analysis:")
	print("  - Raw input pos: ", pos)
	
	# IMPORTANT: The input pos is in THIS sprite's local coordinate space
	# We need to convert it to global space, then to region_map's local space
	
	# Convert from this sprite's local coords to global
	var global_pos = to_global(pos - get_rect().size / 2.0 + offset)
	
	# Convert from global to region_map's local coords
	var region_local_pos = region_map.to_local(global_pos)
	
	# Now convert to region map's pixel coordinates
	var region_rect_size = Vector2(region_image.get_width(), region_image.get_height())
	var region_pixel_pos = region_local_pos - region_map.offset + region_rect_size / 2.0
	
	print("  - Global position: ", global_pos)
	print("  - Region map local position: ", region_local_pos)
	print("  - Region rect size: ", region_rect_size)
	print("  - Calculated region pixel pos: ", region_pixel_pos)
	
	# Make sure the position is within bounds
	var img_width = region_image.get_width()
	var img_height = region_image.get_height()
	
	print("  - Bounds check: x(", region_pixel_pos.x, ") in [0,", img_width, "], y(", region_pixel_pos.y, ") in [0,", img_height, "]")
	
	if region_pixel_pos.x < 0 or region_pixel_pos.x >= img_width or region_pixel_pos.y < 0 or region_pixel_pos.y >= img_height:
		print("ERROR: Position out of bounds!")
		return
	
	# Get the pixel color at this position
	var pixel_color = region_image.get_pixel(int(region_pixel_pos.x), int(region_pixel_pos.y))
	print("SUCCESS: Region color at pixel ", region_pixel_pos, ": ", pixel_color)
	print("RGB values: R=", pixel_color.r, " G=", pixel_color.g, " B=", pixel_color.b, " A=", pixel_color.a)
	print("===============================")

func get_region_color_at_position(pos: Vector2) -> Color:
	# Get the region map texture
	var region_texture = region_map.texture
	if region_texture == null:
		return Color.TRANSPARENT
	
	# Get the image from the texture
	var region_image = region_texture.get_image()
	if region_image == null:
		return Color.TRANSPARENT
	
	# Convert from this sprite's local coords to global
	var global_pos = to_global(pos - get_rect().size / 2.0 + offset)
	
	# Convert from global to region_map's local coords
	var region_local_pos = region_map.to_local(global_pos)
	
	# Now convert to region map's pixel coordinates
	var region_rect_size = Vector2(region_image.get_width(), region_image.get_height())
	var region_pixel_pos = region_local_pos - region_map.offset + region_rect_size / 2.0
	
	# Make sure the position is within bounds
	var img_width = region_image.get_width()
	var img_height = region_image.get_height()
	
	if region_pixel_pos.x < 0 or region_pixel_pos.x >= img_width or region_pixel_pos.y < 0 or region_pixel_pos.y >= img_height:
		return Color.TRANSPARENT
	
	# Get the pixel color at this position
	return region_image.get_pixel(int(region_pixel_pos.x), int(region_pixel_pos.y))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and not event.is_echo() and event.button_index == MOUSE_BUTTON_LEFT:
			var lpos = to_local(event.position)
			var impos = lpos - offset + get_rect().size / 2.0
			
			# Check region color before painting
			check_region_at_position(impos)
			
			# Store the current region color when starting to paint
			current_region_color = get_region_color_at_position(impos)
			
			# Don't paint if the region is pink (the excluded color)
			if is_color_similar(current_region_color, excluded_color):
				print("Cannot paint - this is a pink (excluded) region!")
				print("Region color: ", current_region_color)
				return
			
			is_painting = true
			print("Started painting in region with color: ", current_region_color)
			_paint_tex(impos.round())
			needs_texture_update = true
				
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			# Mouse button released
			is_painting = false
			current_region_color = Color.TRANSPARENT
			needs_texture_update = true
			print("Stopped painting")
			
	if event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			var lpos = to_local(event.position)
			var impos = lpos - offset + get_rect().size / 2.0
			
			# Check if we've moved to a different region
			if is_painting:
				var current_pos_region_color = get_region_color_at_position(impos)
				
				# Check if out of bounds (returns TRANSPARENT)
				if current_pos_region_color == Color.TRANSPARENT:
					#print("OUT OF BOUNDS - outside the region map!")
					return
				# Check if moved to a different region
				elif current_pos_region_color != current_region_color:
					#print("OUT OF BOUNDS - moved to different region!")
					#print("  Original region color: ", current_region_color)
					#print("  New region color: ", current_pos_region_color)
					return
			else:
				# Not painting, so don't do anything
				return
			
			if event.relative.length_squared() > 0:
				var num := ceili(event.relative.length())
				var target_pos = impos - (event.relative)
				
				# Optimize: Check region less frequently during fast strokes
				@warning_ignore("integer_division")
				var check_interval: int = maxi(1, num / 5)  # Check every 5th point or at least once
				
				for i in num:
					var next_pos = impos.move_toward(target_pos, 1.0)
					
					# Only check region bounds periodically to improve performance
					if i % check_interval == 0:
						var check_color = get_region_color_at_position(next_pos)
						if check_color == Color.TRANSPARENT:
							# Out of bounds
							needs_texture_update = true
							return
						elif not is_color_similar(check_color, current_region_color):
							# Different region
							needs_texture_update = true
							return
					
					_paint_tex(next_pos.round())
					impos = next_pos
				
			needs_texture_update = true


func _on_h_slider_value_changed(value: float) -> void:
	print(value)
	brush_size = int(value)
	generate_brush_mask()
