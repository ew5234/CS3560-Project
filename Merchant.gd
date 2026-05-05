extends Node2D

@onready var gold_label = $GoldLabel
@onready var food_label = $FoodLabel
@onready var water_label = $WaterLabel
@onready var buy_food_button = $BuyButtonFood
@onready var buy_water_button = $BuyButtonWater

var player_gold = 20
var player_food = 0
var player_water = 0

var food_price = 5
var water_price = 3

func _ready():
	buy_food_button.pressed.connect(buy_food)
	buy_water_button.pressed.connect(buy_water)
	update_display()

func buy_food():
	if player_gold >= food_price:
		player_gold -= food_price
		player_food += 1
	else:
		print("Not enough gold for food!")
	update_display()

func buy_water():
	if player_gold >= water_price:
		player_gold -= water_price
		player_water += 1
	else:
		print("Not enough gold for water!")
	update_display()

func update_display():
	gold_label.text = "Gold: " + str(player_gold)
	food_label.text = "Food: " + str(player_food)
	water_label.text = "Water: " + str(player_water)
