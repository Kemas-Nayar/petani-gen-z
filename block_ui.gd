extends PanelContainer
class_name BlockUI


var definition: BlockDefinition = null
var is_in_sequence: bool = false
var drag_preview: bool = false

signal block_removed(block_ui: BlockUI)
signal block_clicked(block_ui: BlockUI)

const BLOCK_WIDTH  = 130
const BLOCK_HEIGHT = 44

func setup(def: BlockDefinition, in_sequence: bool = false) -> void:
	definition = def
	is_in_sequence = in_sequence
	custom_minimum_size = Vector2(BLOCK_WIDTH, BLOCK_HEIGHT)

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

	var label = Label.new()
	label.text = tr(def.label)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 14)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(label)

func _get_drag_data(_at_position: Vector2) -> Variant:
	var preview = BlockUI.new()
	preview.setup(definition, false)
	preview.modulate.a = 0.7
	set_drag_preview(preview)
	return { "block_id": definition.id, "from_sequence": is_in_sequence, "source": self }

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	tooltip_text = "Klik untuk tambah · drag ke urutan blok" if not is_in_sequence else ""

var _press_pos: Vector2 = Vector2.ZERO
var _press_started: bool = false

func _gui_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return

	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_press_pos = event.position
			_press_started = true
		else:
			if _press_started and not is_in_sequence:
				var moved_distance = (event.position - _press_pos).length()
				if moved_distance < 6.0:
					block_clicked.emit(self)
			_press_started = false
	elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and is_in_sequence:
		block_removed.emit(self)
