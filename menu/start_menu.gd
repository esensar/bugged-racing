extends Panel

const buggy = preload("res://vehicles/buggy.tscn")
const beetle = preload("res://vehicles/beetlecar.tscn")
const bugmobile = preload("res://vehicles/bugmobile.tscn")
const test_scene = preload("res://scenes/test_level.tscn")
const gui_scene = preload("res://player/gui.tscn")

onready var vehicle_selector = $MarginContainer/VSplitContainer/CenterContainer/VBoxContainer/VehicleSelector
onready var track_selector = $MarginContainer/VSplitContainer/CenterContainer/VBoxContainer/TrackSelector

var vehicles = [beetle, buggy, bugmobile]
var tracks = [test_scene]

func _ready() -> void:
	vehicle_selector.grab_focus()
	vehicle_selector.add_item("Beetlecar")
	vehicle_selector.add_item("Buggy")
	vehicle_selector.add_item("Bugmobile")

	track_selector.add_item("Test track")

func _on_StartButton_pressed() -> void:
	print(vehicle_selector.get_selected_id())
	print(track_selector.get_selected_id())
	if vehicle_selector.get_selected_id() < 0:
		return
	if track_selector.get_selected_id() < 0:
		return
	var vehicle = vehicles[vehicle_selector.get_selected_id()]
	var track = tracks[track_selector.get_selected_id()]
	_start_track_with_vehicle(track.instance(), vehicle.instance())

func _start_track_with_vehicle(track: Node, vehicle: Node) -> void:
	var gui = gui_scene.instance()
	vehicle.connect("speed_updated", gui, "update_speed")
	vehicle.connect("rpm_updated", gui, "update_rpm")
	vehicle.connect("gear_updated", gui, "update_gear")
	track.call_deferred("spawn_player", vehicle, gui)
	get_tree().root.call_deferred("add_child", track)
	queue_free()

func _on_BackButton_pressed() -> void:
	get_tree().change_scene("res://menu/main_menu.tscn")
