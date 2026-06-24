extends PanelContainer

# BlockSequence.gd
# Panel kanan: slot urutan blok + tombol Run.
# Attach ke node PanelContainer bernama "BlockSequence".

const MAX_BLOCKS = 12

@onready var slot_container: VBoxContainer = $MarginContainer/VBox/SlotContainer
@onready var run_button:     Button        = $MarginContainer/VBox/RunButton
@onready var status_label:   Label         = $MarginContainer/VBox/StatusLabel

@onready var character: CharacterBody2D = $"../../../CharacterBody2D"

var sequence: Array[String] = []   # list block id yang akan dieksekusi
var is_running: bool = false

func _ready():
	run_button.pressed.connect(_on_run_pressed)
	_refresh_slots()

# ── Drop handling ──────────────────────────────────────────────────────────

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("block_id") and not is_running

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if sequence.size() >= MAX_BLOCKS:
		status_label.text = "Slot penuh! (maks %d blok)" % MAX_BLOCKS
		return
	sequence.append(data["block_id"])
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
		row.add_theme_constant_override("separation", 6)

		# Nomor urut
		var num = Label.new()
		num.text = "%d." % (i + 1)
		num.custom_minimum_size = Vector2(22, 0)
		num.add_theme_font_size_override("font_size", 13)
		num.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(num)

		# Blok visual
		var block = PanelContainer.new()
		block.set_script(load("res://block_ui.gd"))
		block.setup(def, true)
		block.block_removed.connect(_on_block_removed)
		row.add_child(block)

		slot_container.add_child(row)

	# Update tombol Run
	run_button.disabled = sequence.is_empty() or is_running

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

# ── Hapus blok ────────────────────────────────────────────────────────────

func _on_block_removed(block_ui) -> void:
	# Cari index berdasarkan posisi di slot_container
	var rows = slot_container.get_children()
	for i in rows.size():
		for child in rows[i].get_children():
			if child == block_ui:
				sequence.remove_at(i)
				_refresh_slots()
				return

# ── Helper ────────────────────────────────────────────────────────────────

func _find_def(id: String) -> BlockDefinition:
	for def in BlockDefinition.get_all():
		if def.id == id:
			return def
	return null
