extends PanelContainer

const MAX_BLOCKS = 20
const BLOCK_PANEL_WIDTH = 96
const BLOCK_PANEL_HEIGHT = 26
const DROP_ZONE_HEIGHT = 22
const BLOCK_FONT_SIZE = 11
const INDENT_PX = 12

@onready var slot_container: VBoxContainer = $MarginContainer/VBox/ScrollContainer/SlotContainer
@onready var run_button: Button = $MarginContainer/VBox/ButtonRow/RunButton
@onready var stop_button: Button = $MarginContainer/VBox/ButtonRow/StopButton
@onready var clear_button: Button = $MarginContainer/VBox/ButtonRow/ClearButton
@onready var status_label: Label = $MarginContainer/VBox/StatusLabel
@onready var character: CharacterBody2D = $"../../../CharacterBody2D"

var program: Array[BlockNode] = []
var executor: BlockExecutor = null

func _ready() -> void:
	run_button.pressed.connect(_on_run_pressed)
	stop_button.pressed.connect(_on_stop_pressed)
	clear_button.pressed.connect(_on_clear_pressed)
	stop_button.disabled = true

	LevelManager.progress_updated.connect(_on_progress_updated)
	_on_progress_updated(
		LevelManager.harvest_count,
		_get_harvest_target(),
		LevelManager.step_count,
		_get_max_steps()
	)

	executor = BlockExecutor.new(character)
	executor.execution_finished.connect(_on_execution_finished)
	add_child(executor)

	_refresh_ui()

# ── Drop handling ──────────────────────────────────────────────────────────

func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	if executor.is_running:
		return false
	if not (data is Dictionary and data.has("block_id")):
		return false
	var def := BlockDefinition.get_by_id(data["block_id"])
	if def == null or def.category == BlockDefinition.Category.CONDITION:
		return false
	return _count_nodes(program) < MAX_BLOCKS

func _drop_data(_pos: Vector2, data: Variant) -> void:
	if _count_nodes(program) >= MAX_BLOCKS:
		status_label.text = "Program penuh! (maks %d blok)" % MAX_BLOCKS
		return
	program.append(_make_block_node(data["block_id"]))
	_refresh_ui()
	_update_status()

func _make_block_node(id: String) -> BlockNode:
	var node := BlockNode.new(id)
	if id == "for":
		node.repeat_count = 3
	elif id in ["while", "if"]:
		node.condition_id = "is_harvestable"
	return node

func add_child_block(parent_node: BlockNode, block_id: String) -> void:
	if _count_nodes(program) >= MAX_BLOCKS:
		status_label.text = "Program penuh! (maks %d blok)" % MAX_BLOCKS
		return
	parent_node.children.append(_make_block_node(block_id))
	_refresh_ui()
	_update_status()

# ── UI rendering ───────────────────────────────────────────────────────────

func _refresh_ui() -> void:
	for child in slot_container.get_children():
		child.queue_free()
	_render_program(program, slot_container, 0)
	var busy := executor.is_running
	run_button.disabled = program.is_empty() or busy
	stop_button.disabled = not busy
	clear_button.disabled = program.is_empty() or busy

func _render_program(nodes: Array[BlockNode], container: VBoxContainer, depth: int) -> void:
	for i in nodes.size():
		var node := nodes[i]
		var def := BlockDefinition.get_by_id(node.id)
		if def == null:
			continue

		var indent := depth * INDENT_PX
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 2)

		if indent > 0:
			var spacer := Control.new()
			spacer.custom_minimum_size = Vector2(indent, 0)
			row.add_child(spacer)

		if depth == 0:
			var num := Label.new()
			num.text = "%d." % (i + 1)
			num.custom_minimum_size = Vector2(18, 0)
			num.add_theme_font_size_override("font_size", BLOCK_FONT_SIZE)
			num.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			row.add_child(num)

		var block_panel := PanelContainer.new()
		var style := StyleBoxFlat.new()
		style.bg_color = def.color
		style.set_corner_radius_all(4)
		style.border_width_left = 1
		style.border_width_right = 1
		style.border_width_top = 1
		style.border_width_bottom = 1
		style.border_color = def.color.darkened(0.3)
		block_panel.add_theme_stylebox_override("panel", style)
		block_panel.custom_minimum_size = Vector2(BLOCK_PANEL_WIDTH, BLOCK_PANEL_HEIGHT)

		var label_text := def.label
		if node.id == "for":
			label_text = "for(%d×) {" % node.repeat_count
		elif node.id in ["while", "if"]:
			var cond_def := BlockDefinition.get_by_id(node.condition_id)
			var cond_name := cond_def.label if cond_def else "?"
			label_text = "%s(%s) {" % [node.id, cond_name]

		var lbl := Label.new()
		lbl.text = label_text
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_color_override("font_color", Color.WHITE)
		lbl.add_theme_font_size_override("font_size", BLOCK_FONT_SIZE)
		lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		block_panel.add_child(lbl)
		row.add_child(block_panel)

		var del_btn := Button.new()
		del_btn.text = "×"
		del_btn.custom_minimum_size = Vector2(22, 22)
		del_btn.disabled = executor.is_running
		var captured_nodes := nodes
		var captured_i := i
		del_btn.pressed.connect(func():
			captured_nodes.remove_at(captured_i)
			_refresh_ui()
			_update_status()
		)
		row.add_child(del_btn)
		container.add_child(row)

		if def.has_children:
			if not node.children.is_empty():
				_render_program(node.children, container, depth + 1)
			container.add_child(_make_child_drop_zone(node, depth + 1))

			var close_row := HBoxContainer.new()
			if indent > 0:
				var close_spacer := Control.new()
				close_spacer.custom_minimum_size = Vector2(indent, 0)
				close_row.add_child(close_spacer)
			var close_lbl := Label.new()
			close_lbl.text = "}"
			close_lbl.add_theme_color_override("font_color", def.color)
			close_lbl.add_theme_font_size_override("font_size", BLOCK_FONT_SIZE + 2)
			close_row.add_child(close_lbl)
			container.add_child(close_row)

func _make_child_drop_zone(parent_node: BlockNode, depth: int) -> PanelContainer:
	var zone := PanelContainer.new()
	zone.custom_minimum_size = Vector2(0, DROP_ZONE_HEIGHT)
	zone.mouse_filter = Control.MOUSE_FILTER_STOP
	zone.set_script(load("res://child_drop_zone.gd"))
	zone.set_meta("parent_block", parent_node)
	zone.set_meta("sequence_ref", self)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0.05)
	style.border_color = Color(1, 1, 1, 0.2)
	style.border_width_left = 1
	style.set_corner_radius_all(3)
	zone.add_theme_stylebox_override("panel", style)

	var indent_box := HBoxContainer.new()
	var sp := Control.new()
	sp.custom_minimum_size = Vector2(depth * INDENT_PX, 0)
	indent_box.add_child(sp)
	var hint := Label.new()
	hint.text = "+ drop blok"
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.4))
	hint.add_theme_font_size_override("font_size", 10)
	indent_box.add_child(hint)
	zone.add_child(indent_box)
	return zone

# ── Eksekusi ──────────────────────────────────────────────────────────────

func _on_run_pressed() -> void:
	if program.is_empty() or executor.is_running:
		return
	LevelManager.reset_run()
	run_button.disabled = true
	stop_button.disabled = false
	clear_button.disabled = true
	status_label.text = "Menjalankan..."
	await executor.execute(program)
	_on_execution_finished()

func _on_stop_pressed() -> void:
	executor.stop()

func _on_execution_finished() -> void:
	run_button.disabled = program.is_empty()
	stop_button.disabled = true
	clear_button.disabled = program.is_empty()
	if not LevelManager.level_complete:
		status_label.text = "Selesai ✓"

func _on_clear_pressed() -> void:
	if executor.is_running or program.is_empty():
		return
	program.clear()
	_refresh_ui()
	_update_status()

func _on_progress_updated(harvest: int, target: int, steps: int, max_steps: int) -> void:
	if max_steps > 0:
		status_label.text = "Panen: %d/%d | Langkah: %d/%d" % [harvest, target, steps, max_steps]
	else:
		status_label.text = "Panen: %d/%d" % [harvest, target]

func _update_status() -> void:
	_on_progress_updated(
		LevelManager.harvest_count,
		_get_harvest_target(),
		LevelManager.step_count,
		_get_max_steps()
	)

func _get_harvest_target() -> int:
	var level := LevelManager.get_current_level()
	if level == null:
		return 0
	for c in level.conditions:
		if c["type"] == LevelData.ConditionType.HARVEST_COUNT:
			return c["target"]
	return 0

func _get_max_steps() -> int:
	var level := LevelManager.get_current_level()
	if level == null:
		return -1
	for c in level.conditions:
		if c["type"] == LevelData.ConditionType.HARVEST_COUNT_WITH_STEP_LIMIT:
			return c["max_steps"]
	return -1

func _count_nodes(nodes: Array[BlockNode]) -> int:
	var count := 0
	for node in nodes:
		count += 1
		count += _count_nodes(node.children)
	return count
