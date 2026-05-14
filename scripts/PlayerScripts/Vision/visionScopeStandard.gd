extends VisionScope

class_name VisionScopeStandard

#Standard Scope
# X
# X X
# O X X 
# X X
# X
func scope():
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
