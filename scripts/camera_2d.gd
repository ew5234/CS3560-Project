extends Camera2D

@export var speed = 2000#100.0
var min = 16
var max = 4800

var direction = "right"

func _process(delta):
	if direction == "right":
		# Moves the camera to the right
		position.x += speed * delta
		if SIDE_RIGHT >= 4784:
			direction = "left"
			print(direction)
	if direction == "left":
		position.x -= speed * delta
		if SIDE_LEFT == 16:
			direction = "right"
