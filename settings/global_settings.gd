extends Node

var auto_clutch: bool = true
var automatic_transmission: bool = true
var steering_sensitivity = 1.0
var return_speed = 2.0
var throttle_sensitivity = 1.0
var brake_sensitivity = 1.0
var steering_deadzone_inner = 0.0
var steering_deadzone_outer = 0.0

var selected_camera: int = 0
var multiplayer_name: String = "Player"

var camera_fov = 70
var camera_move_forward = 0
var camera_move_backward = 0
var camera_move_right = 0
var camera_move_left = 0
var camera_move_up = 0
var camera_move_down = 0

var _config: Dictionary


func _ready() -> void:
	_config = read_json_file("res://info.json")
	get_tree().set_auto_accept_quit(false)
	var stored_config = read_json_file("user://settings.json")
	if stored_config.has("hidden"):
		selected_camera = stored_config["hidden"].get("selected_camera", 0)

	if stored_config.has("gameplay"):
		multiplayer_name = stored_config["gameplay"].get("multiplayer_name", "Player")

	if stored_config.has("controls"):
		auto_clutch = stored_config["controls"].get("auto_clutch", true)
		automatic_transmission = stored_config["controls"].get("automatic_transmission", true)
		steering_sensitivity = stored_config["controls"].get("steering_sensitivity", 1.0)
		return_speed = stored_config["controls"].get("return_speed", 2.0)
		throttle_sensitivity = stored_config["controls"].get("throttle_sensitivity", 1.0)
		brake_sensitivity = stored_config["controls"].get("brake_sensitivity", 1.0)
		steering_deadzone_inner = stored_config["controls"].get("steering_deadzone_inner", 1.0)
		steering_deadzone_outer = stored_config["controls"].get("steering_deadzone_outer", 1.0)

	if stored_config.has("camera"):
		camera_fov = stored_config["camera"].get("fov", 70)
		camera_move_forward = stored_config["camera"].get("camera_move_forward", 0)
		camera_move_backward = stored_config["camera"].get("camera_move_backward", 0)
		camera_move_left = stored_config["camera"].get("camera_move_left", 0)
		camera_move_right = stored_config["camera"].get("camera_move_right", 0)
		camera_move_up = stored_config["camera"].get("camera_move_up", 0)
		camera_move_down = stored_config["camera"].get("camera_move_down", 0)


func read_json_file(file_path: String) -> Dictionary:
	var file = File.new()
	if not file.file_exists(file_path):
		print("File not found: %s" % file_path)
		return Dictionary()
	file.open(file_path, File.READ)
	var content_as_text = file.get_as_text()
	var content_as_dictionary = parse_json(content_as_text)
	return content_as_dictionary


func save_json_file(file_path: String, contents: Dictionary) -> void:
	var file = File.new()
	file.open(file_path, File.WRITE)
	file.store_line(to_json(contents))
	file.close()


func get_version_string() -> String:
	var version = _config["version"]
	var major = version["major"]
	var minor = version["minor"]
	var patch = version["patch"]
	return "%d.%d.%d" % [major, minor, patch]


func save_settings() -> void:
	save_json_file("user://settings.json", to_dictionary())


func to_dictionary() -> Dictionary:
	return {
		"hidden": {"selected_camera": selected_camera},
		"gameplay": {"multiplayer_name": multiplayer_name},
		"controls":
		{
			"auto_clutch": auto_clutch,
			"automatic_transmission": automatic_transmission,
			"steering_sensitivity": steering_sensitivity,
			"return_speed": return_speed,
			"throttle_sensitivity": throttle_sensitivity,
			"brake_sensitivity": brake_sensitivity,
			"steering_deadzone_inner": steering_deadzone_inner,
			"steering_deadzone_outer": steering_deadzone_outer,
		},
		"camera":
		{
			"fov": camera_fov,
			"move_forward": camera_move_forward,
			"move_backward": camera_move_backward,
			"move_right": camera_move_right,
			"move_left": camera_move_left,
			"move_up": camera_move_up,
			"move_down": camera_move_down
		}
	}


# Handle quit
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_settings()
		get_tree().quit()  # default behavior
