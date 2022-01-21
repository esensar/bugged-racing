extends Node

var auto_clutch: bool = false
var automatic_transmission: bool = true
var steering_sensitivity = 1.0
var return_speed = 2.0
var throttle_sensitivity = 1.0
var brake_sensitivity = 1.0
var steering_deadzone_inner = 0.0
var steering_deadzone_outer = 0.0

var selected_camera: int = 0
var multiplayer_name: String = "Player"

var _config: Dictionary


func _ready() -> void:
	_config = read_json_file("res://info.json")


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
