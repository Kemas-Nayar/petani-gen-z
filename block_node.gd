extends RefCounted
class_name BlockNode

var id: String = ""
var children: Array[BlockNode] = []
var repeat_count: int = 4
var condition_id: String = ""

var wait_time: float = 1.0

func _init(p_id: String = "") -> void:
	id = p_id

func is_control() -> bool:
	var def := BlockDefinition.get_by_id(id)
	return def != null and def.has_children

func to_dict() -> Dictionary:
	var d := { "id": id }
	if id == "for":
		d["repeat_count"] = repeat_count
	if id == "wait":
		d["wait_time"] = wait_time
	if id in ["while", "if"]:
		d["condition_id"] = condition_id
	if not children.is_empty():
		d["children"] = children.map(func(c: BlockNode): return c.to_dict())
	return d
