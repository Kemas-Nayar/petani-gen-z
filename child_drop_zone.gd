extends PanelContainer

func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	if not (data is Dictionary and data.has("block_id")):
		return false
	var def := BlockDefinition.get_by_id(data["block_id"])
	if def == null or def.has_children or def.category == BlockDefinition.Category.CONDITION:
		return false
	var sequence_ref = get_meta("sequence_ref")
	return sequence_ref != null and not sequence_ref.executor.is_running

func _drop_data(_pos: Vector2, data: Variant) -> void:
	var parent_block: BlockNode = get_meta("parent_block")
	var sequence_ref = get_meta("sequence_ref")
	sequence_ref.add_child_block(parent_block, data["block_id"])
