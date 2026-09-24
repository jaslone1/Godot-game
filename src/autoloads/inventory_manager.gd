extends Node

signal inventory_updated

var items: Array[ItemData] = []

func add_item(item: ItemData) -> void:
	if item == null:
		return
	items.append(item)
	inventory_updated.emit()
	print("Inventory now contains: ", items.size(), " items.")

func remove_item(item: ItemData) -> bool:
	if item == null or not items.has(item):
		return false
	items.erase(item)
	inventory_updated.emit()
	return true

func get_placeable_items_for(target_type: String) -> Array[ItemData]:
	var options: Array[ItemData] = []
	for item in items:
		if item == null or not item.is_placeable:
			continue
		if item.placeable_on.is_empty() or item.placeable_on.has(target_type):
			options.append(item)
	return options

func drop_item(item: ItemData, drop_position: Vector2) -> void:
	if not remove_item(item):
		return

	var pickup_scene = load("res://src/objects/pickup/pickup_item.tscn")
	var new_pickup = pickup_scene.instantiate()
	new_pickup.item_data = item
	new_pickup.global_position = drop_position
	get_tree().current_scene.add_child(new_pickup)
	print("Dropped: ", item.name)
