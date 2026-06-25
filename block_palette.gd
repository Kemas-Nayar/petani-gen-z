extends PanelContainer

@onready var move_blocks: VBoxContainer = $MarginContainer/ScrollContainer/VBox/MoveSection/Blocks
@onready var action_blocks: VBoxContainer = $MarginContainer/ScrollContainer/VBox/ActionSection/Blocks
@onready var control_blocks: VBoxContainer = $MarginContainer/ScrollContainer/VBox/ControlSection/Blocks
@onready var condition_blocks: VBoxContainer = $MarginContainer/ScrollContainer/VBox/ConditionSection/Blocks

func _ready() -> void:
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
				action_blocks.add_child(block)
			BlockDefinition.Category.CONTROL:
				control_blocks.add_child(block)
			BlockDefinition.Category.CONDITION:
				condition_blocks.add_child(block)

func _can_drop_data(_pos: Vector2, _data: Variant) -> bool:
	return false
