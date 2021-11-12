extends Panel

const buggy = preload("res://vehicles/buggy.tscn")
const beetle = preload("res://vehicles/beetlecar.tscn")
const test_scene = preload("res://scenes/test_level.tscn")

func _on_BuggyButton_pressed() -> void:
	_start_with_vehicle(buggy.instance())

func _on_BeetleButton_pressed() -> void:
	_start_with_vehicle(beetle.instance())

func _start_with_vehicle(vehicle: Node) -> void:
	var scene = test_scene.instance()
	scene.call_deferred("spawn_player", vehicle)
	get_tree().root.call_deferred("add_child", scene)
	queue_free()

func _on_BackButton_pressed() -> void:
	get_tree().change_scene("res://scenes/menu/main_menu.tscn")
