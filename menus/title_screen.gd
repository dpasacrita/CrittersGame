extends Control

@onready var title_label: Label = $CenterContainer/VBoxContainer/TitleLabel
@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var settings_button: Button = $CenterContainer/VBoxContainer/SettingsButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton


func _ready() -> void:
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 72)

	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://match/game_screen.tscn")


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/settings_screen.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
