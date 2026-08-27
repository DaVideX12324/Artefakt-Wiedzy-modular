extends Node

## Globalny serwis audio -- muzyka, SFX (UI + spatial), busy AudioServer.
## Rejestrowany jako autoload w host project.godot pod nazwa "AudioService".
## Do uzycia w standalone: skopiuj ten plik do modulu i zarejestruj pod
## ta sama nazwa w standalone_project.godot.example (patrz docs/module_contract.md).
## Kod woluje bezposrednio AudioService.play_music(...) itd. -- to prawdziwy
## autoload, NIE przechodzi przez CoreManager.get_singleton() (ten jest
## czyszczony przy kazdym przelaczeniu modulu, audio ma byc trwale).
##
## Utwory muzyczne nie sa preloadowane na starcie -- mapa nazwa->sciezka
## jest wczytywana z JSON (MUSIC_TRACKS_JSON_PATH), a same pliki .ogg
## sa doladowywane leniwie (load()) przy pierwszym uzyciu i cache'owane.

const MUSIC_MIN_DB := -60.0
const SFX_MIN_DB := -60.0
const MASTER_MIN_DB := -60.0
const MUTE_DB := -80.0

const MUSIC_TRACKS_JSON_PATH := "res://resources/audio/music_tracks.json"

signal music_volume_changed(volume: float)
signal sfx_volume_changed(volume: float)
signal master_volume_changed(volume: float)
signal music_changed(track_name: String)
signal mute_toggled(is_muted: bool)

const BUS_MASTER := "Master"
const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"

var music_player: AudioStreamPlayer
var ambience_player: AudioStreamPlayer

var sfx_pool: Array[AudioStreamPlayer] = []
const SFX_POOL_SIZE := 16

var is_muted: bool = false:
	set(value):
		is_muted = value
		mute_toggled.emit(is_muted)

var current_track: String = ""
var previous_track: String = ""

var music_volume: float = 0.8:
	set(value):
		music_volume = clamp(value, 0.0, 1.0)
		_apply_music_volume()
		music_volume_changed.emit(music_volume)

var sfx_volume: float = 1.0:
	set(value):
		sfx_volume = clamp(value, 0.0, 1.0)
		_apply_sfx_volume()
		sfx_volume_changed.emit(sfx_volume)

var master_volume: float = 1.0:
	set(value):
		master_volume = clamp(value, 0.0, 1.0)
		_apply_master_volume()
		master_volume_changed.emit(master_volume)

## Nazwa -> sciezka res:// (wczytane z JSON, bez zaladowanych zasobow)
var music_track_paths: Dictionary = {}
## Cache zaladowanych AudioStream, wypelniany leniwie
var _music_stream_cache: Dictionary = {}

const PREFERENCES_PATH := "user://preferences.dat"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	music_player = AudioStreamPlayer.new()
	music_player.bus = BUS_MUSIC
	music_player.name = "MusicPlayer"
	add_child(music_player)

	ambience_player = AudioStreamPlayer.new()
	ambience_player.bus = BUS_MUSIC
	ambience_player.name = "AmbiencePlayer"
	add_child(ambience_player)

	for i in SFX_POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.bus = BUS_SFX
		player.name = "SFXPlayer%d" % i
		add_child(player)
		sfx_pool.append(player)

	_load_music_tracks_manifest()
	load_audio_settings()
	_apply_music_volume()
	_apply_sfx_volume()
	_apply_master_volume()


func _load_music_tracks_manifest() -> void:
	music_track_paths.clear()
	if not FileAccess.file_exists(MUSIC_TRACKS_JSON_PATH):
		push_warning("[AudioService] Brak manifestu: %s" % MUSIC_TRACKS_JSON_PATH)
		return
	var text := FileAccess.get_file_as_string(MUSIC_TRACKS_JSON_PATH)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("[AudioService] Niepoprawny JSON w %s" % MUSIC_TRACKS_JSON_PATH)
		return
	var parsed_dict: Dictionary = parsed
	for key in parsed_dict.keys():
		var track_key: String = key
		var track_path: String = str(parsed_dict[key])
		music_track_paths[track_key] = track_path


func _get_music_stream(track_name: String) -> AudioStream:
	if _music_stream_cache.has(track_name):
		return _music_stream_cache[track_name]
	if not music_track_paths.has(track_name):
		return null
	var path: String = music_track_paths[track_name]
	if not ResourceLoader.exists(path):
		push_warning("[AudioService] Plik nie istnieje: %s (%s)" % [track_name, path])
		return null
	var stream: AudioStream = load(path)
	if stream is AudioStreamOggVorbis:
		var ogg_stream := stream as AudioStreamOggVorbis
		ogg_stream.loop = true
		ogg_stream.loop_offset = 3.0
	_music_stream_cache[track_name] = stream
	return stream


## ============================================
## SFX PLAYBACK -- GLOBAL (UI, non-spatial)
## ============================================
func play_sfx(sound: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	if not sound:
		push_warning("[AudioService] Attempted to play null sound!")
		return
	var player := _get_free_sfx_player()
	if player:
		player.stream = sound
		player.volume_db = volume_db
		player.pitch_scale = pitch_scale
		player.play()
	else:
		push_warning("[AudioService] No free global SFX player!")


func _get_free_sfx_player() -> AudioStreamPlayer:
	for player in sfx_pool:
		if not player.playing:
			return player
	return null


static func create_spatial_sfx_player(parent: Node, max_distance: float = 1000.0, attenuation: float = 1.5) -> AudioStreamPlayer2D:
	var player := AudioStreamPlayer2D.new()
	player.bus = BUS_SFX
	player.max_distance = max_distance
	player.attenuation = attenuation
	parent.add_child(player)
	return player


static func play_spatial_sfx(player: AudioStreamPlayer2D, sound: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	if not player or not sound:
		return
	player.stream = sound
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.play()


## ============================================
## MUSIC PLAYBACK
## ============================================
func play_music(track_name: String, _fade_time: float = 1.0) -> void:
	var stream := _get_music_stream(track_name)
	if stream == null:
		push_warning("[AudioService] Track not found: %s" % track_name)
		return

	if current_track == track_name and music_player.playing:
		return

	if not track_name.begins_with("boss_"):
		previous_track = track_name

	current_track = track_name
	music_player.stream = stream
	music_player.volume_db = 0.0
	music_player.play()
	music_changed.emit(track_name)


func start_boss_music(boss_name: String, fade_time: float = 0.5) -> void:
	var boss_track := "boss_%s" % boss_name
	if not music_track_paths.has(boss_track):
		push_warning("[AudioService] Boss track not found: %s" % boss_track)
		return
	if current_track != "" and not current_track.begins_with("boss_"):
		previous_track = current_track
	play_music(boss_track, fade_time)


func end_boss_music(fade_time: float = 2.0, return_to_previous: bool = true) -> void:
	if return_to_previous and previous_track != "":
		play_music(previous_track, fade_time)
	else:
		stop_music(fade_time)


func stop_music(fade_time: float = 1.0) -> void:
	if music_player.playing:
		var tween := create_tween()
		tween.tween_method(_set_music_player_volume, music_player.volume_db, -80.0, fade_time)
		await tween.finished
		music_player.stop()
		current_track = ""


func _set_music_player_volume(volume: float) -> void:
	music_player.volume_db = volume


## ============================================
## AMBIENCE
## ============================================
func play_ambience(sound: AudioStream, fade_time: float = 2.0) -> void:
	if not sound:
		return
	if ambience_player.playing:
		var fade_out := create_tween()
		fade_out.tween_property(ambience_player, "volume_db", -80.0, fade_time * 0.5)
		await fade_out.finished
	ambience_player.stream = sound
	ambience_player.play()
	var fade_in := create_tween()
	fade_in.tween_property(ambience_player, "volume_db", -20.0, fade_time * 0.5)


func stop_ambience(fade_time: float = 1.0) -> void:
	if ambience_player.playing:
		var tween := create_tween()
		tween.tween_property(ambience_player, "volume_db", -80.0, fade_time)
		await tween.finished
		ambience_player.stop()


## ============================================
## VOLUME CONTROL
## ============================================
func _shape_slider(value: float) -> float:
	return pow(value, 0.7)


func _apply_master_volume() -> void:
	var bus_index := AudioServer.get_bus_index(BUS_MASTER)
	if bus_index == -1:
		return
	var db := MUTE_DB
	if master_volume > 0.0:
		db = lerp(MASTER_MIN_DB, 0.0, _shape_slider(master_volume))
	AudioServer.set_bus_volume_db(bus_index, db)


func _apply_music_volume() -> void:
	var bus_index := AudioServer.get_bus_index(BUS_MUSIC)
	if bus_index == -1:
		return
	var db := MUTE_DB
	if music_volume > 0.0:
		db = lerp(MUSIC_MIN_DB, 0.0, _shape_slider(music_volume))
	AudioServer.set_bus_volume_db(bus_index, db)


func _apply_sfx_volume() -> void:
	var bus_index := AudioServer.get_bus_index(BUS_SFX)
	if bus_index == -1:
		return
	var db := MUTE_DB
	if sfx_volume > 0.0:
		db = lerp(SFX_MIN_DB, 0.0, _shape_slider(sfx_volume))
	AudioServer.set_bus_volume_db(bus_index, db)


## ============================================
## SAVE/LOAD PREFERENCES
## ============================================
func save_audio_settings() -> void:
	var settings := {
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"master_volume": master_volume,
		"is_muted": is_muted,
	}
	var all_preferences := _load_preferences()
	all_preferences["audio"] = settings
	var file := FileAccess.open(PREFERENCES_PATH, FileAccess.WRITE)
	if file:
		file.store_var(all_preferences)
		file.close()
	else:
		push_error("[AudioService] Failed to save preferences!")


func load_audio_settings() -> void:
	var all_preferences := _load_preferences()
	if all_preferences.has("audio"):
		var audio_settings: Dictionary = all_preferences["audio"]
		music_volume = audio_settings.get("music_volume", 0.8)
		sfx_volume = audio_settings.get("sfx_volume", 1.0)
		master_volume = audio_settings.get("master_volume", 1.0)
		is_muted = audio_settings.get("is_muted", false)


func _load_preferences() -> Dictionary:
	if FileAccess.file_exists(PREFERENCES_PATH):
		var file := FileAccess.open(PREFERENCES_PATH, FileAccess.READ)
		if file:
			var data: Variant = file.get_var()
			file.close()
			if typeof(data) == TYPE_DICTIONARY:
				return data
	return {}
