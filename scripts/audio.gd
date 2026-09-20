extends Node
## Global sound effects. Autoloaded as "Audio".
## Owns a pool of AudioStreamPlayers so sounds can overlap and so no sound
## is ever killed by a scene being freed.

const POOL_SIZE := 12

## Remembers which variant each sound played last, so we never repeat back-to-back.
var _last_variant := {}

const SFX := {
	"door_open":    preload("res://assets/sfx/dragon-studio-opening-door-sfx-454240.mp3"),
	"door_close":   preload("res://assets/sfx/dragon-studio-close-door-382723.mp3"),
	"item_get":     preload("res://assets/sfx/retrogamelevel_complete_004.mp3"),
	"quiz_correct": preload("res://assets/sfx/duolingo-correct.mp3"),
	"quiz_wrong":   preload("res://assets/sfx/duolingo-wrong.mp3"),
	"quiz_passed":  preload("res://assets/sfx/duolingo-end-of-lesson.mp3"),
	"paper_crumple":  preload("res://assets/sfx/oxidvideos-crumpling-paper-478841.mp3"),
	"book_close":  preload("res://assets/sfx/bookClose.mp3"),
	"footstep":     [
		preload("res://assets/sfx/footstep00.mp3"),
		preload("res://assets/sfx/footstep01.mp3"),
		preload("res://assets/sfx/footstep02.mp3")
		#preload("res://assets/sfx/footstep05.mp3")
		#preload("res://assets/sfx/footstep07.mp3"),
		#preload("res://assets/sfx/footstep09.mp3")
		]
}

var _players: Array[AudioStreamPlayer] = []

func _ready() -> void:
	# Keep playing even if the tree is ever paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_players.append(p)

## Audio.play("door_open")
func play(sound_name: String, volume_db := 0.0, pitch := 1.0) -> AudioStreamPlayer:
	if not SFX.has(sound_name):
		push_error("Audio.play: unknown sound '%s'" % sound_name)
		return null

	var p := _get_free_player()
	if p == null:
		# Every voice is busy. Dropping the new sound is better than
		# cutting off one that's already audible.
		push_warning("Audio.play: pool exhausted, dropped '%s'" % sound_name)
		return null

	#p.stream = SFX[sound_name]
	p.stream = _pick_stream(sound_name)
	p.volume_db = volume_db
	p.pitch_scale = pitch
	p.play()
	return p

## Same, with a small random pitch shift so repeats don't sound robotic.
func play_varied(sound_name: String, volume_db := 0.0, spread := 0.08) -> AudioStreamPlayer:
	return play(sound_name, volume_db, randf_range(1.0 - spread, 1.0 + spread))

func _get_free_player() -> AudioStreamPlayer:
	for p in _players:
		if not p.playing:
			return p
	return null

func _pick_stream(sound_name: String) -> AudioStream:
	var entry = SFX[sound_name]

	# Single sound — nothing to choose.
	if entry is AudioStream:
		return entry

	var variants: Array = entry
	if variants.size() == 1:
		return variants[0]

	var idx := randi() % variants.size()
	# If we drew the same one as last time, step to the next instead.
	if _last_variant.get(sound_name, -1) == idx:
		idx = (idx + 1) % variants.size()
	_last_variant[sound_name] = idx

	return variants[idx]
