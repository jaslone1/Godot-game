extends Area2D

@onready var held_item_sprite: Sprite2D = $HeldItemSprite

var accepted_types: Array[String] = ["surface"]
var item_on_top: ItemData = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func can_accept_item(item: ItemData) -> bool:
	if item == null or not item.is_placeable:
		return false
	if item.placeable_on.is_empty():
		return true
	for accepted_type in accepted_types:
		if item.placeable_on.has(accepted_type):
			return true
	return false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if item_on_top != null:
			print("This surface is full! It has a ", item_on_top.name)
			return

		var placeable_options = Inventory.get_placeable_items_for(accepted_types[0])
		if placeable_options.is_empty():
			print("You ran into the surface, but you have no items to place here!")
			return

		UIManager.show_placement_menu(placeable_options, self)

func receive_placed_item(item: ItemData) -> void:
	if not can_accept_item(item):
		return

	item_on_top = item
	Inventory.remove_item(item)
	Inventory.inventory_updated.emit()

	if item.texture != null:
		held_item_sprite.texture = item.texture
		held_item_sprite.scale = item.item_scale
		held_item_sprite.position = item.placement_offset
	else:
		held_item_sprite.texture = load("res://icons/icon.svg")
		held_item_sprite.scale = Vector2(0.5, 0.5)
		held_item_sprite.self_modulate = Color.DARK_GOLDENROD

	print("Successfully placed ", item.name, " on the surface!")
