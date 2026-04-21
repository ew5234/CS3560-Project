extends Node2D

var inputChecker = InputChecker.new()

#Automatically set game to easy and update gamemanager difficulty
func _ready() -> void:
	$MenuRow1/EasyHardButtons/ButtonPosition/EasyButton.disabled = true
	GameManager.difficulty = 0

#Press Easy Button
func _on_easy_button_pressed() -> void:
	#Set gamemanager difficulty to easy
	#Keep easy button pressed, unpress hard button
	GameManager.difficulty = 0
	$MenuRow1/EasyHardButtons/ButtonPosition/EasyButton.disabled = true
	$MenuRow1/EasyHardButtons/ButtonPosition/HardButton.disabled = false
	
#Press Hard Button
func _on_hard_button_pressed() -> void:
	#Set gamemanager difficulty to hard
	#Keep hard button pressed, unpress easy button
	GameManager.difficulty = 1
	$MenuRow1/EasyHardButtons/ButtonPosition/EasyButton.disabled = false
	$MenuRow1/EasyHardButtons/ButtonPosition/HardButton.disabled = true

#Press Back Button
func _on_back_button_pressed() -> void:
	#Returns to main menu scene
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

#Seed Box
func _on_enter_seed_box_text_changed(seedInput: String) -> void:
	#Checks if only digits are typed
	if inputChecker.digitChecker(seedInput, $MenuRow1/SeedBoxPosition/EnterSeedBox) == true:
		#If true, save to gamemanager seed
		GameManager.seed = int(seedInput)

#X Box
func _on_enter_x_text_changed(xInput: String) -> void:
	#Checks if only digits are typed
	if inputChecker.digitChecker(xInput, $MenuRow2/MapSizeBox/SetYourMapSize/EnterX) == true:
		#If true, save to gamemanager x
		GameManager.x = int(xInput) + 1

#Y Box
func _on_enter_y_text_changed(yInput: String) -> void:
	#Checks if only digits are typed
	if inputChecker.digitChecker(yInput, $MenuRow2/MapSizeBox/SetYourMapSize/EnterY) == true:
		#If true, save to gamemanager y
		GameManager.y = int(yInput) + 1

#Press Play Button
func _on_play_button_pressed() -> void:
	#Move to gameboard scene
	get_tree().change_scene_to_file("res://scenes/gameboard.tscn")
