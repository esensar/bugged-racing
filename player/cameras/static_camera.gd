extends Camera


func reset() -> void:
	rotation = Vector3.ZERO
	rotate(Vector3.UP, deg2rad(180))
	fov = GlobalSettings.camera_fov
	translation = Vector3.ZERO
	translate(
		Vector3(
			GlobalSettings.camera_move_right - GlobalSettings.camera_move_left,
			GlobalSettings.camera_move_up - GlobalSettings.camera_move_down,
			GlobalSettings.camera_move_backward - GlobalSettings.camera_move_forward
		)
	)


func update_rotation(horizontal: float, vertical: float) -> void:
	rotate(Vector3.DOWN, horizontal * deg2rad(90))
	rotate(Vector3.LEFT, vertical * deg2rad(90))
