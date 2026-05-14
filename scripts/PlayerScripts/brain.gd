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

func algorithm(brainType, visionCoors, tileMap: TileMapLayer):
	var coor
	if brainType == "survival":
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
	elif brainType == "aggressive":
		if criticalEmergency() == true:
			pass
	elif brainType == "capitalist":
		coor = vision.closestGold(visionCoors, tileMap)
		if coor == null:
			coor = vision.closestMerchant()
		if coor == null:
			coor = vision.goStraight(visionCoors, tileMap)
	print(coor)
	return coor

func calculatePath(destCoor: Vector2):
	var xDiff = destCoor.x - GameManager.playerPosition.x
	var yDiff = destCoor.y - GameManager.playerPosition.y
	var coorPath = []
	var coorHolder = GameManager.playerPosition
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
		if not coorPath.has(coorHolder):
			coorPath.append(coorHolder)
	return coorPath

func getDecision(brainType, scopeType, tileMap):
	if scopeType == "standard":
		visionScope = VisionScope.new()
	elif scopeType == "cautious":
		visionScope = VisionScopeCautious.new()
	elif scopeType == "broad":
		visionScope = VisionScopeBroad.new()
	elif scopeType == "cone":
		visionScope = VisionScopeCone.new()
	scopeCoor = visionScope.scope()
	var destinationCoor = algorithm(brainType, scopeCoor, tileMap.get_child(2))
	if destinationCoor != null:
		var destinationPath = calculatePath(destinationCoor)
		return destinationPath
	else:
		return destinationCoor
