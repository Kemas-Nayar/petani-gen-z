extends PanelContainer
class_name BlockUI

# BlockUI.gd
# Satu blok yang bisa di-drag. Dibuat secara dinamis oleh BlockPalette dan BlockSequence.

var definition: BlockDefinition = null
var is_in_sequence: bool = false   # true jika blok ada di sequence slot
var drag_preview: bool = false     # true jika ini adalah preview saat drag

signal block_removed(block_ui: BlockUI)  # dipancarkan saat blok di-klik kanan di sequence

const BLOCK_WIDTH  = 130
const BLOCK_HEIGHT = 44

func setup(def: BlockDefinition, in_sequence: bool = false) -> void:
	definition = def
	is_in_sequence = in_sequence
	custom_minimum_size = Vector2(BLOCK_WIDTH, BLOCK_HEIGHT)

	# Warna background blok
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
	mouse_filter = Control.MOUSE_FILTER_STOP

	var label = Label.new()
	label.text = def.label
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 14)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(label)

func _get_drag_data(_at_position: Vector2) -> Variant:
	# Buat preview visual saat drag
	var preview = BlockUI.new()
	preview.setup(definition, false)
	preview.modulate.a = 0.7
	set_drag_preview(preview)
	return { "block_id": definition.id, "from_sequence": is_in_sequence, "source": self }

func _gui_input(event: InputEvent) -> void:
	# Klik kanan di sequence → hapus blok
	if is_in_sequence and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			block_removed.emit(self)
