extends CanvasLayer

@onready var panel_container: PanelContainer = $Overlay/CenterContainer/PanelContainer

@onready var title_label: Label = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBox/TitleLabel
@onready var master_label: Label = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBox/Grid/MasterLabel
@onready var music_label: Label = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBox/Grid/MusicLabel
@onready var sfx_label: Label = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBox/Grid/SFXLabel
@onready var fullscreen_label: Label = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBox/Grid/FullscreenLabel
@onready var resolution_label: Label = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBox/Grid/ResolutionLabel
@onready var language_label: Label = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBox/Grid/LanguageLabel

@onready var master_slider: HSlider = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBox/Grid/MasterSlider
@onready var music_slider: HSlider = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBox/Grid/MusicSlider
@onready var sfx_slider: HSlider = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBox/Grid/SFXSlider
@onready var fullscreen_check: CheckBox = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBox/Grid/FullscreenCheck
@onready var resolution_option: OptionButton = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBox/Grid/ResolutionOption
@onready var language_option: OptionButton = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBox/Grid/LanguageOption

@onready var reset_button: Button = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBox/Buttons/ResetButton
@onready var apply_button: Button = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBox/Buttons/ApplyButton
@onready var close_button: Button = $Overlay/CenterContainer/PanelContainer/MarginContainer/VBox/Buttons/CloseButton

# Ambil SettingsManager secara dinamis saat runtime untuk menghindari error parse compile-time
@onready var settings_manager = get_node("/root/SettingsManager")

var resolutions = ["1280x720", "1366x768", "1600x900", "1920x1080"]
var local_settings = {}

func _ready() -> void:
	# Duplikasi pengaturan ke variabel lokal agar perubahan bersifat sementara sebelum di-apply
	local_settings = settings_manager.settings.duplicate()

	# Styling panel secara dinamis untuk memberikan kesan glassmorphism premium
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.08, 0.09, 0.12, 0.92) # Dark navy translucent
	style_box.border_width_left = 2
	style_box.border_width_top = 2
	style_box.border_width_right = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(0.0, 0.75, 1.0, 0.65) # Neon Cyan
	style_box.corner_radius_top_left = 12
	style_box.corner_radius_top_right = 12
	style_box.corner_radius_bottom_left = 12
	style_box.corner_radius_bottom_right = 12
	style_box.content_margin_left = 16
	style_box.content_margin_top = 16
	style_box.content_margin_right = 16
	style_box.content_margin_bottom = 16
	panel_container.add_theme_stylebox_override("panel", style_box)
	
	# Hubungkan signal
	settings_manager.settings_changed.connect(_on_settings_changed)
	
	master_slider.value_changed.connect(_on_master_slider_changed)
	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	resolution_option.item_selected.connect(_on_resolution_selected)
	language_option.item_selected.connect(_on_language_selected)
	
	reset_button.pressed.connect(_on_reset_pressed)
	apply_button.pressed.connect(_on_apply_pressed)
	close_button.pressed.connect(_on_close_pressed)
	
	# Inisialisasi data resolusi
	resolution_option.clear()
	for res in resolutions:
		resolution_option.add_item(res)
		
	# Inisialisasi data bahasa
	language_option.clear()
	language_option.add_item("Bahasa Indonesia", 0)
	language_option.set_item_metadata(0, "id")
	language_option.add_item("English", 1)
	language_option.set_item_metadata(1, "en")
	
	# Muat nilai dari settings_manager
	_load_ui_values()
	_update_texts()

func _load_ui_values() -> void:
	master_slider.value = local_settings.master_volume
	music_slider.value = local_settings.music_volume
	sfx_slider.value = local_settings.sfx_volume
	fullscreen_check.button_pressed = local_settings.fullscreen
	
	# Pilih resolusi
	var res_idx = resolutions.find(local_settings.resolution)
	if res_idx != -1:
		resolution_option.selected = res_idx
		
	# Pilih bahasa
	if local_settings.language == "en":
		language_option.selected = 1
	else:
		language_option.selected = 0

func _update_texts() -> void:
	title_label.text = tr("PENGATURAN")
	master_label.text = tr("Volume Master")
	music_label.text = tr("Volume Musik")
	sfx_label.text = tr("Volume SFX")
	fullscreen_label.text = tr("Layar Penuh")
	resolution_label.text = tr("Resolusi")
	language_label.text = tr("Bahasa")
	reset_button.text = tr("Reset Progres")
	apply_button.text = tr("Terapkan")
	close_button.text = tr("Tutup")

func _on_settings_changed() -> void:
	_update_texts()

func _on_master_slider_changed(value: float) -> void:
	local_settings.master_volume = value

func _on_music_slider_changed(value: float) -> void:
	local_settings.music_volume = value

func _on_sfx_slider_changed(value: float) -> void:
	local_settings.sfx_volume = value

func _on_fullscreen_toggled(toggled_on: bool) -> void:
	local_settings.fullscreen = toggled_on

func _on_resolution_selected(index: int) -> void:
	local_settings.resolution = resolutions[index]

func _on_language_selected(index: int) -> void:
	var lang = language_option.get_item_metadata(index)
	local_settings.language = lang

func _on_apply_pressed() -> void:
	# Salin pengaturan lokal ke SettingsManager dan simpan secara permanen
	for key in local_settings.keys():
		settings_manager.settings[key] = local_settings[key]
	settings_manager.save_settings()
	settings_manager.apply_settings()

func _is_settings_modified() -> bool:
	var s = settings_manager.settings
	return (
		local_settings.master_volume != s.master_volume or
		local_settings.music_volume != s.music_volume or
		local_settings.sfx_volume != s.sfx_volume or
		local_settings.fullscreen != s.fullscreen or
		local_settings.resolution != s.resolution or
		local_settings.language != s.language
	)

func _show_unsaved_changes_dialog() -> void:
	var confirm = ConfirmationDialog.new()
	confirm.title = tr("Perubahan Belum Disimpan")
	confirm.dialog_text = tr("Apakah Anda ingin menyimpan perubahan sebelum menutup?")
	confirm.get_ok_button().text = tr("Simpan")
	confirm.get_cancel_button().text = tr("Batal")
	
	# Tambahkan tombol "Jangan Simpan" (Discard)
	var discard_btn = confirm.add_button(tr("Jangan Simpan"), true, "discard")
	
	confirm.confirmed.connect(func():
		_on_apply_pressed() # Terapkan perubahan
		confirm.queue_free()
		_close_panel() # Tutup
	)
	
	confirm.custom_action.connect(func(action):
		if action == "discard":
			confirm.queue_free()
			_close_panel() # Tutup tanpa menyimpan
	)
	
	confirm.canceled.connect(func():
		confirm.queue_free() # Tutup dialog konfirmasi, biarkan menu setting tetap terbuka
	)
	
	add_child(confirm)
	confirm.popup_centered()

func _on_reset_pressed() -> void:
	var confirm = ConfirmationDialog.new()
	confirm.title = tr("Konfirmasi")
	confirm.dialog_text = tr("Apakah Anda yakin ingin meriset level kembali ke level 1?")
	confirm.get_ok_button().text = tr("Ya")
	confirm.get_cancel_button().text = tr("Batal")
	
	confirm.confirmed.connect(func():
		LevelManager.load_level(1)
		FarmManager.tiles.clear()
		if get_tree().current_scene.scene_file_path == "res://node_2d.tscn":
			get_tree().reload_current_scene()
		print("Level reset to 1")
		confirm.queue_free()
	)
	
	confirm.canceled.connect(func():
		confirm.queue_free()
	)
	
	add_child(confirm)
	confirm.popup_centered()

func _on_close_pressed() -> void:
	if _is_settings_modified():
		_show_unsaved_changes_dialog()
	else:
		_close_panel()

func _close_panel() -> void:
	var tween = create_tween()
	tween.tween_property($Overlay, "modulate:a", 0.0, 0.15)
	await tween.finished
	queue_free()
