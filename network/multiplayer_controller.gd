extends Node

const GUI_SCENE = "res://player/gui.tscn"

var enet_peer = NetworkedMultiplayerENet.new()
var peers = {}
var peers_vehicles = {}

var current_track: Node = null
var current_track_path: String
var current_vehicle: String
var connected = false


func _ready():
	enet_peer.connect("peer_connected", self, "_peer_connected")
	enet_peer.connect("peer_disconnected", self, "_peer_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	enet_peer.connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("connection_failed", self, "_connection_failed")


func create_server(port, track, vehicle):
	current_track_path = track
	current_track = load(track).instance()
	current_vehicle = vehicle
	enet_peer.create_server(port, 2)
	get_tree().network_peer = enet_peer
	peers[1] = true
	create_player(1, vehicle)
	get_tree().root.call_deferred("add_child", current_track)
	connected = true


func create_client(address, port, vehicle):
	current_vehicle = vehicle
	peers[get_tree().get_network_unique_id()] = true
	enet_peer.create_client(address, port)
	get_tree().network_peer = enet_peer


func _peer_connected(peer_id):
	print("_peer_connected(%s)" % peer_id)
	peers[peer_id] = false
	rpc_id(peer_id, "add_player", get_tree().get_network_unique_id(), current_vehicle)
	if get_tree().get_network_unique_id() == 1:
		rpc_id(peer_id, "select_track", current_track_path)


func _peer_disconnected(peer_id):
	print("_peer_disconnected(%s)" % peer_id)
	peers.erase(peer_id)
	destroy_player(peer_id)
	print("new peers state: %s" % peers)


func _connected_to_server():
	print("_connected_to_server")
	connected = true


func _connection_failed():
	connected = false
	current_track = null
	peers_vehicles.clear()
	_server_disconnected()


func _server_disconnected():
	connected = false
	current_track = null
	peers.clear()
	peers_vehicles.clear()
	get_tree().root.get_child(get_tree().root.get_child_count() - 1).queue_free()
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
	connected = false
	current_track = null
	peers.clear()
	peers_vehicles.clear()


remote func add_player(peer_id, vehicle_path):
	if peers[peer_id] == false:
		peers[peer_id] = true
		if current_track != null:
			create_player(peer_id, vehicle_path)
		else:
			peers_vehicles[peer_id] = vehicle_path


remote func select_track(track_path):
	current_track = load(track_path).instance()
	get_tree().root.call_deferred("add_child", current_track)
	create_player(get_tree().get_network_unique_id(), current_vehicle)
	for peer in peers_vehicles:
		create_player(peer, peers_vehicles[peer])
	peers_vehicles.clear()
