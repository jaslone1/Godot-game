extends Area2D

@export var accepted_types: PackedStringArray = []
@export var max_items: int = 12

var stored_items: Array[ItemData] = []

signal storage_updated

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func get_stored_items() -> Array[ItemData]:
	return stored_items

func is_storage_full() -> bool:
	return stored_items.size() >= max_items

func can_accept_item(item: ItemData) -> bool:
	if item == null or not item.is_placeable or is_storage_full():
		return false
	if accepted_types.is_empty() or item.placeable_on.is_empty():
		return true
	for accepted_type in accepted_types:
		if item.placeable_on.has(accepted_type):
			return true
	return false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		UIManager.show_storage_menu(self, body)

func store_item(item: ItemData) -> bool:
	if not can_accept_item(item):
		return false
	if not Inventory.remove_item(item):
		return false
	stored_items.append(item)
	storage_updated.emit()
	print("Stored ", item.name)
	return true

func take_item(item: ItemData) -> bool:
	if not stored_items.has(item):
		return false
	stored_items.erase(item)
	Inventory.add_item(item)
	storage_updated.emit()
	print("Taken ", item.name)
	return true
