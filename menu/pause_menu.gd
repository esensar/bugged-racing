extends PopupDialog


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused:
			hide()
			get_tree().paused = false
		else:
			show()
			get_tree().paused = true


func _on_ContinueButton_pressed():
	hide()
	get_tree().paused = false


func _on_ExitButton_pressed():
	get_tree().paused = false
	if MultiplayerController.is_online():
		MultiplayerController.quit()
	get_tree().change_scene("res://menu/main_menu.tscn")
	get_tree().root.get_child(get_tree().root.get_child_count() - 1).queue_free()
