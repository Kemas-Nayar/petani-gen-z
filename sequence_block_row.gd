extends HBoxContainer

# Baris blok di urutan program — bisa di-drag untuk mengubah posisi.

var sequence_ref: BlockSequence = null
var block_nodes: Array[BlockNode] = []
var block_index: int = 0
var depth: int = 0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	if sequence_ref:
		set_drag_forwarding(
			Callable(),
			Callable(self, "_can_drop_data"),
			Callable(self, "_drop_data")
		)

func _get_drag_data(_at_position: Vector2) -> Variant:
	if sequence_ref == null or sequence_ref.executor.is_running:
		return null
	if block_index < 0 or block_index >= block_nodes.size():
		return null

	var node := block_nodes[block_index]
	var def := BlockDefinition.get_by_id(node.id)
	if def == null:
		return null

	var preview := BlockUI.new()
	preview.setup(def, true)
	preview.modulate.a = 0.7
	set_drag_preview(preview)

	return {
		"block_id": node.id,
		"from_sequence": true,
		"reorder": true,
		"source_nodes": block_nodes,
		"source_index": block_index,
		"depth": depth,
	}

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return sequence_ref != null and sequence_ref._can_drop_on_row(at_position, data, self)

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if sequence_ref:
		sequence_ref._drop_on_row(at_position, data, self)
