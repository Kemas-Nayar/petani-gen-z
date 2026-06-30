extends Node2D


@onready var tile_map_layer: TileMapLayer = $"../TileMapLayer"

const SOURCE_IDS: Dictionary = {
	FarmTile.State.EMPTY:       10,
	FarmTile.State.PLANTED:     11,
	FarmTile.State.WATERED:     12,
	FarmTile.State.HARVESTABLE: 13,
}

const ATLAS_COORD := Vector2i(0, 0)
const ALT_TILE := 0

func _ready():
	FarmManager.tile_state_changed.connect(_on_tile_state_changed)
	for pos in FarmManager.tiles:
		_on_tile_state_changed(pos, FarmManager.tiles[pos].state)

func _on_tile_state_changed(grid_pos: Vector2i, new_state: FarmTile.State) -> void:
	var source_id = SOURCE_IDS.get(new_state, SOURCE_IDS[FarmTile.State.EMPTY])
	tile_map_layer.set_cell(grid_pos, source_id, ATLAS_COORD, ALT_TILE)
	print("Tile at ", grid_pos, " swapped to source ", source_id, " (", FarmTile.State.keys()[new_state], ")")
