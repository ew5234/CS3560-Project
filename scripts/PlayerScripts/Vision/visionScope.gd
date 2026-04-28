extends Vision

class_name VisionScope

#Vision Types
#standard
#cautious
#broad
var visionType = "standard"

var currentPosition
var scopeCoors = []

# X
# X X
# O X X 
# X X
# X
func standardScope():
	#get coordinates of standard scope
	currentPosition = GameManager.playerPosition
	scopeCoors = [
		currentPosition, #currentposition
		Vector2(currentPosition.x, currentPosition.y+1), #currentPosition above
		Vector2(currentPosition.x, currentPosition.y-1), #currentPosition below
		Vector2(currentPosition.x+1, currentPosition.y), #currentPosition forward
		Vector2(currentPosition.x+1, currentPosition.y+1), #currentPosition diag above
		Vector2(currentPosition.x+1, currentPosition.y-1), #currentPosition diag below
		Vector2(currentPosition.x, currentPosition.y+2), #currentPosition above +1
		Vector2(currentPosition.x, currentPosition.y-2), #currentPosition below +1
		Vector2(currentPosition.x+2, currentPosition.y), #currentPosition forward +1
		]
	return scopeCoors

# X X
# X X
# O X 
# X X
# X X
func cautiousScope():
	#get coordinates of cautious scope
	currentPosition = GameManager.playerPosition
	scopeCoors = [
		currentPosition, #currentposition
		Vector2(currentPosition.x, currentPosition.y+1), #currentPosition above
		Vector2(currentPosition.x, currentPosition.y-1), #currentPosition below
		Vector2(currentPosition.x+1, currentPosition.y), #currentPosition forward
		Vector2(currentPosition.x+1, currentPosition.y+1), #currentPosition diag above
		Vector2(currentPosition.x-1, currentPosition.y-1), #currentPosition diag below
		Vector2(currentPosition.x, currentPosition.y+2), #currentPosition above +1
		Vector2(currentPosition.x, currentPosition.y-2), #currentPosition below +1
		Vector2(currentPosition.x+1, currentPosition.y+2), #currentPosition top right
		Vector2(currentPosition.x+1, currentPosition.y-2), #currentPosition bottom right
		]
	return scopeCoors

# X X X
# O X X
# X X X
func broadScope():
	#get coordinates of broad scope
	currentPosition = GameManager.playerPosition
	scopeCoors = [
		currentPosition, #currentposition
		Vector2(currentPosition.x, currentPosition.y+1), #currentPosition above
		Vector2(currentPosition.x, currentPosition.y-1), #currentPosition below
		Vector2(currentPosition.x+1, currentPosition.y), #currentPosition forward
		Vector2(currentPosition.x+1, currentPosition.y+1), #currentPosition diag above
		Vector2(currentPosition.x-1, currentPosition.y-1), #currentPosition diag below
		Vector2(currentPosition.x+2, currentPosition.y), #currentPosition forward +1
		Vector2(currentPosition.x+2, currentPosition.y+1), #currentPosition top right
		Vector2(currentPosition.x+2, currentPosition.y-1), #currentPosition bottom right
		]
	return scopeCoors

func getScope():
	if visionType == "standard":
		return standardScope()
	elif visionType == "cautious":
		return cautiousScope()
	else:
		return broadScope()
