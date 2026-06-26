extends Node
class_name BlockExecutor

# BlockExecutor.gd
# Engine eksekusi rekursif untuk program blok visual.
# Mendukung: simple blocks, for(N), while(cond), if(cond)

const MAX_ITERATIONS = 100  # Batas loop untuk mencegah infinite loop

signal execution_started
signal execution_finished
signal block_highlighted(block_node: BlockNode, depth: int)

var character: FarmCharacter = null
var is_running: bool = false

func _init(p_character: FarmCharacter) -> void:
	character = p_character

# Jalankan list BlockNode secara berurutan
func execute(program: Array[BlockNode]) -> void:
	if is_running:
		return
	is_running = true
	execution_started.emit()
	await _run_list(program, 0)
	is_running = false
	execution_finished.emit()

func _run_list(nodes: Array[BlockNode], depth: int) -> void:
	var last_if_evaluated_to_true: bool = false
	var last_was_if: bool = false
	for node in nodes:
		if not is_running or LevelManager.level_complete or LevelManager.level_failed_state:
			break
		if node.id == "else":
			block_highlighted.emit(node, depth)
			if last_was_if and not last_if_evaluated_to_true:
				await _run_list(node.children, depth + 1)
			last_was_if = false
		else:
			if node.id == "if":
				last_was_if = true
				last_if_evaluated_to_true = _evaluate_condition(node.condition_id)
			else:
				last_was_if = false
			await _run_node(node, depth)

func _run_node(node: BlockNode, depth: int) -> void:
	block_highlighted.emit(node, depth)
	if node.id not in ["for", "while", "if", "else"]:
		LevelManager.on_step_executed()

	match node.id:
		"for":
			await _run_for(node, depth)
		"while":
			await _run_while(node, depth)
		"if":
			await _run_if(node, depth)
		"north":
			character.move_to_grid(Vector2i(0, -1))
			await character.move_finished
		"south":
			character.move_to_grid(Vector2i(0, 1))
			await character.move_finished
		"west":
			character.move_to_grid(Vector2i(-1, 0))
			await character.move_finished
		"east":
			character.move_to_grid(Vector2i(1, 0))
			await character.move_finished
		"plant", "water", "harvest":
			character.do_action(node.id)
			await character.get_tree().create_timer(0.3).timeout
		"wait":
			var t = maxf(node.wait_time, 0.0)
			await character.get_tree().create_timer(t).timeout
		_:
			push_warning("BlockExecutor: unknown block id '%s'" % node.id)

func _run_for(node: BlockNode, depth: int) -> void:
	var n = clampi(node.repeat_count, 1, MAX_ITERATIONS)
	for i in n:
		if not is_running or LevelManager.level_complete or LevelManager.level_failed_state:
			break
		await _run_list(node.children, depth + 1)

func _run_while(node: BlockNode, depth: int) -> void:
	var iterations = 0
	while _evaluate_condition(node.condition_id) and is_running and not LevelManager.level_complete and not LevelManager.level_failed_state:
		iterations += 1
		if iterations >= MAX_ITERATIONS:
			push_warning("BlockExecutor: while loop melebihi batas %d iterasi — dihentikan." % MAX_ITERATIONS)
			break
		await _run_list(node.children, depth + 1)

func _run_if(node: BlockNode, depth: int) -> void:
	if _evaluate_condition(node.condition_id):
		await _run_list(node.children, depth + 1)

func _evaluate_condition(condition_id: String) -> bool:
	var grid_pos: Vector2i = character.grid_pos
	var state := FarmManager.get_tile_state(grid_pos)
	match condition_id:
		"is_planted":
			return state == FarmTile.State.PLANTED
		"is_watered":
			return state == FarmTile.State.WATERED
		"is_harvestable":
			return state == FarmTile.State.HARVESTABLE
		"is_not_planted":
			return state == FarmTile.State.EMPTY
		"is_not_watered":
			return state != FarmTile.State.WATERED
		"is_not_harvestable":
			return state != FarmTile.State.HARVESTABLE
		"is_path_north":
			return character.has_path(Vector2i(0, -1))
		"is_path_south":
			return character.has_path(Vector2i(0, 1))
		"is_path_west":
			return character.has_path(Vector2i(-1, 0))
		"is_path_east":
			return character.has_path(Vector2i(1, 0))
		_:
			return false

func stop() -> void:
	is_running = false
