extends Node

signal inventory_updated

var items: Array[ItemData] = []

func add_item(item: ItemData) -> void:
	items.append(item)
	inventory_updated.emit()
	print("Inventory now contains: ", items.size(), " items.")

# New Function: Call this when you want to remove an item and throw it on the ground
func drop_item(item: ItemData, drop_position: Vector2) -> void:
	if items.has(item):
		items.erase(item)
		inventory_updated.emit()
		
		# 1. Load the blueprint of our pickup scene
		var pickup_scene = load("res://src/objects/pickup/pickup_item.tscn")
		# 2. Spawn a physical instance of it
		var new_pickup = pickup_scene.instantiate()
		
		# 3. Give it its data and place it at the drop position
		new_pickup.item_data = item
		new_pickup.global_position = drop_position
		
		# 4. Add it to the active world map
		get_tree().current_scene.add_child(new_pickup)
		print("Dropped: ", item.name)
