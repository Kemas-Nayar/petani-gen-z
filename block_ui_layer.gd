extends CanvasLayer

# block_ui_layer.gd
# Mengontrol panel blok di sisi kiri agar tidak menutupi area permainan.

@onready var sidebar: HBoxContainer = $HBoxContainer
@onready var toggle_button: Button = $ToggleButton

# Referensi ke label-label dan tombol-tombol internal untuk lokalisasi
@onready var label_available_blocks: Label = $HBoxContainer/BlockPalette/MarginContainer/ScrollContainer/VBox/Label
@onready var label_move_section: Label = $HBoxContainer/BlockPalette/MarginContainer/ScrollContainer/VBox/MoveSection/Label
@onready var label_action_section: Label = $HBoxContainer/BlockPalette/MarginContainer/ScrollContainer/VBox/ActionSection/Label
@onready var label_control_section: Label = $HBoxContainer/BlockPalette/MarginContainer/ScrollContainer/VBox/ControlSection/Label
@onready var label_condition_section: Label = $HBoxContainer/BlockPalette/MarginContainer/ScrollContainer/VBox/ConditionSection/Label
@onready var label_block_sequence: Label = $HBoxContainer/BlockSequence/MarginContainer/VBox/Label
@onready var run_button: Button = $HBoxContainer/BlockSequence/MarginContainer/VBox/ButtonRow/RunButton
@onready var stop_button: Button = $HBoxContainer/BlockSequence/MarginContainer/VBox/ButtonRow/StopButton
@onready var clear_button: Button = $HBoxContainer/BlockSequence/MarginContainer/VBox/ButtonRow/ClearButton
@onready var reset_map_button: Button = $HBoxContainer/BlockSequence/MarginContainer/VBox/ButtonRow/ResetMapButton

var objective_panel: PanelContainer
var level_select: OptionButton
var desc_label: Label
var progress_label: Label
var hint_label: Label
var menu_button: Button

# Ambil SettingsManager secara dinamis saat runtime untuk menghindari error parse compile-time
@onready var settings_manager = get_node("/root/SettingsManager")

func _ready() -> void:
	toggle_button.pressed.connect(_on_toggle_pressed)
	_update_toggle_label()
	
	_create_objective_panel()
	_create_menu_button()
	
	LevelManager.progress_updated.connect(_on_progress_updated)
	settings_manager.settings_changed.connect(_on_settings_changed)
	
	_update_objectives_display()
	_update_ui_translations()

func _on_toggle_pressed() -> void:
	sidebar.visible = not sidebar.visible
	_update_toggle_label()

func _update_toggle_label() -> void:
	toggle_button.text = tr("▶ Blocks") if not sidebar.visible else tr("◀ Hide")

func _create_menu_button() -> void:
	menu_button = Button.new()
	menu_button.name = "MenuButton"
	
	menu_button.text = tr("⚙️ Menu")
	menu_button.offset_left = 136
	menu_button.offset_top = 8
	menu_button.offset_right = 236
	menu_button.offset_bottom = 36
	
	menu_button.pressed.connect(_on_menu_pressed)
	add_child(menu_button)

func _on_menu_pressed() -> void:
	var settings_scene = load("res://settings_menu.tscn")
	var settings_instance = settings_scene.instantiate()
	add_child(settings_instance)
	
	var overlay = settings_instance.get_node("Overlay")
	overlay.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, 0.15)

func _on_settings_changed() -> void:
	_update_ui_translations()
	_update_objectives_display()
	_update_toggle_label()

func _update_ui_translations() -> void:
	if menu_button:
		menu_button.text = tr("⚙️ Menu")
		
	# Update label statis
	label_available_blocks.text = tr("Available Blocks")
	label_move_section.text = tr("🔵 Movement")
	label_action_section.text = tr("🟢 Action")
	label_control_section.text = tr("🟣 Control")
	label_condition_section.text = tr("🟡 Condition")
	label_block_sequence.text = tr("Block Sequence")
	
	# Update tombol kontrol sequence
	run_button.text = tr("▶ Run")
	stop_button.text = tr("⏹ Stop")
	clear_button.text = tr("Clear All")
	reset_map_button.text = tr("🔄 Reset Map")
	
	# Update teks statis di panel objektif
	var lvl_lbl = objective_panel.find_child("LevelSelectLabel", true, false)
	if lvl_lbl:
		lvl_lbl.text = tr("Select Level:")
		
	# Refresh level items text di dropdown
	level_select.clear()
	for lvl in LevelData.get_all():
		level_select.add_item(tr(lvl.title), lvl.id)
		
	# Cari kembali indeks level aktif agar dropdown sync
	for i in level_select.item_count:
		if level_select.get_item_id(i) == LevelManager.current_level_id:
			level_select.select(i)
			break

func _create_objective_panel() -> void:
	objective_panel = PanelContainer.new()
	objective_panel.name = "ObjectivePanel"
	
	# Set anchoring to top-right
	objective_panel.anchor_left = 1.0
	objective_panel.anchor_top = 0.0
	objective_panel.anchor_right = 1.0
	objective_panel.anchor_bottom = 0.0
	
	objective_panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	objective_panel.grow_vertical = Control.GROW_DIRECTION_END
	
	# Position at top right
	objective_panel.offset_left = -320
	objective_panel.offset_top = 16
	objective_panel.offset_right = -16
	
	# Style the panel (sleek glassmorphism style)
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.08, 0.09, 0.12, 0.85) # Dark slate translucent
	style_box.border_width_left = 2
	style_box.border_width_top = 2
	style_box.border_width_right = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(0.24, 0.51, 0.93, 0.6) # Sleek blue border
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	style_box.content_margin_left = 12
	style_box.content_margin_top = 12
	style_box.content_margin_right = 12
	style_box.content_margin_bottom = 12
	objective_panel.add_theme_stylebox_override("panel", style_box)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	objective_panel.add_child(vbox)
	
	# 1. Level Dropdown
	var header_hbox = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(header_hbox)
	
	var lvl_lbl = Label.new()
	lvl_lbl.name = "LevelSelectLabel"
	lvl_lbl.text = tr("Select Level:")
	lvl_lbl.add_theme_font_size_override("font_size", 12)
	lvl_lbl.add_theme_color_override("font_color", Color(0.7, 0.75, 0.8))
	lvl_lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header_hbox.add_child(lvl_lbl)
	
	level_select = OptionButton.new()
	level_select.name = "LevelSelect"
	level_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	level_select.add_theme_font_size_override("font_size", 12)
	
	for lvl in LevelData.get_all():
		level_select.add_item(tr(lvl.title), lvl.id)
		
	level_select.item_selected.connect(_on_level_selected)
	header_hbox.add_child(level_select)
	
	# Separator line
	var sep = ColorRect.new()
	sep.custom_minimum_size = Vector2(0, 1)
	sep.color = Color(0.24, 0.51, 0.93, 0.4)
	vbox.add_child(sep)
	
	# 2. Description Label
	desc_label = Label.new()
	desc_label.name = "DescLabel"
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", Color(0.8, 0.82, 0.86, 1.0))
	vbox.add_child(desc_label)
	
	# 3. Progress Label
	progress_label = Label.new()
	progress_label.name = "ProgressLabel"
	progress_label.add_theme_font_size_override("font_size", 13)
	progress_label.add_theme_color_override("font_color", Color(0.35, 0.85, 0.45, 1.0)) # Green
	vbox.add_child(progress_label)
	
	# 4. Hint Label
	hint_label = Label.new()
	hint_label.name = "HintLabel"
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	hint_label.add_theme_font_size_override("font_size", 11)
	hint_label.add_theme_color_override("font_color", Color(0.95, 0.8, 0.4, 0.9)) # Gold
	vbox.add_child(hint_label)
	
	add_child(objective_panel)

func _on_progress_updated(_harvest: int, _target: int, _steps: int, _max_steps: int) -> void:
	_update_objectives_display()

func _on_level_selected(index: int) -> void:
	var level_id = level_select.get_item_id(index)
	if level_id != LevelManager.current_level_id:
		LevelManager.load_level(level_id)
		FarmManager.tiles.clear()
		get_tree().reload_current_scene()

func _update_objectives_display() -> void:
	var level := LevelManager.get_current_level()
	if not level or not level_select:
		return
		
	# Sync dropdown selection
	for i in level_select.item_count:
		if level_select.get_item_id(i) == LevelManager.current_level_id:
			level_select.select(i)
			break
			
	desc_label.text = tr(level.description)
	
	var target_harvest := 0
	var max_steps := -1
	for c in level.conditions:
		if c["type"] == LevelData.ConditionType.HARVEST_COUNT:
			target_harvest = c["target"]
		if c["type"] == LevelData.ConditionType.HARVEST_COUNT_WITH_STEP_LIMIT:
			max_steps = c["max_steps"]
			
	var text_progress = tr("Harvest:") + " %d/%d" % [LevelManager.harvest_count, target_harvest]
	if max_steps > 0:
		text_progress += " | " + tr("Steps:") + " %d/%d" % [LevelManager.step_count, max_steps]
	else:
		text_progress += " | " + tr("Steps:") + " %d" % LevelManager.step_count
		
	progress_label.text = text_progress
	
	hint_label.text = tr("Hint: ") + tr(level.hint)
