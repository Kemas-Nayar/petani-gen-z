extends Node

var current_level_id: int = 1
var harvest_count: int = 0
var step_count: int = 0
var level_complete: bool = false

signal level_won(level_id: int)
signal progress_updated(harvest_count: int, target: int, steps: int, max_steps: int)

func _ready() -> void:
	load_level(1)

func load_level(id: int) -> void:
	current_level_id = id
	harvest_count = 0
	step_count = 0
	level_complete = false
	var level := get_current_level()
	if level:
		print("Level %d dimuat: %s" % [id, level.title])
	_emit_progress()

func get_current_level() -> LevelData:
	return LevelData.get_level(current_level_id)

func reset_run() -> void:
	step_count = 0
	_emit_progress()

func on_step_executed() -> void:
	step_count += 1
	_emit_progress()
	_check_win()

func on_harvested() -> void:
	if level_complete:
		return
	harvest_count += 1
	_emit_progress()
	_check_win()

func _check_win() -> void:
	if level_complete:
		return

	var level := get_current_level()
	if level == null:
		return

	var all_met := true
	for condition in level.conditions:
		match condition["type"]:
			LevelData.ConditionType.HARVEST_COUNT:
				if harvest_count < condition["target"]:
					all_met = false
			LevelData.ConditionType.HARVEST_COUNT_WITH_STEP_LIMIT:
				if step_count > condition["max_steps"]:
					all_met = false

	if all_met:
		level_complete = true
		level_won.emit(current_level_id)

func _emit_progress() -> void:
	var level := get_current_level()
	if level == null:
		return
	var target := 0
	var max_steps := -1
	for c in level.conditions:
		if c["type"] == LevelData.ConditionType.HARVEST_COUNT:
			target = c["target"]
		if c["type"] == LevelData.ConditionType.HARVEST_COUNT_WITH_STEP_LIMIT:
			max_steps = c["max_steps"]
	progress_updated.emit(harvest_count, target, step_count, max_steps)

func next_level() -> void:
	var next_id := current_level_id + 1
	if next_id <= LevelData.get_all().size():
		load_level(next_id)
	else:
		print("Semua level selesai!")
