class_name Bucket
extends Node2D

@export var color: Color = 'Blue'
@onready var sprite_2d: Sprite2D = $Sprite2D
signal ball_entered(bool)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mat := sprite_2d.material as ShaderMaterial
	mat.set_shader_parameter("tint_color", color)
	pass # Replace with function body.

func _on_area_entered(area: Area2D) -> void:
	if (area.color == color):
		area.queue_free()
		ball_entered.emit(true)
