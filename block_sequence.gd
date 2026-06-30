extends PanelContainer
class_name BlockSequence


const MAX_BLOCKS = 20

@onready var slot_container: VBoxContainer = $MarginContainer/VBox/ScrollContainer/SlotContainer
@onready var scroll_container: ScrollContainer = $MarginContainer/VBox/ScrollContainer
@onready var run_button:     Button        = $MarginContainer/VBox/ButtonRow/RunButton
@onready var stop_button:    Button        = $MarginContainer/VBox/ButtonRow/StopButton
@onready var clear_button:   Button        = $MarginContainer/VBox/ButtonRow/ClearButton
@onready var reset_map_button: Button      = $MarginContainer/VBox/ButtonRow/ResetMapButton
@onready var status_label:   Label         = $MarginContainer/VBox/StatusLabel
@onready var character: FarmCharacter = $"../../../CharacterBody2D"
@onready var palette: PanelContainer      = $"../BlockPalette"

var program: Array[BlockNode] = []
var executor: BlockExecutor = null
var _highlighted_block: BlockNode = null

func _ready():
	run_button.pressed.connect(_on_run_pressed)
	stop_button.pressed.connect(_on_stop_pressed)
	stop_button.disabled = true
	clear_button.pressed.connect(_on_clear_pressed)
	reset_map_button.pressed.connect(_on_reset_map_pressed)

	if palette.has_signal("block_selected"):
		palette.block_selected.connect(_on_palette_block_selected)

	_setup_drop_target(self)
	_setup_drop_target(scroll_container)
	_setup_drop_target(slot_container)

	LevelManager.load_level(LevelManager.current_level_id)
	LevelManager.progress_updated.connect(_on_progress_updated)

	executor = BlockExecutor.new(character)
	executor.execution_finished.connect(_on_execution_finished)
	executor.block_highlighted.connect(_on_block_highlighted)
	add_child(executor)

	var settings_manager = get_node_or_null("/root/SettingsManager")
	if settings_manager:
		settings_manager.settings_changed.connect(_on_settings_changed)

	_refresh_ui()

func _on_settings_changed() -> void:
	_refresh_ui()

func _setup_drop_target(control: Control) -> void:
	control.mouse_filter = Control.MOUSE_FILTER_STOP
	control.set_drag_forwarding(
		Callable(),
		Callable(self, "_can_drop_data"),
		Callable(self, "_drop_data")
	)

func _on_palette_block_selected(block_id: String) -> void:
	add_block_to_program(block_id)


func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	if executor.is_running:
		return false
	if not (data is Dictionary and data.has("block_id")):
		return false
	if data.get("reorder", false):
		return data.has("source_nodes")
	return _is_valid_top_level_block(data["block_id"])

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data.get("reorder", false):
		var source_nodes: Array = data["source_nodes"]
		if source_nodes == program:
			var insert_index := _get_insert_index_for_list(at_position, program)
			reorder_block_in_list(program, data["source_index"], insert_index)
		else:
			var block: BlockNode = source_nodes[data["source_index"]]
			source_nodes.remove_at(data["source_index"])
			var insert_index := _get_insert_index_for_list(at_position, program)
			program.insert(clampi(insert_index, 0, program.size()), block)
			_refresh_ui()
	else:
		var insert_index := _get_insert_index_for_list(at_position, program)
		add_block_to_program(data["block_id"], insert_index)

func _can_drop_on_row(_at_position: Vector2, data: Variant, target_row: Control) -> bool:
	if executor.is_running:
		return false
	if not (data is Dictionary and data.has("block_id")):
		return false

	var dragged_def = BlockDefinition.get_by_id(data["block_id"])
	if dragged_def and dragged_def.category == BlockDefinition.Category.CONDITION:
		var target_nodes = target_row.block_nodes
		var target_index = target_row.block_index
		if target_index >= 0 and target_index < target_nodes.size():
			var target_node = target_nodes[target_index]
			if target_node.id in ["while", "if"]:
				return true
		return false

	if data.get("reorder", false):
		return true

	return _is_valid_top_level_block(data["block_id"])

func _drop_on_row(at_position: Vector2, data: Variant, target_row: Control) -> void:
	var target_nodes: Array = target_row.get_meta("block_nodes")

	var dragged_def = BlockDefinition.get_by_id(data["block_id"])
	if dragged_def and dragged_def.category == BlockDefinition.Category.CONDITION:
		var target_index = target_row.block_index
		if target_index >= 0 and target_index < target_nodes.size():
			var target_node = target_nodes[target_index]
			if target_node.id in ["while", "if"]:
				target_node.condition_id = data["block_id"]
				_refresh_ui()
				return

	if data.get("reorder", false):
		var source_nodes: Array = data["source_nodes"]
		if source_nodes == target_nodes:
			var insert_index := _get_insert_index_before_row(at_position, target_row, target_nodes)
			reorder_block_in_list(target_nodes, data["source_index"], insert_index)
		else:
			var block: BlockNode = source_nodes[data["source_index"]]
			source_nodes.remove_at(data["source_index"])
			var insert_index := _get_insert_index_before_row(at_position, target_row, target_nodes)
			target_nodes.insert(clampi(insert_index, 0, target_nodes.size()), block)
			_refresh_ui()
	else:
		var insert_index := _get_insert_index_before_row(at_position, target_row, target_nodes)
		add_block_to_list(data["block_id"], target_nodes, insert_index)


func _is_valid_top_level_block(block_id: String) -> bool:
	var def := BlockDefinition.get_by_id(block_id)
	if def == null:
		return false
	return def.category != BlockDefinition.Category.CONDITION

func count_total_blocks(nodes: Array[BlockNode]) -> int:
	var total = 0
	for node in nodes:
		total += 1
		total += count_total_blocks(node.children)
	return total

func add_block_to_list(block_id: String, list: Array, insert_index: int = -1) -> void:
	if executor.is_running:
		return
	if not _is_valid_top_level_block(block_id):
		status_label.text = tr("Condition blocks can only be inside for/while/if.")
		return
	if count_total_blocks(program) >= MAX_BLOCKS:
		status_label.text = tr("Program full!")
		return

	var node := _make_block_node(block_id)
	if insert_index < 0 or insert_index >= list.size():
		list.append(node)
	else:
		list.insert(insert_index, node)
	status_label.text = ""
	_refresh_ui()

func add_block_to_program(block_id: String, insert_index: int = -1) -> void:
	add_block_to_list(block_id, program, insert_index)

func _get_insert_index_for_list(at_position: Vector2, nodes: Array[BlockNode]) -> int:
	var rows := _get_rows_for_list(nodes)
	if rows.is_empty():
		return nodes.size()

	var local_pos := slot_container.get_global_transform().affine_inverse() * at_position
	for row in rows:
		var row_center_y := row.position.y + row.size.y * 0.5
		if local_pos.y < row_center_y:
			return row.get_meta("block_index")
	return nodes.size()

func _get_insert_index_before_row(at_position: Vector2, target_row: Control, nodes: Array[BlockNode]) -> int:
	var target_index: int = target_row.get_meta("block_index")
	var local_pos := slot_container.get_global_transform().affine_inverse() * at_position
	var row_center_y := target_row.position.y + target_row.size.y * 0.5
	if local_pos.y < row_center_y:
		return target_index
	return target_index + 1

func _get_rows_for_list(nodes: Array[BlockNode]) -> Array[Control]:
	var rows: Array[Control] = []
	for child in slot_container.get_children():
		if child.has_meta("block_nodes") and child.get_meta("block_nodes") == nodes:
			rows.append(child)
	rows.sort_custom(func(a: Control, b: Control) -> bool:
		return a.get_meta("block_index") < b.get_meta("block_index")
	)
	return rows

func move_block_up(nodes: Array[BlockNode], index: int) -> void:
	if index <= 0 or index >= nodes.size():
		return
	var temp := nodes[index]
	nodes[index] = nodes[index - 1]
	nodes[index - 1] = temp
	_refresh_ui()

func move_block_down(nodes: Array[BlockNode], index: int) -> void:
	if index < 0 or index >= nodes.size() - 1:
		return
	var temp := nodes[index]
	nodes[index] = nodes[index + 1]
	nodes[index + 1] = temp
	_refresh_ui()

func reorder_block_in_list(nodes: Array[BlockNode], from_index: int, insert_index: int) -> void:
	if from_index < 0 or from_index >= nodes.size():
		return

	insert_index = clampi(insert_index, 0, nodes.size())
	var block := nodes[from_index]
	nodes.remove_at(from_index)
	if from_index < insert_index:
		insert_index -= 1
	if from_index == insert_index:
		nodes.insert(from_index, block)
		return

	nodes.insert(insert_index, block)
	_refresh_ui()

func _make_block_node(id: String) -> BlockNode:
	var node = BlockNode.new(id)
	if id == "for":
		node.repeat_count = 4
	elif id in ["while", "if"]:
		node.condition_id = "is_harvestable"
	elif id == "wait":
		node.wait_time = 1.0
	return node


func _refresh_ui() -> void:
	for child in slot_container.get_children():
		child.queue_free()

	if program.is_empty():
		var hint := Label.new()
		hint.text = tr("Click or drag blocks here")
		hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.35))
		hint.add_theme_font_size_override("font_size", 13)
		hint.custom_minimum_size = Vector2(0, 80)
		_setup_drop_target(hint)
		slot_container.add_child(hint)
	else:
		_render_program(program, slot_container, 0)

	run_button.disabled = program.is_empty() or executor.is_running


func _on_block_highlighted(block_node: BlockNode, _depth: int) -> void:
	_highlighted_block = block_node
	_apply_highlight_to_rows()

func _apply_highlight_to_rows() -> void:
	for child in slot_container.get_children():
		_apply_highlight_recursive(child)

func _apply_highlight_recursive(node: Node) -> void:
	if node.has_meta("block_node_ref"):
		var block_ref: BlockNode = node.get_meta("block_node_ref")
		var block_panel = node.get_meta("block_panel_ref") if node.has_meta("block_panel_ref") else null
		if block_panel:
			if block_ref == _highlighted_block:
				_set_highlight_style(block_panel, true)
			else:
				_set_highlight_style(block_panel, false)
	for child in node.get_children():
		_apply_highlight_recursive(child)

func _set_highlight_style(panel: PanelContainer, active: bool) -> void:
	var style := panel.get_theme_stylebox("panel") as StyleBoxFlat
	if style == null:
		return
	if active:
		style.border_color  = Color(1.0, 0.95, 0.2, 1.0)
		style.border_width_left   = 3
		style.border_width_top    = 3
		style.border_width_right  = 3
		style.border_width_bottom = 3
		style.shadow_color = Color(1.0, 0.9, 0.0, 0.6)
		style.shadow_size  = 8
	else:
		style.border_width_left   = 0
		style.border_width_top    = 0
		style.border_width_right  = 0
		style.border_width_bottom = 0
		style.shadow_size = 0

func _clear_all_highlights() -> void:
	_highlighted_block = null
	_apply_highlight_to_rows()

func _make_reorder_button(label: String, disabled: bool, callback: Callable) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.custom_minimum_size = Vector2(28, 28)
	btn.disabled = disabled
	btn.pressed.connect(callback)
	return btn

func _render_program(nodes: Array[BlockNode], container: VBoxContainer, depth: int) -> void:
	for i in nodes.size():
		var node = nodes[i]
		var def = BlockDefinition.get_by_id(node.id)
		if def == null:
			continue

		var indent = depth * 16
		var captured_nodes := nodes
		var captured_i := i

		var row: HBoxContainer = HBoxContainer.new()
		row.set_script(load("res://sequence_block_row.gd"))
		row.sequence_ref = self
		row.block_nodes = captured_nodes
		row.block_index = captured_i
		row.depth = depth
		row.add_theme_constant_override("separation", 4)
		row.set_meta("block_nodes", captured_nodes)
		row.set_meta("block_index", captured_i)
		row.set_meta("depth", depth)
		row.tooltip_text = "Drag untuk ubah urutan"

		if indent > 0:
			var spacer = Control.new()
			spacer.custom_minimum_size = Vector2(indent, 0)
			spacer.mouse_filter = Control.MOUSE_FILTER_PASS
			row.add_child(spacer)

		if depth == 0:
			var num = Label.new()
			num.text = "%d." % (i + 1)
			num.custom_minimum_size = Vector2(22, 0)
			num.add_theme_font_size_override("font_size", 13)
			num.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			num.mouse_filter = Control.MOUSE_FILTER_PASS
			row.add_child(num)

		var block_panel = PanelContainer.new()
		var style = StyleBoxFlat.new()
		style.bg_color = def.color
		style.corner_radius_top_left = 6
		style.corner_radius_top_right = 6
		style.corner_radius_bottom_left = 6
		style.corner_radius_bottom_right = 6
		block_panel.add_theme_stylebox_override("panel", style)
		block_panel.custom_minimum_size = Vector2(170 if (def.has_children or def.id == "wait") else 120, 36)
		block_panel.mouse_filter = Control.MOUSE_FILTER_PASS
		row.set_meta("block_node_ref",  node)
		row.set_meta("block_panel_ref", block_panel)

		if node.id == "for":
			var hbox := HBoxContainer.new()
			hbox.alignment = BoxContainer.ALIGNMENT_CENTER
			hbox.add_theme_constant_override("separation", 2)
			
			var lbl1 := Label.new()
			lbl1.text = tr("for") + "("
			lbl1.add_theme_color_override("font_color", Color.WHITE)
			lbl1.add_theme_font_size_override("font_size", 13)
			hbox.add_child(lbl1)
			
			var line_edit := LineEdit.new()
			line_edit.text = str(node.repeat_count)
			line_edit.custom_minimum_size = Vector2(40, 24)
			line_edit.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			line_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
			line_edit.add_theme_font_size_override("font_size", 12)
			
			line_edit.text_changed.connect(func(new_text: String):
				var filtered := ""
				for char in new_text:
					if char >= "0" and char <= "9":
						filtered += char
				if filtered != new_text:
					line_edit.text = filtered
					line_edit.caret_column = filtered.length()
				if filtered.is_valid_int():
					node.repeat_count = clampi(filtered.to_int(), 1, 999)
			)
			hbox.add_child(line_edit)
			
			var lbl2 := Label.new()
			lbl2.text = "×) {"
			lbl2.add_theme_color_override("font_color", Color.WHITE)
			lbl2.add_theme_font_size_override("font_size", 13)
			hbox.add_child(lbl2)
			
			block_panel.add_child(hbox)
		elif node.id == "wait":
			var hbox := HBoxContainer.new()
			hbox.alignment = BoxContainer.ALIGNMENT_CENTER
			hbox.add_theme_constant_override("separation", 2)
			
			var lbl1 := Label.new()
			lbl1.text = tr("wait") + "("
			lbl1.add_theme_color_override("font_color", Color.WHITE)
			lbl1.add_theme_font_size_override("font_size", 13)
			hbox.add_child(lbl1)
			
			var line_edit := LineEdit.new()
			line_edit.text = str(node.wait_time)
			line_edit.custom_minimum_size = Vector2(40, 24)
			line_edit.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			line_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
			line_edit.add_theme_font_size_override("font_size", 12)
			
			line_edit.text_changed.connect(func(new_text: String):
				var filtered := ""
				var has_dot := false
				for char in new_text:
					if char >= "0" and char <= "9":
						filtered += char
					elif char == "." and not has_dot:
						filtered += char
						has_dot = true
				if filtered != new_text:
					line_edit.text = filtered
					line_edit.caret_column = filtered.length()
				if filtered.is_valid_float():
					node.wait_time = maxf(filtered.to_float(), 0.0)
			)
			hbox.add_child(line_edit)
			
			var lbl2 := Label.new()
			lbl2.text = tr("s)")
			lbl2.add_theme_color_override("font_color", Color.WHITE)
			lbl2.add_theme_font_size_override("font_size", 13)
			hbox.add_child(lbl2)
			
			block_panel.add_child(hbox)
		elif node.id in ["while", "if"]:
			var hbox := HBoxContainer.new()
			hbox.alignment = BoxContainer.ALIGNMENT_CENTER
			hbox.add_theme_constant_override("separation", 2)
			
			var lbl1 := Label.new()
			lbl1.text = "%s(" % tr(node.id)
			lbl1.add_theme_color_override("font_color", Color.WHITE)
			lbl1.add_theme_font_size_override("font_size", 13)
			hbox.add_child(lbl1)
			
			var cond_panel := PanelContainer.new()
			var cond_style := StyleBoxFlat.new()
			var cond_def = BlockDefinition.get_by_id(node.condition_id)
			cond_style.bg_color = cond_def.color if cond_def else Color(0.75, 0.65, 0.00)
			cond_style.corner_radius_top_left = 4
			cond_style.corner_radius_top_right = 4
			cond_style.corner_radius_bottom_left = 4
			cond_style.corner_radius_bottom_right = 4
			cond_panel.add_theme_stylebox_override("panel", cond_style)
			cond_panel.custom_minimum_size = Vector2(80, 24)
			cond_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			
			var cond_margin := MarginContainer.new()
			cond_margin.add_theme_constant_override("margin_left", 4)
			cond_margin.add_theme_constant_override("margin_right", 4)
			cond_panel.add_child(cond_margin)
			
			var cond_lbl := Label.new()
			cond_lbl.text = tr(cond_def.label) if cond_def else "?"
			cond_lbl.add_theme_color_override("font_color", Color.WHITE)
			cond_lbl.add_theme_font_size_override("font_size", 11)
			cond_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			cond_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			cond_margin.add_child(cond_lbl)
			
			hbox.add_child(cond_panel)
			
			var lbl2 := Label.new()
			lbl2.text = ") {"
			lbl2.add_theme_color_override("font_color", Color.WHITE)
			lbl2.add_theme_font_size_override("font_size", 13)
			hbox.add_child(lbl2)
			
			block_panel.add_child(hbox)
		elif node.id == "else":
			var lbl = Label.new()
			lbl.text = tr("else") + " {"
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lbl.add_theme_color_override("font_color", Color.WHITE)
			lbl.add_theme_font_size_override("font_size", 13)
			lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			lbl.mouse_filter = Control.MOUSE_FILTER_PASS
			block_panel.add_child(lbl)
		else:
			var lbl = Label.new()
			lbl.text = tr(def.label)
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lbl.add_theme_color_override("font_color", Color.WHITE)
			lbl.add_theme_font_size_override("font_size", 13)
			lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			lbl.mouse_filter = Control.MOUSE_FILTER_PASS
			block_panel.add_child(lbl)
			
		row.add_child(block_panel)


		var up_btn := _make_reorder_button("▲", i == 0, func(): move_block_up(captured_nodes, captured_i))
		var down_btn := _make_reorder_button("▼", i >= nodes.size() - 1, func(): move_block_down(captured_nodes, captured_i))
		row.add_child(up_btn)
		row.add_child(down_btn)

		var del_btn = Button.new()
		del_btn.text = "✕"
		del_btn.custom_minimum_size = Vector2(28, 28)
		del_btn.pressed.connect(func():
			captured_nodes.remove_at(captured_i)
			_refresh_ui()
		)
		row.add_child(del_btn)

		container.add_child(row)

		if def.has_children:
			if not node.children.is_empty():
				_render_program(node.children, container, depth + 1)

			var drop_zone = _make_child_drop_zone(node, depth + 1)
			container.add_child(drop_zone)

			var close_row = HBoxContainer.new()
			var close_spacer = Control.new()
			close_spacer.custom_minimum_size = Vector2(indent, 0)
			close_row.add_child(close_spacer)
			var close_lbl = Label.new()
			close_lbl.text = "}"
			close_lbl.add_theme_color_override("font_color", def.color)
			close_lbl.add_theme_font_size_override("font_size", 16)
			close_row.add_child(close_lbl)
			container.add_child(close_row)

func _make_child_drop_zone(parent_node: BlockNode, depth: int) -> Control:
	var zone = PanelContainer.new()
	zone.custom_minimum_size = Vector2(0, 32)

	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0.05)
	style.border_color = Color(1, 1, 1, 0.2)
	style.border_width_left = 2
	style.set_corner_radius_all(4)
	zone.add_theme_stylebox_override("panel", style)

	var indent_box = HBoxContainer.new()
	var sp = Control.new()
	sp.custom_minimum_size = Vector2(depth * 16, 0)
	indent_box.add_child(sp)
	var hint = Label.new()
	hint.text = tr("  + drop block here")
	hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.4))
	hint.add_theme_font_size_override("font_size", 12)
	indent_box.add_child(hint)
	zone.add_child(indent_box)

	zone.set_script(load("res://child_drop_zone.gd") if ResourceLoader.exists("res://child_drop_zone.gd") else null)

	zone.set_meta("parent_block", parent_node)
	zone.set_meta("sequence_ref", self)

	zone.mouse_filter = Control.MOUSE_FILTER_STOP
	return zone

func add_child_block(parent_node: BlockNode, block_id: String) -> void:
	var node = _make_block_node(block_id)
	parent_node.children.append(node)
	_refresh_ui()


func _on_run_pressed() -> void:
	if program.is_empty() or executor.is_running:
		return
	character.input_locked = true
	run_button.disabled = true
	stop_button.disabled = false
	status_label.text = tr("Running...")
	executor.execute(program)

func _on_stop_pressed() -> void:
	executor.stop()

func _on_execution_finished() -> void:
	character.input_locked = false
	run_button.disabled = false
	stop_button.disabled = true
	_clear_all_highlights()
	if not LevelManager.level_complete and not LevelManager.level_failed_state:
		LevelManager.trigger_fail()
	if not LevelManager.level_complete and not LevelManager.level_failed_state:
		status_label.text = tr("Finished.")

func _on_progress_updated(harvest: int, target: int, steps: int, max_steps: int) -> void:
	if executor.is_running:
		if max_steps > 0:
			status_label.text = tr("Harvest: %d/%d | Steps: %d/%d") % [harvest, target, steps, max_steps]
		else:
			status_label.text = tr("Harvest: %d/%d") % [harvest, target]

func _on_clear_pressed() -> void:
	if executor.is_running:
		return
	program.clear()
	_refresh_ui()
	status_label.text = ""

func _on_reset_map_pressed() -> void:
	if executor.is_running:
		return
	FarmManager.reset_map()
	LevelManager.reset_run()
	status_label.text = tr("Map reset to initial state.")
