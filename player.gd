extends Node

# --- VARIABLES ---
var current_level: int = 1
var inventory = {"antidote": 0, "food": 0}
var gold: int = 50
var health: int = 100
var water: int = 100
var is_poisoned: bool = false
var base_water_drain: int = 5

# This variable holds one of your TerrainType resources
var current_terrain: TerrainType

# --- DYNAMIC SPAWN LOGIC ---
func get_random_terrain_name() -> String:
	var table = []
	var plains_weight = max(1, 11 - current_level)
	
	for i in plains_weight: table.append("Plains")
	for i in 5: table.append("Desert")
	for i in 5: table.append("Mountain")
	for i in 4: table.append("Swamp")
	for i in 6: table.append("Forest")
	
	table.shuffle()
	return table.pick_random()

# --- TRADER & ANTIDOTE SYSTEM ---
func interact_with_trader():
	if not current_terrain or current_terrain.name != "Plains":
		print("No trader here.")
		return
		
	var base_antidote_cost = 20
	var final_cost = int(base_antidote_cost * current_terrain.trader_generosity)
	
	if gold >= final_cost:
		gold -= final_cost
		inventory["antidote"] += 1
		print("Bought 1 antidote! Gold left: ", gold)

func use_antidote():
	if inventory["antidote"] > 0:
		inventory["antidote"] -= 1
		is_poisoned = false
		print("Poison cured!")

# --- CORE TURN LOGIC ---
func process_turn():
	if not current_terrain: return

	# 1. Desert Dehydration
	if current_terrain.name == "Desert":
		water -= int(base_water_drain * current_terrain.water_mult)
	
	# 2. Swamp Poisoning
	if current_terrain.name == "Swamp":
		is_poisoned = true 
	
	if is_poisoned:
		health -= 5
		print("Poisoned! Health: ", health)

	# 3. Forest/Mountain Gathering
	if current_terrain.name == "Forest" and randf() < current_terrain.food_chance:
		inventory["food"] += 1
		health -= 2 # Forest damage
		
	if current_terrain.name == "Mountain" and randf() < current_terrain.water_chance:
		water += 10
