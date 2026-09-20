extends Node

const HOST := "127.0.0.1"
const PORT := 8777
const PROBE_TIMEOUT := 1.5
const POLL_INTERVAL := 1.0

## Emitted once the player has successfully logged into the fake inbox.
signal pmail_unlocked

var _http: HTTPRequest
var _poll: Timer
var _busy := false

var _reaction_pending := false


func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)

	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_request_completed)

	_poll = Timer.new()
	_poll.wait_time = POLL_INTERVAL
	_poll.timeout.connect(_on_poll_tick)
	add_child(_poll)

	# Clear any login left over from a previous run of the game. Fails
	# silently and harmlessly if the server isn't running yet.
	_fetch("/game/reset")


func _on_dialogic_signal(argument: String) -> void:
	if argument == "open_pmail":
		open_browser()


func open_browser() -> void:
	if await _server_is_up():
		OS.shell_open(_page_url())
		if not Gamedata.PMAIL_HACKED:
			_poll.start()
	else:
		push_error("Pmail: nothing listening on %s" % _page_url())
		print("Pmail: start the server first -> python assets/pmail/server.py")


func _on_poll_tick() -> void:
	_fetch("/game/state")


## One request at a time - HTTPRequest rejects overlapping calls.
func _fetch(path: String) -> void:
	if _busy:
		return
	_busy = true
	if _http.request(_base() + path) != OK:
		_busy = false


func _on_request_completed(_result: int, code: int,
		_headers: PackedStringArray, body: PackedByteArray) -> void:
	_busy = false
	if code != 200:
		return

	var data = JSON.parse_string(body.get_string_from_utf8())
	if typeof(data) != TYPE_DICTIONARY:
		return

	if data.get("logged_in", false) and not Gamedata.PMAIL_HACKED:
		_poll.stop()
		Gamedata.PMAIL_HACKED = true
		Dialogic.VAR.set_variable("PMAIL_HACKED", true)
		pmail_unlocked.emit()
		_reaction_pending = true
		print("Pmail: login detected.")


#func _notification(what: int) -> void:
	#if what != NOTIFICATION_APPLICATION_FOCUS_IN:
		#return
	#if not _reaction_pending or Gamedata.is_input_blocked():
		#return
	#_reaction_pending = false
	#Gamedata._is_dialog_active = true
	#Dialogic.start("after_pmail_hacked")

func _notification(what: int) -> void:
	if what != NOTIFICATION_APPLICATION_FOCUS_IN:
		return
	if not _reaction_pending or Gamedata.is_input_blocked():
		return
	_reaction_pending = false
	_start_reaction.call_deferred()


## Runs on a clean frame boundary. NOTIFICATION_APPLICATION_FOCUS_IN arrives
## from the OS window handler, where pending queue_free() deletions from the
## previous timeline have not been flushed yet.
func _start_reaction() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	Gamedata._is_dialog_active = true
	Dialogic.start("pmail_after_login")

func _base() -> String:
	return "http://%s:%d" % [HOST, PORT]


func _page_url() -> String:
	return _base() + "/"


## Polls the port briefly. When the server is already running this returns
## within a frame or two; the timeout only costs you anything on failure.
func _server_is_up() -> bool:
	var deadline := Time.get_ticks_msec() + int(PROBE_TIMEOUT * 1000.0)

	while Time.get_ticks_msec() < deadline:
		var probe := StreamPeerTCP.new()
		if probe.connect_to_host(HOST, PORT) == OK:
			for i in 30:
				probe.poll()
				var st := probe.get_status()
				if st == StreamPeerTCP.STATUS_CONNECTED:
					probe.disconnect_from_host()
					return true
				if st == StreamPeerTCP.STATUS_ERROR:
					break
				await get_tree().process_frame
		probe.disconnect_from_host()
		await get_tree().create_timer(0.1).timeout

	return false
