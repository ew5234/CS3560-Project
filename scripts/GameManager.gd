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

# --- SIGNALS FOR CLICK-TO-MOVE ---
# Emitted when the decision phase needs the player to pick a tile.
# Listeners should highlight valid tiles and enable click input.
signal awaiting_player_input
# Emitted after the player clicks a valid tile (or stays).
# Carries the chosen tile coordinate.
signal player_input_received(tile_coord: Vector2i)

#difficulty automatically set to 0
#0=easy, 1=hard
var difficulty = 0

#null=random seed
var world_seed = null

#boardsize automatically set to 100x100
var x = 100
var y = 100

#gameState controls whether the game is running or not.
var gameState = STATE_OFF

#survival, aggressive
var playerBrain = "survival"

#standard, cautious, broad
var playerScope = "standard"

#gamePhase controls the flow of one turn.
var gamePhase = PHASE_START

#turnNumber tracks how many turns have started.
var turnNumber = 0

#selectedAction is temporary turn data shared between DECISION and ACTION.
var selectedAction = {
	"type": ACTION_STAY,
	"direction": Vector2i.ZERO,
	"name": ACTION_STAY,
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
var active_items_dictionary = {}

var path

var target_position: Vector2
var speed: float
var direction

var terrainCost = TerrainCost.new()

var terrainCosts = {
	"grass": {"strength": 1, "water": 1, "food": 1},
	"sand": {"strength": 2, "water": 2, "food": 1},
	"forest": {"strength": 2, "water": 1, "food": 2},
	"water": {"strength": 4, "water": 3, "food": 2},
}

# Set this to true to let the player click tiles, false for AI brain control.
var player_controlled := true

# The tile the player clicked during the decision phase.
var _chosen_tile := Vector2i.ZERO

func runPhase() -> void:
	while gameState == STATE_RUNNING:
		startPhase()
		await get_tree().create_timer(0.5).timeout
		decisionPhase()
		# Wait for the decision phase to finish (player click or brain).
		await player_input_received
		await get_tree().create_timer(0.2).timeout
		actionPhase()
		await get_tree().create_timer(0.5).timeout
		endPhase()
		await get_tree().create_timer(0.5).timeout

func registerBoard(tile_map_layer: TileMapLayer) -> void:
	boardTileMap = tile_map_layer
	gameState = STATE_RUNNING

func registerPlayer(playerNode: CharacterBody2D) -> void:
	player = playerNode
	resetPlayerState()

func resetPlayerState() -> void:
	player.position = boardTileMap.map_to_local(Vector2i(1, y / 2))
	playerPosition = Vector2i(1, y / 2)
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
	if player_controlled:
		# Tell the gameboard to show valid tiles and listen for clicks.
		debugPrint("DECISION", "Waiting for player to click a tile...")
		awaiting_player_input.emit()
		# The phase pauses here. gameboard.gd will call
		# submit_player_choice() when the player clicks a valid tile,
		# which emits player_input_received and resumes the loop.
	else:
		# Original AI brain logic.
		path = brain.getDecision(playerBrain, playerScope, boardTileMap)
		_finish_decision_with_path(path)

# Called by gameboard.gd when the player clicks a valid tile.
func submit_player_choice(tile_coord: Vector2i) -> void:
	_chosen_tile = tile_coord
	if tile_coord == playerPosition:
		selectedAction = {
			"type": ACTION_STAY,
			"direction": Vector2i.ZERO,
			"name": ACTION_STAY,
		}
		path = null
	else:
		var dir = tile_coord - playerPosition
		selectedAction = {
			"type": ACTION_MOVE,
			"direction": dir,
			"name": "move_%s" % _direction_name(dir),
		}
		path = [tile_coord]
	debugPrint("DECISION", "Player chose %s → action %s." % [tile_coord, selectedAction["name"]])
	player_input_received.emit(tile_coord)

func _finish_decision_with_path(p) -> void:
	path = p
	if path and path.size() > 0:
		var dest = path[-1]
		selectedAction = {
			"type": ACTION_MOVE,
			"direction": Vector2i(dest) - playerPosition,
			"name": "move_path",
		}
	else:
		selectedAction = {
			"type": ACTION_STAY,
			"direction": Vector2i.ZERO,
			"name": ACTION_STAY,
		}
	player_input_received.emit(playerPosition)

func actionPhase() -> void:
	if path and path.size() > 0:
		for i in path:
			# Smooth tween to each tile instead of teleporting.
			var world_pos = boardTileMap.map_to_local(Vector2i(i))
			var tween = player.create_tween()
			tween.tween_property(player, "position", world_pos, 0.15)
			await tween.finished
			playerPosition = Vector2i(i)
			terrainCost.calcCost(playerPosition)
	else:
		# Staying — recover some resources.
		resolveStayAction()
	gamePhase = PHASE_END

func endPhase() -> void:
	# --- 1. ITEM COLLECTION LOGIC ---
	if active_items_dictionary.has(playerPosition):
		var item = active_items_dictionary[playerPosition]
		item.apply_effect()
		if not item.repeating:
			active_items_dictionary.erase(playerPosition)
			if boardTileMap != null:
				var itemTileMap = boardTileMap.get_child(2)
				itemTileMap.erase_cell(playerPosition)

	# --- 2. WIN/LOSS CHECKS ---
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

func resolveMoveAction(dir: Vector2i) -> void:
	var targetPosition = playerPosition + dir
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
	var tc = getTerrainCosts(position)
	return {
		"water": maxi(1, ceili(tc["water"] / 2.0)),
		"food": maxi(1, ceili(tc["food"] / 2.0)),
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

# Returns the valid tiles the player can move to (adjacent + current for stay).
func get_valid_move_tiles() -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	var directions = [
		Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT,
		Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1),
	]
	for dir in directions:
		var target = playerPosition + dir
		if isPositionOnMap(target) and canPayCosts(getTerrainCosts(target)):
			tiles.append(target)
	# Include current tile (stay option).
	tiles.append(playerPosition)
	return tiles

func _direction_name(dir: Vector2i) -> String:
	if dir == Vector2i.RIGHT: return "east"
	if dir == Vector2i.LEFT: return "west"
	if dir == Vector2i.UP: return "north"
	if dir == Vector2i.DOWN: return "south"
	if dir == Vector2i(1, -1): return "northeast"
	if dir == Vector2i(1, 1): return "southeast"
	if dir == Vector2i(-1, -1): return "northwest"
	if dir == Vector2i(-1, 1): return "southwest"
	return "unknown"

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
