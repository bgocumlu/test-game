extends Node2D

@onready var flowers: Sprite2D = $Flowers
@onready var snail: Sprite2D = $Snail

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")


func _on_h_slider_value_changed(value: float) -> void:
	for c:Sprite2D in flowers.get_children():
		c.brush_radius = value
	for c:Sprite2D in snail.get_children():
		c.brush_radius = value
