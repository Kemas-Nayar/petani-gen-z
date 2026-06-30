extends CanvasLayer


@onready var panel: PanelContainer = $CenterBottom/PanelContainer
@onready var timer_label: Label = $CenterBottom/PanelContainer/MarginContainer/TimerLabel

@onready var character: FarmCharacter = $"../CharacterBody2D"

var countdown: float = 0.0
var is_counting: bool = false
var watched_pos: Vector2i = Vector2i(-9999, -9999)

func _ready():
	FarmManager.tile_state_changed.connect(_on_tile_state_changed)
	panel.visible = false

func _process(delta):
	if not is_counting:
		return

	countdown -= delta
	if countdown <= 0.0:
		countdown = 0.0
		is_counting = false
		panel.visible = false
		return

	timer_label.text = tr("🌱 Grows in %.1f seconds") % countdown

func _on_tile_state_changed(grid_pos: Vector2i, new_state: FarmTile.State) -> void:
	if new_state == FarmTile.State.WATERED:
		watched_pos = grid_pos
		countdown = FarmManager.GROWTH_TIME
		is_counting = true
		panel.visible = true
	elif grid_pos == watched_pos:
		is_counting = false
		panel.visible = false
