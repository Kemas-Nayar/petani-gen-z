extends PanelContainer

<<<<<<< HEAD
@onready var move_blocks: VBoxContainer = $MarginContainer/ScrollContainer/VBox/MoveSection/Blocks
@onready var action_blocks: VBoxContainer = $MarginContainer/ScrollContainer/VBox/ActionSection/Blocks
@onready var control_blocks: VBoxContainer = $MarginContainer/ScrollContainer/VBox/ControlSection/Blocks
@onready var condition_blocks: VBoxContainer = $MarginContainer/ScrollContainer/VBox/ConditionSection/Blocks

func _ready() -> void:
=======
# BlockPalette.gd
# Panel kiri berisi semua blok yang tersedia untuk di-drag.

@onready var move_container:    VBoxContainer = $MarginContainer/VBox/MoveSection/Blocks
@onready var action_container:  VBoxContainer = $MarginContainer/VBox/ActionSection/Blocks
@onready var control_container: VBoxContainer = $MarginContainer/VBox/ControlSection/Blocks

func _ready():
>>>>>>> a7c34be5b6467be36097ac77b82f3655f6ff0708
	_populate()

func _populate() -> void:
	for def in BlockDefinition.get_all():
		var block = PanelContainer.new()
		block.set_script(load("res://block_ui.gd"))
		block.setup(def, false)

		match def.category:
			BlockDefinition.Category.MOVE:
				move_blocks.add_child(block)
			BlockDefinition.Category.ACTION:
<<<<<<< HEAD
				action_blocks.add_child(block)
			BlockDefinition.Category.CONTROL:
				control_blocks.add_child(block)
			BlockDefinition.Category.CONDITION:
				condition_blocks.add_child(block)

func _can_drop_data(_pos: Vector2, _data: Variant) -> bool:
=======
				action_container.add_child(block)
			BlockDefinition.Category.CONTROL:
				control_container.add_child(block)

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
>>>>>>> a7c34be5b6467be36097ac77b82f3655f6ff0708
	return false
