class_name TireSmoke
extends Particles

func update(skidinfo: float) -> void:
	if skidinfo < 0.5:
		emitting = true
	else:
		emitting = false
