extends Node

class_name TerrainCost

func deductStats(str: int, water: int, food: int):
		GameManager.playerStrength -=str
		GameManager.playerWater -=water
		GameManager.playerFood -= food

func calcCost(coor: Vector2):
	var tile = GameManager.boardTileMap.get_child(0).get_cell_tile_data(coor).get_custom_data("terrainName")
	if tile == "grass":
		deductStats(1,1,1)
	elif tile == "sand":
		deductStats(2,2,1)
	elif tile == "water":
		deductStats(2,1,2)
	elif tile == "forest":
		deductStats(4,3,2)
