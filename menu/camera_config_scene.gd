extends Spatial

const CAMERA_CONTROLLER = preload("res://player/cameras/camera_controller.gd")

var vehicle_path = "res://vehicles/buggy.tscn"
var camera_controller: CameraController
var vehicle: Node = null


func _ready() -> void:
	reset()


func _process(_delta: float) -> void:
	if Input.is_action_just_released("next_camera"):
		camera_controller.next_camera()

	camera_controller.update_camera(
		(
			Input.get_action_strength("turn_camera_right")
			- Input.get_action_strength("turn_camera_left")
		),
		Input.get_action_strength("turn_camera_up") - Input.get_action_strength("turn_camera_down"),
		Input.is_action_pressed("look_backwards")
	)


func change_vehicle_to(new_vehicle_path: String) -> void:
	vehicle_path = new_vehicle_path
	reset()


func reset() -> void:
	if vehicle != null:
		vehicle.queue_free()
		camera_controller.clear()

	vehicle = load(vehicle_path).instance()
	add_child(vehicle)
	camera_controller = CAMERA_CONTROLLER.new()
	camera_controller.attach_cameras_to(vehicle)
