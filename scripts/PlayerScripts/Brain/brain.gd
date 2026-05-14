extends Node

class_name Brain

var visionScope = VisionScope.new()

var coor
var scopeCoor
var brain

#if thirst is less than half of max thirst, find water in scope
func thirstCheck():
	if GameManager.playerWater < GameManager.playerMaxWater/2:
		return true
	else:
		return false

#if hunger is less than half of max hunger, find hunger in scope
func hungerCheck():
	if GameManager.playerFood < GameManager.playerMaxFood/2:
		return true
	else:
		return false

#if fatigue is less than half of max fatigue, find fatigue in scope
func fatigueCheck():
	if GameManager.playerStrength < GameManager.playerMaxStrength/2:
		return true
	else:
		return false

#Check if any stats are under 10. If so, return which stat
func criticalEmergency():
	if GameManager.playerWater < 10:
		return "water"
	elif GameManager.playerFood < 10:
		return "food"
	elif GameManager.playerStrength < 10:
		return "strength"
	else:
		return null

func algorithm(visionCoors, tileMap: TileMapLayer):
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

func getScopeType(scopeType):
	if scopeType == "standard":
		visionScope = VisionScope.new()
	elif scopeType == "cautious":
		visionScope = VisionScopeCautious.new()
	elif scopeType == "broad":
		visionScope = VisionScopeBroad.new()
	elif scopeType == "cone":
		visionScope = VisionScopeCone.new()

func getDecision(brainType, scopeType, tileMap):
	#getScopeType(scopeType)
	visionScope = visionScope.getScope(scopeType)
	scopeCoor = visionScope.scope()
	brain = getBrain(brainType)
	var destinationCoor = brain.algorithm(scopeCoor, tileMap.get_child(2))
	print(destinationCoor)
	if destinationCoor != null:
		var destinationPath = calculatePath(destinationCoor)
		return destinationPath
	else:
		return destinationCoor
		
func getBrain(brainType):
	if brainType == "survival":
		return BrainSurvival.new()
	elif brainType == "aggressive":
		return BrainAggressive.new()
	elif brainType == "capitalist":
		return BrainCapitalist.new()
