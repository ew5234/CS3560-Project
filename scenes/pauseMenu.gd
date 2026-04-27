extends Control

class_name PauseMenu

var menuPath: Control
func resume():
	get_tree().paused = false
	hide()
	
func pause():
	get_tree().resume = true
	show()
	
func testEsc(escPath: Control):
	menuPath = escPath
	if Input.is_action_just_pressed("Escape") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("Escape") and get_tree().paused:
		resume()
