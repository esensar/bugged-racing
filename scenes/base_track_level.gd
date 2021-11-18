class_name BaseTrackLevel
extends Spatial

const camera = preload("res://player/camera.tscn")
onready var spawn_point = $PlayerSpawnLocation
var player_node: Node
var gui: Node

func _ready() -> void:
	player_node.global_transform = spawn_point.global_transform
	add_child(player_node)
	add_child(gui)
	var player_camera = camera.instance()
	player_camera.global_transform = spawn_point.global_transform
	player_camera.global_transform.origin = -spawn_point.global_transform.basis.z * 1000
	player_camera.follow_target_path = player_node.get_path()
	add_child(player_camera)

func spawn_player(player_node: Node, gui: Node) -> void:
	self.player_node = player_node
	self.gui = gui
