extends CanvasLayer

# Mengontrol panel blok di sisi kiri agar tidak menutupi area permainan.

@onready var sidebar: HBoxContainer = $HBoxContainer
@onready var toggle_button: Button = $ToggleButton

var objective_panel: PanelContainer
var level_select: OptionButton
var desc_label: Label
var progress_label: Label
var hint_label: Label

func _ready() -> void:
	toggle_button.pressed.connect(_on_toggle_pressed)
	_update_toggle_label()
	
	_create_objective_panel()
	
	LevelManager.progress_updated.connect(_on_progress_updated)
	_update_objectives_display()

func _on_toggle_pressed() -> void:
	sidebar.visible = not sidebar.visible
	_update_toggle_label()

func _update_toggle_label() -> void:
	toggle_button.text = "▶ Blok" if not sidebar.visible else "◀ Sembunyikan"

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
	
	# Position at top right (e.g. 16px from top, 16px from right, 300px width)
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
	
	# 1. Level Dropdown (OptionButton)
	var header_hbox = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(header_hbox)
	
	var lvl_lbl = Label.new()
	lvl_lbl.text = "Pilih Level:"
	lvl_lbl.add_theme_font_size_override("font_size", 12)
	lvl_lbl.add_theme_color_override("font_color", Color(0.7, 0.75, 0.8))
	lvl_lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header_hbox.add_child(lvl_lbl)
	
	level_select = OptionButton.new()
	level_select.name = "LevelSelect"
	level_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	level_select.add_theme_font_size_override("font_size", 12)
	
	for lvl in LevelData.get_all():
		level_select.add_item(lvl.title, lvl.id)
		
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
	hint_label.add_theme_color_override("font_color", Color(0.95, 0.8, 0.4, 0.9)) # Gold/yellow
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
	if not level:
		return
		
	# Sync dropdown selection
	for i in level_select.item_count:
		if level_select.get_item_id(i) == LevelManager.current_level_id:
			level_select.selected = i
			break
			
	desc_label.text = level.description
	
	var target_harvest := 0
	var max_steps := -1
	for c in level.conditions:
		if c["type"] == LevelData.ConditionType.HARVEST_COUNT:
			target_harvest = c["target"]
		if c["type"] == LevelData.ConditionType.HARVEST_COUNT_WITH_STEP_LIMIT:
			max_steps = c["max_steps"]
			
	var text_progress = "Panen: %d/%d" % [LevelManager.harvest_count, target_harvest]
	if max_steps > 0:
		text_progress += " | Langkah: %d/%d" % [LevelManager.step_count, max_steps]
	else:
		text_progress += " | Langkah: %d" % LevelManager.step_count
		
	progress_label.text = text_progress
	hint_label.text = "Petunjuk: " + level.hint
