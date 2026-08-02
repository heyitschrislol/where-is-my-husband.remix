extends Polygon2D

@export var room_name: String = ""  # must match a "<ROOM>_REVEALED" flag in Gamedata

func _ready() -> void:
	z_as_relative = false
	z_index = 50  # make sure it draws above tiles/furniture regardless of tree order

	if Gamedata.get(room_name + "_REVEALED"):
		visible = false
		return

	Gamedata.room_revealed.connect(_on_room_revealed)

func _on_room_revealed(revealed_room: String) -> void:
	if revealed_room != room_name:
		return
	visible = false
	# later: swap this for a fade-out tween once the scene-fade system is in place
