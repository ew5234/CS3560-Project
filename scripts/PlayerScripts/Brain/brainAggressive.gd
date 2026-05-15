extends Brain

class_name BrainAggressive

#Aggressive Brain Algorithm
#1 - Check if any stats are less than 10, if so, find the item
#2 - If not, then go east
func algorithm(visionCoors, tileMap: TileMapLayer):
	var critical = criticalEmergency()
	if critical != null:
		if critical == "water":
			coor = visionScope.closestWater(visionCoors, tileMap)
		if critical == "food":
			coor = visionScope.closestFood(visionCoors, tileMap)
		if critical == "strength":
			coor = visionScope.stay()
	else:
		coor = visionScope.goStraight(visionCoors, tileMap)
	return coor
