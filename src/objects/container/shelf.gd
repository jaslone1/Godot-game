extends "res://src/objects/placeable_base.gd"

func _ready() -> void:
	accepted_types = ["shelf"]
	super._ready()
