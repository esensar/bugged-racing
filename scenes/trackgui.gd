extends MarginContainer

var best_time = -1
var leaderboards_data = {}

onready var time_value = $VBoxContainer/HBoxContainer/TimeValue
onready var best_time_value = $VBoxContainer/HBoxContainer/BestTimeValue
onready var wrong_way_label = $CenterContainer/WrongWayLabel
onready var leaderboards = $VBoxContainer/LeaderboardsLine
onready var leaderboards_list = $VBoxContainer/LeaderboardsLine/VBoxContainer/Leaderboards
onready var track_minimap = $VBoxContainer2/HBoxContainer/ViewportContainer/TrackRadar/TrackMinimap


func _ready() -> void:
	time_value.text = "NaN"
	best_time_value.text = "NaN"
	if MultiplayerController.is_online():
		leaderboards.visible = true
		MultiplayerController.connect("peers_updated", self, "_on_peers_updated")
	else:
		leaderboards.visible = false


func _on_time_updated(new_time: float) -> void:
	time_value.text = _format_time(new_time)


func _on_lap_complete(lap_time: float) -> void:
	if lap_time < best_time or best_time < 0:
		best_time = lap_time
		best_time_value.text = _format_time(best_time)
		if MultiplayerController.is_online():
			update_leaderboard_time(String(get_tree().get_network_unique_id()), lap_time)
			rpc("update_leaderboard_time", String(get_tree().get_network_unique_id()), lap_time)


func _on_wrong_way_detected() -> void:
	wrong_way_label.visible = true
	yield(get_tree().create_timer(3.0), "timeout")
	wrong_way_label.visible = false


func _format_time(time: float) -> String:
	var minute = floor(time / 1000.0 / 60.0)
	var second = floor((time / 1000.0) - minute * 60)
	var millisecond = time - minute * 60 * 1000 - second * 1000
	return "%02d:%02d.%03d" % [minute, second, millisecond]


remote func update_leaderboard_time(peer_id: String, lap_time: float):
	leaderboards_data[peer_id] = lap_time
	_refresh_leaderboard()


func _refresh_leaderboard():
	var leaderboards_sorted = []
	for peer in leaderboards_data:
		leaderboards_sorted.append([peer, leaderboards_data[peer]])

	leaderboards_sorted.sort_custom(self, "_leaderbords_comparison")

	for child in leaderboards_list.get_children():
		child.queue_free()

	for entry in leaderboards_sorted:
		var label = Label.new()
		var player_name = MultiplayerController.peers[int(float(entry[0]))].name
		label.text = "%s - %s" % [player_name, _format_time(entry[1])]

		leaderboards_list.add_child(label)


func _leaderbords_comparison(left: Array, right: Array) -> bool:
	return left[1] < right[1]


func set_curve(curve: Curve3D) -> void:
	track_minimap.set_curve(curve)


func on_player_position_updated(player_id: int, position: Transform) -> void:
	track_minimap.on_player_position_updated(player_id, position)


func _on_peers_updated() -> void:
	for peer in leaderboards_data.keys():
		if not MultiplayerController.peers.has(peer):
			leaderboards_data.erase(peer)

	_refresh_leaderboard()
