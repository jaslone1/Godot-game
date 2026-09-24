extends CharacterBody2D

@export var speed: float = 300.0

func _physics_process(_delta: float) -> void:
	# Get vector direction from Arrow keys or WASD automatically
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
func _unhandled_input(event: InputEvent) -> void:
	# Press the "G" key (for Ground/Give) to drop the first item in your pocket
	if event is InputEventKey and event.pressed and event.keycode == KEY_G:
		if Inventory.items.size() > 0:
			var item_to_drop = Inventory.items[0] # Grab the first item
			
			# Drop it slightly offset from the player so you don't instantly pick it up again
			var drop_spot = global_position + Vector2(0, 150) 
			
			Inventory.drop_item(item_to_drop, drop_spot)
