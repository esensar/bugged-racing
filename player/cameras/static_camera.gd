extends Camera


func reset() -> void:
	rotation = Vector3.ZERO
	rotate(Vector3.UP, deg2rad(180))
	fov = GlobalSettings.camera_fov
	translation = Vector3.ZERO
	translate(
		Vector3(
			GlobalSettings.camera_move_horizontal,
			GlobalSettings.camera_move_vertical,
			GlobalSettings.camera_move_depth
		)
	)


func update_rotation(horizontal: float, vertical: float) -> void:
	rotate(Vector3.DOWN, horizontal * deg2rad(90))
	rotate(Vector3.LEFT, vertical * deg2rad(90))
