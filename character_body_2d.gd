extends CharacterBody2D

@onready var tile_map_layer: TileMapLayer = $"../TileMapLayer"

var is_moving: bool = false
var grid_pos: Vector2i = Vector2i(0, 0)

func _ready():
	# --- DIAGNOSTIC: print all used cells so we know the real coordinate range ---
	var used_cells = tile_map_layer.get_used_cells()
	print("Total tiles in map: ", used_cells.size())
	if used_cells.size() > 0:
		var min_x = used_cells[0].x
		var max_x = used_cells[0].x
		var min_y = used_cells[0].y
		var max_y = used_cells[0].y
		for cell in used_cells:
			min_x = min(min_x, cell.x)
			max_x = max(max_x, cell.x)
			min_y = min(min_y, cell.y)
			max_y = max(max_y, cell.y)
		print("Grid X range: ", min_x, " to ", max_x)
		print("Grid Y range: ", min_y, " to ", max_y)

		# Snap starting position to the center of the tile bounds
		var center_x = (min_x + max_x) / 2
		var center_y = (min_y + max_y) / 2
		grid_pos = Vector2i(center_x, center_y)

		# Find the closest actually-used cell to that center
		var best = used_cells[0]
		var best_dist = grid_pos.distance_squared_to(best)
		for cell in used_cells:
			var d = grid_pos.distance_squared_to(cell)
			if d < best_dist:
				best_dist = d
				best = cell
		grid_pos = best
		print("Starting grid_pos snapped to nearest tile: ", grid_pos)
	else:
		print("WARNING: TileMapLayer has no cells! Check the node path.")

	global_position = tile_map_layer.to_global(tile_map_layer.map_to_local(grid_pos))

func _process(_delta):
	if is_moving:
		return

	if Input.is_action_just_pressed("ui_up"):
		move_to_grid(Vector2i(0, -1))
	elif Input.is_action_just_pressed("ui_down"):
		move_to_grid(Vector2i(0, 1))
	elif Input.is_action_just_pressed("ui_left"):
		move_to_grid(Vector2i(-1, 0))
	elif Input.is_action_just_pressed("ui_right"):
		move_to_grid(Vector2i(1, 0))

func move_to_grid(direction: Vector2i):
	var target_grid_pos = grid_pos + direction

	var tile_data = tile_map_layer.get_cell_tile_data(target_grid_pos)
	if tile_data == null:
		print("Blocked at: ", target_grid_pos, " | Current pos: ", grid_pos)
		return

	is_moving = true
	grid_pos = target_grid_pos

	var target_pos = tile_map_layer.to_global(tile_map_layer.map_to_local(grid_pos))

	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, 0.2) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(func(): is_moving = false)
	
