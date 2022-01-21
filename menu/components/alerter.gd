extends Node


func show_simple_alert(text: String, title: String = "Alert") -> void:
	var dialog = AcceptDialog.new()
	dialog.dialog_text = text
	dialog.window_title = title
	dialog.connect("modal_closed", dialog, "queue_free")
	var scene_tree = Engine.get_main_loop()
	scene_tree.current_scene.add_child(dialog)
	dialog.popup_centered()


func create_simple_alert(text: String, title: String = "Alert") -> AcceptDialog:
	var dialog = AcceptDialog.new()
	dialog.dialog_text = text
	dialog.window_title = title
	dialog.connect("modal_closed", dialog, "queue_free")
	return dialog
