extends Camera2D

@export var speed = 100.0

func _process(delta):
	# Moves the camera to the right
	position.x += speed * delta
