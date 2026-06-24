extends PanelContainer

# BlockPalette.gd
# Panel kiri berisi semua blok Tier 1 yang tersedia untuk di-drag.
# Attach ke node PanelContainer bernama "BlockPalette".

const BlockUIScene = preload("res://block_ui.gd")

@onready var move_container:   VBoxContainer = $MarginContainer/VBox/MoveSection/Blocks
@onready var action_container: VBoxContainer = $MarginContainer/VBox/ActionSection/Blocks

func _ready():
	_populate()

func _populate() -> void:
	for def in BlockDefinition.get_all():
		var block = PanelContainer.new()
		block.set_script(load("res://block_ui.gd"))
		block.setup(def, false)

		match def.category:
			BlockDefinition.Category.MOVE:
				move_container.add_child(block)
			BlockDefinition.Category.ACTION:
				action_container.add_child(block)

# Palette tidak menerima drop — hanya sequence yang menerima
func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return false
