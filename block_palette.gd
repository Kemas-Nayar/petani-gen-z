extends PanelContainer

# BlockPalette.gd — versi Tier 2 dengan 4 kategori

signal block_selected(block_id: String)

@onready var move_blocks:      VBoxContainer = $MarginContainer/ScrollContainer/VBox/MoveSection/Blocks
@onready var action_blocks:    VBoxContainer = $MarginContainer/ScrollContainer/VBox/ActionSection/Blocks
@onready var control_blocks:   VBoxContainer = $MarginContainer/ScrollContainer/VBox/ControlSection/Blocks
@onready var condition_blocks: VBoxContainer = $MarginContainer/ScrollContainer/VBox/ConditionSection/Blocks

func _ready() -> void:
	_populate()
	
	# Connect ke settings_changed secara dinamis untuk memperbarui bahasa blok saat diubah
	var settings_manager = get_node_or_null("/root/SettingsManager")
	if settings_manager:
		settings_manager.settings_changed.connect(_on_settings_changed)

func _populate() -> void:
	for def in BlockDefinition.get_all():
		var block: BlockUI = BlockUI.new()
		block.setup(def, false)
		block.block_clicked.connect(_on_block_clicked)

		match def.category:
			BlockDefinition.Category.MOVE:
				move_blocks.add_child(block)
			BlockDefinition.Category.ACTION:
				action_blocks.add_child(block)
			BlockDefinition.Category.CONTROL:
				control_blocks.add_child(block)
			BlockDefinition.Category.CONDITION:
				condition_blocks.add_child(block)

func _on_block_clicked(block_ui: BlockUI) -> void:
	block_selected.emit(block_ui.definition.id)

func _on_settings_changed() -> void:
	# Bersihkan semua anak/blok yang ada di kategori
	for container in [move_blocks, action_blocks, control_blocks, condition_blocks]:
		for child in container.get_children():
			child.queue_free()
	
	# Isi kembali dengan teks bahasa yang baru
	_populate()

func _can_drop_data(_pos: Vector2, _data: Variant) -> bool:
	return false
