extends Node2D

@export var color: Color = 'blue'
@onready var ball: Sprite2D = $Ball
var dragging := false
var drag_offset := Vector2.ZERO
	
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ball.modulate = color
	ball.self_modulate = color
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if dragging:
		position = get_global_mouse_position() - drag_offset


func _on_button_button_down() -> void:
	dragging = true
	drag_offset = get_global_mouse_position() - global_position

func _on_button_button_up() -> void:
	dragging = false
