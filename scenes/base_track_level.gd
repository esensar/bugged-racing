class_name BaseTrackLevel
extends Spatial

const CAMERA = preload("res://player/CAMERA.tscn")

var player_node: Node
var gui: Node

onready var spawn_point = $PlayerSpawnLocation
onready var track = $Track


func _ready() -> void:
	player_node.global_transform = spawn_point.global_transform
	add_child(player_node)
	add_child(gui)
	var player_camera = CAMERA.instance()
	player_camera.global_transform = spawn_point.global_transform
	player_camera.global_transform.origin -= spawn_point.global_transform.basis.z * 1000
	player_camera.follow_target_path = player_node.get_path()
	add_child(player_camera)


func spawn_player(player_node: Node, gui: Node) -> void:
	self.player_node = player_node
	self.gui = gui


func reset_player_to(node_to_reset_to: Node, player_node: BuggedVehicle) -> void:
	player_node.reset_transform = node_to_reset_to.global_transform
	player_node.reset_transform.origin += node_to_reset_to.global_transform.basis.y * 15


func _on_ResetArea_body_entered(body: Node) -> void:
	if body.get_groups().has("car"):
		reset_player_to(track.get_last_checkpoint(), body)
