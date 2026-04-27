extends Node

class_name Vision

func closestFood(scopeCoors, tileMap: TileMapLayer):
	#search for closest food within visionScope
	var closestFoodCoord
	var closestDistance = INF
	for i in scopeCoors:
		var data = tileMap.get_cell_tile_data(i)
		if data:
			var scopeCoorDistance = GameManager.player.position.distance_squared_to(i)
			if data.get_custom_data("itemType") == "food" and closestDistance > scopeCoorDistance:
				closestDistance = scopeCoorDistance
				closestFoodCoord = i
	return closestFoodCoord

func closestWater(scopeCoors, tileMap: TileMapLayer):
	#search for closest water within visionScope
	var closestWaterCoord
	var closestDistance = INF
	for i in scopeCoors:
		var data = tileMap.get_cell_tile_data(i)
		if data:
			var scopeCoorDistance = GameManager.player.position.distance_squared_to(i)
			if data.get_custom_data("itemType") == "food" and closestDistance > scopeCoorDistance:
				closestDistance = scopeCoorDistance
				closestWaterCoord = i
	return closestWaterCoord
	
func closestGold(scopeCoors, tileMap: TileMapLayer):
	#search for closest gold within visionScope
	var closestGoldCoord
	var closestDistance = INF
	for i in scopeCoors:
		var data = tileMap.get_cell_tile_data(i)
		if data:
			var scopeCoorDistance = GameManager.player.position.distance_squared_to(i)
			if data.get_custom_data("itemType") == "food" and closestDistance > scopeCoorDistance:
				closestDistance = scopeCoorDistance
				closestGoldCoord = i
	return closestGoldCoord

func closestTrader(scopeCoors, tileMap: TileMapLayer):
	#search for closest trader within visionScope
	pass
	
func stay():
	return GameManager.playerPosition

func goStraight(scopeCoors, tileMap: TileMapLayer):
	var farthestX = -INF
	var farthestY = INF
	for i in scopeCoors:
		print(i)
		if i.x > farthestX and i.y < farthestY:
			farthestX = i.x
			farthestY = i.y
	return Vector2(farthestX, farthestY)
