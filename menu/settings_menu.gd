extends Panel

const PLAYER_CONTROLLER = preload("res://player/vehicle_controller.gd")
const CAMERA_TEST_SCENE = preload("res://menu/camera_config_scene.tscn")

const BUGGY = "res://vehicles/buggy.tscn"
const BEETLE = "res://vehicles/beetlecar.tscn"
const BUGMOBILE = "res://vehicles/bugmobile.tscn"

var vehicles = [BEETLE, BUGGY, BUGMOBILE]

var inputs = BuggedVehicle.VehicleInputs.new()

onready var master_bus := AudioServer.get_bus_index("Master")
onready var sound_bus := AudioServer.get_bus_index("Sound")
onready var music_bus := AudioServer.get_bus_index("Music")

# gdlint: ignore=max-line-length
onready var master_slider: HSlider = $MarginContainer/VSplitContainer/TabContainer/Audio/Audio/MasterSlider
# gdlint: ignore=max-line-length
onready var sound_slider: HSlider = $MarginContainer/VSplitContainer/TabContainer/Audio/Audio/SoundEffectsSlider
# gdlint: ignore=max-line-length
onready var music_slider: HSlider = $MarginContainer/VSplitContainer/TabContainer/Audio/Audio/MusicSlider
# gdlint: ignore=max-line-length
onready var auto_clutch_cb: CheckBox = $MarginContainer/VSplitContainer/TabContainer/Controls/Controls/AutoClutchCheckBox
# gdlint: ignore=max-line-length
onready var automatic_transmission_cb: CheckBox = $MarginContainer/VSplitContainer/TabContainer/Controls/Controls/AutomaticTransmissionCheckBox
# gdlint: ignore=max-line-length
onready var fullscreen_cb: CheckBox = $MarginContainer/VSplitContainer/TabContainer/Video/TabContainer/System/FullscreenCheckBox
# gdlint: ignore=max-line-length
onready var borderless_cb: CheckBox = $MarginContainer/VSplitContainer/TabContainer/Video/TabContainer/System/BorderlessCheckBox
# gdlint: ignore=max-line-length
onready var multiplayer_name_box: LineEdit = $MarginContainer/VSplitContainer/TabContainer/Gameplay/Gameplay/MultiplayerNameBox
# gdlint: ignore=max-line-length
onready var steering_sensitivity_slider: HSlider = $MarginContainer/VSplitContainer/TabContainer/Controls/Controls/SteeringSensitivitySlider
# gdlint: ignore=max-line-length
onready var steering_return_speed_slider: HSlider = $MarginContainer/VSplitContainer/TabContainer/Controls/Controls/SteeringReturnSpeedSlider
# gdlint: ignore=max-line-length
onready var steering_deadzone_inner_slider: HSlider = $MarginContainer/VSplitContainer/TabContainer/Controls/Controls/SteeringInnerDeadzoneSlider
# gdlint: ignore=max-line-length
onready var steering_deadzone_outer_slider: HSlider = $MarginContainer/VSplitContainer/TabContainer/Controls/Controls/SteeringOuterDeadzoneSlider
# gdlint: ignore=max-line-length
onready var throttle_sensitivity_slider: HSlider = $MarginContainer/VSplitContainer/TabContainer/Controls/Controls/ThrottleSensitivitySlider
# gdlint: ignore=max-line-length
onready var brakes_sensitivity_slider: HSlider = $MarginContainer/VSplitContainer/TabContainer/Controls/Controls/BrakesSensitivitySlider

# gdlint: ignore=max-line-length
onready var steering_value_slider: HSlider = $MarginContainer/VSplitContainer/TabContainer/Controls/Controls/HBoxContainer/Steering/HSlider
# gdlint: ignore=max-line-length
onready var throttle_value_slider: HSlider = $MarginContainer/VSplitContainer/TabContainer/Controls/Controls/HBoxContainer/Throttle/HSlider
# gdlint: ignore=max-line-length
onready var brakes_value_slider: HSlider = $MarginContainer/VSplitContainer/TabContainer/Controls/Controls/HBoxContainer/Brakes/HSlider
# gdlint: ignore=max-line-length
onready var gear_value_slider: HSlider = $MarginContainer/VSplitContainer/TabContainer/Controls/Controls/HBoxContainer/Gear/HSlider

# gdlint: ignore=max-line-length
onready var fov_slider: HSlider = $MarginContainer/VSplitContainer/TabContainer/Video/TabContainer/Camera/Camera/FovSlider
# gdlint: ignore=max-line-length
onready var move_depth_slider: HSlider = $MarginContainer/VSplitContainer/TabContainer/Video/TabContainer/Camera/Camera/MoveDepthSlider
# gdlint: ignore=max-line-length
onready var move_horizontal_slider: HSlider = $MarginContainer/VSplitContainer/TabContainer/Video/TabContainer/Camera/Camera/MoveHorizontalSlider
# gdlint: ignore=max-line-length
onready var move_vertical_slider: HSlider = $MarginContainer/VSplitContainer/TabContainer/Video/TabContainer/Camera/Camera/MoveVerticalSlider
# gdlint: ignore=max-line-length
onready var vehicle_selector: OptionButton = $MarginContainer/VSplitContainer/TabContainer/Video/TabContainer/Camera/VBoxContainer/VehicleSelector
# gdlint: ignore=max-line-length
onready var viewport: Viewport = $MarginContainer/VSplitContainer/TabContainer/Video/TabContainer/Camera/VBoxContainer/ViewportContainer/Viewport
onready var camera_scene = CAMERA_TEST_SCENE.instance()


func _ready() -> void:
	auto_clutch_cb.grab_focus()
	master_slider.value = db2linear(AudioServer.get_bus_volume_db(master_bus))
	sound_slider.value = db2linear(AudioServer.get_bus_volume_db(sound_bus))
	music_slider.value = db2linear(AudioServer.get_bus_volume_db(music_bus))
	auto_clutch_cb.pressed = GlobalSettings.auto_clutch
	automatic_transmission_cb.pressed = GlobalSettings.automatic_transmission
	multiplayer_name_box.text = GlobalSettings.multiplayer_name
	steering_sensitivity_slider.value = GlobalSettings.steering_sensitivity
	steering_return_speed_slider.value = GlobalSettings.return_speed
	steering_deadzone_inner_slider.value = GlobalSettings.steering_deadzone_inner
	steering_deadzone_outer_slider.value = GlobalSettings.steering_deadzone_outer
	throttle_sensitivity_slider.value = GlobalSettings.throttle_sensitivity
	brakes_sensitivity_slider.value = GlobalSettings.brake_sensitivity
	fov_slider.value = GlobalSettings.camera_fov
	move_depth_slider.value = GlobalSettings.camera_move_depth
	move_horizontal_slider.value = GlobalSettings.camera_move_horizontal
	move_vertical_slider.value = GlobalSettings.camera_move_vertical
	fullscreen_cb.pressed = false
	borderless_cb.pressed = false
	var controller = PLAYER_CONTROLLER.new()
	controller.input_sink_path = get_path()
	add_child(controller)
	if OS.is_window_fullscreen():
		_set_fullscreen(true)
	if OS.get_borderless_window():
		_set_borderless(true)

	vehicle_selector.add_item("Beetlecar")
	vehicle_selector.add_item("Buggy")
	vehicle_selector.add_item("Bugmobile")
	vehicle_selector.selected = 1

	viewport.add_child(camera_scene)


func _physics_process(_delta: float) -> void:
	steering_value_slider.value = -inputs.steering
	throttle_value_slider.value = inputs.throttle
	brakes_value_slider.value = inputs.brake
	match inputs.gear_request:
		BuggedVehicle.GearRequest.UP:
			gear_value_slider.value += 1
		BuggedVehicle.GearRequest.DOWN:
			gear_value_slider.value -= 1


func _on_autoclutch_toggled(new_state: bool) -> void:
	GlobalSettings.auto_clutch = new_state


func _on_fullscreen_toggled(new_state: bool) -> void:
	_set_borderless(false)
	_set_fullscreen(new_state)


func _on_borderless_toggled(new_state: bool) -> void:
	_set_fullscreen(false)
	_set_borderless(new_state)


func _on_automatictransmission_toggled(new_state: bool) -> void:
	GlobalSettings.automatic_transmission = new_state
	auto_clutch_cb.disabled = new_state == true


func _on_BackButton_pressed() -> void:
	GlobalSettings.multiplayer_name = multiplayer_name_box.text
	get_tree().change_scene("res://menu/main_menu.tscn")


func _on_MasterSlider_value_changed(new_value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus, linear2db(new_value))


func _on_SoundEffectsSlider_value_changed(new_value: float) -> void:
	AudioServer.set_bus_volume_db(sound_bus, linear2db(new_value))


func _on_MusicSlider_value_changed(new_value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus, linear2db(new_value))


func _on_SteeringSensitivitySlider_value_changed(new_value: float) -> void:
	GlobalSettings.steering_sensitivity = new_value


func _on_SteeringReturnSpeedSlider_value_changed(new_value: float) -> void:
	GlobalSettings.return_speed = new_value


func _on_SteeringInnerDeadzoneSlider_value_changed(new_value: float) -> void:
	GlobalSettings.steering_deadzone_inner = new_value


func _on_SteeringOuterDeadzoneSlider_value_changed(new_value: float) -> void:
	GlobalSettings.steering_deadzone_outer = new_value


func _on_ThrottleSensitivitySlider_value_changed(new_value: float) -> void:
	GlobalSettings.throttle_sensitivity = new_value


func _on_BrakesSensitivitySlider_value_changed(new_value: float) -> void:
	GlobalSettings.brake_sensitivity = new_value


func _on_FovSlider_value_changed(new_value: float) -> void:
	GlobalSettings.camera_fov = new_value


func _on_MoveDepthSlider_value_changed(new_value: float) -> void:
	GlobalSettings.camera_move_depth = new_value


func _on_MoveHorizontalSlider_value_changed(new_value: float) -> void:
	GlobalSettings.camera_move_horizontal = new_value


func _on_MoveVerticalSlider_value_changed(new_value: float) -> void:
	GlobalSettings.camera_move_vertical = new_value


func _on_VehicleSelector_item_selected(item_index: int) -> void:
	camera_scene.change_vehicle_to(vehicles[item_index])


func _set_fullscreen(new_state: bool) -> void:
	OS.set_window_fullscreen(new_state)
	OS.set_window_maximized(new_state)
	if new_state == true:
		borderless_cb.disabled = true
	else:
		borderless_cb.disabled = false


func _set_borderless(new_state: bool) -> void:
	OS.set_borderless_window(new_state)
	OS.set_window_maximized(new_state)
	if new_state == true:
		fullscreen_cb.disabled = true
	else:
		fullscreen_cb.disabled = false
