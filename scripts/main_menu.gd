extends Node2D

func _ready() -> void:
	pass
	
func _on_play_button_pressed() -> void:
	#change to size, difficulty, seed screen
	get_tree().change_scene_to_file("res://scenes/game_options_menu.tscn")

#Press settings button
func _on_settings_button_pressed() -> void:
	#hide main menu buttons, show settings menu
	$Camera2D/CanvasLayer/CenterContainer/MainButtons2.visible = false
	$Camera2D/CanvasLayer/CenterContainer/SettingsMenu.visible = true

#Press back button in settings menu
func _on_back_button_pressed() -> void:
	#hide settings options and show main menu buttons
	$Camera2D/CanvasLayer/CenterContainer/MainButtons2.visible = true
	$Camera2D/CanvasLayer/CenterContainer/SettingsMenu.visible = false	

#Press exit button
func _on_exit_button_pressed() -> void:
	#exit game
	get_tree().quit()
