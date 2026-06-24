extends CanvasLayer

# Mengontrol panel blok di sisi kiri agar tidak menutupi area permainan.

@onready var sidebar: HBoxContainer = $HBoxContainer
@onready var toggle_button: Button = $ToggleButton

func _ready() -> void:
	toggle_button.pressed.connect(_on_toggle_pressed)
	_update_toggle_label()

func _on_toggle_pressed() -> void:
	sidebar.visible = not sidebar.visible
	_update_toggle_label()

func _update_toggle_label() -> void:
	toggle_button.text = "▶ Blok" if not sidebar.visible else "◀ Sembunyikan"
