extends Node2D

@export var ball_scene: PackedScene
@export var ball_position: Vector2
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
var count := 0
@onready var bucket: Bucket = $Bucket
@onready var bucket_2: Bucket = $Bucket2
@onready var bucket_3: Bucket = $Bucket3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.max_fps = 200
	AudioServer.unlock()
	pass # Replace with function body.

func shuffle_buckets():
	var colors = [bucket.color, bucket_2.color, bucket_3.color]
	var new_colors = colors.duplicate()
	new_colors.shuffle()
	while new_colors == colors:
		new_colors.shuffle()
	colors = new_colors
	
	bucket.color = new_colors[0]
	bucket_2.color = new_colors[1]
	bucket_3.color = new_colors[2]
	bucket.sprite_2d.material.set_shader_parameter("tint_color", bucket.color)
	bucket_2.sprite_2d.material.set_shader_parameter("tint_color", bucket_2.color)
	bucket_3.sprite_2d.material.set_shader_parameter("tint_color", bucket_3.color)

func spawn_new_ball():
	count += 1
	print(count)
	if count % 5 == 0:
		shuffle_buckets()
		
	AudioServer.unlock()
	audio.play()
	var new_ball = ball_scene.instantiate()
	new_ball.position = ball_position
	var rand = randi_range(1, 3)
	if (rand == 1): new_ball.color = 'red' 
	if (rand == 2): new_ball.color = 'blue' 
	if (rand == 3): new_ball.color = 'green' 
	await get_tree().create_timer(0.5).timeout
	call_deferred("add_child", new_ball)
	

func _on_bucket_ball_entered(_correct: bool) -> void:
	spawn_new_ball()

func _on_bucket_2_ball_entered(_correct: bool) -> void:
	spawn_new_ball()

func _on_bucket_3_ball_entered(_correct: bool) -> void:
	spawn_new_ball()


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")
