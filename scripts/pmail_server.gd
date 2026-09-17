extends Node

const HOST := "127.0.0.1"
const PORT := 8777
const PROBE_TIMEOUT := 1.5


func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)


func _on_dialogic_signal(argument: String) -> void:
	if argument == "open_pmail":
		open_browser()


## Checks the server is actually up before handing the player to a browser,
## so a forgotten server.py fails in the output panel rather than as a
## "connection refused" page in the middle of the story.
func open_browser() -> void:
	if await _server_is_up():
		OS.shell_open(_url())
	else:
		push_error("Pmail: nothing listening on %s" % _url())
		print("Pmail: start the server first -> python assets/pmail/server.py")


func _url() -> String:
	return "http://%s:%d/" % [HOST, PORT]


## Polls the port briefly. When the server is already running this returns
## within a frame or two; the timeout only costs you anything on failure.
func _server_is_up() -> bool:
	var deadline := Time.get_ticks_msec() + int(PROBE_TIMEOUT * 1000.0)

	while Time.get_ticks_msec() < deadline:
		var probe := StreamPeerTCP.new()
		if probe.connect_to_host(HOST, PORT) == OK:
			# connect_to_host is non-blocking, so poll until it resolves.
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
