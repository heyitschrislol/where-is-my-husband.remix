extends CanvasLayer

## Emitted once the popup has fully closed.
signal popup_closed

@onready var dimmer: ColorRect = $dimmer
@onready var panel: PanelContainer = $center/panel
@onready var item_icon: TextureRect = $center/panel/margin/vbox/item_icon
@onready var item_label: Label = $center/panel/margin/vbox/item_label
@onready var sfx: AudioStreamPlayer = $sfx

var _is_open := false
var _can_dismiss := false


func _ready() -> void:
	hide()
	# Keep running even if we ever add a pause to the rest of the game.
	process_mode = Node.PROCESS_MODE_ALWAYS


## Shows the popup and does not return until the player dismisses it.
## Call it with: await ItemPopup.show_item("the Spanish Book", my_texture)
func show_item(display_name: String, texture: Texture2D) -> void:
	if _is_open:
		return
	_is_open = true
	_can_dismiss = false

	item_icon.texture = texture
	item_label.text = "You obtained %s" % display_name

	# Freezes the player and blocks InteractionManager, using the flag
	# the rest of the project already checks.
	Gamedata._is_dialog_active = true

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


func _unhandled_input(event: InputEvent) -> void:
	if not _is_open or not _can_dismiss:
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	_can_dismiss = false

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(dimmer, "modulate:a", 0.0, 0.15)
	tween.tween_property(panel, "modulate:a", 0.0, 0.15)
	await tween.finished

	hide()
	_is_open = false
	Gamedata._is_dialog_active = false
	popup_closed.emit()
