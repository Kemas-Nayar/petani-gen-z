#set page(
  paper: "a4",
  margin: (x: 2cm, y: 2.5cm),
)

#set text(
  font: "Times New Roman",
  size: 11pt,
  lang: "id"
)

#set heading(numbering: "1.1.")

// --- Cover Page ---
#align(center + horizon)[
  #text(size: 24pt, weight: "bold")[GAME DESIGN DOCUMENT] \
  #v(1em)
  #text(size: 32pt, weight: "bold")[Petani Gen Z] \
  #image("ipb.png", width: 60%)
  #v(4cm)
  #text(size: 14pt, style: "italic")[Puzzle Edukasi · Coding · Strategy]
  
  
  #grid(
    columns: (1fr),
    gutter: 1em,
    [KOM1304 — Grafika Komputer dan Visualisasi],
    [Program Studi Ilmu Komputer, IPB University],
    [2026]
  )
  
  #v(2cm)
  
  #text(weight: "bold")[Kelompok 6 — Pararel 4 — Heavy Metal]
  #table(
    columns: (auto, auto),
    inset: 10pt,
    stroke: none,
    align: left,
    [Kemas Adirangga Nayar], [M0403241043],
    [Adzkia Muftia Rahman], [M0403241153],
    [Kafka M. Arya Mukti], [M0403241008],
    [Nabil Musannif Siregar], [M0403241121],
  )
]

#pagebreak()

// --- Main Content ---

= Gambaran Umum Proyek

#table(
  columns: (3cm, 1fr),
  inset: 8pt,
  [#strong[Judul]], [Petani Gen Z],
  [#strong[Genre]], [Puzzle Edukasi / Coding / Strategy],
  [#strong[Engine]], [Godot Engine 4.x],
  [#strong[Platform]], [PC (Desktop)],
  [#strong[Bahasa]], [Indonesia],
  [#strong[Inspirasi]], [The Farmer Was Replaced + Scratch Visual Block],
  [#strong[Tim]], [Kelompok 6 — Heavy Metal — KOM1304 IPB University 2026],
)

== Latar Belakang
Literasi pemrograman menjadi keterampilan fundamental di era digital. Namun, metode pengajaran konvensional seringkali bersifat abstrak dan sulit dipahami oleh pelajar. Diperlukan pendekatan yang lebih intuitif, menyenangkan, dan berbasis konteks nyata. Permainan ini membuktikan bahwa pemrograman dapat dipelajari secara organik melalui mekanik permainan di mana pemain secara alami mempelajari konsep loop, kondisional, dan variabel.

== Konsep Inti
- Robot petani dikontrol menggunakan script dengan antarmuka visual block mirip Scratch.
- Sistem grid berbasis `TileMapLayer` (128x128 px) digunakan untuk memetakan perintah kode.
- Setiap level menantang pemain menggunakan konsep pemrograman baru.

= Mekanik Permainan

== Sistem Grid
Permainan menggunakan sistem grid berbasis `TileMapLayer` Godot 4:
- *Ukuran tile:* 128×128 piksel.
- *Proyeksi:* 2D top-down grid.
- *Y-sort:* Diaktifkan untuk kedalaman visual karakter dan tile yang benar.
- *Keamanan:* Pergerakan dikunci ke grid; robot tidak dapat bergerak saat animasi berjalan (`is_moving` flag).

== Sistem Pergerakan
Robot bergerak menggunakan input keyboard atau blok visual melalui Tween animasi (durasi 0.2 detik, transisi `TRANS_SINE`). Posisi dikonversi menggunakan:
#align(center)[
  `tile_map_layer.to_global(tile_map_layer.map_to_local(grid_pos))`
]

== Sistem Pertanian (Farming System)
Dikelola oleh `FarmManager` (Autoload singleton) dan `FarmTile` (Resource).

*Siklus State Tile:*
#table(
  columns: (auto, 1fr, auto, 1fr),
  fill: (x, y) => if y == 0 { gray.lighten(50%) },
  [*State*], [*Deskripsi*], [*Tekstur*], [*Transisi Berikutnya*],
  [EMPTY], [Tanah kosong, siap ditanami], [Empty.jpg], [PLANTED (via Plant)],
  [PLANTED], [Benih telah ditanam], [Planted.jpg], [WATERED (via Water)],
  [WATERED], [Tanah telah disiram], [Watered.jpg], [HARVESTABLE (Otomatis, 10s)],
  [HARVESTABLE], [Tanaman siap dipanen], [Harvestable.jpg], [EMPTY (via Harvest)],
)

#quote(block: true)[
  *Alur:* EMPTY $arrow.r$ PLANTED $arrow.r$ WATERED $arrow.r$ (10 detik) $arrow.r$ HARVESTABLE $arrow.r$ EMPTY
]

== Sistem Visual Tile
`TileVisualManager` memperbarui tampilan menggunakan `set_cell()` berdasarkan sinyal `tile_state_changed`:
- EMPTY (ID: 10) | PLANTED (ID: 11) | WATERED (ID: 12) | HARVESTABLE (ID: 13)

= Kontrol & Input

== Input Keyboard (Mode Manual)
#table(
  columns: (1fr, 1fr, 2fr),
  [*Tombol*], [*Aksi*], [*Fungsi GDScript*],
  [↑ / ↓ / ← / →], [Gerak], [`move_to_grid(dir)`],
  [Z], [Tanam], [`do_action("plant")`],
  [X], [Siram], [`do_action("water")`],
  [C], [Panen], [`do_action("harvest")`],
)

== Mode Visual Block (Rencana — Tier 1)
Implementasi drag-and-drop meliputi blok kategori *Gerak* (North, South, West, East) dan *Aksi* (Plant, Water, Harvest).

= Arsitektur Teknis

== Aliran Data Sistem
1. *Input Pemain* (Keyboard / Blok)
2. `CharacterBody2D.do_action(action)`
3. `FarmManager.plant/water/harvest(grid_pos)`
4. `FarmTile.state` berubah & memancarkan sinyal `tile_state_changed`
5. `TileVisualManager` memanggil `TileMapLayer.set_cell()`

= Rencana Pengembangan

== Fase 2 — Sistem Blok Visual & Level (Prioritas Tinggi)
- HUD status tile saat ini di bawah robot.
- Sistem visual block (Scratch-like).
- Kondisi menang per level (misal: panen 3 tanaman).

== Fase 3 — Finalisasi (Prioritas Sedang/Tinggi)
- Sistem variabel & mata uang (Tier 3).
- UI/UX polish & menu utama.
- Bug fixing & build final.

= Struktur Tim
#table(
  columns: (1fr, 1fr, 1fr, 2fr),
  [*Nama*], [*NIM*], [*Peran*], [*Tanggung Jawab*],
  [Kemas Adirangga], [M0403241043], [Lead Dev], [Arsitektur, Farming System, GDD],
  [Adzkia Muftia], [M0403241153], [], [],
  [Kafka M. Arya], [M0403241008], [], [],
  [Nabil Musannif], [M0403241121], [], [],
)

= Referensi
- Godot Engine 4.x Documentation.
- Scratch — MIT Media Lab.
- Tim Soret (2024). _The Farmer Was Replaced_. Steam.

#v(2em)
#align(center)[
  #text(size: 9pt, style: "italic")[Petani Gen Z GDD v1.0 · Kelompok 6 Heavy Metal · IPB University 2026]
]
