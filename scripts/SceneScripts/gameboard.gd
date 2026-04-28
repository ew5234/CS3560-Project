extends Node2D

@export var noise_height_texture : NoiseTexture2D
var noise : Noise

var pauseMenu = PauseMenu.new()

var generateWorld = GenerateWorld.new()

func _ready() -> void:
	if GameManager.seed == null:
		print("isNull")
		randomize()
		noise_height_texture.noise.seed = randi()
	else: 
		noise_height_texture.noise.seed = int(GameManager.seed)
	noise = noise_height_texture.noise
	generateWorld.generateWorld($board/TileMapLayer, noise, GameManager.x, GameManager.y)
	GameManager.registerBoard($board/TileMapLayer)
	
	GameManager.registerPlayer($CharacterBody2D)
	
	GameManager.runPhase()
"""
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	GameManager.runPhase()
"""
#escape menu
"""
func _input(event: InputEvent) -> void:
	if event.is_action("ui_cancel"):
		if get_tree().paused == false:
			get_tree().paused = true
			$CharacterBody2D/Camera2D/CanvasLayer/Control.show()
		elif get_tree().paused == true:
			get_tree().paused = false
			$CharacterBody2D/Camera2D/CanvasLayer/Control.hide()
		

func _on_resume_pressed() -> void:
	get_tree().paused = false
"""
