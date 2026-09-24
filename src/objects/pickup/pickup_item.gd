extends Area2D

@export var item_data: ItemData

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	if item_data != null:
		sprite.texture = item_data.texture
		sprite.scale = item_data.item_scale
		sprite.position = item_data.placement_offset

	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		Inventory.add_item(item_data)
		queue_free()
