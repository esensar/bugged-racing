extends Panel


func _ready() -> void:
	# gdlint: ignore=max-line-length
	$MarginContainer/VSplitContainer/VSplitContainer/CenterContainer/VBoxContainer/SingleplayerButton.grab_focus()
	$MarginContainer/VSplitContainer/VBoxContainer/VersionLabel.text = (
		"Version: %s"
		% GlobalSettings.get_version_string()
	)


func _on_SingleplayerButton_pressed() -> void:
	get_tree().change_scene("res://menu/start_menu.tscn")


func _on_MultiplayerButton_pressed() -> void:
	get_tree().change_scene("res://menu/multiplayer_menu.tscn")


func _on_ExitButton_pressed() -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)


func _on_SettingsButton_pressed() -> void:
	get_tree().change_scene("res://menu/settings_menu.tscn")


func _on_AboutButton_pressed() -> void:
	get_tree().change_scene("res://menu/about.tscn")


func _on_GodotButton_pressed() -> void:
	OS.shell_open("https://godotengine.org")


func _on_BlenderButton_pressed() -> void:
	OS.shell_open("https://www.blender.org")


func _on_KritaButton_pressed() -> void:
	OS.shell_open("https://krita.org")


func _on_KenneyButton_pressed() -> void:
	OS.shell_open("https://kenney.nl")
