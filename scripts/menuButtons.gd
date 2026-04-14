extends Node2D

#Press play button
func _on_play_button_pressed() -> void:
	#change to size, difficulty, seed screen
	get_tree().change_scene_to_file("res://scenes/game_options_menu.tscn")

#Press settings button
func _on_settings_button_pressed() -> void:
	#hide play, settings, and exit button, show settings menu
	$CenterContainer/MainButtons2.visible = false
	$CenterContainer/SettingsMenu.visible = true

#Press exit button
func _on_exit_button_pressed() -> void:
	#exit game
	get_tree().quit()
	
#add back button


#add settings sliders
