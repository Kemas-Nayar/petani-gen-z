extends CanvasLayer

@onready var overlay: ColorRect = $Overlay
@onready var title_label: Label = $Overlay/CenterContainer/PopupPanel/MarginContainer/VBox/TitleLabel
@onready var stats_label: Label = $Overlay/CenterContainer/PopupPanel/MarginContainer/VBox/StatsLabel
@onready var next_button: Button = $Overlay/CenterContainer/PopupPanel/MarginContainer/VBox/NextButton
@onready var retry_button: Button = $Overlay/CenterContainer/PopupPanel/MarginContainer/VBox/RetryButton

func _ready() -> void:
	overlay.visible = false
	layer = 10
	LevelManager.level_won.connect(_on_level_won)
	next_button.pressed.connect(_on_next_pressed)
	retry_button.pressed.connect(_on_retry_pressed)
	
	# Menerapkan lokalisasi untuk tombol
	next_button.text = tr("Next Level ▶")
	retry_button.text = tr("Retry 🔄")

func _on_level_won(level_id: int) -> void:
	var level := LevelData.get_level(level_id)
	var is_last := level_id >= LevelData.get_all().size()

	title_label.text = tr("🎉 Level Complete!\n%s") % tr(level.title)
	stats_label.text = tr("Harvested: %d crops\nSteps: %d blocks executed") % [
		LevelManager.harvest_count,
		LevelManager.step_count
	]

	next_button.visible = not is_last
	if is_last:
		title_label.text = tr("🏆 Congratulations!\nAll Levels Completed!")

	overlay.visible = true

func _on_next_pressed() -> void:
	overlay.visible = false
	LevelManager.next_level()
	FarmManager.tiles.clear()
	get_tree().reload_current_scene()

func _on_retry_pressed() -> void:
	overlay.visible = false
	LevelManager.load_level(LevelManager.current_level_id)
	FarmManager.tiles.clear()
	get_tree().reload_current_scene()
