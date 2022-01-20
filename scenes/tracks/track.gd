class_name Track
extends Spatial

signal time_updated(new_time)
signal lap_complete(lap_time)
signal wrong_way

export(NodePath) var track_path = null
export(int, 10, 50) var checkpoint_count = 20
export(float) var checkpoint_depth = 5.0
export(PoolVector2Array) var checkpoint_polygon = PoolVector2Array(
	[Vector2(-10, -10), Vector2(-10, 10), Vector2(10, 10), Vector2(10, -10)]
)

var furthest_checkpoint = -1
var last_checkpoint = -1

var start_time = 0
var current_time = 0

var lap_done = false

onready var checkpoints = $Checkpoints
onready var path: Path = get_node(track_path)


func get_furthest_checkpoint() -> Node:
	return checkpoints.get_child(max(0, furthest_checkpoint))


func _ready() -> void:
	start_time = OS.get_ticks_msec()
	var length = path.curve.get_baked_length()
	var section_size = 1 * length / checkpoint_count
	var section = 0.0
	for _checkpoint_number in range(checkpoint_count):
		var new_checkpoint: Area = Area.new()
		new_checkpoint.add_child(_build_checkpoint_collision())
		new_checkpoint.look_at_from_position(
			checkpoints.to_global(path.curve.interpolate_baked(section)),
			checkpoints.to_global(path.curve.interpolate_baked(section + 0.01)),
			path.curve.interpolate_baked_up_vector(section)
		)
		section += section_size
		checkpoints.add_child(new_checkpoint)
		new_checkpoint.connect("body_entered", self, "_on_body_entered_area", [new_checkpoint])
	checkpoints.global_transform.origin = path.global_transform.origin


func _process(_delta: float) -> void:
	_update_time()


func _on_body_entered_area(body: Node, area: Area) -> void:
	if (
		MultiplayerController.is_online()
		and body.get_network_master() != get_tree().get_network_unique_id()
	):
		return

	if body.get_groups().has("car"):
		if area.get_index() < last_checkpoint || abs(area.get_index() - last_checkpoint) > 1:
			emit_signal("wrong_way")

		last_checkpoint = area.get_index()

		# We got the correct checkpoint
		if furthest_checkpoint == area.get_index() - 1:
			furthest_checkpoint += 1

		if lap_done and furthest_checkpoint == 0:
			emit_signal("lap_complete", current_time)
			start_time = OS.get_ticks_msec()
			_update_time()
			lap_done = false

		if furthest_checkpoint == checkpoints.get_child_count() - 1:
			lap_done = true
			furthest_checkpoint = -1
			last_checkpoint = -1


func _build_checkpoint_collision():
	var collision = CollisionPolygon.new()
	collision.depth = checkpoint_depth
	collision.polygon = checkpoint_polygon
	return collision


func _update_time():
	current_time = OS.get_ticks_msec() - start_time
	emit_signal("time_updated", current_time)
