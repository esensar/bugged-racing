extends Panel

onready var master_bus := AudioServer.get_bus_index("Master")
onready var sound_bus := AudioServer.get_bus_index("Sound")
onready var music_bus := AudioServer.get_bus_index("Music")

# gdlint: ignore=max-line-length
onready var master_slider: HSlider = $MarginContainer/VSplitContainer/CenterContainer/VBoxContainer/MasterSlider
# gdlint: ignore=max-line-length
onready var sound_slider: HSlider = $MarginContainer/VSplitContainer/CenterContainer/VBoxContainer/SoundEffectsSlider
# gdlint: ignore=max-line-length
onready var music_slider: HSlider = $MarginContainer/VSplitContainer/CenterContainer/VBoxContainer/MusicSlider
# gdlint: ignore=max-line-length
onready var auto_clutch_cb: CheckBox = $MarginContainer/VSplitContainer/CenterContainer/VBoxContainer/AutoClutchCheckBox
# gdlint: ignore=max-line-length
onready var automatic_transmission_cb: CheckBox = $MarginContainer/VSplitContainer/CenterContainer/VBoxContainer/AutomaticTransmissionCheckBox
# gdlint: ignore=max-line-length
onready var debug_cb: CheckBox = $MarginContainer/VSplitContainer/CenterContainer/VBoxContainer/DebugModeCheckBox
# gdlint: ignore=max-line-length
onready var fullscreen_cb: CheckBox = $MarginContainer/VSplitContainer/CenterContainer/VBoxContainer/FullscreenCheckBox
# gdlint: ignore=max-line-length
onready var borderless_cb: CheckBox = $MarginContainer/VSplitContainer/CenterContainer/VBoxContainer/BorderlessCheckBox


func _ready() -> void:
	master_slider.value = db2linear(AudioServer.get_bus_volume_db(master_bus))
	sound_slider.value = db2linear(AudioServer.get_bus_volume_db(sound_bus))
	music_slider.value = db2linear(AudioServer.get_bus_volume_db(music_bus))
	debug_cb.pressed = GlobalSettings.debug
	auto_clutch_cb.pressed = GlobalSettings.auto_clutch
	automatic_transmission_cb.pressed = GlobalSettings.automatic_transmission
	fullscreen_cb.pressed = false
	borderless_cb.pressed = false
	if OS.is_window_fullscreen():
		_set_fullscreen(true)
	if OS.get_borderless_window():
		_set_borderless(true)


func _on_debug_toggled(new_state: bool) -> void:
	GlobalSettings.debug = new_state


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
	get_tree().change_scene("res://menu/main_menu.tscn")


func _on_MasterSlider_value_changed(new_value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus, linear2db(new_value))


func _on_SoundEffectsSlider_value_changed(new_value: float) -> void:
	AudioServer.set_bus_volume_db(sound_bus, linear2db(new_value))


func _on_MusicSlider_value_changed(new_value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus, linear2db(new_value))


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
