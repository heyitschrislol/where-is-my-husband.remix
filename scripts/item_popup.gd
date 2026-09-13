extends CanvasLayer

## Emitted once the popup has fully closed.
signal popup_closed

@export var popup_type = ""

@onready var dimmer: ColorRect = $dimmer
@onready var center: CenterContainer = $center
@onready var panel: PanelContainer = $center/panel
@onready var item_icon: TextureRect = $center/panel/margin/vbox/item_icon
@onready var item_label: Label = $center/panel/margin/vbox/item_label
@onready var image_center: CenterContainer = $image_center
@onready var item_closeup: TextureRect = $image_center/item_closeup

const IMAGE_TARGET_SIZE := 768.0
const IMAGE_SCREEN_MARGIN := 48.0

@onready var sfx: AudioStreamPlayer = $sfx

var _is_open := false
var _can_dismiss := false


func _ready() -> void:
	hide()
	# Keep running even if we ever add a pause to the rest of the game.
	process_mode = Node.PROCESS_MODE_ALWAYS



## Shows the popup and does not return until the player dismisses it.
## Call it with: await ItemPopup.show_item("the Spanish Book", my_texture)
func show_item(display_name: String, texture: Texture2D, _timeline_after: String) -> void:
	if _is_open:
		return
	_is_open = true
	_can_dismiss = false

	item_icon.texture = texture
	if popup_type == "popup":
		item_label.text = "You obtained %s" % display_name
	elif popup_type == "closeup":
		item_label.text = ""

	# Freezes the player and blocks InteractionManager, using the flag
	# the rest of the project already checks.
	Gamedata._is_popup_active = true

	image_center.hide()
	center.show()

	show()
	if sfx.stream:
		sfx.play()

	# Let CenterContainer lay out `panel` so panel.size is real,
	# otherwise pivot_offset is (0,0) and it scales from the corner.
	await get_tree().process_frame
	panel.pivot_offset = panel.size / 2.0

	dimmer.modulate.a = 0.0
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.8, 0.8)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(dimmer, "modulate:a", 1.0, 0.20)
	tween.tween_property(panel, "modulate:a", 1.0, 0.20)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.35) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tween.finished

	# Only now is it safe to listen for input — see gotcha #1.
	_can_dismiss = true

	await popup_closed
	if _timeline_after != "":
		Gamedata._is_dialog_active = true
		Dialogic.start(_timeline_after)


## Shows a full-screen closeup image until the player dismisses it.
## Awaitable: await ItemPopup.show_image(my_texture)
func show_image(texture: Texture2D) -> void:
	if _is_open:
		return
	_is_open = true
	_can_dismiss = false

	item_closeup.texture = texture

	# Aim for 768x768, but never let it overflow the viewport.
	var vp := get_viewport().get_visible_rect().size
	var side: float = min(IMAGE_TARGET_SIZE, min(vp.x, vp.y) - IMAGE_SCREEN_MARGIN)
	item_closeup.custom_minimum_size = Vector2(side, side)

	center.hide()
	image_center.show()

	Gamedata._is_popup_active = true
	show()

	await get_tree().process_frame
	item_closeup.pivot_offset = item_closeup.size / 2.0

	dimmer.modulate.a = 0.0
	item_closeup.modulate.a = 0.0
	item_closeup.scale = Vector2(0.9, 0.9)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(dimmer, "modulate:a", 1.0, 0.20)
	tween.tween_property(item_closeup, "modulate:a", 1.0, 0.20)
	tween.tween_property(item_closeup, "scale", Vector2.ONE, 0.30) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween.finished

	_can_dismiss = true
	await popup_closed


func _unhandled_input(event: InputEvent) -> void:
	if not _is_open or not _can_dismiss:
		return
	if event.is_action_pressed("dismiss"):
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	_can_dismiss = false

	var content: Control = panel if center.visible else item_closeup

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(dimmer, "modulate:a", 0.0, 0.15)
	tween.tween_property(panel, "modulate:a", 0.0, 0.15)
	await tween.finished

	hide()
	_is_open = false
	Gamedata._is_popup_active = false
	popup_closed.emit()
