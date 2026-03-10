extends Node2D
class_name ContentItem

@export var item: DataItem
@export var quantity := 0 ##If greater than 0, the item will be added to the inventory, otherwise it will consumed immediately.
