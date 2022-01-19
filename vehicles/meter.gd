extends MeshInstance

export(float) var min_angle = -90
export(float) var max_angle = 90
export(NodePath) var needle_path = null


func _on_value_updated(_value: int, value_percent: float) -> void:
	get_node(needle_path).rotation.y = -(
		deg2rad(min_angle)
		+ value_percent * deg2rad(max_angle - min_angle)
	)
