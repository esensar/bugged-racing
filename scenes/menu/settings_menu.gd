extends Panel

onready var master_bus := AudioServer.get_bus_index("Master")
onready var sound_bus := AudioServer.get_bus_index("Sound")
onready var music_bus := AudioServer.get_bus_index("Music")

onready var master_slider: HSlider = $MarginContainer/VSplitContainer/CenterContainer/VBoxContainer/MasterSlider
onready var sound_slider: HSlider = $MarginContainer/VSplitContainer/CenterContainer/VBoxContainer/SoundEffectsSlider
onready var music_slider: HSlider = $MarginContainer/VSplitContainer/CenterContainer/VBoxContainer/MusicSlider
onready var auto_clutch_cb: CheckBox = $MarginContainer/VSplitContainer/CenterContainer/VBoxContainer/AutoClutchCheckBox
onready var automatic_transmission_cb: CheckBox = $MarginContainer/VSplitContainer/CenterContainer/VBoxContainer/AutomaticTransmissionCheckBox
onready var debug_cb: CheckBox = $MarginContainer/VSplitContainer/CenterContainer/VBoxContainer/DebugModeCheckBox

func _ready() -> void:
	master_slider.value = db2linear(AudioServer.get_bus_volume_db(master_bus))
	sound_slider.value = db2linear(AudioServer.get_bus_volume_db(sound_bus))
	music_slider.value = db2linear(AudioServer.get_bus_volume_db(music_bus))
	debug_cb.pressed = GlobalSettings.debug
	auto_clutch_cb.pressed = GlobalSettings.auto_clutch
	automatic_transmission_cb.pressed = GlobalSettings.automatic_transmission


func _on_debug_toggled(new_state: bool) -> void:
	GlobalSettings.debug = new_state


func _on_autoclutch_toggled(new_state: bool) -> void:
	GlobalSettings.auto_clutch = new_state


func _on_automatictransmission_toggled(new_state: bool) -> void:
	GlobalSettings.automatic_transmission = new_state
	auto_clutch_cb.disabled = new_state == true


func _on_BackButton_pressed() -> void:
	get_tree().change_scene("res://scenes/menu/main_menu.tscn")


func _on_MasterSlider_value_changed(new_value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus, linear2db(new_value))


func _on_SoundEffectsSlider_value_changed(new_value: float) -> void:
	AudioServer.set_bus_volume_db(sound_bus, linear2db(new_value))


func _on_MusicSlider_value_changed(new_value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus, linear2db(new_value))
