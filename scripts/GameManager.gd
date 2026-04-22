extends Node

const STATE_OFF := 0
const STATE_RUNNING := 1
const STATE_WON := 2
const STATE_LOST := 3

const PHASE_START := 0
const PHASE_DECISION := 1
const PHASE_ACTION := 2
const PHASE_END := 3

const ACTION_STAY := "stay"
const ACTION_MOVE := "move"
const DEBUG_PHASES := true

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
var selectedAction = {
	"type": ACTION_STAY,
	"direction": Vector2i.ZERO,
	"name": ACTION_STAY,
}

var lastActionResult = "none"
var boardTileMap: TileMapLayer = null
var playerPosition = Vector2i.ZERO
var playerMaxStrength = 12
var playerStrength = 12
var playerMaxWater = 10
var playerWater = 10
var playerMaxFood = 10
var playerFood = 10

var terrainCosts = {
	"grass": {"strength": 1, "water": 1, "food": 1},
	"sand": {"strength": 2, "water": 2, "food": 1},
	"forest": {"strength": 2, "water": 1, "food": 2},
	"water": {"strength": 4, "water": 3, "food": 2},
}

func _ready() -> void:
	gameState = STATE_RUNNING
	resetTurnState()
	resetPlayerState()

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

func registerBoard(tile_map_layer: TileMapLayer) -> void:
	boardTileMap = tile_map_layer
	resetPlayerState()

func resetPlayerState() -> void:
	playerPosition = Vector2i(0, maxi(0, y / 2))
	playerStrength = playerMaxStrength
	playerWater = playerMaxWater
	playerFood = playerMaxFood

func resetTurnState() -> void:
	selectedAction = {
		"type": ACTION_STAY,
		"direction": Vector2i.ZERO,
		"name": ACTION_STAY,
	}
	lastActionResult = "none"

func startPhase() -> void:
	turnNumber += 1
	resetTurnState()
	debugPrint("START", "Beginning turn %d." % turnNumber)
	gamePhase = PHASE_DECISION

func decisionPhase() -> void:
	# Placeholder decision until Brain logic is implemented.
	# For now the player prefers moving east and rests if that is not possible.
	selectedAction = choosePlaceholderAction()
	debugPrint("DECISION", "Selected action %s." % selectedAction["name"])
	gamePhase = PHASE_ACTION

func actionPhase() -> void:
	debugPrint("ACTION", "Resolving action %s from %s." % [selectedAction["name"], playerPosition])
	if selectedAction["type"] == ACTION_STAY:
		resolveStayAction()
		gamePhase = PHASE_END
		return

	if selectedAction["type"] == ACTION_MOVE:
		resolveMoveAction(selectedAction["direction"])

	gamePhase = PHASE_END

func endPhase() -> void:
	if playerPosition.x >= x - 1:
		gameState = STATE_WON
		debugPrint("END", "Player reached the east edge and won.")
		return

	if playerStrength <= 0 or playerWater <= 0 or playerFood <= 0:
		gameState = STATE_LOST
		debugPrint("END", "Player ran out of resources and lost.")
		return

	if gameState == STATE_RUNNING:
		debugPrint("END", "Turn finished with result %s." % lastActionResult)
		gamePhase = PHASE_START

func resolveStayAction() -> void:
	var restCosts = getRestCosts(playerPosition)
	playerStrength = mini(playerMaxStrength, playerStrength + 2)
	playerWater = maxi(0, playerWater - restCosts["water"])
	playerFood = maxi(0, playerFood - restCosts["food"])
	lastActionResult = ACTION_STAY

func resolveMoveAction(direction: Vector2i) -> void:
	var targetPosition = playerPosition + direction

	if not isPositionOnMap(targetPosition):
		lastActionResult = "rejected_out_of_bounds"
		return

	var moveCosts = getTerrainCosts(targetPosition)
	if not canPayCosts(moveCosts):
		lastActionResult = "rejected_not_enough_resources"
		return

	applyCosts(moveCosts)
	playerPosition = targetPosition
	lastActionResult = "moved"

func isPositionOnMap(position: Vector2i) -> bool:
	return position.x >= 0 and position.x < x and position.y >= 0 and position.y < y

func getTerrainCosts(position: Vector2i) -> Dictionary:
	return terrainCosts[getTerrainType(position)]

func getRestCosts(position: Vector2i) -> Dictionary:
	var terrainCost = getTerrainCosts(position)
	return {
		"water": maxi(1, ceili(terrainCost["water"] / 2.0)),
		"food": maxi(1, ceili(terrainCost["food"] / 2.0)),
	}

func getTerrainType(position: Vector2i) -> String:
	if boardTileMap == null:
		return "grass"

	var groundTileMap = boardTileMap.get_child(0)
	var atlasCoordinates = groundTileMap.get_cell_atlas_coords(position)

	if atlasCoordinates == Vector2i(10, 1):
		return "sand"
	if atlasCoordinates == Vector2i(10, 5):
		return "water"
	if atlasCoordinates == Vector2i(10, 9) or atlasCoordinates == Vector2i(12, 8):
		return "forest"

	return "grass"

func canPayCosts(costs: Dictionary) -> bool:
	return playerStrength > costs["strength"] and playerWater > costs["water"] and playerFood > costs["food"]

func applyCosts(costs: Dictionary) -> void:
	playerStrength -= costs["strength"]
	playerWater -= costs["water"]
	playerFood -= costs["food"]

func choosePlaceholderAction() -> Dictionary:
	var eastPosition = playerPosition + Vector2i.RIGHT
	if isPositionOnMap(eastPosition) and canPayCosts(getTerrainCosts(eastPosition)):
		return {
			"type": ACTION_MOVE,
			"direction": Vector2i.RIGHT,
			"name": "move_east",
		}

	return {
		"type": ACTION_STAY,
		"direction": Vector2i.ZERO,
		"name": ACTION_STAY,
	}

func debugPrint(phaseName: String, message: String) -> void:
	if not DEBUG_PHASES:
		return

	print(
		"[Turn %d][%s] %s Pos=%s Str=%d/%d Water=%d/%d Food=%d/%d Last=%s"
		% [
			turnNumber,
			phaseName,
			message,
			playerPosition,
			playerStrength,
			playerMaxStrength,
			playerWater,
			playerMaxWater,
			playerFood,
			playerMaxFood,
			lastActionResult,
		]
	)
