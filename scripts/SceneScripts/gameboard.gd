extends Node2D

@export var noise_height_texture : NoiseTexture2D
var noise : Noise

var pauseMenu = PauseMenu.new()
var generateWorld = GenerateWorld.new()

# --- CLICK-TO-MOVE STATE ---
var _awaiting_click := false
var _valid_tiles: Array[Vector2i] = []
var _highlight_nodes: Array[Node2D] = []

func _ready() -> void:
	if GameManager.world_seed == null:
		print("isNull")
		randomize()
		noise_height_texture.noise.seed = randi()
	else:
		noise_height_texture.noise.seed = int(GameManager.world_seed)
	noise = noise_height_texture.noise
	generateWorld.generateWorld($board/TileMapLayer, noise, GameManager.x, GameManager.y)
	GameManager.registerBoard($board/TileMapLayer)
	GameManager.registerPlayer($CharacterBody2D)

	GameManager.awaiting_player_input.connect(_on_awaiting_player_input)
	GameManager.runPhase()

func _on_awaiting_player_input() -> void:
	_valid_tiles = GameManager.get_valid_move_tiles()
	print("[CLICK] Valid tiles: ", _valid_tiles)
	_show_highlights()
	_awaiting_click = true

func _input(event: InputEvent) -> void:
	if not _awaiting_click:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Use the ground tilemap (child 0) for coordinate conversion,
		# since that's where tiles are actually placed.
		var ground_tilemap: TileMapLayer = GameManager.boardTileMap.get_child(0)
		var global_click = get_global_mouse_position()
		var local_click = ground_tilemap.to_local(global_click)
		var clicked_tile = ground_tilemap.local_to_map(local_click)

		print("[CLICK] Global: ", global_click, " | Local: ", local_click, " | Tile: ", clicked_tile)
		print("[CLICK] Is tile in valid list? ", clicked_tile in _valid_tiles)

		if clicked_tile in _valid_tiles:
			_awaiting_click = false
			_clear_highlights()
			GameManager.submit_player_choice(clicked_tile)

# ---- TILE HIGHLIGHTING (white outline + tinted fill) ----

func _show_highlights() -> void:
	_clear_highlights()
	var ground_tilemap: TileMapLayer = GameManager.boardTileMap.get_child(0)
	# Get the tile size from the tileset itself.
	var tile_size_vec: Vector2i = ground_tilemap.tile_set.tile_size
	var ts := Vector2(tile_size_vec)
	var half := ts / 2.0

	for tile in _valid_tiles:
		var world_pos = ground_tilemap.to_global(ground_tilemap.map_to_local(tile))
		var is_stay = (tile == GameManager.playerPosition)
		var container = Node2D.new()
		container.position = world_pos

		# Semi-transparent fill.
		var rect = ColorRect.new()
		rect.size = ts
		rect.position = -half
		if is_stay:
			rect.color = Color(1.0, 1.0, 0.3, 0.25)
		else:
			rect.color = Color(0.3, 1.0, 0.3, 0.25)
		container.add_child(rect)

		# White outline using Line2D.
		var outline = Line2D.new()
		outline.width = 1.0
		outline.default_color = Color.WHITE
		outline.closed = true
		outline.points = PackedVector2Array([
			Vector2(-half.x, -half.y),
			Vector2( half.x, -half.y),
			Vector2( half.x,  half.y),
			Vector2(-half.x,  half.y),
		])
		container.add_child(outline)

		add_child(container)
		_highlight_nodes.append(container)

func _clear_highlights() -> void:
	for node in _highlight_nodes:
		if is_instance_valid(node):
			node.queue_free()
	_highlight_nodes.clear()
