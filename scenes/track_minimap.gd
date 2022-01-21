extends Node2D

export(Vector2) var size = Vector2(200, 200)
export(Texture) var player_icon

onready var scaling_helper = $ScalingHelper
onready var track_path = $ScalingHelper/TrackPath
onready var track_line = $ScalingHelper/TrackLine
onready var start_line = $ScalingHelper/TrackPath/StartLine
onready var players_container = $ScalingHelper/Players


func _ready() -> void:
	scaling_helper.position.x = size.x / 2
	scaling_helper.position.y = size.y / 2
	MultiplayerController.connect("peers_updated", self, "_on_peers_updated")


func set_curve(curve: Curve3D) -> void:
	var curve2d = Curve2D.new()
	var point_count = curve.get_point_count()
	for point in range(point_count):
		var point3d = curve.get_point_position(point)
		var point_in = curve.get_point_in(point)
		var point_out = curve.get_point_out(point)
		curve2d.add_point(
			Vector2(point3d.x, point3d.z),
			Vector2(point_in.x, point_in.z),
			Vector2(point_out.x, point_out.z)
		)

	var max_x = curve2d.get_baked_points()[0].x
	var max_y = curve2d.get_baked_points()[0].y
	var min_x = curve2d.get_baked_points()[0].x
	var min_y = curve2d.get_baked_points()[0].y
	for point in curve2d.get_baked_points():
		if point.x > max_x:
			max_x = point.x
		if point.x < min_x:
			min_x = point.x
		if point.y > max_y:
			max_y = point.y
		if point.y < min_y:
			min_y = point.y

	var center_x = (max_x + min_x) / 2
	var center_y = (max_y + min_y) / 2
	var width = max_x - min_x
	var height = max_y - min_y
	var max_dim = max(width, height)
	var scale_factor = size.x / (max_dim + track_line.width)
	var new_center_x = scaling_helper.position.x - (center_x * scale_factor)
	var new_center_y = scaling_helper.position.y - (center_y * scale_factor)
	scaling_helper.scale.x = scale_factor
	scaling_helper.scale.y = scale_factor
	scaling_helper.position.x = new_center_x
	scaling_helper.position.y = new_center_y
	track_path.curve = curve2d
	track_line.curve = curve2d
	start_line.offset = 0.01


func on_player_position_updated(player_id: int, position: Transform) -> void:
	var existing_node: Sprite = players_container.get_node_or_null(String(player_id))
	if existing_node == null:
		var player_color
		if MultiplayerController.is_online():
			player_color = MultiplayerController.peers[player_id].color
		else:
			player_color = Color(1, 1, 1)
		existing_node = Sprite.new()
		existing_node.name = String(player_id)
		existing_node.texture = player_icon
		existing_node.modulate = player_color
		players_container.add_child(existing_node)
	existing_node.position.x = position.origin.x
	existing_node.position.y = position.origin.z
	existing_node.rotation = position.basis.x.signed_angle_to(Vector3.LEFT, Vector3.UP)


func _on_peers_updated() -> void:
	for peer in MultiplayerController.peers:
		var existing_node: Sprite = players_container.get_node_or_null(String(peer))
		if existing_node != null:
			var player_color = MultiplayerController.peers[peer].color
			existing_node.modulate = player_color

	for child in players_container.get_children():
		if not MultiplayerController.peers.has(int(float(child.name))):
			child.queue_free()
