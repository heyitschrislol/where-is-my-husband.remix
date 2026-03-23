extends Node2D


@onready var label = $label

const base_text = "[SPACEBAR] to "

var active_areas = []
var can_interact = true

func _get_player():
	return get_tree().get_first_node_in_group("player")

func register_area(area: InteractionArea):
	active_areas.push_back(area)

func unregister_area(area: InteractionArea):
	var index = active_areas.find(area)
	if index != -1:
		active_areas.remove_at(index)

func _purge_stale_areas():
	active_areas = active_areas.filter(func(area): return is_instance_valid(area))

func _process(_delta):
	_purge_stale_areas()  # ← removes any freed nodes before we touch them

	var player = _get_player()
	if not is_instance_valid(player):
		return  # player not ready yet, skip this frame

	if active_areas.size() > 0 && can_interact:
		active_areas.sort_custom(_sort_by_distance_to_player)
		label.text = base_text + active_areas[0].action_name
		label.global_position = active_areas[0].global_position
		label.global_position.y -= 36
		label.global_position.x -= label.size.x / 3
		label.show()
	else:
		label.hide()

func _sort_by_distance_to_player(area1, area2):
	var player = _get_player()
	var area1_to_player = player.global_position.distance_to(area1.global_position)
	var area2_to_player = player.global_position.distance_to(area2.global_position)
	return area1_to_player < area2_to_player

func _input(event):
	var player = _get_player()
	if not is_instance_valid(player):
		return

	if event.is_action_pressed("interact") && can_interact && not Gamedata._is_dialog_active:
		if active_areas.size() > 0:
			#Gamedata.player_previous_location = player.global_position
			can_interact = false
			label.hide()
			await active_areas[0].interact.call()
			can_interact = true


#func _on_tree_changed():
	## Prune any areas that have been freed
	#active_areas = active_areas.filter(func(area): return is_instance_valid(area))
	## Refresh player reference in case it reloaded
	#player = get_tree().get_first_node_in_group("player")
#
#func clear_areas():
	#active_areas.clear()
