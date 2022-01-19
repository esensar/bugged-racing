extends MeshInstance

export(float) var max_steer_angle = 90


func update_angle(steering_angle_percent: float) -> void:
	rotation.z = deg2rad(max_steer_angle) * steering_angle_percent


func _on_steering_updated(_steering_angle: float, steering_angle_percent: float) -> void:
	update_angle(-steering_angle_percent)
