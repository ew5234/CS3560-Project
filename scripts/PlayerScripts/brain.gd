extends Node

class_name Brain

var vision = Vision.new()
var visionScope = VisionScope.new()

var scopeCoor

#survival, aggressive
#var brainType = "survival"

func thirstCheck():
	if GameManager.playerWater < GameManager.playerMaxWater/2:
		return true
	else:
		return false
	
func hungerCheck():
	if GameManager.playerFood < GameManager.playerMaxFood/2:
		return true
	else:
		return false
	
func fatigueCheck():
	if GameManager.playerStrength < GameManager.playerMaxStrength/2:
		return true
	else:
		return false

func criticalEmergency():
	return true

func algorithm(brainType, visionScope, tileMap: TileMapLayer):
	var coor
	if brainType == "survival":
		if thirstCheck() == true:
			coor = vision.closestWater(visionScope, tileMap)
		elif hungerCheck() == true:
			coor = vision.closestFood(visionScope, tileMap)
		elif fatigueCheck() == true:
			coor = vision.stay()
		else:
			print("gostraight")
			coor = vision.goStraight(visionScope, tileMap)
	elif brainType == "aggressive":
		if criticalEmergency() == true:
			pass
	return coor

func calculatePath(destCoor: Vector2):
	var xDiff = destCoor.x - GameManager.player.position.x
	var yDiff = destCoor.y - GameManager.player.position.y
	var coorPath = []
	var coorHolder = GameManager.player.position
	var calculating = true
	while calculating == true:
		if xDiff > 0 and yDiff > 0:
			coorHolder = Vector2(coorHolder.x+1, coorHolder.y+1)
			xDiff -=1
			yDiff -=1
		elif xDiff > 0 and yDiff < 0:
			coorHolder = Vector2(coorHolder.x+1, coorHolder.y-1)
			xDiff -=1
			yDiff +=1
		elif xDiff > 0 and yDiff == 0:
			coorHolder = Vector2(coorHolder.x+1, coorHolder.y)
			xDiff -=1
		elif xDiff == 0 and yDiff != 0:
			if yDiff > 0:
				coorHolder = Vector2(coorHolder.x, coorHolder.y+1)
				yDiff -=1
			else:
				coorHolder = Vector2(coorHolder.x, coorHolder.y-1)
				yDiff +=1
		else:
			calculating = false
		coorPath.append(coorHolder)
	return coorPath

func getDecision(brainType, scopeType, tileMap):
	if scopeType == "standard":
		scopeCoor = visionScope.standardScope()
	elif scopeType == "cautious":
		scopeCoor = visionScope.cautiousScope()
	elif scopeType == "broad":
		scopeCoor = visionScope.broadScope()
	var destinationCoor = algorithm(brainType, scopeCoor, tileMap.get_child(2))
	if destinationCoor != null:
		
		var destinationPath = calculatePath(destinationCoor)
		print(destinationPath)
		return destinationPath
	else:
		print(destinationCoor)
		return destinationCoor
