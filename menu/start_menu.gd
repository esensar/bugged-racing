extends Panel

const BUGGY = preload("res://vehicles/buggy.tscn")
const BEETLE = preload("res://vehicles/beetlecar.tscn")
const BUGMOBILE = preload("res://vehicles/bugmobile.tscn")
const TEST_SCENE = preload("res://scenes/test_level.tscn")
const INFINITE_LOOP_SCENE = preload("res://scenes/infinite_loop_track_level.tscn")
const ROUNDING_ERROR = preload("res://scenes/rounding_error_track_level.tscn")
const SCARAB = preload("res://scenes/scarab_track_level.tscn")
const RACE_CONDITION = preload("res://scenes/race_condition_track_level.tscn")
const GUI_SCENE = preload("res://player/gui.tscn")

var vehicles = [BEETLE, BUGGY, BUGMOBILE]
var tracks = [INFINITE_LOOP_SCENE, ROUNDING_ERROR, RACE_CONDITION, SCARAB, TEST_SCENE]

# gdlint: ignore=max-line-length
onready var vehicle_selector = $MarginContainer/VSplitContainer/CenterContainer/VBoxContainer/VehicleSelector
# gdlint: ignore=max-line-length
onready var track_selector = $MarginContainer/VSplitContainer/CenterContainer/VBoxContainer/TrackSelector


func _ready() -> void:
	vehicle_selector.grab_focus()
	vehicle_selector.add_item("Beetlecar")
	vehicle_selector.add_item("Buggy")
	vehicle_selector.add_item("Bugmobile")

	track_selector.add_item("Infinite Loop")
	track_selector.add_item("Rounding Error")
	track_selector.add_item("Race Condition")
	track_selector.add_item("Scarab")
	track_selector.add_item("Testing grounds")


func _on_StartButton_pressed() -> void:
	if vehicle_selector.get_selected_id() < 0:
		return
	if track_selector.get_selected_id() < 0:
		return
	var vehicle = vehicles[vehicle_selector.get_selected_id()]
	var track = tracks[track_selector.get_selected_id()]
	_start_track_with_vehicle(track.instance(), vehicle.instance())


func _start_track_with_vehicle(track: Node, vehicle: Node) -> void:
	var gui = GUI_SCENE.instance()
	vehicle.connect("speed_updated", gui, "update_speed")
	vehicle.connect("rpm_updated", gui, "update_rpm")
	vehicle.connect("gear_updated", gui, "update_gear")
	track.call_deferred("spawn_player", vehicle, gui)
	get_tree().root.call_deferred("add_child", track)
	queue_free()


func _on_BackButton_pressed() -> void:
	get_tree().change_scene("res://menu/main_menu.tscn")
