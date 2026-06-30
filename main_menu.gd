extends Control

@onready var play_button: TextureButton = $CenterContainer/VBox/Buttons/PlayButton
@onready var settings_button: TextureButton = $CenterContainer/VBox/Buttons/SettingsButton
@onready var quit_button: TextureButton = $CenterContainer/VBox/Buttons/QuitButton

@onready var settings_manager = get_node("/root/SettingsManager")

var settings_scene = preload("res://settings_menu.tscn")

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	settings_manager.settings_changed.connect(_update_locale_texts)
	
	_setup_button_effects(play_button)
	_setup_button_effects(settings_button)
	_setup_button_effects(quit_button)
	
	_update_locale_texts()
	
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.4)

func _update_locale_texts() -> void:
	pass

func _setup_button_effects(btn: TextureButton) -> void:
	btn.pivot_offset = btn.size / 2
	btn.item_rect_changed.connect(func(): btn.pivot_offset = btn.size / 2)
	
	btn.mouse_entered.connect(func():
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(btn, "scale", Vector2(1.05, 1.05), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(btn, "self_modulate", Color(1.1, 1.1, 1.2, 1.0), 0.15)
	)
	
	btn.mouse_exited.connect(func():
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(btn, "self_modulate", Color(1.0, 1.0, 1.0, 1.0), 0.15)
	)

func _on_play_pressed() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	get_tree().change_scene_to_file("res://node_2d.tscn")

func _on_settings_pressed() -> void:
	var settings_instance = settings_scene.instantiate()
	add_child(settings_instance)
	
	var overlay = settings_instance.get_node("Overlay")
	overlay.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, 0.2)

func _on_quit_pressed() -> void:
	get_tree().quit()
