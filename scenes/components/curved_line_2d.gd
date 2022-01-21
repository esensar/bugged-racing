extends Node2D

export(Curve2D) var curve
export(Color) var color = Color.red
export(float) var width = 2.0


func _draw() -> void:
	if curve == null:
		return

	draw_polyline(curve.get_baked_points(), color, width)
