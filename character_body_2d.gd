extends CharacterBody2D

@onready var tile_map_layer: TileMapLayer = $"../TileMapLayer" # Sesuaikan path ke node TileMapLayer Anda

var is_moving: bool = false
var grid_pos: Vector2i = Vector2i(0, 0) # Koordinat awal robot di grid
var tile_size: Vector2 = Vector2(64, 32) # Ukuran tile isometrik standar Kenney

func _ready():
	# Sinkronisasi posisi awal robot dengan pusat tile di grid
	global_position = tile_map_layer.map_to_local(grid_pos)

func _process(_delta):
	# Testing manual menggunakan tombol panah sebelum sistem blok Scratch jadi
	if is_moving:
		return
		
	if Input.is_action_just_pressed("ui_up"):
		move_to_grid(Vector2i(0, -1)) # North
	elif Input.is_action_just_pressed("ui_down"):
		move_to_grid(Vector2i(0, 1))  # South
	elif Input.is_action_just_pressed("ui_left"):
		move_to_grid(Vector2i(-1, 0)) # West
	elif Input.is_action_just_pressed("ui_right"):
		move_to_grid(Vector2i(1, 0))  # East

func move_to_grid(direction: Vector2i):
	var target_grid_pos = grid_pos + direction
	
	# Cek apakah tile tujuan ada di dalam batas ladang (Fase 1: Implementasi batas)
	var tile_data = tile_map_layer.get_cell_tile_data(target_grid_pos)
	if tile_data == null:
		print("Batas ladang tercapai!")
		return

	is_moving = true
	grid_pos = target_grid_pos
	var target_pos = tile_map_layer.map_to_local(grid_pos)
	
	# Animasi pergerakan menggunakan Tween
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_pos, 0.3).set_trans(Tween.TRANS_SINE)
	tween.finished.connect(func(): is_moving = false)
	
