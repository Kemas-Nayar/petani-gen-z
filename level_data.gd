extends Resource
class_name LevelData

enum ConditionType {
	HARVEST_COUNT,
	PLANT_ALL_TILES,
	HARVEST_COUNT_WITH_STEP_LIMIT,
}

var id: int = 0
var title: String = ""
var description: String = ""
var hint: String = ""
var conditions: Array = []
var initial_tiles: Dictionary = {}  # Vector2i -> FarmTile.State

static func get_all() -> Array[LevelData]:
	return [
		level_1(),
		level_2(),
		level_3(),
		level_4(),
		level_5(),
		level_6(),
		level_7(),
		level_8(),
		level_9(),
		level_10()
	]

static func get_level(level_id: int) -> LevelData:
	for lvl in get_all():
		if lvl.id == level_id:
			return lvl
	return null

static func level_1() -> LevelData:
	var l = LevelData.new()
	l.id = 1
	l.title = "Level 1 — Novice Farmer"
	l.description = "Harvest 1 crop to complete this level."
	l.hint = "Use blocks: Plant → Water → (wait) → Harvest"
	l.conditions = [
		{ "type": ConditionType.HARVEST_COUNT, "target": 1 }
	]
	return l

static func level_2() -> LevelData:
	var l = LevelData.new()
	l.id = 2
	l.title = "Level 2 — Small Field"
	l.description = "Harvest 3 crops to complete this level."
	l.hint = "Use loops or arrange block sequences efficiently!"
	l.conditions = [
		{ "type": ConditionType.HARVEST_COUNT, "target": 3 }
	]
	return l

static func level_3() -> LevelData:
	var l = LevelData.new()
	l.id = 3
	l.title = "Level 3 — High Efficiency"
	l.description = "Harvest 3 crops in maximum 20 steps!"
	l.hint = "Plan the robot's route before pressing Run."
	l.conditions = [
		{ "type": ConditionType.HARVEST_COUNT, "target": 3 },
		{ "type": ConditionType.HARVEST_COUNT_WITH_STEP_LIMIT, "max_steps": 20 }
	]
	return l

static func level_4() -> LevelData:
	var l = LevelData.new()
	l.id = 4
	l.title = "Level 4 — The Spiral Path"
	l.description = "Harvest 5 crops."
	l.hint = "Plant, water, and harvest 5 crops in a spiral pattern."
	l.conditions = [
		{ "type": ConditionType.HARVEST_COUNT, "target": 5 }
	]
	return l

static func level_5() -> LevelData:
	var l = LevelData.new()
	l.id = 5
	l.title = "Level 5 — Grand Harvest"
	l.description = "Harvest all 9 crops in the field."
	l.hint = "Find a traversal pattern (like zigzag) to plant, water, and harvest all 9 tiles."
	l.conditions = [
		{ "type": ConditionType.HARVEST_COUNT, "target": 9 }
	]
	return l

static func level_6() -> LevelData:
	var l = LevelData.new()
	l.id = 6
	l.title = "Level 6 — Smart Loop"
	l.description = "Harvest 6 crops in maximum 35 steps!"
	l.hint = "Use nested loops to cover tiles and save steps."
	l.conditions = [
		{ "type": ConditionType.HARVEST_COUNT, "target": 6 },
		{ "type": ConditionType.HARVEST_COUNT_WITH_STEP_LIMIT, "max_steps": 35 }
	]
	return l

static func level_7() -> LevelData:
	var l = LevelData.new()
	l.id = 7
	l.title = "Level 7 — Grid Speedrun"
	l.description = "Harvest all 9 crops in maximum 55 steps!"
	l.hint = "Combine actions efficiently within loops to traverse and harvest the 3x3 grid."
	l.conditions = [
		{ "type": ConditionType.HARVEST_COUNT, "target": 9 },
		{ "type": ConditionType.HARVEST_COUNT_WITH_STEP_LIMIT, "max_steps": 55 }
	]
	return l

static func level_8() -> LevelData:
	var l = LevelData.new()
	l.id = 8
	l.title = "Level 8 — Adaptive Farming"
	l.description = "Harvest 6 crops in maximum 40 steps!"
	l.hint = "Use conditions like 'if(IsNotPlanted())' to avoid planting on already planted tiles."
	l.conditions = [
		{ "type": ConditionType.HARVEST_COUNT, "target": 6 },
		{ "type": ConditionType.HARVEST_COUNT_WITH_STEP_LIMIT, "max_steps": 40 }
	]
	l.initial_tiles = {
		Vector2i(3, 4): FarmTile.State.PLANTED,
		Vector2i(4, 5): FarmTile.State.PLANTED,
		Vector2i(5, 6): FarmTile.State.PLANTED
	}
	return l

static func level_9() -> LevelData:
	var l = LevelData.new()
	l.id = 9
	l.title = "Level 9 — The Lazy Robot"
	l.description = "Harvest 6 crops in maximum 35 steps!"
	l.hint = "Pre-watered tiles grow automatically. Check if tiles are growing to save actions."
	l.conditions = [
		{ "type": ConditionType.HARVEST_COUNT, "target": 6 },
		{ "type": ConditionType.HARVEST_COUNT_WITH_STEP_LIMIT, "max_steps": 35 }
	]
	l.initial_tiles = {
		Vector2i(3, 4): FarmTile.State.WATERED,
		Vector2i(4, 5): FarmTile.State.WATERED,
		Vector2i(5, 4): FarmTile.State.WATERED,
		Vector2i(5, 6): FarmTile.State.WATERED
	}
	return l

static func level_10() -> LevelData:
	var l = LevelData.new()
	l.id = 10
	l.title = "Level 10 — Ultimate Farm Master"
	l.description = "Harvest all 9 crops in maximum 60 steps!"
	l.hint = "Write an adaptive program that handles a mix of empty, planted, and watered tiles."
	l.conditions = [
		{ "type": ConditionType.HARVEST_COUNT, "target": 9 },
		{ "type": ConditionType.HARVEST_COUNT_WITH_STEP_LIMIT, "max_steps": 60 }
	]
	l.initial_tiles = {
		Vector2i(3, 4): FarmTile.State.WATERED,
		Vector2i(4, 4): FarmTile.State.PLANTED,
		Vector2i(3, 5): FarmTile.State.PLANTED,
		Vector2i(4, 5): FarmTile.State.WATERED,
		Vector2i(5, 5): FarmTile.State.PLANTED,
		Vector2i(5, 6): FarmTile.State.WATERED
	}
	return l
