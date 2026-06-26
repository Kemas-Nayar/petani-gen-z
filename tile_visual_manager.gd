extends Node2D

# TileVisualManager.gd
# Instead of overlaying sprites, we swap tiles directly in the TileMapLayer.
# Source IDs from your TileSet:
#   source 10 = Empty.jpg      (TileSetAtlasSource_kdubu)
#   source 9  = maingrass.png  (TileSetAtlasSource_d21ai) -- grass/base
# We'll use source 10 (Empty atlas) as the base farmable tile,
# and swap atlas coords to show the correct state texture.
#
# Since your state textures (Planted, Watered, Harvestable) are separate files,
# we add them as additional atlas sources and switch between them.
#
# !! IMPORTANT: After adding this script, you need to:
# 1. Add Planted.jpg, Watered.jpg, Harvestable.jpg as TileSet atlas sources in the TileSet editor
# 2. Note their source IDs and update SOURCE_IDS below

@onready var tile_map_layer: TileMapLayer = $"../TileMapLayer"

# Map each FarmTile state to its TileSet source ID
# Update these IDs after adding your textures to the TileSet
const SOURCE_IDS: Dictionary = {
	FarmTile.State.EMPTY:       10,   # Empty.jpg    — already in TileSet as source 10
	FarmTile.State.PLANTED:     11,   # Planted.jpg  — add to TileSet, assign source ID 11
	FarmTile.State.WATERED:     12,   # Watered.jpg  — add to TileSet, assign source ID 12
	FarmTile.State.HARVESTABLE: 13,   # Harvestable.jpg — add to TileSet, assign source ID 13
}

# All state textures use atlas coord 0,0 with tile index 0
const ATLAS_COORD := Vector2i(0, 0)
const ALT_TILE := 0

func _ready():
	FarmManager.tile_state_changed.connect(_on_tile_state_changed)
	# Draw existing tiles if any are already populated in FarmManager
	for pos in FarmManager.tiles:
		_on_tile_state_changed(pos, FarmManager.tiles[pos].state)

func _on_tile_state_changed(grid_pos: Vector2i, new_state: FarmTile.State) -> void:
	var source_id = SOURCE_IDS.get(new_state, SOURCE_IDS[FarmTile.State.EMPTY])
	tile_map_layer.set_cell(grid_pos, source_id, ATLAS_COORD, ALT_TILE)
	print("Tile at ", grid_pos, " swapped to source ", source_id, " (", FarmTile.State.keys()[new_state], ")")
