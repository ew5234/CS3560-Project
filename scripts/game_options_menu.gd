extends Node2D

var regex = RegEx.new()

#difficulty 0=easy, 1=hard
var difficulty = 0

func _ready() -> void:
	$EasyHardButtons/HBoxContainer/EasyButton.disabled = true
	#compile regex to detect numbers
	regex.compile("^[0-9]+$")

#Press Easy Button
func _on_easy_button_pressed() -> void:
	difficulty = 0
	$EasyHardButtons/HBoxContainer/EasyButton.disabled = true
	$EasyHardButtons/HBoxContainer/HardButton.disabled = false
	
#Press Hard Button
func _on_hard_button_pressed() -> void:
	difficulty = 1
	$EasyHardButtons/HBoxContainer/EasyButton.disabled = false
	$EasyHardButtons/HBoxContainer/HardButton.disabled = true

#Press Back Button
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

#Seed Box
func _on_line_edit_text_submitted(new_text: String) -> void:
	#Check for only digits in text.
	var result = regex.search(new_text)
	if result:
		var seed = new_text
	else:
		$LineEdit.clear()
