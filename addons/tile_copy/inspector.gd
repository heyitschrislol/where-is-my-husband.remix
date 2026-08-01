extends EditorInspectorPlugin

const Tool = preload("uid://bqr3fxrvrmc32")
const ActionButtonScene = preload("uid://cxasq8wcxx21c")
const SettingsPopupScene = preload("uid://dyyawj2ata8gu")

var action_button: VBoxContainer
var settings_popup: AcceptDialog
var base_control: Control
var tileset_editor: Node
var atlas_source_editor: Node
var atlas_source_proxy: Object
var atlas_source: TileSetAtlasSource
var copied_tiles: Dictionary[Vector2i, TileData]
var copied_tiles_version: int = 0
var copied_property_filters: Dictionary

func get_current_atlas_source() -> TileSetAtlasSource:
	tileset_editor = base_control.find_children("*", "TileSetEditor", true, false).front()
	atlas_source_editor = tileset_editor.find_children("*", "TileSetAtlasSourceEditor", true, false).front()
	atlas_source_proxy = Tool.get_connected_objects_by_class(atlas_source_editor, "TileSetAtlasSourceProxyObject").back()
	return Tool.get_source(atlas_source_proxy)

func _can_handle(object: Object) -> bool:
	return object.is_class("AtlasTileProxyObject")

func _parse_begin(object: Object) -> void:
	base_control = EditorInterface.get_base_control()
	action_button = ActionButtonScene.instantiate(); add_custom_control(action_button)
	var copy_button: Button = action_button.find_child("CopyButton", true, false)
	var paste_button: Button = action_button.find_child("PasteButton", true, false)
	var setting_button: Button = action_button.find_child("SettingButton", true, false)
	var change_terrain_button: Button = action_button.find_child("ChangeTerrainButton", true, false)
	var source_terrain_input: SpinBox = action_button.find_child("SourceTerrainInput", true, false)
	var target_terrain_input: SpinBox = action_button.find_child("TargetTerrainInput", true, false)
	copy_button.pressed.connect(_on_copy.bind(object))
	paste_button.pressed.connect(_on_paste.bind(object))
	setting_button.pressed.connect(_on_setting)
	if settings_popup == null:
		settings_popup = SettingsPopupScene.instantiate()
		settings_popup.confirmed.connect(_on_setting_confirmed)
	change_terrain_button.pressed.connect(_on_change_terrain.bind(object, source_terrain_input, target_terrain_input))

func _on_copy(atlas_tile_proxy: Object) -> void:
	var selected_tiles: Array[TileData] = Tool.get_selected_tiles(atlas_tile_proxy)
	if copied_tiles.is_empty() == false and selected_tiles == copied_tiles.values(): return
	atlas_source = get_current_atlas_source()
	copied_tiles = Tool.get_copied_tiles(selected_tiles, atlas_source)
	copied_tiles_version += 1
	copied_property_filters.clear()
	settings_popup.call("update_copied_tiles", copied_tiles, copied_tiles_version)

func _on_paste(atlas_tile_proxy: Object) -> void:
	if copied_tiles.is_empty(): return
	atlas_source = get_current_atlas_source()
	var selected_tiles: Array[TileData] = Tool.get_selected_tiles(atlas_tile_proxy)
	var paste_tiles: Dictionary[Vector2i, TileData] = Tool.get_copied_tiles(selected_tiles, atlas_source)
	Tool.paste_tile_data_properties(copied_tiles, paste_tiles, copied_property_filters)

func _on_change_terrain(atlas_tile_proxy: Object, source_terrain_input: SpinBox, target_terrain_input: SpinBox) -> void:
	var selected_tiles: Array[TileData] = Tool.get_selected_tiles(atlas_tile_proxy)
	var source_terrain: int = source_terrain_input.value
	var target_terrain: int = target_terrain_input.value
	Tool.change_terrain(selected_tiles, source_terrain, target_terrain)

func _on_setting():
	if copied_tiles.is_empty(): return
	settings_popup.call("update_copied_tiles", copied_tiles, copied_tiles_version)
	if settings_popup.get_parent() == null: EditorInterface.popup_dialog_centered(settings_popup, Vector2i(1500, 800))
	else: settings_popup.popup_centered(Vector2i(1500, 800))

func _on_setting_confirmed() -> void:
	var selected_properties: Dictionary = settings_popup.call("get_selected_properties")
	copied_property_filters = selected_properties
