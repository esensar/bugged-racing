class_name BaseTrackLevel
extends Spatial

const CAMERA_CONTROLLER = preload("res://player/cameras/camera_controller.gd")
const PLAYER_CONTROLLER = preload("res://player/vehicle_controller.gd")

var player_node: BuggedVehicle
var gui: Node
var camera_controller: CameraController
var player_controller: PlayerVehicleController
var ready = false

onready var track = $Track


func _ready() -> void:
	if player_node != null:
		_spawn_in_player()
	ready = true


func spawn_player(player_node: BuggedVehicle, gui: Node) -> void:
	self.player_node = player_node
	self.gui = gui
	if ready:
		_spawn_in_player()


func spawn_vehicle(vehicle: BuggedVehicle) -> void:
	reset_player_to(track.get_furthest_checkpoint(), vehicle)
	add_child(vehicle)


func remove_player(peer_id: String) -> void:
	get_node(peer_id).queue_free()


func reset_player_to(node_to_reset_to: Node, player_node: BuggedVehicle) -> void:
	player_node.reset_transform = node_to_reset_to.global_transform.looking_at(
		node_to_reset_to.global_transform.translated(
			node_to_reset_to.global_transform.basis.z
		).origin,
		node_to_reset_to.global_transform.basis.y
	)
	player_node.reset_transform.origin += node_to_reset_to.global_transform.basis.y * 2


func _spawn_in_player():
	reset_player_to(track.get_furthest_checkpoint(), player_node)
	add_child(player_node)
	add_child(gui)
	player_controller = PLAYER_CONTROLLER.new()
	player_controller.vehicle_path = player_node.get_path()
	player_node.add_child(player_controller)
	camera_controller = CAMERA_CONTROLLER.new()
	camera_controller.attach_cameras_to(player_node)


func _process(_delta: float) -> void:
	if Input.is_action_just_released("reset_vehicle"):
		reset_player_to(track.get_furthest_checkpoint(), player_node)

	if Input.is_action_just_released("next_camera"):
		camera_controller.next_camera()


func _on_ResetArea_body_entered(body: Node) -> void:
	if body.get_groups().has("car"):
		reset_player_to(track.get_furthest_checkpoint(), body)
