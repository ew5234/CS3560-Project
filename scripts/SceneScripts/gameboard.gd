extends Node2D

@export var noise_height_texture : NoiseTexture2D
var noise : Noise

var generateWorld = GenerateWorld.new()

func _ready() -> void:
	if GameManager.seed == null:
		print("isNull")
		randomize()
		noise_height_texture.noise.seed = randi()
	else: 
		noise_height_texture.noise.seed = int(GameManager.seed)
	noise = noise_height_texture.noise
	
	#check for difficulty and generate world with that difficulty
	generateWorld = generateWorld.getDifficulty(GameManager.difficulty)
	generateWorld.generateWorld($board/TileMapLayer, noise, GameManager.x, GameManager.y)
	GameManager.registerBoard($board/TileMapLayer)
	
	GameManager.registerPlayer($CharacterBody2D)
	
	GameManager.runPhase()
"""
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	GameManager.runPhase()
"""

func _on_finished():
	queue_free()
