extends Control

@onready var panel_container: PanelContainer = $CenterContainer/PanelContainer
@onready var title_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBox/TitleLabel

@onready var play_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBox/Buttons/PlayButton
@onready var settings_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBox/Buttons/SettingsButton
@onready var quit_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBox/Buttons/QuitButton

# Ambil SettingsManager secara dinamis saat runtime untuk menghindari error parse compile-time
@onready var settings_manager = get_node("/root/SettingsManager")

var settings_scene = preload("res://settings_menu.tscn")

func _ready() -> void:
	# Styling panel secara dinamis untuk memberikan kesan glassmorphism premium
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.08, 0.09, 0.12, 0.9) # Dark navy translucent
	style_box.border_width_left = 2
	style_box.border_width_top = 2
	style_box.border_width_right = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(0.24, 0.51, 0.93, 0.7) # Sleek Blue Border
	style_box.corner_radius_top_left = 12
	style_box.corner_radius_top_right = 12
	style_box.corner_radius_bottom_left = 12
	style_box.corner_radius_bottom_right = 12
	style_box.content_margin_left = 16
	style_box.content_margin_top = 16
	style_box.content_margin_right = 16
	style_box.content_margin_bottom = 16
	panel_container.add_theme_stylebox_override("panel", style_box)
	
	# Menghubungkan signal tombol
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Menghubungkan signal lokalisasi
	settings_manager.settings_changed.connect(_update_locale_texts)
	
	# Mengatur efek interaktif pada tombol-tombol
	_setup_button_effects(play_button)
	_setup_button_effects(settings_button)
	_setup_button_effects(quit_button)
	
	# Update label dan tombol sesuai bahasa terpilih
	_update_locale_texts()
	
	# Animasi masuk (fade in) untuk seluruh menu utama saat dimulai
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.4)

func _update_locale_texts() -> void:
	play_button.text = tr("Start Game")
	settings_button.text = tr("Settings")
	quit_button.text = tr("Exit")

func _setup_button_effects(btn: Button) -> void:
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
