extends Sprite2D

func _ready():
	if false:
		call_deferred("save_with_shader", "res://pikachu_outline.png")

func save_with_shader(path: String):
	# Create a SubViewport to render this sprite with its shader
	var vp := SubViewport.new()
	vp.size = texture.get_size()
	vp.disable_3d = true
	vp.transparent_bg = true
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	vp.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	get_tree().root.add_child.call_deferred(vp) # Defer adding to root
	
	# Clone this sprite inside the viewport
	var clone := Sprite2D.new()
	clone.texture = texture
	clone.material = material
	clone.centered = centered
	clone.flip_h = flip_h
	clone.flip_v = flip_v
	clone.position = vp.size / 2.0
	vp.add_child.call_deferred(clone)
	
	# Wait a frame after everything’s added & rendered
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Capture the rendered texture
	var img := vp.get_texture().get_image()
	img.save_png(path)
	
	print("✅ Shader-applied image saved to:", path)
	
	vp.queue_free()
