extends Panel

func _on_StartButton_pressed() -> void:
	get_tree().change_scene("res://scenes/menu/start_menu.tscn")

func _on_ExitButton_pressed() -> void:
	get_tree().quit()

func _on_SettingsButton_pressed() -> void:
	get_tree().change_scene("res://scenes/menu/settings_menu.tscn")
