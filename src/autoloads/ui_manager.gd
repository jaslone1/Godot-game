extends Node

# Tracks which piece of furniture triggered the current menu
var active_target_furniture: Node2D = null

func show_placement_menu(options: Array[ItemData], target_furniture: Node2D) -> void:
	active_target_furniture = target_furniture
	
	# Create a temporary popup canvas layer so it renders on top of everything
	var canvas = CanvasLayer.new()
	var panel = PanelContainer.new()
	var vbox = VBoxContainer.new()
	
	# Position the UI centrally on screen
	panel.custom_minimum_size = Vector2(300, 200)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	var label = Label.new()
	label.text = "Choose an item to place:"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label)
	
	# Generate a clickable text button for every placeable item in your pocket
	for item in options:
		var btn = Button.new()
		btn.text = item.name
		# Connect the click event using a lambda function
		btn.pressed.connect(func(): _on_item_selected(item, canvas))
		vbox.add_child(btn)
		
	# Add a close/cancel button
	var cancel_btn = Button.new()
	cancel_btn.text = "Cancel"
	cancel_btn.pressed.connect(func(): canvas.queue_free())
	vbox.add_child(cancel_btn)
	
	panel.add_child(vbox)
	canvas.add_child(panel)
	get_tree().current_scene.add_child(canvas)

func _on_item_selected(item: ItemData, canvas_to_destroy: CanvasLayer) -> void:
	if active_target_furniture != null and active_target_furniture.has_method("receive_placed_item"):
		active_target_furniture.receive_placed_item(item)
		
	# Close the UI menu
	canvas_to_destroy.queue_free()
	active_target_furniture = null
