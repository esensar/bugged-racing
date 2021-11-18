extends MarginContainer

var best_time = -1

onready var time_value = $VBoxContainer/HBoxContainer/TimeValue
onready var best_time_value = $VBoxContainer/HBoxContainer/BestTimeValue
onready var wrong_way_label = $VBoxContainer/WrongWayLabel


func _ready() -> void:
	time_value.text = "NaN"
	best_time_value.text = "NaN"


func _on_time_updated(new_time: float) -> void:
	time_value.text = _format_time(new_time)


func _on_lap_complete(lap_time: float) -> void:
	if lap_time < best_time or best_time < 0:
		best_time = lap_time
		best_time_value.text = _format_time(best_time)


func _on_wrong_way_detected() -> void:
	wrong_way_label.visible = true
	yield(get_tree().create_timer(3.0), "timeout")
	wrong_way_label.visible = false


func _format_time(time: float) -> String:
	var minute = floor(time / 1000.0 / 60.0)
	var second = floor((time / 1000.0) - minute * 60)
	var millisecond = time - minute * 60 * 1000 - second * 1000
	return "%02d:%02d.%03d" % [minute, second, millisecond]
