extends Node
class_name Item


enum Type {
	FOOD_BONUS,      # Restores GameManager.playerFood
	WATER_BONUS,     # Restores GameManager.playerWater
	STRENGTH_BONUS,  # Restores GameManager.playerStrength (New for CS3560)
	GOLD_BONUS,      # Reserved for trading
	TRADER           # Triggers trade event
}

var item_type: int
var amount: int
var repeating: bool
var collected_this_turn: bool = false

# Added to track where this item lives on the CS3560 grid
var grid_position: Vector2i 

func _init(type: int, amt: int, is_repeating: bool = false, pos: Vector2i = Vector2i.ZERO):
	item_type = type
	amount = amt
	repeating = is_repeating
	grid_position = pos

func get_label() -> String:
	match item_type:
		Type.FOOD_BONUS:     return "Food(+" + str(amount) + ")" + ("*" if repeating else "")
		Type.WATER_BONUS:    return "Water(+" + str(amount) + ")" + ("*" if repeating else "")
		Type.STRENGTH_BONUS: return "Strength(+" + str(amount) + ")" + ("*" if repeating else "")
		Type.GOLD_BONUS:     return "Gold(+" + str(amount) + ")" + ("*" if repeating else "")
		Type.TRADER:         return "Trader"
	return "?"

func can_collect() -> bool:
	if repeating:
		return not collected_this_turn
	return true

# ─────────────────────────────────────────────────────────────────────────────
# apply_effect()
# Hooks directly into CS3560's GameManager to modify player resources.
# Uses mini() to ensure we don't exceed the max resource limits.
# ─────────────────────────────────────────────────────────────────────────────
func apply_effect() -> void:
	if not can_collect():
		return
		
	match item_type:
		Type.FOOD_BONUS:
			GameManager.playerFood = mini(GameManager.playerMaxFood, GameManager.playerFood + amount)
		Type.WATER_BONUS:
			GameManager.playerWater = mini(GameManager.playerMaxWater, GameManager.playerWater + amount)
		Type.STRENGTH_BONUS:
			GameManager.playerStrength = mini(GameManager.playerMaxStrength, GameManager.playerStrength + amount)
		Type.GOLD_BONUS:
			pass # Implement if you add a gold variable to GameManager
		Type.TRADER:
			pass # Implement trader logic
			
	if repeating:
		collected_this_turn = true

func reset_turn():
	collected_this_turn = false
