class_name ItemData
extends Resource

@export var name: String = "Item"
@export var display_name: String = "Item"
@export var texture: Texture2D
@export var is_placeable: bool = false
@export var placeable_on: PackedStringArray = []
@export var item_scale: Vector2 = Vector2(.5, .5)
@export var placement_offset: Vector2 = Vector2.ZERO
