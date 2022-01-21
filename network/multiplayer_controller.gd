extends Node

signal peers_updated

const GUI_SCENE = "res://player/gui.tscn"

var enet_peer = NetworkedMultiplayerENet.new()
var peers = {}
var version_checked = []

var current_track: Node = null
var current_track_path: String
var current_vehicle: String

var colors = [
	Color.blue, Color.yellow, Color.green, Color.violet, Color.brown, Color.cyan, Color.orange
]


class PeerInfo:
	var id: int
	var vehicle: String
	var name: String
	var spawned: bool
	var color: Color

	static func new_peer(
		new_id: int,
		new_vehicle: String = "",
		new_name: String = "",
		new_spawned: bool = false,
		new_color: Color = Color(1, 1, 1)
	) -> PeerInfo:
		var new_instance = PeerInfo.new()
		new_instance.id = new_id
		new_instance.vehicle = new_vehicle
		new_instance.name = new_name
		new_instance.spawned = new_spawned
		new_instance.color = new_color
		return new_instance

	func to_array() -> Array:
		return [id, vehicle, name, spawned, color]

	func from_array(data: Array) -> void:
		self.id = data[0]
		self.vehicle = data[1]
		self.name = data[2]
		self.spawned = data[3]
		self.color = data[4]


func _ready():
	enet_peer.connect("peer_connected", self, "_peer_connected")
	enet_peer.connect("peer_disconnected", self, "_peer_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	enet_peer.connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("connection_failed", self, "_connection_failed")


func is_online():
	var network_peer = get_tree().get_network_peer()
	if network_peer == null:
		return false
	return network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED


func create_server(port, track, vehicle):
	current_track_path = track
	current_track = load(track).instance()
	current_vehicle = vehicle
	enet_peer.create_server(port, 2)
	get_tree().network_peer = enet_peer
	peers[1] = PeerInfo.new_peer(
		1, vehicle, GlobalSettings.multiplayer_name, true, get_next_color(1)
	)
	create_player(1, vehicle)
	get_tree().root.call_deferred("add_child", current_track)
	emit_signal("peers_updated")


func create_client(address, port, vehicle):
	current_vehicle = vehicle
	enet_peer.create_client(address, port)
	get_tree().network_peer = enet_peer
	peers[get_tree().get_network_unique_id()] = PeerInfo.new_peer(
		get_tree().get_network_unique_id(),
		vehicle,
		GlobalSettings.multiplayer_name,
		true,
		get_next_color(1)
	)
	emit_signal("peers_updated")


func _peer_connected(peer_id):
	peers[peer_id] = PeerInfo.new_peer(peer_id, "", "", false, get_next_color(peer_id))
	rpc_id(
		peer_id,
		"add_player",
		get_tree().get_network_unique_id(),
		peers[get_tree().get_network_unique_id()].to_array()
	)
	emit_signal("peers_updated")
	if get_tree().get_network_unique_id() == 1:
		if version_checked.has(peer_id):
			rpc_id(peer_id, "select_track", current_track_path)


func _peer_disconnected(peer_id):
	peers.erase(peer_id)
	destroy_player(peer_id)


func _connected_to_server():
	rpc_id(
		1, "check_version", get_tree().get_network_unique_id(), GlobalSettings.get_version_string()
	)


func _connection_failed():
	current_track = null
	get_tree().network_peer = null
	_server_disconnected()


func _server_disconnected():
	current_track = null
	peers.clear()
	get_tree().network_peer = null
	get_tree().root.get_child(get_tree().root.get_child_count() - 1).queue_free()
	var alert = Alerter.create_simple_alert("Connection to the host has been lost.")
	get_tree().root.add_child(alert)
	alert.connect("popup_hide", self, "_on_disconnect_confirmed")
	alert.popup_centered()


func _on_disconnect_confirmed():
	get_tree().change_scene("res://menu/main_menu.tscn")


func create_player(peer_id, vehicle_path):
	var vehicle = load(vehicle_path).instance()
	var gui
	if peer_id == get_tree().get_network_unique_id():
		gui = load(GUI_SCENE).instance()
		vehicle.connect("speed_updated", gui, "update_speed")
		vehicle.connect("rpm_updated", gui, "update_rpm")
		vehicle.connect("gear_updated", gui, "update_gear")
	vehicle.set_network_master(peer_id)
	vehicle.name = String(peer_id)
	if peer_id == get_tree().get_network_unique_id():
		current_track.call_deferred("spawn_player", vehicle, gui)
	else:
		current_track.call_deferred("spawn_vehicle", vehicle)


func destroy_player(peer_id):
	current_track.remove_player(String(peer_id))


func quit():
	enet_peer.close_connection()
	current_track = null
	get_tree().network_peer = null
	peers.clear()


remote func add_player(peer_id, peer_info: Array):
	if peers[peer_id] == null:
		peers[peer_id] = PeerInfo.new_peer(peer_id, "", "", false, get_next_color(peer_id))

	if peers[peer_id].spawned == false:
		peers[peer_id].from_array(peer_info)

		# Check for duplicate names on server side and update colors
		if get_tree().get_network_unique_id() == 1:
			var names = []
			for peer in peers:
				if peer != peer_id:
					names.append(peers[peer].name)

			if names.has(peers[peer_id].name):
				peers[peer_id].name = peers[peer_id].name + ("(%s)" % peer_id)
				rpc("update_name", peer_id, peers[peer_id].name)

			peers[peer_id].color = get_next_color(peer_id)
			rpc("update_color", peer_id, peers[peer_id].color)

		if current_track != null:
			peers[peer_id].spawned = true
			create_player(peer_id, peers[peer_id].vehicle)
		else:
			peers[peer_id].spawned = false
		emit_signal("peers_updated")


remote func check_version(peer_id: int, version: String) -> void:
	if version != GlobalSettings.get_version_string():
		enet_peer.disconnect_peer(peer_id)
		return

	version_checked.append(peer_id)
	rpc_id(peer_id, "select_track", current_track_path)


remote func select_track(track_path):
	current_track = load(track_path).instance()
	get_tree().root.call_deferred("add_child", current_track)
	create_player(get_tree().get_network_unique_id(), current_vehicle)
	for peer in peers:
		if peers[peer].spawned == false:
			peers[peer].spawned = true
			create_player(peer, peers[peer].vehicle)
			emit_signal("peers_updated")


remote func update_name(peer_id, name: String):
	peers[peer_id].name = name
	emit_signal("peers_updated")


remote func update_color(peer_id, color: Color):
	peers[peer_id].color = color
	emit_signal("peers_updated")


func get_next_color(peer_id: int) -> Color:
	if peers.size() >= colors.size():
		return Color(peer_id)
	else:
		return colors[peers.size()]
