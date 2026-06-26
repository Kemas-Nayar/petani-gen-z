extends Node

# settings_manager.gd
# Add as an Autoload named "SettingsManager"

const SAVE_PATH = "user://settings.cfg"

signal settings_changed()

var settings = {
	"master_volume": 0.8,
	"music_volume": 0.8,
	"sfx_volume": 0.8,
	"fullscreen": false,
	"resolution": "1280x720",
	"language": "en" # Default language is English
}

func _ready() -> void:
	setup_audio_buses()
	setup_translations()
	load_settings()

func setup_audio_buses() -> void:
	var buses = ["Master", "Music", "SFX"]
	for bus_name in buses:
		var idx = AudioServer.get_bus_index(bus_name)
		if idx == -1:
			AudioServer.add_bus()
			idx = AudioServer.get_bus_count() - 1
			AudioServer.set_bus_name(idx, bus_name)
			if bus_name != "Master":
				AudioServer.set_bus_send(idx, "Master")

func setup_translations() -> void:
	# -------------------- TRANSLASI INDONESIA (id) --------------------
	var t_id = Translation.new()
	t_id.locale = "id"
	
	# UI Menu Utama & Umum
	t_id.add_message("Start Game", "Mulai Bermain")
	t_id.add_message("Settings", "Pengaturan")
	t_id.add_message("Exit", "Keluar")
	t_id.add_message("Close", "Tutup")
	t_id.add_message("Back", "Kembali")
	t_id.add_message("⚙️ Menu", "⚙️ Menu")
	
	# UI Pengaturan
	t_id.add_message("SETTINGS", "PENGATURAN")
	t_id.add_message("Master Volume", "Volume Master")
	t_id.add_message("Music Volume", "Volume Musik")
	t_id.add_message("SFX Volume", "Volume SFX")
	t_id.add_message("Fullscreen", "Layar Penuh")
	t_id.add_message("Resolution", "Resolusi")
	t_id.add_message("Language", "Bahasa")
	t_id.add_message("Reset Progress", "Reset Progres")
	t_id.add_message("Game progress has been reset!", "Progres game telah di-reset!")
	t_id.add_message("Confirmation", "Konfirmasi")
	t_id.add_message("Are you sure you want to reset level back to level 1?", "Apakah Anda yakin ingin meriset level kembali ke level 1?")
	t_id.add_message("Yes", "Ya")
	t_id.add_message("Cancel", "Batal")
	t_id.add_message("Apply", "Terapkan")
	t_id.add_message("Unsaved Changes", "Perubahan Belum Disimpan")
	t_id.add_message("Do you want to save changes before closing?", "Apakah Anda ingin menyimpan perubahan sebelum menutup?")
	t_id.add_message("Save", "Simpan")
	t_id.add_message("Discard", "Jangan Simpan")
	t_id.add_message("❌ Level Failed!\n%s", "❌ Level Gagal!\n%s")
	t_id.add_message("Target level not reached.", "Target level tidak tercapai.")
	t_id.add_message("Steps exceeded limit (%d/%d)!", "Langkah melebihi batas (%d/%d)!")
	
	# UI Game / Block UI
	t_id.add_message("Select Level:", "Pilih Level:")
	t_id.add_message("Block Sequence", "Urutan Blok")
	t_id.add_message("Available Blocks", "Blok Tersedia")
	t_id.add_message("▶ Run", "▶ Jalankan")
	t_id.add_message("⏹ Stop", "⏹ Stop")
	t_id.add_message("Clear All", "Hapus Semua")
	t_id.add_message("🔄 Reset Map", "🔄 Reset Map")
	t_id.add_message("Steps:", "Langkah:")
	t_id.add_message("Harvest:", "Panen:")
	t_id.add_message("🌱 Grows in %.1f seconds", "🌱 Tumbuh dalam %.1f detik")
	
	# Pesan Status & Petunjuk Block Sequence
	t_id.add_message("Condition blocks can only be inside for/while/if.", "Blok kondisi hanya bisa di dalam for/while/if.")
	t_id.add_message("Program full!", "Program penuh!")
	t_id.add_message("Click or drag blocks here", "Klik atau drag blok ke sini")
	t_id.add_message("  + drop block here", "  + drop blok di sini")
	t_id.add_message("Running...", "Menjalankan...")
	t_id.add_message("Finished.", "Selesai.")
	t_id.add_message("Map reset to initial state.", "Map direset ke kondisi awal.")
	t_id.add_message("Harvest: %d/%d | Steps: %d/%d", "Panen: %d/%d | Langkah: %d/%d")
	t_id.add_message("Harvest: %d/%d", "Panen: %d/%d")
	
	# Level Titles & Info
	t_id.add_message("Level 1 — Novice Farmer", "Level 1 — Petani Pemula")
	t_id.add_message("Harvest 1 crop to complete this level.", "Panen 1 tanaman untuk menyelesaikan level ini.")
	t_id.add_message("Use blocks: Plant → Water → (wait) → Harvest", "Gunakan blok Plant → Water → (tunggu) → Harvest")
	t_id.add_message("Hint: ", "Petunjuk: ")
	
	t_id.add_message("Level 2 — Small Field", "Level 2 — Ladang Kecil")
	t_id.add_message("Harvest 3 crops to complete this level.", "Panen 3 tanaman untuk menyelesaikan level ini.")
	t_id.add_message("Use loops or arrange block sequences efficiently!", "Gunakan loop atau susun urutan blok yang efisien!")
	
	t_id.add_message("Level 3 — High Efficiency", "Level 3 — Efisiensi Tinggi")
	t_id.add_message("Harvest 3 crops in maximum 20 steps!", "Panen 3 tanaman dalam maksimal 20 langkah!")
	t_id.add_message("Plan the robot's route before pressing Run.", "Rencanakan rute robot sebelum menekan Run.")
	
	t_id.add_message("Level 4 — The Spiral Path", "Level 4 — Jalur Spiral")
	t_id.add_message("Harvest 5 crops.", "Panen 5 tanaman.")
	t_id.add_message("Plant, water, and harvest 5 crops in a spiral pattern.", "Tanam, siram, dan panen 5 tanaman dengan pola spiral.")
	
	t_id.add_message("Level 5 — Grand Harvest", "Level 5 — Panen Raya")
	t_id.add_message("Harvest all 9 crops in the field.", "Panen seluruh 9 tanaman di ladang.")
	t_id.add_message("Find a traversal pattern (like zigzag) to plant, water, and harvest all 9 tiles.", "Temukan pola penjelajahan (seperti zigzag) untuk menanam, menyiram, dan memanen seluruh 9 ubin.")
	
	t_id.add_message("Level 6 — Smart Loop", "Level 6 — Loop Pintar")
	t_id.add_message("Harvest 6 crops in maximum 35 steps!", "Panen 6 tanaman dalam maksimal 35 langkah!")
	t_id.add_message("Use nested loops to cover tiles and save steps.", "Gunakan loop bersarang untuk menjangkau ubin dan menghemat langkah.")
	
	t_id.add_message("Level 7 — Grid Speedrun", "Level 7 — Balapan Grid")
	t_id.add_message("Harvest all 9 crops in maximum 55 steps!", "Panen seluruh 9 tanaman dalam maksimal 55 langkah!")
	t_id.add_message("Combine actions efficiently within loops to traverse and harvest the 3x3 grid.", "Gabungkan aksi secara efisien di dalam loop untuk menjelajahi dan memanen grid 3x3.")
	
	t_id.add_message("Level 8 — Adaptive Farming", "Level 8 — Pertanian Adaptif")
	t_id.add_message("Harvest 6 crops in maximum 40 steps!", "Panen 6 tanaman dalam maksimal 40 langkah!")
	t_id.add_message("Use conditions like 'if(IsNotPlanted())' to avoid planting on already planted tiles.", "Gunakan kondisi seperti 'jika(BelumDitanam())' untuk menghindari menanam pada ubin yang sudah ditanami.")
	
	t_id.add_message("Level 9 — The Lazy Robot", "Level 9 — Robot Pemalas")
	t_id.add_message("Harvest 6 crops in maximum 35 steps!", "Panen 6 tanaman dalam maksimal 35 langkah!")
	t_id.add_message("Pre-watered tiles grow automatically. Check if tiles are growing to save actions.", "Ubin yang sudah disiram tumbuh otomatis. Periksa apakah tanaman sedang tumbuh untuk menghemat aksi.")
	
	t_id.add_message("Level 10 — Ultimate Farm Master", "Level 10 — Master Petani Sejati")
	t_id.add_message("Harvest all 9 crops in maximum 60 steps!", "Panen seluruh 9 tanaman dalam maksimal 60 langkah!")
	t_id.add_message("Write an adaptive program that handles a mix of empty, planted, and watered tiles.", "Tulis program adaptif yang menangani campuran ubin kosong, ditanam, dan disiram.")
	
	# Block Names (Indonesian translations of English source labels)
	t_id.add_message("North ↑", "Utara ↑")
	t_id.add_message("South ↓", "Selatan ↓")
	t_id.add_message("West ←", "Barat ←")
	t_id.add_message("East →", "Timur →")
	t_id.add_message("Plant 🌱", "Tanam 🌱")
	t_id.add_message("Water 💧", "Siram 💧")
	t_id.add_message("Harvest 🌾", "Panen 🌾")
	
	# Categories (Indonesian)
	t_id.add_message("🔵 Movement", "🔵 Gerak")
	t_id.add_message("🟢 Action", "🟢 Aksi")
	t_id.add_message("🟣 Control", "🟣 Kontrol")
	t_id.add_message("🟡 Condition", "🟡 Kondisi")
	
	# Keyword Kontrol & Kondisi (Indonesian)
	t_id.add_message("for", "untuk")
	t_id.add_message("while", "selama")
	t_id.add_message("if", "jika")
	t_id.add_message("wait", "tunggu")
	t_id.add_message("s)", "detik)")
	t_id.add_message("IsPlanted()", "SudahDitanam()")
	t_id.add_message("IsWatered()", "SudahDisiram()")
	t_id.add_message("IsHarvestable()", "SiapPanen()")
	t_id.add_message("IsNotPlanted()", "BelumDitanam()")
	t_id.add_message("IsNotWatered()", "BelumDisiram()")
	t_id.add_message("IsNotHarvestable()", "BelumSiapPanen()")
	t_id.add_message("else", "selain_itu")
	t_id.add_message("else { }", "selain_itu { }")
	t_id.add_message("IsPathNorth()", "AdaJalanUtara()")
	t_id.add_message("IsPathSouth()", "AdaJalanSelatan()")
	t_id.add_message("IsPathWest()", "AdaJalanBarat()")
	t_id.add_message("IsPathEast()", "AdaJalanTimur()")
	
	# Popups (Indonesian)
	t_id.add_message("🎉 Level Complete!\n%s", "🎉 Level Selesai!\n%s")
	t_id.add_message("Harvested: %d crops\nSteps: %d blocks executed", "Panen: %d tanaman\nLangkah: %d blok dieksekusi")
	t_id.add_message("Next Level ▶", "Level Berikutnya ▶")
	t_id.add_message("Retry 🔄", "Ulangi 🔄")
	t_id.add_message("🏆 Congratulations!\nAll Levels Completed!", "🏆 Selamat!\nSemua Level Selesai!")
	
	TranslationServer.add_translation(t_id)

func load_settings() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		settings.master_volume = config.get_value("audio", "master_volume", 0.8)
		settings.music_volume = config.get_value("audio", "music_volume", 0.8)
		settings.sfx_volume = config.get_value("audio", "sfx_volume", 0.8)
		settings.fullscreen = config.get_value("video", "fullscreen", false)
		settings.resolution = config.get_value("video", "resolution", "1280x720")
		settings.language = config.get_value("general", "language", "en")
	
	apply_settings()

func save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "master_volume", settings.master_volume)
	config.set_value("audio", "music_volume", settings.music_volume)
	config.set_value("audio", "sfx_volume", settings.sfx_volume)
	config.set_value("video", "fullscreen", settings.fullscreen)
	config.set_value("video", "resolution", settings.resolution)
	config.set_value("general", "language", settings.language)
	config.save(SAVE_PATH)

func apply_settings() -> void:
	set_volume("Master", settings.master_volume)
	set_volume("Music", settings.music_volume)
	set_volume("SFX", settings.sfx_volume)
	
	if settings.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		var parts = settings.resolution.split("x")
		if parts.size() == 2:
			var w = int(parts[0])
			var h = int(parts[1])
			DisplayServer.window_set_size(Vector2i(w, h))
			# Center window
			var screen = DisplayServer.window_get_current_screen()
			var screen_size = DisplayServer.screen_get_size(screen)
			DisplayServer.window_set_position(screen_size / 2 - Vector2i(w, h) / 2)
			
	TranslationServer.set_locale(settings.language)
	settings_changed.emit()

func set_volume(bus_name: String, volume_linear: float) -> void:
	var idx = AudioServer.get_bus_index(bus_name)
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, linear_to_db(volume_linear))
		AudioServer.set_bus_mute(idx, volume_linear < 0.05)
