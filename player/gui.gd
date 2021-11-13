extends MarginContainer


onready var rpm_needle = $HBoxContainer/RPMGauge/RPMNeedle
onready var speed_needle = $HBoxContainer/SpeedGauge/SpeedNeedle
onready var gear_label = $HBoxContainer/GearLabel

var min_rotation = -85
var max_rotation = 75

func _get_rotation(percent: float) -> float:
	return min_rotation + (max_rotation - min_rotation) * percent

func update_speed(speed_percent: float) -> void:
	speed_needle.rect_rotation = _get_rotation(speed_percent)

func update_rpm(rpm_percent: float) -> void:
	rpm_needle.rect_rotation = _get_rotation(rpm_percent)

func update_gear(gear: int) -> void:
	if gear == -1:
		gear_label.text = "R"
	elif gear == 0:
		gear_label.text = "N"
	else:
		gear_label.text = str(gear)
