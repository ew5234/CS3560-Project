extends Node

#difficulty automatically set to 0
#0=easy, 1=hard
var difficulty = 0

#null=random seed
var seed = null

#boardsize automatically set to 100x100
var x = 100
var y = 100

#gameState controls whether the game is running or not
#0 = off
#1 = on
var gameState = 0

func _ready() -> void:
	gameState = 1

func startPhase() -> void:
	pass

func decisionPhase() -> void:
	pass

func actionPhase() -> void:
	pass

func endPhase() -> void:
	pass
