@tool
extends AcceptDialog

const Tool = preload("uid://bqr3fxrvrmc32")

var copied_tiles: Dictionary[Vector2i, TileData]
var copied_tiles_version: int = -1
var property_tree_item: TreeItem
var tile_data_tree_item: TreeItem
var property_items: Dictionary[Vector2i, Array] = {}
var is_syncing: bool = false
var max_row: int = 0
var max_col: int = 0

@onready var tile_data_tree: Tree = $ContentSplit/VBoxContainer/TileDataTree
@onready var property_tree: Tree = $ContentSplit/VBoxContainer2/PropertyTree

func _ready() -> void:
	refresh_tree()

func update_copied_tiles(new_copied_tiles: Dictionary[Vector2i, TileData], new_copied_tiles_version: int) -> void:
	if copied_tiles_version == new_copied_tiles_version: return
	copied_tiles = new_copied_tiles; copied_tiles_version = new_copied_tiles_version
	if is_node_ready(): refresh_tree()

func refresh_tree() -> void:
	max_row = 0; max_col = 0; property_items.clear()
	tile_data_tree.clear(); property_tree.clear()
	for coords: Vector2i in copied_tiles:
		max_row = max(max_row, coords.y); max_col = max(max_col, coords.x)
	init_tile_data_tree()
	property_tree_item = property_tree.create_item()
	for coords: Vector2i in copied_tiles:
		var tile_data: TileData = copied_tiles[coords]
		var properties: Dictionary = Tool.get_tile_data_properties(tile_data)
		init_property_tree(property_tree_item, properties, coords, 0)
	for tree_item: TreeItem in property_tree_item.get_children(): tree_item.set_collapsed_recursive(true)

func init_property_tree(parent: TreeItem, properties: Dictionary, coords: Vector2i, level: int, property_path: StringName = "") -> void:
	for property_name: String in properties:
		var value: Variant = properties[property_name]
		var full_property_name: StringName = property_name if property_path.is_empty() else "%s/%s" % [property_path, property_name]
		var current_item: TreeItem = get_child_tree_item_by_text(parent, property_name)
		if current_item == null: current_item = create_check_item(property_tree, parent, property_name)
		if level == 0:
			var row_text: String = "Row: %d" % coords.y
			var row_item: TreeItem = get_child_tree_item_by_text(current_item, row_text)
			if row_item == null: row_item = create_check_item(property_tree, current_item, row_text)
			var coords_item: TreeItem = create_check_item(property_tree, row_item, "(%d, %d)" % [coords.x, coords.y])
			coords_item.set_metadata(0, coords); register_property_item(coords_item, coords)
			if value is Dictionary: init_property_tree(coords_item, value, coords, level + 1, full_property_name)
			else:
				coords_item.set_text(1, var_to_str(value)); coords_item.set_metadata(1, full_property_name)
		elif value is Dictionary: init_property_tree(current_item, value, coords, level + 1, full_property_name)
		else:
			current_item.set_text(1, var_to_str(value)); current_item.set_metadata(1, full_property_name)

func init_tile_data_tree() -> void:
	tile_data_tree.columns = max_col + 2
	tile_data_tree_item = tile_data_tree.create_item()
	for row: int in range(max_row + 2): create_check_item(tile_data_tree, tile_data_tree_item, "Row: %d" % row)
	var header_item: TreeItem = tile_data_tree_item.get_first_child()
	header_item.set_text(0, "Coords"); header_item.set_editable(0, false)
	for column: int in range(1, tile_data_tree.columns):
		header_item.set_cell_mode(column, TreeItem.CELL_MODE_CHECK)
		header_item.set_editable(column, true); header_item.set_text(column, "Col: %d" % column); header_item.set_checked(column, true)
	for y: int in range(max_row + 1):
		var row_item: TreeItem = tile_data_tree_item.get_child(y + 1)
		for x: int in range(max_col + 1):
			var column: int = x + 1
			row_item.set_cell_mode(column, TreeItem.CELL_MODE_CHECK)
			row_item.set_editable(column, true); row_item.set_text(column, "(%d, %d)" % [x, y]); row_item.set_checked(column, true)
			row_item.set_metadata(column, Vector2i(x, y))

func register_property_item(item: TreeItem, coords: Vector2i) -> void:
	if not property_items.has(coords): property_items[coords] = []
	var items: Array = property_items[coords]
	items.append(item)

func create_check_item(tree: Tree, parent: TreeItem, text: String, column: int = 0) -> TreeItem:
	var item: TreeItem = tree.create_item(parent)
	item.set_cell_mode(column, TreeItem.CELL_MODE_CHECK)
	item.set_editable(column, true); item.set_text(column, text); item.set_checked(column, true)
	return item

func get_child_tree_item_by_text(parent: TreeItem, text: String, column: int = 0) -> TreeItem:
	for tree_item: TreeItem in parent.get_children(): if tree_item.get_text(column) == text: return tree_item
	return null

func update_children(parent: TreeItem, checked: bool, column: int = 0) -> void:
	for child: TreeItem in parent.get_children():
		if child.get_child_count() > 0: update_children(child, checked, column)
		child.set_checked(column, checked); child.set_indeterminate(column, false)

func update_parent(child: TreeItem, column: int = 0) -> void:
	var parent: TreeItem = child.get_parent()
	while parent != null and parent != property_tree_item:
		var has_checked: bool = false; var has_unchecked: bool = false; var has_indeterminate: bool = false
		for tree_item: TreeItem in parent.get_children():
			if tree_item.is_indeterminate(column): has_indeterminate = true
			elif tree_item.is_checked(column): has_checked = true
			else: has_unchecked = true
		parent.set_indeterminate(column, has_indeterminate or (has_checked and has_unchecked))
		parent.set_checked(column, has_checked and not has_unchecked and not has_indeterminate)
		parent = parent.get_parent()

func update_row_children(row_item: TreeItem, checked: bool) -> void:
	for column: int in range(1, tile_data_tree.columns):
		row_item.set_checked(column, checked); row_item.set_indeterminate(column, false)

func update_column_children(header_item: TreeItem, column: int, checked: bool) -> void:
	var row_item: TreeItem = header_item.get_next()
	while row_item != null:
		row_item.set_checked(column, checked); row_item.set_indeterminate(column, false); row_item = row_item.get_next()

func update_row_parent(row_item: TreeItem) -> void:
	var has_checked: bool = false; var has_unchecked: bool = false; var has_indeterminate: bool = false
	for column: int in range(1, tile_data_tree.columns):
		if row_item.is_indeterminate(column): has_indeterminate = true
		elif row_item.is_checked(column): has_checked = true
		else: has_unchecked = true
	row_item.set_indeterminate(0, has_indeterminate or (has_checked and has_unchecked))
	row_item.set_checked(0, has_checked and not has_unchecked and not has_indeterminate)

func update_column_parent(header_item: TreeItem, column: int) -> void:
	var has_checked: bool = false; var has_unchecked: bool = false; var has_indeterminate: bool = false
	var row_item: TreeItem = header_item.get_next()
	while row_item != null:
		if row_item.is_indeterminate(column): has_indeterminate = true
		elif row_item.is_checked(column): has_checked = true
		else: has_unchecked = true
		row_item = row_item.get_next()
	header_item.set_indeterminate(column, has_indeterminate or (has_checked and has_unchecked))
	header_item.set_checked(column, has_checked and not has_unchecked and not has_indeterminate)

func get_property_coords(item: TreeItem, coords_list: Array[Vector2i]) -> void:
	var metadata: Variant = item.get_metadata(0)
	if metadata is Vector2i:
		var coords: Vector2i = metadata
		if not coords_list.has(coords): coords_list.append(coords)
		return
	for child: TreeItem in item.get_children(): get_property_coords(child, coords_list)

func get_selected_property_names(item: TreeItem, property_names: Array[StringName]) -> void:
	if item.get_child_count() > 0:
		for child: TreeItem in item.get_children(): get_selected_property_names(child, property_names)
		return
	var property_name: Variant = item.get_metadata(1)
	if item.is_checked(0) and property_name is StringName: property_names.append(property_name)

func get_selected_properties() -> Dictionary:
	var selected_properties: Dictionary = {}
	for coords: Vector2i in property_items:
		var property_names: Array[StringName] = []
		for item: TreeItem in property_items[coords]: get_selected_property_names(item, property_names)
		selected_properties[coords] = property_names
	return selected_properties

func get_item_coords(item: TreeItem, column: int, coords_list: Array[Vector2i]) -> void:
	var metadata: Variant = item.get_metadata(column)
	if metadata is Vector2i:
		var coords: Vector2i = metadata
		if copied_tiles.has(coords) and not coords_list.has(coords): coords_list.append(coords)

func sync_grid_cell(coords: Vector2i) -> void:
	if not property_items.has(coords): return
	var items: Array = property_items[coords]
	var has_checked: bool = false; var has_unchecked: bool = false; var has_indeterminate: bool = false
	for item: TreeItem in items:
		if item.is_indeterminate(0): has_indeterminate = true
		elif item.is_checked(0): has_checked = true
		else: has_unchecked = true
	var row_item: TreeItem = tile_data_tree_item.get_child(coords.y + 1)
	var column: int = coords.x + 1
	row_item.set_indeterminate(column, has_indeterminate or (has_checked and has_unchecked))
	row_item.set_checked(column, has_checked and not has_unchecked and not has_indeterminate)

func sync_property_items(coords: Vector2i, checked: bool) -> void:
	if not property_items.has(coords): return
	var items: Array = property_items[coords]
	for item: TreeItem in items:
		item.set_checked(0, checked); item.set_indeterminate(0, false)
		update_children(item, checked); update_parent(item)

func update_grid_parents(coords_list: Array[Vector2i]) -> void:
	var header_item: TreeItem = tile_data_tree_item.get_first_child()
	for coords: Vector2i in coords_list:
		update_row_parent(tile_data_tree_item.get_child(coords.y + 1))
		update_column_parent(header_item, coords.x + 1)

func _on_property_tree_item_edited(source: Tree) -> void:
	if is_syncing: return
	var editor_tree_item: TreeItem = source.get_edited()
	var column: int = source.get_edited_column()
	var checked: bool = editor_tree_item.is_checked(column)
	is_syncing = true
	editor_tree_item.set_indeterminate(column, false)
	update_children(editor_tree_item, checked, column); update_parent(editor_tree_item, column)
	var coords_list: Array[Vector2i] = []
	get_property_coords(editor_tree_item, coords_list)
	for coords: Vector2i in coords_list: sync_grid_cell(coords)
	update_grid_parents(coords_list)
	is_syncing = false

func _on_tile_data_tree_item_edited(source: Tree) -> void:
	if is_syncing: return
	var item: TreeItem = source.get_edited()
	var column: int = source.get_edited_column()
	var header_item: TreeItem = tile_data_tree_item.get_first_child()
	var checked: bool = item.is_checked(column)
	var coords_list: Array[Vector2i] = []
	is_syncing = true; item.set_indeterminate(column, false)
	if item == header_item and column > 0:
		update_column_children(header_item, column, checked)
		var row_item: TreeItem = header_item.get_next()
		while row_item != null:
			get_item_coords(row_item, column, coords_list); update_row_parent(row_item); row_item = row_item.get_next()
		update_column_parent(header_item, column)
	elif column == 0:
		update_row_children(item, checked)
		for current_column: int in range(1, source.columns):
			get_item_coords(item, current_column, coords_list); update_column_parent(header_item, current_column)
	else:
		get_item_coords(item, column, coords_list)
		update_row_parent(item); update_column_parent(header_item, column)
	for coords: Vector2i in coords_list: sync_property_items(coords, checked)
	is_syncing = false
