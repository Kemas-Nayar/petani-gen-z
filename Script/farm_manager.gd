extends Node

# Add this as an Autoload in Project > Project Settings > Autoload
# Name it "FarmManager"

const GROWTH_TIME: float = 10.0  # Seconds for watered crop to become harvestable

var tiles: Dictionary = {}  # Vector2i -> FarmTile

signal tile_state_changed(grid_pos: Vector2i, new_state: FarmTile.State)

# --- Public API (callable from scripts and later from visual block system) ---

func plant(grid_pos: Vector2i) -> bool:
	var tile = _get_or_create_tile(grid_pos)
	var success = tile.plant()
	if success:
		tile_state_changed.emit(grid_pos, tile.state)
	return success

func water(grid_pos: Vector2i) -> bool:
	var tile = _get_or_create_tile(grid_pos)
	var success = tile.water()
	if success:
		tile_state_changed.emit(grid_pos, tile.state)
		# Start growth timer — watered -> harvestable after GROWTH_TIME seconds
		var timer = get_tree().create_timer(GROWTH_TIME)
		timer.timeout.connect(_on_growth_complete.bind(grid_pos))
	return success

func harvest(grid_pos: Vector2i) -> bool:
	var tile = _get_or_create_tile(grid_pos)
	var success = tile.harvest()
	if success:
		tile_state_changed.emit(grid_pos, tile.state)
	return success

func get_tile_state(grid_pos: Vector2i) -> FarmTile.State:
	if tiles.has(grid_pos):
		return tiles[grid_pos].state
	return FarmTile.State.EMPTY

func get_tile_state_name(grid_pos: Vector2i) -> String:
	if tiles.has(grid_pos):
		return tiles[grid_pos].get_state_name()
	return "Empty"

# --- Internal ---

func _get_or_create_tile(grid_pos: Vector2i) -> FarmTile:
	if not tiles.has(grid_pos):
		var tile = FarmTile.new()
		tile.grid_pos = grid_pos
		tiles[grid_pos] = tile
	return tiles[grid_pos]

func _on_growth_complete(grid_pos: Vector2i) -> void:
	if not tiles.has(grid_pos):
		return
	var tile = tiles[grid_pos]
	# Only advance if still watered (player may have already harvested or reset)
	if tile.state == FarmTile.State.WATERED:
		tile.state = FarmTile.State.HARVESTABLE
		print("Crop ready to harvest at ", grid_pos)
		tile_state_changed.emit(grid_pos, tile.state)
