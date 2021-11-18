class_name Track
extends Spatial

signal time_updated(new_time)
signal lap_complete(lap_time)
signal wrong_way()

export (NodePath) var track_path = null
export (int, 10, 50) var checkpoint_count = 20
export (Vector2) var checkpoint_dim = Vector2(20, 15)
export (Material) var debug_material = null

onready var checkpoints = $Checkpoints
onready var path: Path = get_node(track_path)
var furthest_checkpoint = -1
var last_checkpoint = -1

var start_time = 0
var current_time = 0

func _ready() -> void:
	start_time = OS.get_ticks_msec()
	var length = path.curve.get_baked_length()
	var section_size = 1.0 * length / checkpoint_count
	var section = 0.0
	for _checkpoint_number in range(checkpoint_count):
		var new_checkpoint: Area = Area.new()
		new_checkpoint.add_child(_build_checkpoint_collision())
		new_checkpoint.transform.origin = path.curve.interpolate_baked(section, true)
		section += section_size
		checkpoints.add_child(new_checkpoint)
		if GlobalSettings.debug:
			var mesh = CylinderMesh.new()
			mesh.top_radius = checkpoint_dim.y
			mesh.bottom_radius = checkpoint_dim.y
			mesh.height = checkpoint_dim.x
			if debug_material != null:
				mesh.material = debug_material
			var meshinst = MeshInstance.new()
			meshinst.mesh = mesh
			new_checkpoint.add_child(meshinst)
		new_checkpoint.connect("body_entered", self, "_on_body_entered_area", [ new_checkpoint ])
	checkpoints.global_transform.origin = path.global_transform.origin


func _process(delta: float) -> void:
	_update_time()


func _on_body_entered_area(body: Node, area: Area) -> void:
	if body.get_groups().has("car"):

		if area.get_index() < last_checkpoint || abs(area.get_index() - last_checkpoint) > 1:
			emit_signal("wrong_way")

		last_checkpoint = area.get_index()

		# We got the correct checkpoint
		if furthest_checkpoint == area.get_index() - 1:
			furthest_checkpoint += 1

		if furthest_checkpoint == checkpoints.get_child_count() - 1:
			emit_signal("lap_complete", current_time)
			start_time = OS.get_ticks_msec()
			_update_time()
			furthest_checkpoint = -1


func _build_checkpoint_collision():
	var collision = CollisionShape.new()
	var shape = CylinderShape.new()
	shape.radius = checkpoint_dim.x
	shape.height = checkpoint_dim.y
	collision.shape = shape
	return collision

func _update_time():
	current_time = OS.get_ticks_msec() - start_time
	emit_signal("time_updated", current_time)
