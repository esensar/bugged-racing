extends Camera

export(NodePath) var follow_target_path = null
export var target_distance: float = 3.0
export var target_height: float = 2.0

var follow_target: Node = null
var last_lookat: Vector3


# Called when the node enters the scene tree for the first time.
func _ready():
	follow_target = get_node(follow_target_path)
	last_lookat = follow_target.global_transform.origin


func _physics_process(delta):
	var delta_v = global_transform.origin - follow_target.global_transform.origin
	var target_pos = global_transform.origin

	delta_v.y = 0.0

	if delta_v.length() > target_distance:
		delta_v = delta_v.normalized() * target_distance
		delta_v.y = target_height
		target_pos = follow_target.global_transform.origin + delta_v
	else:
		target_pos.y = follow_target.global_transform.origin.y + target_height

	global_transform.origin = global_transform.origin.linear_interpolate(target_pos, delta * 20.0)

	last_lookat = last_lookat.linear_interpolate(
		follow_target.global_transform.origin, delta * 20.0
	)

	look_at(last_lookat, Vector3(0.0, 1.0, 0.0))
