extends Area2D

# This will display whatever item is currently placed on top
@onready var held_item_sprite: Sprite2D = $HeldItemSprite

var item_on_top: ItemData = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# Check if we are already holding something
		if item_on_top != null:
			print("This table is full! It has a ", item_on_top.name)
			return
			
		# Filter player's inventory to see if they have anything placeable
		var placeable_options: Array[ItemData] = []
		for item in Inventory.items:
			if item.is_placeable:
				placeable_options.append(item)
				
		if placeable_options.size() == 0:
			print("You ran into the table, but you have no items to place on it!")
			return
			
		# Request the Global UI system to pop up a selection menu
		# We pass 'self' so the UI knows which specific table to send the item back to
		UIManager.show_placement_menu(placeable_options, self)

# This function gets called by our UI once the player clicks an item
func receive_placed_item(item: ItemData) -> void:
	item_on_top = item
	Inventory.items.erase(item) # Remove it from player's pockets
	Inventory.inventory_updated.emit()
	
	# Update the table's visuals to show the item
	if item.texture != null:
		held_item_sprite.texture = item.texture
		held_item_sprite.scale = Vector2(1.0, 1.0)
	else:
		# Fallback color block if you haven't given your resource an art asset yet
		held_item_sprite.texture = load("res://icon.svg")
		held_item_sprite.scale = Vector2(0.4, 0.4) # Make it smaller so it fits on top
		held_item_sprite.self_modulate = Color.DARK_GOLDENROD
		
	print("Successfully placed ", item.name, " on the table!")
