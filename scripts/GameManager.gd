extends Node

const PHASE_START := 0
const PHASE_DECISION := 1
const PHASE_ACTION := 2
const PHASE_END := 3

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

#gamePhase controls the flow of one turn.
#START 0: prepare the turn and hand control to the decision logic.
#DECISION 1: ask the player/brain what action to take this turn.
#ACTION 2: apply the chosen move or rest action and spend or recover resources.
#END 3: collect items, trade with traders, check win/loss, then advance to the next turn.
var gamePhase = PHASE_START

func _ready() -> void:
	gameState = 1

func startPhase() -> void:
	gamePhase = PHASE_DECISION

func decisionPhase() -> void:
	pass

func actionPhase() -> void:
	pass

func endPhase() -> void:
	pass
