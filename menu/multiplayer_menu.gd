extends Panel

const BUGGY = "res://vehicles/buggy.tscn"
const BEETLE = "res://vehicles/beetlecar.tscn"
const BUGMOBILE = "res://vehicles/bugmobile.tscn"
const TEST_SCENE = "res://scenes/test_level.tscn"
const INFINITE_LOOP_SCENE = "res://scenes/infinite_loop_track_level.tscn"
const ROUNDING_ERROR = "res://scenes/rounding_error_track_level.tscn"
const SCARAB = "res://scenes/scarab_track_level.tscn"
const RACE_CONDITION = "res://scenes/race_condition_track_level.tscn"
const GUI_SCENE = "res://player/gui.tscn"

var vehicles = [BEETLE, BUGGY, BUGMOBILE]
var tracks = [INFINITE_LOOP_SCENE, ROUNDING_ERROR, RACE_CONDITION, SCARAB, TEST_SCENE]

# gdlint: ignore=max-line-length
onready var vehicle_selector = $MarginContainer/VSplitContainer/CenterContainer/GridContainer/VehicleSelector
# gdlint: ignore=max-line-length
onready var track_selector = $MarginContainer/VSplitContainer/CenterContainer/GridContainer/TrackSelector
onready var ip = $MarginContainer/VSplitContainer/CenterContainer/GridContainer/IpBox
onready var port = $MarginContainer/VSplitContainer/CenterContainer/GridContainer/PortBox


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


func _on_JoinButton_pressed() -> void:
	if vehicle_selector.get_selected_id() < 0:
		return
	if track_selector.get_selected_id() < 0:
		return
	var vehicle = vehicles[vehicle_selector.get_selected_id()]
	MultiplayerController.create_client(ip.text, int(float(port.text)), vehicle)
	queue_free()


func _on_HostButton_pressed() -> void:
	if vehicle_selector.get_selected_id() < 0:
		return
	if track_selector.get_selected_id() < 0:
		return
	var vehicle = vehicles[vehicle_selector.get_selected_id()]
	var track = tracks[track_selector.get_selected_id()]
	MultiplayerController.create_server(int(float(port.text)), track, vehicle)
	queue_free()


func _on_BackButton_pressed() -> void:
	get_tree().change_scene("res://menu/main_menu.tscn")
