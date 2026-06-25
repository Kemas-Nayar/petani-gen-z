extends Resource
class_name BlockDefinition

enum Category { MOVE, ACTION, CONTROL, CONDITION }
enum BlockType { SIMPLE, CONTROL_BLOCK, CONDITION }

var id: String = ""
var label: String = ""
var category: Category = Category.MOVE
var color: Color = Color.WHITE
var block_type: BlockType = BlockType.SIMPLE
var has_children: bool = false   # true untuk while/for/if — punya slot anak
var condition_ids: Array = []    # untuk CONTROL_BLOCK: kondisi yang bisa dipakai

static func create(p_id: String, p_label: String, p_cat: Category, p_color: Color,
		p_type: BlockType = BlockType.SIMPLE, p_has_children: bool = false) -> BlockDefinition:
	var b = BlockDefinition.new()
	b.id = p_id
	b.label = p_label
	b.category = p_cat
	b.color = p_color
	b.block_type = p_type
	b.has_children = p_has_children
	return b

static func get_all() -> Array[BlockDefinition]:
	var move    = Color(0.20, 0.47, 0.85)   # Biru
	var action  = Color(0.18, 0.60, 0.25)   # Hijau
	var control = Color(0.50, 0.15, 0.70)   # Ungu
	var cond    = Color(0.75, 0.65, 0.00)   # Kuning

	return [
		# Tier 1 — Gerak
		create("north",   "North ↑",   Category.MOVE,   move),
		create("south",   "South ↓",   Category.MOVE,   move),
		create("west",    "West ←",    Category.MOVE,   move),
		create("east",    "East →",    Category.MOVE,   move),
		# Tier 1 — Aksi
		create("plant",   "Plant 🌱",  Category.ACTION, action),
		create("water",   "Water 💧",  Category.ACTION, action),
		create("harvest", "Harvest 🌾",Category.ACTION, action),
		# Tier 2 — Kontrol
		create("for",     "for(N) { }",   Category.CONTROL,   control, BlockType.CONTROL_BLOCK, true),
		create("while",   "while(cond){ }",Category.CONTROL,  control, BlockType.CONTROL_BLOCK, true),
		create("if",      "if(cond){ }",  Category.CONTROL,   control, BlockType.CONTROL_BLOCK, true),
		create("wait",    "wait(N s)",    Category.CONTROL,   control, BlockType.SIMPLE, false),
		# Tier 2 — Kondisi
		create("is_planted",     "IsPlanted()",     Category.CONDITION, cond, BlockType.CONDITION),
		create("is_watered",     "IsWatered()",     Category.CONDITION, cond, BlockType.CONDITION),
		create("is_harvestable", "IsHarvestable()", Category.CONDITION, cond, BlockType.CONDITION),
		create("is_not_planted", "IsNotPlanted()", Category.CONDITION, cond, BlockType.CONDITION),
		create("is_not_watered", "IsNotWatered()", Category.CONDITION, cond, BlockType.CONDITION),
		create("is_not_harvestable", "IsNotHarvestable()", Category.CONDITION, cond, BlockType.CONDITION),
	]

static func get_by_id(id: String) -> BlockDefinition:
	for def in get_all():
		if def.id == id:
			return def
	return null

static func get_by_category(cat: Category) -> Array[BlockDefinition]:
	var result: Array[BlockDefinition] = []
	for def in get_all():
		if def.category == cat:
			result.append(def)
	return result
