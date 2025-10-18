extends Sprite2D

@export var paint_color: Color = Color.RED
@export var brush_radius: int = 10
static var active_painter: Sprite2D = null

var img: Image
var paintable_mask: Image
var paint_tex: ImageTexture
@export var region_id: String

# -------------------------------
func _ready() -> void:
	if texture == null:
		push_error("No texture assigned to Sprite2D!")
		return

	var base_tex: Texture2D = texture
	var base_img: Image = base_tex.get_image()
	base_img.convert(Image.FORMAT_RGBA8)

	img = base_img.duplicate()
	paint_tex = ImageTexture.create_from_image(img)
	texture = paint_tex
	paintable_mask = base_img.duplicate()


# -------------------------------
func _paint_circle(center: Vector2i) -> void:
	var w: int = img.get_width()
	var h: int = img.get_height()
	var r2: int = brush_radius * brush_radius

	var y0: int = clamp(center.y - brush_radius, 0, h - 1)
	var y1: int = clamp(center.y + brush_radius, 0, h - 1)
	var x0: int = clamp(center.x - brush_radius, 0, w - 1)
	var x1: int = clamp(center.x + brush_radius, 0, w - 1)

	for y in range(y0, y1):
		for x in range(x0, x1):
			var dx: int = x - center.x
			var dy: int = y - center.y
			if dx * dx + dy * dy <= r2:
				if paintable_mask.get_pixel(x, y).a < 0.5:
					continue
				img.set_pixel(x, y, paint_color)

	paint_tex.update(img)


# -------------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and not event.is_echo():
			var lpos: Vector2 = to_local(event.position)
			var impos: Vector2 = lpos - offset + get_rect().size / 2.0
			if impos.x >= 0 and impos.y >= 0 and impos.x < img.get_width() and impos.y < img.get_height():
				if paintable_mask.get_pixelv(impos.round()).a >= 0.5:
					active_painter = self
					_paint_circle(impos.round())
		else:
			if active_painter == self:
				active_painter = null

	elif event is InputEventMouseMotion:
		if active_painter == self and (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
			var lpos: Vector2 = to_local(event.position)
			var impos: Vector2 = lpos - offset + get_rect().size / 2.0
			if event.relative.length_squared() > 0:
				var num: int = ceili(event.relative.length())
				var target_pos: Vector2 = impos - (event.relative)
				for i in num:
					impos = impos.move_toward(target_pos, 1.0)
					_paint_circle(impos.round())
