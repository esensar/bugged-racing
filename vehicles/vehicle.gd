class_name BuggedVehicle
extends VehicleBody

signal speed_updated(speed_kph, speed_percent)
signal rpm_updated(rpm, rpm_percent)
signal throttle_updated(throttle_percent)
signal brake_updated(brake_percent)
signal clutch_updated(clutch_percent)
signal gear_updated(gear)
signal steering_updated(steering_angle, steering_percent)

enum GearRequest { NONE, UP, DOWN }

export(float) var max_steer_angle = 25
export(float) var speed_steer_angle = 10
export(float) var max_steer_speed = 100.0
export(float) var max_steer_input = 80.0

export(float) var max_engine_force = 85.0
export(float) var max_brake_force = 50.0
export(float) var throttle_power = 6000.0
export(float) var max_rpm_loss_ps = 3000.0
export(float) var base_engine_pitch = 0.5
export(float) var expected_max_speed = 200

export(Array) var gear_ratios = [3.4, 2.5, 2.0, 1.5, 1.25]
export(float) var reverse_ratio = -3
export(float) var final_drive = 3.45
export(float) var max_rpm = 3500
export(float) var min_rpm = 900
export(float) var gear_switch_time = 0.2
export(Curve) var power_curve = null
export(Curve) var sound_curve = null

export(float) var automatic_gear_up_threshold = 0.8
export(float) var automatic_gear_down_threshold = 0.3

var clutch_position: float = 0.0
var rpm = 0
var gear = 1

var gear_timer = 0

var traction_wheels: Array
var reset_transform: Transform = Transform.IDENTITY

var inputs: VehicleInputs = VehicleInputs.new()

onready var frwheel: VehicleWheel = $front_right
onready var flwheel: VehicleWheel = $front_left
onready var rrwheel: VehicleWheel = $rear_right
onready var rlwheel: VehicleWheel = $rear_left
onready var frsmoke: TireSmoke = $fr_tire_smoke
onready var flsmoke: TireSmoke = $fl_tire_smoke
onready var rrsmoke: TireSmoke = $rr_tire_smoke
onready var rlsmoke: TireSmoke = $rl_tire_smoke

onready var engine_sound_player: AudioStreamPlayer3D = $engine_sound_player
onready var engine_sound_playback: AudioStreamPlayback = $engine_sound_player.get_stream_playback()

onready var max_steer_angle_rad: float = deg2rad(max_steer_angle)
onready var speed_steer_angle_rad: float = deg2rad(speed_steer_angle)
onready var max_steer_input_rad: float = deg2rad(max_steer_input)

onready var auto_clutch_rpm_limit = max_rpm * automatic_gear_down_threshold


class VehicleInputs:
	var gear_request = GearRequest.NONE
	var clutch = 0.0
	var throttle = 0.0
	var brake = 0.0
	var handbrake = 0.0
	# Left is positive, right is negative
	var steering = 0.0

	func to_array() -> Array:
		return [gear_request, clutch, throttle, brake, handbrake, steering]

	func from_array(array: Array) -> void:
		gear_request = array[0]
		clutch = array[1]
		throttle = array[2]
		brake = array[3]
		handbrake = array[4]
		steering = array[5]


func _ready():
	for wheel in [frwheel, flwheel, rrwheel, rlwheel]:
		if wheel.use_as_traction:
			traction_wheels.append(wheel)

	_generate_engine_sound(0)
	engine_sound_player.play()


func get_cockpit_position() -> Node:
	return $cockpit


func get_hood_position() -> Node:
	return $hood


func get_bumper_position() -> Node:
	return $bumper


func get_static_follow_position() -> Node:
	return $static_follow


func _integrate_forces(state: PhysicsDirectBodyState) -> void:
	if reset_transform != Transform.IDENTITY:
		state.linear_velocity = Vector3.ZERO
		state.angular_velocity = Vector3.ZERO
		state.set_transform(reset_transform)
		reset_transform = Transform.IDENTITY


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
	if clutch_position > 0.8 or GlobalSettings.auto_clutch or GlobalSettings.automatic_transmission:
		match inputs.gear_request:
			GearRequest.UP:
				_gear_up()
			GearRequest.DOWN:
				_gear_down()


func _gear_up():
	if gear + 1 <= gear_ratios.size():
		gear += 1
		gear_timer = gear_switch_time * (2 - clutch_position)
		emit_signal("gear_updated", gear)


func _gear_down():
	if gear - 1 >= -1:
		gear -= 1
		gear_timer = gear_switch_time * (2 - clutch_position)
		emit_signal("gear_updated", gear)


func _has_traction():
	for wheel in traction_wheels:
		if wheel.is_in_contact():
			return true
	return false


func _update_wheels_smoke():
	for wheelnsmoke in [
		[frwheel, frsmoke], [flwheel, flsmoke], [rrwheel, rrsmoke], [rlwheel, rlsmoke]
	]:
		wheelnsmoke[1].update(wheelnsmoke[0].get_skidinfo())


func _lerp_rpm(from, to, delta, factor):
	var new_val = lerp(from, to, factor)
	if abs(from - new_val) > max_rpm_loss_ps * delta:
		var new_factor = inverse_lerp(
			from, to, from - sign(from - new_val) * max_rpm_loss_ps * delta
		)
		new_val = lerp(from, to, new_factor)
	return new_val


func _physics_process(delta: float):
	_update_wheels_smoke()
	clutch_position = inputs.clutch
	_handle_gear_switch(delta)
	var throttle = inputs.throttle
	var brake_input = inputs.brake

	var wheel_rpm = traction_wheels[0].get_rpm()
	var speed = wheel_rpm * 2.0 * PI * rrwheel.wheel_radius / 60.0 * 3600.0 / 1000.0

	if GlobalSettings.automatic_transmission and speed < 1 and gear == 1 and brake_input > 0.1:
		_gear_down()
		_gear_down()

	if GlobalSettings.automatic_transmission and speed > -1 and gear == -1 and throttle > 0.1:
		_gear_up()
		_gear_up()

	if GlobalSettings.automatic_transmission and gear == -1:
		var swap = throttle
		throttle = brake_input
		brake_input = swap

	if GlobalSettings.auto_clutch or GlobalSettings.automatic_transmission:
		clutch_position = 1 - min(rpm, auto_clutch_rpm_limit) / auto_clutch_rpm_limit

	if gear_timer > 0:
		clutch_position = 1
		throttle = 0

	var final_rpm = abs(wheel_rpm) * final_drive
	var transmission_rpm = final_rpm * abs(_get_gear_ratio())

	if gear != 0:
		rpm = lerp(rpm, transmission_rpm, delta * 10 * (1 - clutch_position))
		rpm = _lerp_rpm(rpm, min_rpm, delta, delta * clutch_position)
	else:
		rpm = _lerp_rpm(rpm, min_rpm, delta, delta)
	if _has_traction():
		rpm += throttle * delta * (max(clutch_position, 1 if gear == 0 else 0)) * throttle_power
	else:
		rpm += throttle * delta * throttle_power
	rpm = clamp(rpm, 0, max_rpm)
	var rpm_factor = clamp(rpm / max_rpm, 0.0, 1.0)
	var power_factor = power_curve.interpolate_baked(rpm_factor)

	_generate_engine_sound(rpm_factor)

	# Transfer to transmission
	var transmission_input = power_factor * (1 - clutch_position) * _get_gear_ratio()

	var final_input = transmission_input * final_drive

	emit_signal("throttle_updated", throttle)
	emit_signal("brake_updated", brake_input)
	emit_signal("clutch_updated", clutch_position)
	brake = brake_input * max_brake_force
	engine_force = throttle * final_input * max_engine_force

	var handbrake = inputs.handbrake
	rrwheel.brake = handbrake * max_brake_force
	rlwheel.brake = handbrake * max_brake_force

	if GlobalSettings.automatic_transmission and rpm_factor > automatic_gear_up_threshold:
		_gear_up()
	elif GlobalSettings.automatic_transmission and rpm_factor < automatic_gear_down_threshold:
		if gear > 1:
			_gear_down()

	emit_signal("speed_updated", speed, speed / expected_max_speed)
	emit_signal("rpm_updated", rpm, rpm_factor)

	var steering_input = inputs.steering

	var steer_speed_factor = clamp(speed / max_steer_speed, 0.0, 1.0)

	steering = steering_input * lerp(max_steer_angle_rad, speed_steer_angle_rad, steer_speed_factor)
	emit_signal("steering_updated", steering, steering / max_steer_angle_rad)

	if MultiplayerController.is_online():
		if get_network_master() == get_tree().get_network_unique_id():
			_synchronize()


func _generate_engine_sound(rpm_factor):
	engine_sound_player.pitch_scale = base_engine_pitch + 2 * rpm_factor
	var to_fill = engine_sound_playback.get_frames_available()
	var factor = rpm_factor
	if to_fill <= 0:
		return
	var fill_segment = 1.0 / to_fill
	var fill_percent = 0.0
	while to_fill > 0:
		engine_sound_playback.push_frame(Vector2(1.0, 1.0) * factor)
		factor += (
			cos(factor)
			* sin(factor)
			* (1 + to_fill % 2)
			* ((sound_curve.interpolate_baked(fill_percent) - 0.5) * 2)
		)
		to_fill -= 1
		fill_percent += fill_segment


func _synchronize():
	rpc("sync_position", transform)
	rpc("sync_inputs", inputs.to_array())


remote func sync_position(position: Transform):
	reset_transform = position


remote func sync_inputs(remote_inputs):
	inputs.from_array(remote_inputs)
