extends Node

const STATE_OFF := 0
const STATE_RUNNING := 1
const STATE_WON := 2
const STATE_LOST := 3

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

#gameState controls whether the game is running or not.
#OFF: game loop is not running.
#RUNNING: the game advances through turn phases.
#WON: the player reached the goal.
#LOST: the player can no longer continue.
var gameState = STATE_OFF

#gamePhase controls the flow of one turn.
#START 0: prepare the turn and hand control to the decision logic.
#DECISION 1: ask the player/brain what action to take this turn.
#ACTION 2: apply the chosen move or rest action and spend or recover resources.
#END 3: collect items, trade with traders, check win/loss, then advance to the next turn.
var gamePhase = PHASE_START

#turnNumber tracks how many turns have started.
var turnNumber = 0

#selectedAction is temporary turn data shared between DECISION and ACTION.
#It is a placeholder until Brain and Player are connected.
var selectedAction = ""

func _ready() -> void:
	gameState = STATE_RUNNING

func runPhase() -> void:
	if gameState != STATE_RUNNING:
		return

	match gamePhase:
		PHASE_START:
			startPhase()
		PHASE_DECISION:
			decisionPhase()
		PHASE_ACTION:
			actionPhase()
		PHASE_END:
			endPhase()

func startPhase() -> void:
	turnNumber += 1
	selectedAction = ""
	gamePhase = PHASE_DECISION

func decisionPhase() -> void:
	# Placeholder action until Brain logic is implemented.
	selectedAction = "stay"
	gamePhase = PHASE_ACTION

func actionPhase() -> void:
	# Placeholder action resolution until Player movement exists.
	# Invalid moves will also resolve here later without leaving the turn flow.
	gamePhase = PHASE_END

func endPhase() -> void:
	# Win/loss checks will live here once Player and map position are available.
	if gameState == STATE_RUNNING:
		gamePhase = PHASE_START
