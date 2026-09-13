extends Node

const HOST := "127.0.0.1"
const PORT := 8080

## Every file server.py needs on disk. Paths are relative to both
## SRC_DIR and RUN_DIR, so the folder shape is preserved by the copy.
const FILES := [
	"server.py",
	"web/login.html",
	"web/inbox.html",
	"web/message.html",
]

const SRC_DIR := "res://assets/pmail/"
const RUN_DIR := "user://pmail/"

var _pid := -1


func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)


func _exit_tree() -> void:
	stop()


func _on_dialogic_signal(argument: String) -> void:
	if argument == "open_pmail":
		launch()


## Stages the files, starts Python, waits for the port, opens the browser.
func launch() -> void:
	# Already running (player came back and said yes again) - just reopen the tab.
	if _is_running():
		OS.shell_open(_url())
		return

	if not _stage_files():
		return

	var script_path := ProjectSettings.globalize_path(RUN_DIR + "server.py")

	# create_process does not tell us "python isn't installed" in a useful way,
	# so we try each likely name and keep the first one that spawns.
	for exe in _python_candidates():
		var pid := OS.create_process(exe, [script_path], false)
		if pid > 0:
			_pid = pid
			print("Pmail: started via '%s' (pid %d)" % [exe, pid])
			break

	if _pid <= 0:
		push_error("Pmail: no Python interpreter could be started.")
		return

	if await _wait_for_port():
		OS.shell_open(_url())
	else:
		push_error("Pmail: server never answered on port %d." % PORT)
		stop()


func stop() -> void:
	if _pid > 0 and OS.is_process_running(_pid):
		OS.kill(_pid)
	_pid = -1


func _is_running() -> bool:
	return _pid > 0 and OS.is_process_running(_pid)


func _url() -> String:
	return "http://%s:%d/" % [HOST, PORT]


func _python_candidates() -> Array:
	# pythonw.exe first on Windows: it is the GUI-subsystem build, so it does
	# NOT pop a black console window in front of the game.
	if OS.get_name() == "Windows":
		return ["pythonw.exe", "python.exe", "py.exe"]
	return ["python3", "python"]


## Copies res:// files to a real folder. Needed because res:// is inside
## the .pck once exported, and Python cannot read paths inside an archive.
func _stage_files() -> bool:
	DirAccess.make_dir_recursive_absolute(RUN_DIR + "web")

	for rel in FILES:
		var src := FileAccess.open(SRC_DIR + rel, FileAccess.READ)
		if src == null:
			push_error("Pmail: missing source file " + SRC_DIR + rel)
			return false
		var bytes := src.get_buffer(src.get_length())
		src.close()

		var dst := FileAccess.open(RUN_DIR + rel, FileAccess.WRITE)
		if dst == null:
			push_error("Pmail: cannot write " + RUN_DIR + rel)
			return false
		dst.store_buffer(bytes)
		dst.close()

	return true


## Polls the port until the server accepts a connection, or we give up.
func _wait_for_port(timeout_sec := 6.0) -> bool:
	var deadline := Time.get_ticks_msec() + int(timeout_sec * 1000.0)

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
