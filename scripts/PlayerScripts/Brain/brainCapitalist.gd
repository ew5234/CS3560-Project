extends Brain

class_name BrainCapitalist

#Capitalist Brain Algorithm
#1 - Check if any gold in scope
#2 - If not, check for a mercahtn in scope
#3 - If not, go east
func algorithm(visionCoors, tileMap: TileMapLayer):
	coor = visionScope.closestGold(visionCoors, tileMap)
	if coor == null:
		coor = visionScope.closestMerchant()
	if coor == null:
		coor = visionScope.goStraight(visionCoors, tileMap)
	return coor
