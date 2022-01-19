extends MeshInstance

export(float) var min_angle = 0
export(float) var max_angle = 45


func _on_value_updated(value_percent: float) -> void:
	rotation.x = -(deg2rad(min_angle) + value_percent * deg2rad(max_angle - min_angle))
