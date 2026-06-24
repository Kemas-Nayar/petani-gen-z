extends PanelContainer

# BlockSequence.gd
# Panel kanan: slot urutan blok + tombol Run.
# Attach ke node PanelContainer bernama "BlockSequence".

const MAX_BLOCKS = 12

@onready var slot_container: VBoxContainer = $MarginContainer/VBox/SlotContainer
@onready var run_button:     Button        = $MarginContainer/VBox/ButtonRow/RunButton
@onready var clear_button:   Button        = $MarginContainer/VBox/ButtonRow/ClearButton
@onready var status_label:   Label         = $MarginContainer/VBox/StatusLabel

@onready var character: CharacterBody2D = $"../../../CharacterBody2D"

var sequence: Array[String] = []   # list block id yang akan dieksekusi
var is_running: bool = false

func _ready():
	run_button.pressed.connect(_on_run_pressed)
	clear_button.pressed.connect(_on_clear_pressed)
	character.move_blocked.connect(_on_move_blocked)
	_refresh_slots()

# ── Drop handling ──────────────────────────────────────────────────────────

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if is_running:
		return false
	if not (data is Dictionary and data.has("block_id")):
		return false
	if data.get("from_sequence", false):
		return true
	return sequence.size() < MAX_BLOCKS

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var block_id: String = data["block_id"]
	var insert_index := _get_insert_index(at_position)

	if data.get("from_sequence", false):
		var from_index := _find_block_index(data.get("source"))
		if from_index < 0:
			return
		sequence.remove_at(from_index)
		if from_index < insert_index:
			insert_index -= 1
		sequence.insert(insert_index, block_id)
	else:
		if sequence.size() >= MAX_BLOCKS:
			status_label.text = "Slot penuh! (maks %d blok)" % MAX_BLOCKS
			return
		sequence.insert(insert_index, block_id)

	_refresh_slots()
	status_label.text = ""

# ── Slot rendering ─────────────────────────────────────────────────────────

func _refresh_slots() -> void:
	for child in slot_container.get_children():
		child.queue_free()

	for i in sequence.size():
		var def = _find_def(sequence[i])
		if def == null:
			continue

		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 4)

		var num = Label.new()
		num.text = "%d." % (i + 1)
		num.custom_minimum_size = Vector2(22, 0)
		num.add_theme_font_size_override("font_size", 13)
		num.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(num)

		var block = PanelContainer.new()
		block.set_script(load("res://block_ui.gd"))
		block.setup(def, true)
		block.block_removed.connect(_on_block_removed)
		row.add_child(block)

		var controls = VBoxContainer.new()
		controls.add_theme_constant_override("separation", 0)

		var up_btn = Button.new()
		up_btn.text = "↑"
		up_btn.tooltip_text = "Naikkan"
		up_btn.custom_minimum_size = Vector2(28, 20)
		up_btn.disabled = i == 0 or is_running
		up_btn.pressed.connect(_move_block.bind(i, -1))
		controls.add_child(up_btn)

		var down_btn = Button.new()
		down_btn.text = "↓"
		down_btn.tooltip_text = "Turunkan"
		down_btn.custom_minimum_size = Vector2(28, 20)
		down_btn.disabled = i == sequence.size() - 1 or is_running
		down_btn.pressed.connect(_move_block.bind(i, 1))
		controls.add_child(down_btn)

		var del_btn = Button.new()
		del_btn.text = "×"
		del_btn.tooltip_text = "Hapus (klik kanan juga bisa)"
		del_btn.custom_minimum_size = Vector2(28, 20)
		del_btn.disabled = is_running
		del_btn.pressed.connect(_remove_at_index.bind(i))
		controls.add_child(del_btn)

		row.add_child(controls)
		slot_container.add_child(row)

	run_button.disabled = sequence.is_empty() or is_running
	clear_button.disabled = sequence.is_empty() or is_running

# ── Eksekusi ──────────────────────────────────────────────────────────────

func _on_run_pressed() -> void:
	if sequence.is_empty() or is_running:
		return
	is_running = true
	run_button.disabled = true
	status_label.text = "Menjalankan..."
	_execute_sequence()

func _execute_sequence() -> void:
	for i in sequence.size():
		var block_id = sequence[i]
		_highlight_slot(i)
		await _execute_block(block_id)

	_highlight_slot(-1)
	is_running = false
	run_button.disabled = false
	status_label.text = "Selesai ✓"

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
		# Cari BlockUI di dalam row
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
	var block_id := sequence[index]
	sequence.remove_at(index)
	sequence.insert(new_index, block_id)
	_refresh_slots()

func _on_clear_pressed() -> void:
	if is_running or sequence.is_empty():
		return
	sequence.clear()
	_refresh_slots()
	status_label.text = ""

# ── Helper ────────────────────────────────────────────────────────────────

func _on_move_blocked() -> void:
	status_label.text = "🚫 Robot terhalang, tidak bisa lewat!"

func _get_insert_index(at_position: Vector2) -> int:
	var pos_in_container := slot_container.get_global_transform().affine_inverse() * (get_global_transform() * at_position)
	var rows := slot_container.get_children()
	for i in rows.size():
		var row := rows[i] as Control
		if pos_in_container.y < row.position.y + row.size.y * 0.5:
			return i
	return rows.size()

func _find_block_index(block_ui) -> int:
	var rows := slot_container.get_children()
	for i in rows.size():
		for child in rows[i].get_children():
			if child == block_ui:
				return i
	return -1

func _find_def(id: String) -> BlockDefinition:
	for def in BlockDefinition.get_all():
		if def.id == id:
			return def
	return null
