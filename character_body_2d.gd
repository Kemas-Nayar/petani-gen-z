extends CharacterBody2D
class_name FarmCharacter

@onready var tile_map_layer: TileMapLayer = $"../TileMapLayer"

var is_moving: bool = false
var grid_pos: Vector2i = Vector2i(0, 0)
var input_locked: bool = false  # true saat program blok sedang berjalan
var is_acting: bool = false     # cegah aksi plant/water/harvest dobel

signal move_finished  # dipakai oleh BlockSequence untuk await pergerakan selesai
signal move_blocked  # dipancarkan saat robot mencoba jalan ke luar grid

func _ready():
	var used_cells = tile_map_layer.get_used_cells()
	if used_cells.size() > 0:
		var best = used_cells[0]
		var best_val = best.y - best.x
		for cell in used_cells:
			var val = cell.y - cell.x
			if val > best_val:
				best_val = val
				best = cell
		grid_pos = best

	global_position = tile_map_layer.to_global(tile_map_layer.map_to_local(grid_pos))



func do_action(action: String) -> bool:
	if is_acting:
		return false
	var result := false
	match action:
		"plant":   result = FarmManager.plant(grid_pos)
		"water":   result = FarmManager.water(grid_pos)
		"harvest": result = FarmManager.harvest(grid_pos)
		_:
			print("Unknown action: ", action)
			return false
	return result

func move_to_grid(direction: Vector2i) -> void:
	var target_grid_pos = grid_pos + direction
	var tile_data = tile_map_layer.get_cell_tile_data(target_grid_pos)
	if tile_data == null:
		move_blocked.emit()
		var shake_tween = _shake()
		shake_tween.finished.connect(func():
			move_finished.emit()
		)
		return

	is_moving = true
	grid_pos = target_grid_pos

	var target_pos = tile_map_layer.to_global(tile_map_layer.map_to_local(grid_pos))
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, 0.2) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(func():
		is_moving = false
		move_finished.emit()
	)
func _shake() -> Tween:
	var original_pos = position
	var tween = create_tween()
	tween.tween_property(self, "position", original_pos + Vector2(6, 0), 0.05)
	tween.tween_property(self, "position", original_pos - Vector2(6, 0), 0.05)
	tween.tween_property(self, "position", original_pos, 0.05)
	return tween

func has_path(direction: Vector2i) -> bool:
	if tile_map_layer == null:
		return false
	var target_grid_pos = grid_pos + direction
	return tile_map_layer.get_cell_tile_data(target_grid_pos) != null
