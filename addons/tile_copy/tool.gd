extends RefCounted

const TERRAIN_PEERING_BITS: Array[TileSet.CellNeighbor] = [
	TileSet.CELL_NEIGHBOR_RIGHT_SIDE, TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE,
	TileSet.CELL_NEIGHBOR_BOTTOM_SIDE, TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE,
	TileSet.CELL_NEIGHBOR_LEFT_SIDE, TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE,
	TileSet.CELL_NEIGHBOR_TOP_SIDE, TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE,
	TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER, TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
	TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER, TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER,
]

static func get_connected_objects_by_class(object: Object, p_class_name: String) -> Array:
	var objects: Array
	if object == null: return objects
	for connection in object.get_incoming_connections():
		var connected_object = connection["signal"].get_object()
		if connected_object.is_class(p_class_name): objects.append(connected_object)
	return objects

static func get_source(atlas_source_proxy: Object) -> TileSetSource:
	if atlas_source_proxy == null: return null
	for connection in atlas_source_proxy.get_incoming_connections():
		var connected: Object = connection["signal"].get_object()
		if connected is TileSetSource: return connected
	return null

static func get_selected_tiles(atlas_tile_proxy) -> Array[TileData]:
	var selected_tiles: Array[TileData]
	if atlas_tile_proxy == null: return selected_tiles
	for connection in atlas_tile_proxy.get_incoming_connections():
		var connected: Object = connection["signal"].get_object()
		if connected is TileData: selected_tiles.append(connected)
	return selected_tiles

static func get_copied_tiles(selected_tiles: Array[TileData], atlas_source: TileSetAtlasSource) -> Dictionary[Vector2i, TileData]:
	var copied_tiles: Dictionary[Vector2i, TileData]
	if atlas_source == null: return copied_tiles
	if selected_tiles.size() == 1: copied_tiles.set(Vector2i.ZERO, selected_tiles.front())
	else:
		var first_copy_tile_position: Vector2i = Vector2i(-1, -1)
		for index: int in atlas_source.get_tiles_count():
			var position: Vector2i = atlas_source.get_tile_id(index)
			var tile_data: TileData = atlas_source.get_tile_data(position, 0)
			if selected_tiles.has(tile_data):
				if first_copy_tile_position == Vector2i(-1, -1): first_copy_tile_position = position
				position -= first_copy_tile_position
				copied_tiles.set(position, tile_data)
	return copied_tiles

static func get_tile_data_properties(tile_data: TileData) -> Dictionary:
	return nest_dictionary(get_flat_tile_data_properties(tile_data))

static func get_flat_tile_data_properties(tile_data: TileData) -> Dictionary[StringName, Variant]:
	var properties: Dictionary[StringName, Variant] = {}
	if tile_data == null: return properties
	for property_data: Dictionary in tile_data.get_property_list():
		var usage: int = property_data["usage"]
		var property_name: StringName = property_data["name"]
		if (
				usage & (PROPERTY_USAGE_STORAGE | PROPERTY_USAGE_EDITOR)) == 0 or property_name == "script": continue
		properties[property_name] = duplicate_property(tile_data.get(property_name))
	return properties

static func nest_dictionary(dict: Dictionary) -> Dictionary:
	var result: Dictionary
	for key: String in dict.keys():
		var parts: PackedStringArray = key.split("/")
		var current: Dictionary = result
		for i in range(parts.size() - 1):
			if !current.has(parts[i]): current[parts[i]] = {}
			current = current[parts[i]]
		current[parts[-1]] = dict[key]
	return result

static func paste_tile_data_properties(from_tiles: Dictionary[Vector2i, TileData], to_tiles: Dictionary[Vector2i, TileData], property_filters: Dictionary = {}) -> void:
	var history = EditorInterface.get_editor_undo_redo()
	history.create_action("Paste tile properties")
	for coords: Vector2i in from_tiles.keys():
		if not to_tiles.has(coords): continue
		var from_tile: TileData = from_tiles.get(coords)
		var to_tile: TileData = to_tiles.get(coords)
		var from_tile_properties: Dictionary[StringName, Variant] = get_flat_tile_data_properties(from_tile)
		var to_tile_properties: Dictionary[StringName, Variant] = get_flat_tile_data_properties(to_tile)
		var property_names: Array[StringName] = []
		var has_properties: bool = false
		if property_filters.has(coords): property_names = property_filters[coords]
		else:
			for name: StringName in from_tile_properties: property_names.append(name)
		for name: StringName in property_names:
			if not from_tile_properties.has(name): continue
			history.add_do_property(to_tile, name, from_tile_properties[name]); has_properties = true
		if not has_properties: continue
		var to_property_names: Array = to_tile_properties.keys()
		for index: int in range(to_property_names.size() - 1, -1, -1):
			var name: StringName = to_property_names[index]
			history.add_undo_property(to_tile, name, to_tile_properties[name])
	history.commit_action()

static func change_terrain(selected_tiles: Array[TileData], source_terrain: int, target_terrain: int) -> void:
	if selected_tiles.is_empty() or source_terrain < 0 or target_terrain < 0 or source_terrain == target_terrain: return
	var history = EditorInterface.get_editor_undo_redo()
	history.create_action("Change terrain")
	for tile_data: TileData in selected_tiles:
		if tile_data.terrain == source_terrain:
			history.add_do_property(tile_data, "terrain", target_terrain); history.add_undo_property(tile_data, "terrain", source_terrain)
		for peering_bit: TileSet.CellNeighbor in TERRAIN_PEERING_BITS:
			if not tile_data.is_valid_terrain_peering_bit(peering_bit): continue
			var terrain: int = tile_data.get_terrain_peering_bit(peering_bit)
			if terrain != source_terrain: continue
			history.add_do_method(tile_data, "set_terrain_peering_bit", peering_bit, target_terrain)
			history.add_undo_method(tile_data, "set_terrain_peering_bit", peering_bit, terrain)
	history.commit_action()

static func duplicate_property(value: Variant) -> Variant:
	match typeof(value):
		TYPE_DICTIONARY: return value.duplicate(true)
		var type when type in [TYPE_PACKED_VECTOR2_ARRAY, TYPE_PACKED_VECTOR4_ARRAY]: return value.duplicate()
		_: return value
