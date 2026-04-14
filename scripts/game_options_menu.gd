extends Node2D

#difficulty 0=easy, 1=hard
var difficulty = 0

func _ready() -> void:
	$Title/CenterContainer/MainButtons2/EasyButton.disabled = true

func _on_easy_button_pressed() -> void:
	difficulty = 0
	$Title/CenterContainer/MainButtons2/EasyButton.disabled = true
	$Title/CenterContainer/MainButtons2/HardButton.disabled = false
	

func _on_hard_button_pressed() -> void:
	difficulty = 1
	$Title/CenterContainer/MainButtons2/EasyButton.disabled = false
	$Title/CenterContainer/MainButtons2/HardButton.disabled = true


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
