extends PanelContainer

# BlockPalette.gd
# Panel kiri berisi semua blok yang tersedia untuk di-drag.

@onready var move_container:    VBoxContainer = $MarginContainer/VBox/MoveSection/Blocks
@onready var action_container:  VBoxContainer = $MarginContainer/VBox/ActionSection/Blocks
@onready var control_container: VBoxContainer = $MarginContainer/VBox/ControlSection/Blocks

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
			BlockDefinition.Category.CONTROL:
				control_container.add_child(block)

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return false
