extends Node

const kova_narrator = preload("uid://d13dt5qxsxs3e")

func play_kova():
	var p := AudioStreamPlayer.new()
	p.stream = kova_narrator
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)
	
func play(stream: AudioStream, volume_db: float = 0.0):
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.volume_db = volume_db
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
