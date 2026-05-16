extends CharacterBody2D

@onready var tile_map_layer: TileMapLayer = $"../TileMapLayer"

var is_moving: bool = false
var grid_pos: Vector2i = Vector2i(0, 0)

func _ready():
	var used_cells = tile_map_layer.get_used_cells()
	if used_cells.size() > 0:
		var best = used_cells[0]
		var min_x = used_cells[0].x; var max_x = min_x
		var min_y = used_cells[0].y; var max_y = min_y
		for cell in used_cells:
			min_x = min(min_x, cell.x); max_x = max(max_x, cell.x)
			min_y = min(min_y, cell.y); max_y = max(max_y, cell.y)
		var center = Vector2i((min_x + max_x) / 2, (min_y + max_y) / 2)
		var best_dist = center.distance_squared_to(best)
		for cell in used_cells:
			var d = center.distance_squared_to(cell)
			if d < best_dist:
				best_dist = d
				best = cell
		grid_pos = best

	global_position = tile_map_layer.to_global(tile_map_layer.map_to_local(grid_pos))
	print("Player starting at grid_pos: ", grid_pos)

func _process(_delta):
	if is_moving:
		return

	# --- Movement ---
	if Input.is_action_just_pressed("ui_up"):
		move_to_grid(Vector2i(0, -1))
	elif Input.is_action_just_pressed("ui_down"):
		move_to_grid(Vector2i(0, 1))
	elif Input.is_action_just_pressed("ui_left"):
		move_to_grid(Vector2i(-1, 0))
	elif Input.is_action_just_pressed("ui_right"):
		move_to_grid(Vector2i(1, 0))

	# --- Farming actions (keyboard) ---
	# Also callable from visual block system via FarmManager.plant/water/harvest(grid_pos)
	elif Input.is_action_just_pressed("action_plant"):
		do_action("plant")
	elif Input.is_action_just_pressed("action_water"):
		do_action("water")
	elif Input.is_action_just_pressed("action_harvest"):
		do_action("harvest")

# Called by keypress OR by the visual block system
func do_action(action: String) -> bool:
	match action:
		"plant":
			return FarmManager.plant(grid_pos)
		"water":
			return FarmManager.water(grid_pos)
		"harvest":
			return FarmManager.harvest(grid_pos)
		_:
			print("Unknown action: ", action)
			return false

func move_to_grid(direction: Vector2i):
	var target_grid_pos = grid_pos + direction
	var tile_data = tile_map_layer.get_cell_tile_data(target_grid_pos)
	if tile_data == null:
		return

	is_moving = true
	grid_pos = target_grid_pos

	var target_pos = tile_map_layer.to_global(tile_map_layer.map_to_local(grid_pos))
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, 0.2) \
		.set_trans(Tween.TRANS_SINE) \
		.set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(func(): is_moving = false)
	
