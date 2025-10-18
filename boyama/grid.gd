extends GridContainer

@onready var flowers: Sprite2D = $"../../../Flowers"
@onready var snail: Sprite2D = $"../../../Snail"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for c:ColorRect in get_children():
		c.gui_input.connect(func(input):
			if input is InputEventMouseButton:
				if input.pressed and input.button_index == MOUSE_BUTTON_LEFT:
					for c2:Sprite2D in flowers.get_children():
						c2.paint_color = c.color
					for c2:Sprite2D in snail.get_children():
						c2.paint_color = c.color
		)
