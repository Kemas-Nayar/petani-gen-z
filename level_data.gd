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

static func get_all() -> Array[LevelData]:
	return [level_1(), level_2(), level_3()]

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
