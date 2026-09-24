extends Area2D

# This lets you customize what item this is right from the Inspector
@export var item_data: ItemData 

func _ready() -> void:
	# Listen for when a physics body steps into this Area2D
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Check if the body that stepped on us belongs to the "Player" group
	if body.is_in_group("Player"):
		Inventory.add_item(item_data)
		queue_free() # Delete this item from the ground
