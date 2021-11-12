extends Spatial

const camera = preload("res://player/camera.tscn")
onready var spawn_point = $PlayerSpawnLocation
var player_node: Node

func _ready() -> void:
	player_node.global_transform = spawn_point.global_transform
	add_child(player_node)
	var player_camera = camera.instance()
	player_camera.follow_target_path = player_node.get_path()
	add_child(player_camera)

func spawn_player(player_node: Node) -> void:
	self.player_node = player_node
