extends Resource
class_name FarmTile

enum State { EMPTY, PLANTED, WATERED, HARVESTABLE }

var state: State = State.EMPTY
var grid_pos: Vector2i = Vector2i.ZERO

func plant() -> bool:
	if state != State.EMPTY:
		print("Cannot plant — tile is not empty at ", grid_pos)
		return false
	state = State.PLANTED
	print("Planted at ", grid_pos)
	return true

func water() -> bool:
	if state != State.PLANTED:
		print("Cannot water — tile must be planted first at ", grid_pos)
		return false
	state = State.WATERED
	print("Watered at ", grid_pos)
	return true

func harvest() -> bool:
	if state != State.HARVESTABLE:
		print("Cannot harvest — crop not ready at ", grid_pos)
		return false
	state = State.EMPTY
	print("Harvested at ", grid_pos)
	return true

func get_state_name() -> String:
	match state:
		State.EMPTY: return "Empty"
		State.PLANTED: return "Planted"
		State.WATERED: return "Watered"
		State.HARVESTABLE: return "Harvestable"
	return "Unknown"
