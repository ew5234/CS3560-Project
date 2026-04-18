extends Node2D

class_name GenerateWorld

#Declare coordinate holders and terrain set num
var grassTileCoor = []
var grassTerrainInt = 0
var sandTileCoor = []
var sandTerrainInt = 0
var waterTileCoor = []
var waterTerrainInt = 0

#Function to create a randomly generated world
func generateWorld(tileMapPath: TileMapLayer, noise: Noise, xSize: int = 100, ySize: int = 100) -> void:
	#Retrieve scene tilemaps
	var grassTileMap = tileMapPath.get_child(0)
	var sandTileMap = tileMapPath.get_child(1)
	var waterTileMap = tileMapPath.get_child(2)
	
	#Create noise value for each coordinate
	for x in range(xSize):
		for y in range(ySize):
			var noise_val = noise.get_noise_2d(x,y)
			if noise_val >= -0.2:
				#Place Sand -0.2 <= noise_val < 0.0
				if (noise_val >= -0.2 and noise_val<0.0):
					sandTileCoor.append(Vector2i(x,y))
				#Place Grass 0.0 <= noise_val
				else:
					grassTileCoor.append(Vector2i(x,y))
			#Place Water noise_val < -0.2
			elif noise_val	< -0.2:
				waterTileCoor.append(Vector2i(x,y))

	#Place tiles
	sandTileMap.set_cells_terrain_connect(sandTileCoor, sandTerrainInt, 0)
	grassTileMap.set_cells_terrain_connect(grassTileCoor, grassTerrainInt, 0)
	waterTileMap.set_cells_terrain_connect(waterTileCoor, waterTerrainInt, 0)
