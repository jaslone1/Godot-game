extends Node

var active_target: Node2D = null
var active_player: Node2D = null

func show_storage_menu(target: Node2D, player: Node2D) -> void:
	if not is_instance_valid(target) or not is_instance_valid(player):
		return
	if active_target != null:
		return

	active_target = target
	active_player = player

	var canvas := CanvasLayer.new()
	canvas.name = "StorageMenu"
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 0)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)

	var root := VBoxContainer.new()
	var title := Label.new()
	title.text = "Inventory"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(title)

	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 24)
	columns.add_child(_build_inventory_column("Player inventory", Inventory.items, target, player, canvas))
	columns.add_child(_build_inventory_column("Stored here", target.get_stored_items(), target, player, canvas))
	root.add_child(columns)

	var close_button := Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(func(): _close_storage_menu(canvas))
	root.add_child(close_button)

	panel.add_child(root)
	canvas.add_child(panel)
	get_tree().current_scene.add_child(canvas)

func _build_inventory_column(title_text: String, items: Array[ItemData], target: Node2D, player: Node2D, canvas: CanvasLayer) -> Control:
	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(0, 0)

	var title := Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(title)

	if items.is_empty():
		var empty_label := Label.new()
		empty_label.text = "Empty"
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		column.add_child(empty_label)
		return column

	for item in items:
		var button := Button.new()
		button.text = item.name
		if item.texture != null:
			button.icon = item.texture
			button.expand_icon = true

		if title_text == "Player inventory":
			button.text = "Add  " + item.name
			button.disabled = not target.can_accept_item(item) or target.is_storage_full()
			button.pressed.connect(func(): _store_item(item, target, player, canvas))
		else:
			button.text = "Take  " + item.name
			button.pressed.connect(func(): _take_item(item, target, player, canvas))
		column.add_child(button)

	return column

func _store_item(item: ItemData, target: Node2D, player: Node2D, canvas: CanvasLayer) -> void:
	if target.store_item(item):
		_refresh_storage_menu(canvas, target, player)

func _take_item(item: ItemData, target: Node2D, player: Node2D, canvas: CanvasLayer) -> void:
	if target.take_item(item):
		_refresh_storage_menu(canvas, target, player)

func _refresh_storage_menu(canvas: CanvasLayer, target: Node2D, player: Node2D) -> void:
	_close_storage_menu(canvas)
	call_deferred("show_storage_menu", target, player)

func _close_storage_menu(canvas: CanvasLayer) -> void:
	if is_instance_valid(canvas):
		canvas.queue_free()
	active_target = null
	active_player = null
