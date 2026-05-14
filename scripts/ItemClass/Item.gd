extends Node

class_name Item

#value of each item
var goldValue = 1
var waterValue = 5
var foodValue = 5
var strengthValue = 5


func itemTileChecker(traderNode: Node):
	#grabs tiledata in itemTiles TileMapLayer
	var tileData = GameManager.boardTileMap.get_child(2).get_cell_tile_data(GameManager.playerPosition)
	
	#if no data in itemTiles, grab tiledata in tradeTiles TileMapLayer
	if tileData == null:
		tileData = GameManager.boardTileMap.get_child(3).get_cell_tile_data(GameManager.playerPosition)

	#if tileData is not null
	if tileData:
		var itemTileMap
		#item is gold
		if tileData.get_custom_data("itemType") == "gold":
			GameManager.playerGold +=goldValue
			itemTileMap = GameManager.boardTileMap.get_child(2)
			itemTileMap.erase_cell(GameManager.playerPosition)
			
		#item is food
		elif tileData.get_custom_data("itemType") == "food":
			GameManager.playerFood +=foodValue
			GameManager.playerStrength +=strengthValue
			itemTileMap = GameManager.boardTileMap.get_child(2)
			itemTileMap.erase_cell(GameManager.playerPosition)
			
		#item is water
		elif tileData.get_custom_data("itemType") == "water":
			GameManager.playerWater +=waterValue
			GameManager.playerStrength +=strengthValue
			itemTileMap = GameManager.boardTileMap.get_child(2)
			itemTileMap.erase_cell(GameManager.playerPosition)
		
		#trader is normal
		elif tileData.get_custom_data("traderType") == "normal":
			if GameManager.playerFood < GameManager.playerMaxFood/2:
				if GameManager.playerGold >= 5:
					GameManager.playerFood += foodValue
					GameManager.playerStrength += strengthValue
					print("Bought Food")
			elif GameManager.playerWater < GameManager.playerMaxWater/2:
				if GameManager.playerGold >= 5:
					GameManager.playerWater += waterValue
					GameManager.playerStrength += strengthValue
					print("Bought Water")
			else:
				print("No Money")
			
			#wip menu
			"""
			var trader = GameManager.traderMenu.instantiate()
			add_child(trader)
			trader.visible = true
			print(GameManager.tree)
			GameManager.tree.paused = true
			var current = GameManager.tree.current_scene
			GameManager.tree.root.remove_child(current)
			
			var next = load("res://scenes/merchant.tscn").instantiate()
			GameManager.tree.root.add_child(next)
			GameManager.tree.current_scene = next
			GameManager.tree.paused = true
			"""
			
			itemTileMap = GameManager.boardTileMap.get_child(3)
			itemTileMap.erase_cell(GameManager.playerPosition)
