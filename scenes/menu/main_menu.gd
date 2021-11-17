extends Panel

func _ready() -> void:
	$MarginContainer/VSplitContainer/VSplitContainer/CenterContainer/VBoxContainer/StartButton.grab_focus()

func _on_StartButton_pressed() -> void:
	get_tree().change_scene("res://scenes/menu/start_menu.tscn")

func _on_ExitButton_pressed() -> void:
	get_tree().quit()

func _on_SettingsButton_pressed() -> void:
	get_tree().change_scene("res://scenes/menu/settings_menu.tscn")

func _on_AboutButton_pressed() -> void:
	get_tree().change_scene("res://scenes/menu/about.tscn")

func _on_GodotButton_pressed() -> void:
	OS.shell_open("https://godotengine.org")
