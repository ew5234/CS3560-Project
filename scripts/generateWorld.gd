extends Node2D

@export var noise_height_texture : NoiseTexture2D
var seed = FastNoiseLite.new()
var noise : Noise

#@onready var grassTileMap = $TileMap/grass
#@onready var sandTileMap = $TileMap/sand
#@onready var waterTileMap = $TileMap/water

var sourceid = 0
var wateratlas = Vector2i(5,2)
var landatlas =  Vector2i(4,4)

var grassTileCoor = []
var grassTerrainSet = 0
var sandTileCoor = []
var waterTileCoor = []
var waterTileSet = 0

func _init(argnoise_height_texture, argseed, argnoise):
	noise_height_texture = argnoise_height_texture
	seed = argseed
	noise = argnoise
	randomize()
	noise_height_texture.noise.seed = randi()
	print(noise_height_texture.noise.seed)
	noise = noise_height_texture.noise


func generate_world(width, height):
	var grassTileMap = get_node("res://scenes/grass.tscn")
	print(grassTileMap)
	var sandTileMap = $TileMap/sand
	var waterTileMap = $TileMap/water
	for x in range(width):
		for y in range(height):
			var noise_val = noise.get_noise_2d(x,y)
			#place grass
			if noise_val > 0.0:
				grassTileCoor.append(Vector2i(x,y))
			#place water
			elif noise_val	< 0.0:
				waterTileCoor.append(Vector2i(x,y))
			
	grassTileMap.set_cells_terrain_connect(grassTileCoor, grassTerrainSet)
	waterTileMap.set_cells_terrain_connect(waterTileCoor, waterTileSet, 0)
