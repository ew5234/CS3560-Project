extends Node

const _STATE_OFF := 0
const _STATE_RUNNING := 1
const _STATE_WON := 2
const _STATE_LOST := 3

const _PHASE_START := 0
const _PHASE_DECISION := 1
const _PHASE_ACTION := 2
const _PHASE_END := 3

const _ACTION_STAY := "stay"
const _ACTION_MOVE := "move"
const _DEBUG_PHASES := true

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
var gameState = _STATE_OFF

#survival, aggressive, capitalist
var playerBrain = "aggressive"

#standard, cautious, broad, cone
var playerScope = "standard"

#gamePhase controls the flow of one turn.
#START 0: prepare the turn and hand control to the decision logic.
#DECISION 1: ask the player/brain what action to take this turn.
#ACTION 2: apply the chosen move or rest action and spend or recover resources.
#END 3: collect items, trade with traders, check win/loss, then advance to the next turn.
var gamePhase = _PHASE_START

#turnNumber tracks how many turns have started.
var turnNumber = 0

#selectedAction is temporary turn data shared between DECISION and ACTION.
#It is a placeholder until Brain and Player are connected.
var selectedAction = {
	"type": _ACTION_STAY,
	"direction": Vector2i.ZERO,
	"name": _ACTION_STAY,
}

var lastActionResult = "none"
var boardTileMap: TileMapLayer = null
var player: CharacterBody2D = null
var brain = Brain.new()
var playerPosition = Vector2i.ZERO
var playerMaxStrength = 50
var playerStrength = 10
var playerMaxWater = 25
var playerWater = 10
var playerMaxFood = 50
var playerFood = 10
var playerMaxHealth = 50
var playerHealth = 10
var playerGold = 0
var active_items_dictionary = {}

var path
var traderMenu

var target_position: Vector2
var speed: float
var direction

var terrainCost = TerrainCost.new()
var item = Item.new()
var tree = get_tree()
#var player = Player.new()

var terrainCosts = {
	"grass": {"strength": 1, "water": 1, "food": 1, "health": 0},
	"sand": {"strength": 2, "water": 2, "food": 1, "health": 0},
	"forest": {"strength": 2, "water": 1, "food": 2, "health": 0},
	"water": {"strength": 4, "water": 3, "food": 2, "health": 0},
	"swamp": {"strength": 4, "water": 3, "food": 2, "health": 1},
}
"""
func _ready() -> void:
	gameState = STATE_RUNNING
	resetTurnState()
	resetPlayerState()
"""
#while loop goes through the phases
#timeouts are there so the game doesnt immediately finish
func runPhase() -> void:
	while gameState == _STATE_RUNNING:
		startPhase()
		await get_tree().create_timer(0.5).timeout 
		decisionPhase()
		await get_tree().create_timer(0.5).timeout 
		actionPhase()
		await get_tree().create_timer(0.5).timeout 
		endPhase()
		await get_tree().create_timer(0.5).timeout 

func registerBoard(tile_map_layer: TileMapLayer) -> void:
	boardTileMap = tile_map_layer
	gameState = _STATE_RUNNING
	traderMenu = preload("res://scenes/merchant.tscn")
	tree = get_tree()
	
func registerPlayer(playerNode: CharacterBody2D) -> void:
	player = playerNode
	resetPlayerState()

func resetPlayerState() -> void:
	#actual player position
	player.position =  boardTileMap.map_to_local(Vector2i(1, y/2))
	#for the math 
	playerPosition = Vector2i(1, y/2)
	playerStrength = playerMaxStrength
	playerWater = playerMaxWater
	playerFood = playerMaxFood
	playerHealth = playerMaxHealth
	playerGold = 0
		
func resetTurnState() -> void:
	selectedAction = {
		"type": _ACTION_STAY,
		"direction": Vector2i.ZERO,
		"name": _ACTION_STAY,
	}
	lastActionResult = "none"

func startPhase() -> void:
	turnNumber += 1
	resetTurnState()
	debugPrint("START", "Beginning turn %d." % turnNumber)
	gamePhase = _PHASE_DECISION

func decisionPhase() -> void:
	# Placeholder decision until Brain logic is implemented.
	# For now the player prefers moving east and rests if that is not possible.

	path = brain.getDecision(playerBrain, playerScope, boardTileMap)
	gamePhase = _PHASE_ACTION

func actionPhase() -> void:
	if path:
		#for every coordinate, update the player position on board
		for i in path:
			player.position = boardTileMap.map_to_local(i)
			playerPosition = i
			terrainCost.calcCost(playerPosition)
			item.itemTileChecker($CharacterBody2D/Camera2D/CanvasLayer/Merchant)
		await get_tree().create_timer(1.0).timeout
	gamePhase = _PHASE_END


func endPhase() -> void:
	# ---  WIN/LOSS CHECKS ---
	if playerPosition.x >= x - 1:
		gameState = _STATE_WON
		debugPrint("END", "Player reached the east edge and won.")
		return

	if playerStrength <= 0 or playerWater <= 0 or playerFood <= 0:
		gameState = _STATE_LOST
		debugPrint("END", "Player ran out of resources and lost.")
		return

	if gameState == _STATE_RUNNING:
		debugPrint("END", "Turn finished with result %s." % lastActionResult)
		gamePhase = _PHASE_START

func resolveStayAction() -> void:
	var restCosts = getRestCosts(playerPosition)
	playerStrength = mini(playerMaxStrength, playerStrength + 2)
	playerWater = maxi(0, playerWater - restCosts["water"])
	playerFood = maxi(0, playerFood - restCosts["food"])
	lastActionResult = _ACTION_STAY

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
	if atlasCoordinates == Vector2i(10,13):
		return "swamp"

	return "grass"

func canPayCosts(costs: Dictionary) -> bool:
	return playerStrength > costs["strength"] and playerWater > costs["water"] and playerFood > costs["food"]

func applyCosts(costs: Dictionary) -> void:
	playerStrength -= costs["strength"]
	playerWater -= costs["water"]
	playerFood -= costs["food"]
	playerHealth -= costs["health"]

func debugPrint(phaseName: String, message: String) -> void:
	if not _DEBUG_PHASES:
		return

	print(
		"[Turn %d][%s] %s Pos=%s Hth=%d/%d Str=%d/%d Water=%d/%d Food=%d/%d Last=%s"
		% [
			turnNumber,
			phaseName,
			message,
			playerPosition,
			playerHealth,
			playerMaxHealth,
			playerStrength,
			playerMaxStrength,
			playerWater,
			playerMaxWater,
			playerFood,
			playerMaxFood,
			lastActionResult,
		]
	)
