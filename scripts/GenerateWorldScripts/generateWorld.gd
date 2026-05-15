extends Node2D

class_name GenerateWorld

#Declare coordinate holders and terrain set num
var grassTileCoor = []
var waterTileCoor = []
var sandTileCoor = []
var forestTileCoor = []
var swampTileCoor = []
var cactusTileCoor = []
var treeTileCoor = []
var itemWaterTileCoor = []
var itemFoodTileCoor = []
var itemGoldTileCoor = []
var traderTileCoor = []
var grassTerrainInt = 0
var terrainSet = 0
var waterAtlas = Vector2(10,5)
var sandAtlas = Vector2(10,1)
var forestAtlas = [Vector2(10,9), Vector2(12,8)]
var swampAtlas = Vector2(10,13)

var noise : Noise
var noiseDeco : Noise

func createNoiseTexture(seed = null) -> void:
	var noise_deco_texture = NoiseTexture2D.new()
	var noise_height_texture = NoiseTexture2D.new()
	
	if seed == null:
		randomize()
		seed = randi()
	
	var heightFNL = FastNoiseLite.new()
	var decoFNL = FastNoiseLite.new()
	
	heightFNL.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	heightFNL.seed = seed
	noise_height_texture.noise = heightFNL
	
	noise = noise_height_texture.noise
	#noiseDeco = noise_deco_texture.noise
	var rng = RandomNumberGenerator.new()
	rng.seed = hash(seed)

#Function to create a randomly generated world
func generateWorld(tileMapPath: TileMapLayer, noise: Noise, xSize: int = 100, ySize: int = 100, seed = null) -> void:
	createNoiseTexture()
	#Retrieve scene tilemaps
	var groundTileMap = tileMapPath.get_child(0)
	var decoTileMap = tileMapPath.get_child(1)
	var itemTileMap = tileMapPath.get_child(2)
	var traderTileMap = tileMapPath.get_child(3)
	
	#keep track what tile is placed for deco placing
	#plain: place items
	#water: place nothing
	#swamp: palce nothing
	#sand: place cactus or items
	#forest: place trees or items
	#Create noise value for each coordinate
	for x in range(xSize):
		for y in range(ySize):
			var noise_val = noise.get_noise_2d(x,y)
			var deco_noise = randf() #noiseDeco.get_noise_2d(x,y)
			var placedTile = "plain"
			var itemPlaced = false
			#generation values fall into:
			#-1                    0                   1
			#|forest| |swp|        |water|        |sand|
			# rest is plain
			if noise_val > 0.4:
				groundTileMap.set_cell(Vector2(x,y), terrainSet, sandAtlas)
				sandTileCoor.append(Vector2i(x,y))
				placedTile = "sand"
					
			elif noise_val >0.0 and noise_val < 0.1:
				groundTileMap.set_cell(Vector2(x,y), terrainSet, waterAtlas)
				waterTileCoor.append(Vector2i(x,y))
				placedTile = "water"
			elif noise_val >-0.3 and noise_val < -0.29:
				groundTileMap.set_cell(Vector2(x,y), terrainSet, swampAtlas)
				swampTileCoor.append(Vector2i(x,y))
				placedTile = "water"
			elif noise_val < -0.4:
				groundTileMap.set_cell(Vector2(x,y), terrainSet, forestAtlas.pick_random())
				forestTileCoor.append(Vector2i(x,y))
				placedTile = "forest"

			else:
				grassTileCoor.append(Vector2i(x,y))
			
			#Can place decoration or item if terrain is not water. Only one can be placed per tile
			#Sand has cactus and forest has trees
			if placedTile != "water":
				if placedTile == "sand":
					if deco_noise >0.95:
						cactusTileCoor.append(Vector2i(x,y))
						itemPlaced = true
				elif placedTile == "forest":
					if deco_noise >0.2:
						treeTileCoor.append(Vector2i(x,y))
						itemPlaced = true
				if itemPlaced == false:
					if deco_noise < 0.03:
						itemFoodTileCoor.append(Vector2i(x,y))
					elif deco_noise < 0.06:
						itemWaterTileCoor.append(Vector2i(x,y))
					elif deco_noise < 0.1:
						itemGoldTileCoor.append(Vector2i(x,y))
					elif deco_noise < 0.11:
						traderTileCoor.append(Vector2i(x,y))

	#Place tiles
	groundTileMap.set_cells_terrain_connect(grassTileCoor, terrainSet, grassTerrainInt)
	decoTileMap.set_cells_terrain_connect(cactusTileCoor, terrainSet, 1)
	decoTileMap.set_cells_terrain_connect(treeTileCoor, 1, 0)
	itemTileMap.set_cells_terrain_connect(itemFoodTileCoor, terrainSet, 0)
	itemTileMap.set_cells_terrain_connect(itemWaterTileCoor, terrainSet, 1)
	itemTileMap.set_cells_terrain_connect(itemGoldTileCoor, terrainSet, 2)
	traderTileMap.set_cells_terrain_connect(traderTileCoor, terrainSet, 0)

#function to return either easy or hard world generation
func getDifficulty(difficulty):
	if difficulty == 0:
		return GenerateWorld.new()
	elif difficulty == 1:
		return GenerateWorldHard.new()
