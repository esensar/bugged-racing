extends MarginContainer


onready var rpm_needle = $HBoxContainer/RPMGauge/RPMNeedle
onready var rpm_label = $HBoxContainer/RPMGauge/Panel/RPMLabel
onready var speed_needle = $HBoxContainer/SpeedGauge/SpeedNeedle
onready var speed_label = $HBoxContainer/SpeedGauge/Panel/SpeedLabel
onready var gear_label = $HBoxContainer/GearLabel

var min_rotation = -85
var max_rotation = 75

func _get_rotation(percent: float) -> float:
	return min_rotation + (max_rotation - min_rotation) * percent

func update_speed(speed: int, speed_percent: float) -> void:
	speed_needle.rect_rotation = _get_rotation(speed_percent)
	speed_label.text = str(speed)

func update_rpm(rpm: int, rpm_percent: float) -> void:
	rpm_needle.rect_rotation = _get_rotation(rpm_percent)
	rpm_label.text = str(rpm)

func update_gear(gear: int) -> void:
	if gear == -1:
		gear_label.text = "R"
	elif gear == 0:
		gear_label.text = "N"
	else:
		gear_label.text = str(gear)
