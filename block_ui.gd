extends PanelContainer
class_name BlockUI

# BlockUI.gd
# Satu blok yang bisa di-drag. Dibuat secara dinamis oleh BlockPalette dan BlockSequence.

var definition: BlockDefinition = null
var is_in_sequence: bool = false   # true jika blok ada di sequence slot
var drag_preview: bool = false     # true jika ini adalah preview saat drag
var count_spinbox: SpinBox = null  # hanya dipakai oleh blok "repeat_start"

signal block_removed(block_ui: BlockUI)
signal count_changed(new_value: int)  # dipancarkan saat angka di SpinBox diubah

const BLOCK_WIDTH  = 130
const BLOCK_HEIGHT = 44

func setup(def: BlockDefinition, in_sequence: bool = false, initial_count: int = 3) -> void:
	definition = def
	is_in_sequence = in_sequence
	custom_minimum_size = Vector2(BLOCK_WIDTH, BLOCK_HEIGHT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var style = StyleBoxFlat.new()
	style.bg_color = def.color
	style.corner_radius_top_left     = 8
	style.corner_radius_top_right    = 8
	style.corner_radius_bottom_left  = 8
	style.corner_radius_bottom_right = 8
	style.border_width_left   = 2
	style.border_width_right  = 2
	style.border_width_top    = 2
	style.border_width_bottom = 2
	style.border_color = def.color.darkened(0.3)
	add_theme_stylebox_override("panel", style)

	if def.id == "repeat_start" and in_sequence:
		# Blok "Ulangi" di dalam sequence dapat kotak angka pengulangan
		var hbox = HBoxContainer.new()
		hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox.add_theme_constant_override("separation", 4)
		add_child(hbox)

		var label = Label.new()
		label.text = def.label
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_font_size_override("font_size", 13)
		hbox.add_child(label)

		count_spinbox = SpinBox.new()
		count_spinbox.min_value = 1
		count_spinbox.max_value = 20
		count_spinbox.value = initial_count
		count_spinbox.custom_minimum_size = Vector2(56, 0)
		count_spinbox.value_changed.connect(func(v): count_changed.emit(int(v)))
		hbox.add_child(count_spinbox)

		var x_label = Label.new()
		x_label.text = "x"
		x_label.add_theme_color_override("font_color", Color.WHITE)
		hbox.add_child(x_label)
	else:
		var label = Label.new()
		label.text = def.label
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_font_size_override("font_size", 14)
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(label)

func _get_drag_data(_at_position: Vector2) -> Variant:
	var preview = BlockUI.new()
	preview.setup(definition, false)
	preview.modulate.a = 0.7
	set_drag_preview(preview)

	var data = { "block_id": definition.id, "from_sequence": is_in_sequence, "source": self }
	if definition.id == "repeat_start" and count_spinbox:
		data["count"] = int(count_spinbox.value)
	return data

func _gui_input(event: InputEvent) -> void:
	if is_in_sequence and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			block_removed.emit(self)
