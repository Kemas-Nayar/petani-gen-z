extends Resource
class_name BlockDefinition

enum Category { MOVE, ACTION }

var id: String = ""
var label: String = ""
var category: Category = Category.MOVE
var color: Color = Color.WHITE

static func create(p_id: String, p_label: String, p_category: Category, p_color: Color) -> BlockDefinition:
	var b = BlockDefinition.new()
	b.id = p_id
	b.label = p_label
	b.category = p_category
	b.color = p_color
	return b

# Semua blok Tier 1
static func get_all() -> Array[BlockDefinition]:
	var move  = Color(0.20, 0.47, 0.85)  # Biru
	var action = Color(0.18, 0.60, 0.25) # Hijau
	return [
		create("north",   "North ↑",  Category.MOVE,   move),
		create("south",   "South ↓",  Category.MOVE,   move),
		create("west",    "West ←",   Category.MOVE,   move),
		create("east",    "East →",   Category.MOVE,   move),
		create("plant",   "Plant 🌱", Category.ACTION, action),
		create("water",   "Water 💧", Category.ACTION, action),
		create("harvest", "Harvest 🌾",Category.ACTION, action),
	]
