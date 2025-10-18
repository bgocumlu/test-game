extends Control

@export var kova_game: PackedScene
@export var boya_game: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_kova_button_pressed() -> void:
	AudioManager.play_kova()
	get_tree().change_scene_to_packed(kova_game)



func _on_baloon_button_pressed() -> void:
	const BALONLARIPATLAT_2 = preload("uid://b306p4l70s3kg")
	AudioManager.play(BALONLARIPATLAT_2)


func _on_boya_button_pressed() -> void:
	get_tree().change_scene_to_packed(boya_game)
