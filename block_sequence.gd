extends PanelContainer

<<<<<<< HEAD
const MAX_BLOCKS = 20
const BLOCK_PANEL_WIDTH = 96
const BLOCK_PANEL_HEIGHT = 26
const DROP_ZONE_HEIGHT = 22
const BLOCK_FONT_SIZE = 11
const INDENT_PX = 12
=======
# BlockSequence.gd
# Panel kanan: slot urutan blok + tombol Run.

const MAX_BLOCKS = 12

@onready var slot_container: VBoxContainer = $MarginContainer/VBox/SlotContainer
@onready var run_button:     Button        = $MarginContainer/VBox/ButtonRow/RunButton
@onready var clear_button:   Button        = $MarginContainer/VBox/ButtonRow/ClearButton
@onready var status_label:   Label         = $MarginContainer/VBox/StatusLabel
>>>>>>> a7c34be5b6467be36097ac77b82f3655f6ff0708

@onready var slot_container: VBoxContainer = $MarginContainer/VBox/ScrollContainer/SlotContainer
@onready var run_button: Button = $MarginContainer/VBox/ButtonRow/RunButton
@onready var stop_button: Button = $MarginContainer/VBox/ButtonRow/StopButton
@onready var clear_button: Button = $MarginContainer/VBox/ButtonRow/ClearButton
@onready var status_label: Label = $MarginContainer/VBox/StatusLabel
@onready var character: CharacterBody2D = $"../../../CharacterBody2D"

<<<<<<< HEAD
var program: Array[BlockNode] = []
var executor: BlockExecutor = null
=======
var sequence: Array = []  # setiap item: {"id": String, "count": int (khusus repeat_start)}
var is_running: bool = false
>>>>>>> a7c34be5b6467be36097ac77b82f3655f6ff0708

func _ready() -> void:
	run_button.pressed.connect(_on_run_pressed)
	stop_button.pressed.connect(_on_stop_pressed)
	clear_button.pressed.connect(_on_clear_pressed)
<<<<<<< HEAD
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
=======
	character.move_blocked.connect(_on_move_blocked)
	_refresh_slots()
>>>>>>> a7c34be5b6467be36097ac77b82f3655f6ff0708

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

<<<<<<< HEAD
func _make_block_node(id: String) -> BlockNode:
	var node := BlockNode.new(id)
	if id == "for":
		node.repeat_count = 3
	elif id in ["while", "if"]:
		node.condition_id = "is_harvestable"
	return node
=======
	var item := {"id": block_id}
	if block_id == "repeat_start":
		item["count"] = data.get("count", 3)

	if data.get("from_sequence", false):
		var from_index := _find_block_index(data.get("source"))
		if from_index < 0:
			return
		sequence.remove_at(from_index)
		if from_index < insert_index:
			insert_index -= 1
		sequence.insert(insert_index, item)
	else:
		if sequence.size() >= MAX_BLOCKS:
			status_label.text = "Slot penuh! (maks %d blok)" % MAX_BLOCKS
			return
		sequence.insert(insert_index, item)
>>>>>>> a7c34be5b6467be36097ac77b82f3655f6ff0708

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

<<<<<<< HEAD
func _render_program(nodes: Array[BlockNode], container: VBoxContainer, depth: int) -> void:
	for i in nodes.size():
		var node := nodes[i]
		var def := BlockDefinition.get_by_id(node.id)
=======
	for i in sequence.size():
		var item = sequence[i]
		var def = _find_def(item["id"])
>>>>>>> a7c34be5b6467be36097ac77b82f3655f6ff0708
		if def == null:
			continue

		var indent := depth * INDENT_PX
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 2)

		if indent > 0:
			var spacer := Control.new()
			spacer.custom_minimum_size = Vector2(indent, 0)
			row.add_child(spacer)

<<<<<<< HEAD
		if depth == 0:
			var num := Label.new()
			num.text = "%d." % (i + 1)
			num.custom_minimum_size = Vector2(18, 0)
			num.add_theme_font_size_override("font_size", BLOCK_FONT_SIZE)
			num.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			row.add_child(num)
=======
		var block = PanelContainer.new()
		block.set_script(load("res://block_ui.gd"))
		var initial_count = item.get("count", 3)
		block.setup(def, true, initial_count)
		block.block_removed.connect(_on_block_removed)
		if item["id"] == "repeat_start":
			block.count_changed.connect(_on_count_changed.bind(i))
		row.add_child(block)
>>>>>>> a7c34be5b6467be36097ac77b82f3655f6ff0708

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

<<<<<<< HEAD
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
=======
		var up_btn = Button.new()
		up_btn.text = "↑"
		up_btn.custom_minimum_size = Vector2(28, 20)
		up_btn.disabled = i == 0 or is_running
		up_btn.pressed.connect(_move_block.bind(i, -1))
		controls.add_child(up_btn)

		var down_btn = Button.new()
		down_btn.text = "↓"
		down_btn.custom_minimum_size = Vector2(28, 20)
		down_btn.disabled = i == sequence.size() - 1 or is_running
		down_btn.pressed.connect(_move_block.bind(i, 1))
		controls.add_child(down_btn)
>>>>>>> a7c34be5b6467be36097ac77b82f3655f6ff0708

		var del_btn := Button.new()
		del_btn.text = "×"
<<<<<<< HEAD
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
=======
		del_btn.custom_minimum_size = Vector2(28, 20)
		del_btn.disabled = is_running
		del_btn.pressed.connect(_remove_at_index.bind(i))
		controls.add_child(del_btn)
>>>>>>> a7c34be5b6467be36097ac77b82f3655f6ff0708

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

func _on_count_changed(new_value: int, index: int) -> void:
	if index >= 0 and index < sequence.size():
		sequence[index]["count"] = new_value

# ── Eksekusi ────────────────────────────────────────────────────────────────

func _on_run_pressed() -> void:
	if program.is_empty() or executor.is_running:
		return
	LevelManager.reset_run()
	run_button.disabled = true
<<<<<<< HEAD
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
=======
	clear_button.disabled = true
	status_label.text = "Menjalankan..."
	await _execute_sequence()

func _execute_sequence() -> void:
	var i = 0
	while i < sequence.size():
		var item = sequence[i]
		var block_id = item["id"]

		if block_id == "repeat_start":
			var end_index = _find_matching_end(i)
			if end_index == -1:
				status_label.text = "🚫 Blok 'Ulangi' butuh pasangan 'Akhir Ulang'!"
				break
			var count = item.get("count", 3)
			for r in count:
				for j in range(i + 1, end_index):
					_highlight_slot(j)
					await _execute_block(sequence[j]["id"])
			i = end_index + 1
		elif block_id == "repeat_end":
			i += 1
		else:
			_highlight_slot(i)
			await _execute_block(block_id)
			i += 1

	_highlight_slot(-1)
	is_running = false
	run_button.disabled = sequence.is_empty()
	clear_button.disabled = sequence.is_empty()
	if status_label.text == "Menjalankan...":
		status_label.text = "Selesai ✓"

func _find_matching_end(start_index: int) -> int:
	for i in range(start_index + 1, sequence.size()):
		if sequence[i]["id"] == "repeat_end":
			return i
	return -1

func _execute_block(block_id: String) -> void:
	match block_id:
		"north":
			character.move_to_grid(Vector2i(0, -1))
			await character.move_finished
		"south":
			character.move_to_grid(Vector2i(0, 1))
			await character.move_finished
		"west":
			character.move_to_grid(Vector2i(-1, 0))
			await character.move_finished
		"east":
			character.move_to_grid(Vector2i(1, 0))
			await character.move_finished
		"plant", "water", "harvest":
			character.do_action(block_id)
			await get_tree().create_timer(0.3).timeout

func _highlight_slot(index: int) -> void:
	var rows = slot_container.get_children()
	for i in rows.size():
		var row = rows[i]
		for child in row.get_children():
			if child is PanelContainer:
				child.modulate = Color(1.4, 1.4, 0.4) if i == index else Color.WHITE

# ── Hapus & atur ulang ────────────────────────────────────────────────────

func _on_block_removed(block_ui) -> void:
	var index := _find_block_index(block_ui)
	if index >= 0:
		_remove_at_index(index)

func _remove_at_index(index: int) -> void:
	if index < 0 or index >= sequence.size() or is_running:
		return
	sequence.remove_at(index)
	_refresh_slots()
	status_label.text = ""

func _move_block(index: int, direction: int) -> void:
	if is_running:
		return
	var new_index := index + direction
	if new_index < 0 or new_index >= sequence.size():
		return
	var item = sequence[index]
	sequence.remove_at(index)
	sequence.insert(new_index, item)
	_refresh_slots()
>>>>>>> a7c34be5b6467be36097ac77b82f3655f6ff0708

func _on_clear_pressed() -> void:
	if executor.is_running or program.is_empty():
		return
	program.clear()
	_refresh_ui()
	_update_status()

<<<<<<< HEAD
func _on_progress_updated(harvest: int, target: int, steps: int, max_steps: int) -> void:
	if max_steps > 0:
		status_label.text = "Panen: %d/%d | Langkah: %d/%d" % [harvest, target, steps, max_steps]
	else:
		status_label.text = "Panen: %d/%d" % [harvest, target]
=======
func _on_move_blocked() -> void:
	status_label.text = "🚫 Robot terhalang, tidak bisa lewat!"

# ── Helper ────────────────────────────────────────────────────────────────
>>>>>>> a7c34be5b6467be36097ac77b82f3655f6ff0708

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
