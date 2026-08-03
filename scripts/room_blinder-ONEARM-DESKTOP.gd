extends Polygon2D
class_name RoomBlinder

@export var room_name: String = ""  # must match a "<ROOM>_REVEALED" flag in Gamedata

#const BLINDER_COLOR := Color(0.06, 0.06, 0.08, 0.96)  # near-black, slightly blue-tinted, near-opaque
const BLINDER_COLOR := Color(0.318, 0.318, 0.318, 0.96)

func _ready() -> void:
	color = BLINDER_COLOR
	z_as_relative = false
	z_index = 99  # make sure it draws above tiles/furniture regardless of tree order

	if Gamedata.get(room_name + "_REVEALED"):
		visible = false
		return

	Gamedata.room_revealed.connect(_on_room_revealed)

func _on_room_revealed(revealed_room: String) -> void:
	if revealed_room != room_name:
		return
	visible = false
	# later: swap this for a fade-out tween once the scene-fade system is in place
