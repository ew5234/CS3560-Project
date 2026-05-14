extends Brain

class_name BrainSurvival

#Capitalist Brain Algorithm
#1 - Check if any thirst is at half max
#		if yes, find closest water
#2 - If not thirsty or no closest water, check if any hunger is at half max
#		if yes, find closest food
#3 - If not hungry or no closest food, check if any strength is at half max
#		if yes, rest
#4 - If none, then go straight
func algorithm(visionCoors, tileMap: TileMapLayer):
	if thirstCheck() == true:
		print("thirstCheck")
		coor = visionScope.closestWater(visionCoors, tileMap)		
	if hungerCheck() == true and coor == null:
		print("hungerCheck")
		coor = visionScope.closestFood(visionCoors, tileMap)
	if fatigueCheck() == true and coor == null:
		print("fatigueCheck")
		coor = visionScope.stay()
	if coor == null:
		print("goStraight")
		coor = visionScope.goStraight(visionCoors, tileMap)
	return coor
