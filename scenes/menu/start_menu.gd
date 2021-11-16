extends Panel

const buggy = preload("res://vehicles/buggy.tscn")
const beetle = preload("res://vehicles/beetlecar.tscn")
const bugmobile = preload("res://vehicles/bugmobile.tscn")
const test_scene = preload("res://scenes/test_level.tscn")
const gui_scene = preload("res://player/gui.tscn")

func _ready() -> void:
	$MarginContainer/VSplitContainer/CenterContainer/VBoxContainer/BeetleButton.grab_focus()

func _on_BuggyButton_pressed() -> void:
	_start_with_vehicle(buggy.instance())

func _on_BeetleButton_pressed() -> void:
	_start_with_vehicle(beetle.instance())

func _on_BugmobileButton_pressed() -> void:
	_start_with_vehicle(bugmobile.instance())

func _start_with_vehicle(vehicle: Node) -> void:
	var gui = gui_scene.instance()
	var scene = test_scene.instance()
	vehicle.connect("speed_updated", gui, "update_speed")
	vehicle.connect("rpm_updated", gui, "update_rpm")
	vehicle.connect("gear_updated", gui, "update_gear")
	scene.call_deferred("spawn_player", vehicle, gui)
	get_tree().root.call_deferred("add_child", scene)
	queue_free()

func _on_BackButton_pressed() -> void:
	get_tree().change_scene("res://scenes/menu/main_menu.tscn")
