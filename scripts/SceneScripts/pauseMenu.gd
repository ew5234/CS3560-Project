extends Control

#escape menu

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused == false:
			get_tree().paused = true
			self.show()
		elif get_tree().paused == true:
			get_tree().paused = false
			self.hide()
		

func _on_resume_pressed() -> void:
	get_tree().paused = false
	self.hide()

func _on_quit_pressed() -> void:
	get_tree().paused == false
	get_tree().quit()
