extends VehicleBody

export (float) var MAX_STEER_ANGLE = 25
export (float) var SPEED_STEER_ANGLE = 10
export (float) var MAX_STEER_SPEED = 100.0
export (float) var MAX_STEER_INPUT = 80.0

onready var max_steer_angle_rad: float = deg2rad(MAX_STEER_ANGLE)
onready var speed_steer_angle_rad: float = deg2rad(SPEED_STEER_ANGLE)
onready var max_steer_input_rad: float = deg2rad(MAX_STEER_INPUT)
export (Curve) var steer_curve = null

export (float) var MAX_ENGINE_FORCE = 85.0
export (float) var MAX_BRAKE_FORCE = 50.0
export (float) var THROTTLE_POWER = 6000.0
export (float) var MAX_RPM_LOSS_PS = 3000.0

export (Array) var gear_ratios = [ 3.4, 2.5, 2.0, 1.5, 1.25 ]
export (float) var reverse_ratio = -3
export (float) var final_drive = 3.45
export (float) var max_rpm = 3500
export (float) var min_rpm = 900
export (float) var gear_switch_time = 0.2
export (Curve) var power_curve = null

var clutch_position: float = 0.0
var rpm = 0
var gear = 1

var gear_timer = 0

onready var frwheel: VehicleWheel = $front_right
onready var flwheel: VehicleWheel = $front_left
onready var rrwheel: VehicleWheel = $rear_right
onready var rlwheel: VehicleWheel = $rear_left

onready var engine_sound_player: AudioStreamPlayer3D = $engine_sound_player
onready var engine_sound_playback: AudioStreamPlayback = $engine_sound_player.get_stream_playback()

var traction_wheels: Array

func _ready():
	for wheel in [frwheel, flwheel, rrwheel, rlwheel]:
		if wheel.use_as_traction:
			traction_wheels.append(wheel)

	_generate_engine_sound(0)
	engine_sound_player.play()

func _get_gear_ratio():
	if gear == 0:
		return 0
	elif gear == -1:
		return reverse_ratio
	else:
		return gear_ratios[gear - 1]

func _handle_gear_switch(delta: float):
	if gear_timer > 0:
		gear_timer = max(0, gear_timer - delta)
	elif clutch_position > 0.8:
		if Input.is_action_just_pressed("gear_up"):
			if gear + 1 <= gear_ratios.size():
				gear += 1
				gear_timer = gear_switch_time * (2 - clutch_position)
		if Input.is_action_just_pressed("gear_down"):
			if gear - 1 >= -1:
				gear -= 1
				gear_timer = gear_switch_time * (2 - clutch_position)

func _has_traction():
	for wheel in traction_wheels:
		if wheel.is_in_contact():
			return true
	return false

func _lerp_rpm(from, to, delta, factor):
	var new_val = lerp(from, to, factor)
	if abs(from - new_val) > MAX_RPM_LOSS_PS * delta:
		var new_factor = inverse_lerp(from, to, from - sign(from - new_val) * MAX_RPM_LOSS_PS * delta)
		new_val = lerp(from, to, new_factor)
	return new_val

func _physics_process(delta: float):
	clutch_position = Input.get_action_strength("clutch")
	_handle_gear_switch(delta)
	var throttle = Input.get_action_strength("throttle")

	var wheel_rpm = traction_wheels[0].get_rpm()
	var final_rpm = abs(wheel_rpm) * final_drive
	var transmission_rpm = final_rpm * abs(_get_gear_ratio())

	if gear != 0:
		rpm = lerp(rpm, transmission_rpm, delta * (1 - clutch_position))
		rpm = _lerp_rpm(rpm, min_rpm, delta, delta * clutch_position)
	else:
		rpm = _lerp_rpm(rpm, min_rpm, delta, delta)
	if _has_traction():
		rpm += throttle * delta * clutch_position * THROTTLE_POWER
	else:
		rpm += throttle * delta * THROTTLE_POWER
	rpm = clamp(rpm, 0, max_rpm)
	var rpm_factor = clamp(rpm / max_rpm, 0.0, 1.0)
	var power_factor = power_curve.interpolate_baked(rpm_factor)

	_generate_engine_sound(rpm_factor)

	# Transfer to transmission
	var transmission_input = power_factor * (1 - clutch_position) * _get_gear_ratio()

	var final_input = transmission_input * final_drive

	brake = Input.get_action_strength("brake") * MAX_BRAKE_FORCE
	engine_force = throttle * final_input * MAX_ENGINE_FORCE

	var handbrake = Input.get_action_strength("handbrake")
	rrwheel.brake = handbrake * MAX_BRAKE_FORCE / 2
	rlwheel.brake = handbrake * MAX_BRAKE_FORCE / 2

	var speed = wheel_rpm * 2.0 * PI * rrwheel.wheel_radius / 60.0 * 3600.0 / 1000.0
	$Info.text = "Gear: %d, KPH: %.0f, RPM: %.0f, WheelRPM: %.0f, FinalRPM: %.0f, TRPM: %.0f, Engine force: %.0f" % [ gear, speed, rpm, wheel_rpm, final_rpm, transmission_rpm, engine_force ]

	var steering_input = Input.get_action_strength("steer_left") - Input.get_action_strength("steer_right")
	if abs(steering_input) < 0.05:
		steering_input = 0.0
	elif steer_curve:
		if steering_input < 0.0:
			steering_input = -steer_curve.interpolate_baked(-steering_input)
		else:
			steering_input = steer_curve.interpolate_baked(steering_input)

	var steer_speed_factor = clamp(speed / MAX_STEER_SPEED, 0.0, 1.0)

	steering = steering_input * lerp(max_steer_angle_rad, speed_steer_angle_rad, steer_speed_factor)

func _generate_engine_sound(rpm_factor):
	engine_sound_player.pitch_scale = 0.5 + rpm_factor
	var to_fill = engine_sound_playback.get_frames_available()
	var factor = rpm_factor
	while to_fill > 0:
		engine_sound_playback.push_frame(Vector2(1.0, 1.0) * factor)
		factor += cos(factor) * sin(factor) * (1 + to_fill % 2)
		to_fill -= 1
