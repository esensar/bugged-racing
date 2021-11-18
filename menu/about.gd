extends Panel


func _on_BackButton_pressed() -> void:
	get_tree().change_scene("res://menu/main_menu.tscn")


func _on_link_meta_clicked(meta) -> void:
	OS.shell_open(meta)
