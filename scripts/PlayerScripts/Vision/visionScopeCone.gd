extends VisionScope

class_name VisionScopeCone

#Cone Scope
#     X
#   X X
# O X X
#   X X
#     X
func scope():
	#get coordinates of broad scope
	currentPosition = GameManager.playerPosition
	scopeCoors = [
		currentPosition, #currentposition
		Vector2(currentPosition.x+1, currentPosition.y), #currentPosition forward
		Vector2(currentPosition.x+1, currentPosition.y+1), #currentPosition diag above
		Vector2(currentPosition.x-1, currentPosition.y-1), #currentPosition diag below
		Vector2(currentPosition.x+2, currentPosition.y), #currentPosition forward +1
		Vector2(currentPosition.x+2, currentPosition.y+1), #currentPosition 2nd diag above
		Vector2(currentPosition.x+2, currentPosition.y-1), #currentPosition 2nd diag below
		Vector2(currentPosition.x+2, currentPosition.y+2), #currentPosition top right
		Vector2(currentPosition.x+2, currentPosition.y-2), #currentPosition bottom right
		]
	return scopeCoors
