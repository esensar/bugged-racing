extends Camera


func reset() -> void:
	rotation = Vector3.ZERO
	rotate(Vector3.UP, deg2rad(180))


func update_rotation(horizontal: float, vertical: float) -> void:
	rotate(Vector3.DOWN, horizontal * deg2rad(90))
	rotate(Vector3.LEFT, vertical * deg2rad(90))
