extends Node2D


@onready var tile_map_layer: TileMapLayer = $"../TileMapLayer"

const TILE_SIZE: int = 128

const TEXTURES: Dictionary = {
	FarmTile.State.EMPTY:       preload("res://Tiles/Empty.jpg"),
	FarmTile.State.PLANTED:     preload("res://Tiles/Planted.jpg"),
	FarmTile.State.WATERED:     preload("res://Tiles/Watered.jpg"),
	FarmTile.State.HARVESTABLE: preload("res://Tiles/Harvestable.jpg"),
}

var overlays: Dictionary = {}

func _ready():
	FarmManager.tile_state_changed.connect(_on_tile_state_changed)

func _on_tile_state_changed(grid_pos: Vector2i, new_state: FarmTile.State) -> void:
	if new_state == FarmTile.State.EMPTY:
		_remove_overlay(grid_pos)
	else:
		_set_overlay(grid_pos, new_state)

func _set_overlay(grid_pos: Vector2i, state: FarmTile.State) -> void:
	var sprite: Sprite2D
	if overlays.has(grid_pos):
		sprite = overlays[grid_pos]
	else:
		sprite = Sprite2D.new()
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(sprite)
		overlays[grid_pos] = sprite

	sprite.position = tile_map_layer.to_local(
		tile_map_layer.to_global(tile_map_layer.map_to_local(grid_pos))
	)
	sprite.texture = TEXTURES[state]
	var tex_size = sprite.texture.get_size()
	sprite.scale = Vector2(TILE_SIZE, TILE_SIZE) / tex_size
	sprite.visible = true

func _remove_overlay(grid_pos: Vector2i) -> void:
	if overlays.has(grid_pos):
		overlays[grid_pos].queue_free()
		overlays.erase(grid_pos)
