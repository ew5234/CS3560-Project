extends Node2D

@export var noise_height_texture : NoiseTexture2D
var seed = FastNoiseLite.new()
var noise : Noise

@onready var grassTileMap = $TileMap/grass
@onready var sandTileMap = $TileMap/sand
@onready var waterTileMap = $TileMap/water

var sourceid = 0
var wateratlas = Vector2i(5,2)
var landatlas =  Vector2i(4,4)

var grassTileCoor = []
var grassTerrainInt = 0
var sandTileCoor = []
var waterTileCoor = []

#world size
var width : int = 100
var height : int = 100


func _ready():
	randomize()
	noise_height_texture.noise.seed = randi()
	print(	noise_height_texture.noise.seed)
	noise = noise_height_texture.noise
	generate_world()
	
func generate_world():
	for x in range(width):
		for y in range(height):
			var noise_val = noise.get_noise_2d(x,y)
			#place grass
			if noise_val > 0.0:
				grassTileCoor.append(Vector2i(x,y))
			#place water
			elif noise_val	< 0.0:
				waterTileMap.set_cell(Vector2(x,y), sourceid, wateratlas)
			
	grassTileMap.set_cells_terrain_connect(grassTileCoor, grassTerrainInt, 0)
	
	
	
	
