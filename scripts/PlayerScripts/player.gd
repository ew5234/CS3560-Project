extends Node

class_name Player

var player: CharacterBody2D
var brain: Brain
#ar vision: Vision

var playerPosition = Vector2i.ZERO
var playerStrength = GameManager.playerMaxStrength
var playerWater = GameManager.playerMaxWater
var playerFood = GameManager.playerMaxFood


#var position = player.global_position
func registerPlayer(playerNode: CharacterBody2D) -> void:
	player = playerNode
	resetPlayerState()

func resetPlayerState() -> void:
	#actual player position
	player.position =  GameManager.boardTileMap.map_to_local(Vector2i(1, GameManager.y/2))
	#for the math 
	playerPosition = Vector2i(1, GameManager.y/2)
	playerStrength = GameManager.playerMaxStrength
	playerWater = GameManager.playerMaxWater
	playerFood = GameManager.playerMaxFood
