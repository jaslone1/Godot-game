# Step-by-Step Upgrade Guide

This guide explains how to grow the current Godot game into a larger exploration game with:

- A map the player can move around
- Multiple pickup items
- A player inventory containing multiple items
- Multiple interactive storage objects
- A two-way transfer menu for player and storage inventories
- Static shelf and furniture visuals

The current project uses Godot 4 and has these important areas:

- `src/core/` — shared data classes
- `src/autoloads/` — global inventory and UI systems
- `src/entities/player/` — player movement and input
- `src/objects/pickup/` — world pickup items
- `src/objects/container/` — storage objects such as shelves
- `src/worlds/` — maps and level scenes
- `icons/` — item textures

## 1. Establish the item data model

Use `src/core/item_data.gd` as the single definition for an item type.

Recommended fields:

```gdscript
class_name ItemData
extends Resource

@export var id: String = "item"
@export var display_name: String = "Item"
@export var texture: Texture2D
@export var is_placeable: bool = true
@export var placeable_on: PackedStringArray = []
@export var item_scale: Vector2 = Vector2.ONE
```

Use one `.tres` resource for each item type, for example:

- `src/data/apple.tres`
- `src/data/banana.tres`
- `src/data/shelf_item.tres`

Each resource should point to its texture:

```ini
texture = ExtResource("apple_texture")
```

Keep visual configuration in the item resource. Do not hardcode individual item textures inside the shelf script.

## 2. Keep the player inventory as a collection

Use `src/autoloads/inventory_manager.gd` for the player inventory.

The basic model can remain:

```gdscript
var items: Array[ItemData] = []
```

Required operations:

```gdscript
func add_item(item: ItemData) -> void:
	if item == null:
		return
	items.append(item)
	inventory_updated.emit()

func remove_item(item: ItemData) -> bool:
	if item == null or not items.has(item):
		return false
	items.erase(item)
	inventory_updated.emit()
	return true
```

This supports multiple items, including several copies of the same item.

### Optional stacking upgrade

When individual array entries become inconvenient, replace them with inventory slots or a dictionary of item IDs and quantities:

```gdscript
var item_counts: Dictionary = {}
```

Do this only after the non-stacked version is working. The current array is easier to debug and is suitable for the first playable version.

## 3. Make pickup scenes reusable

Update `src/objects/pickup/pickup_item.gd` so the scene receives an `ItemData` resource and adds it to the player inventory when collected.

The pickup scene should:

1. Display `item_data.texture` in its `Sprite2D`.
2. Apply `item_data.item_scale`.
3. Detect the player through the `Player` group.
4. Add the item to `Inventory`.
5. Remove itself from the world.

Use the same `pickup_item.tscn` for every item. Only the exported `item_data` value should change between instances in `World.tscn`.

## 4. Create a reusable storage base

Create or maintain:

- `src/objects/placeable_base.gd`

This script should manage data only. It should not replace the shelf or furniture texture when an item is stored.

Recommended fields:

```gdscript
@export var accepted_types: PackedStringArray = []
@export var max_items: int = 12

var stored_items: Array[ItemData] = []
signal storage_updated
```

Recommended methods:

```gdscript
func can_accept_item(item: ItemData) -> bool:
	if item == null or stored_items.size() >= max_items:
		return false
	if accepted_types.is_empty() or item.placeable_on.is_empty():
		return true
	for accepted_type in accepted_types:
		if item.placeable_on.has(accepted_type):
			return true
	return false

func store_item(item: ItemData) -> bool:
	if not can_accept_item(item):
		return false
	if not Inventory.remove_item(item):
		return false
	stored_items.append(item)
	storage_updated.emit()
	return true

func take_item(item: ItemData) -> bool:
	if not stored_items.has(item):
		return false
	stored_items.erase(item)
	Inventory.add_item(item)
	storage_updated.emit()
	return true
```

Do not assign an item texture to a shelf sprite in `store_item()` or `receive_placed_item()`. The shelf should remain visually unchanged.

## 5. Update the shelf object

Use `src/objects/container/shelf.gd` to inherit the storage behavior:

```gdscript
extends "res://src/objects/placeable_base.gd"

func _ready() -> void:
	accepted_types = ["shelf"]
	super._ready()
```

In `shelf.tscn`:

- Keep the shelf artwork as-is.
- Keep its collision shapes.
- Remove the `HeldItemSprite` if it is no longer needed.
- Do not add item sprites to the shelf when inventory changes.

The shelf’s state is represented by `stored_items`, not by a visible item.

## 6. Add the two-way storage menu

Use `src/autoloads/ui_manager.gd` or create a dedicated `src/ui/storage_ui.gd`.

When the player interacts with a storage object, show two lists:

- Player inventory
- Storage inventory

Each player item gets an **Add** button.
Each stored item gets a **Take** button.

The menu should call:

```gdscript
storage.store_item(item)
storage.take_item(item)
```

After either action:

1. Refresh the player list.
2. Refresh the storage list.
3. Keep the menu open.
4. Leave the shelf visual unchanged.

Display icons in the menu using:

```gdscript
button.icon = item.texture
```

The menu should prevent adding items when:

- The item is incompatible with the storage object.
- The storage object is full.
- The item no longer exists in the player inventory.

## 7. Use interaction instead of automatic placement

For the first version, collision can open the storage menu. A better long-term approach is an explicit interaction key.

Recommended flow:

1. The player enters an `Area2D` around a storage object.
2. The object becomes the current interactable.
3. A prompt appears: `Press E to open storage`.
4. The player presses `E`.
5. The storage menu opens.
6. Leaving the area clears the current interactable.

This avoids opening a menu unexpectedly when the player merely walks past furniture.

## 8. Add a larger map

Expand `src/worlds/World.tscn` into a real level scene.

Recommended structure:

```text
World (Node2D)
├── Map (Node2D or TileMapLayer)
├── Navigation (optional)
├── Interactables (Node2D)
├── Pickups (Node2D)
├── Player (CharacterBody2D)
└── Camera2D
```

For a tile-based map:

1. Add a `TileMapLayer`.
2. Create a `TileSet` from your map tiles.
3. Paint floors and walls.
4. Add collision to blocking tiles.
5. Put shelves, pickups, and other objects under `Interactables` or `Pickups`.

For a non-tile-based map:

1. Add a `Node2D` called `Map`.
2. Add background sprites or polygons.
3. Add `StaticBody2D` nodes for walls.
4. Add `CollisionShape2D` nodes to each wall.

## 9. Add a camera that follows the player

Add a `Camera2D` as a child of the player scene.

Recommended settings:

- Enable the camera.
- Set position smoothing if desired.
- Set camera limits to the map bounds.

Example player scene structure:

```text
Player
├── Sprite2D
├── CollisionShape2D
└── Camera2D
```

The camera limits prevent the view from scrolling beyond the map.

## 10. Add multiple interactive objects

Create each storage object as a scene that inherits the same storage script.

Examples:

- `src/objects/container/shelf.tscn`
- `src/objects/container/cabinet.tscn`
- `src/objects/container/crate.tscn`
- `src/objects/container/counter.tscn`

Each object can configure:

```gdscript
accepted_types = ["shelf"]
max_items = 12
```

or:

```gdscript
accepted_types = ["food", "counter"]
max_items = 6
```

Do not duplicate inventory transfer logic in every object script. Put shared behavior in `placeable_base.gd`.

## 11. Add more item categories

Add category information to item resources if different storage objects should accept different items.

Examples:

- Food: `apple`, `banana`
- Tools: `hammer`, `brush`
- Documents: `letter`, `receipt`
- Decorations: `plant`, `vase`

An item can be accepted by multiple object types:

```ini
placeable_on = PackedStringArray("shelf", "counter")
```

A storage object should only show compatible player items in its Add list, or show incompatible items disabled.

## 12. Add a proper inventory screen

Later, create:

- `src/ui/inventory_ui.tscn`
- `src/ui/inventory_ui.gd`

The screen can show:

- item icon
- item name
- quantity
- selected item details
- drop or use actions

Keep the storage transfer menu separate from the general inventory screen. The inventory screen is for viewing and using items; the storage menu is for moving items between two containers.

## 13. Save and load inventory state

Once the gameplay loop works, add save data for:

- player position
- player inventory
- stored items in each object
- opened doors or completed interactions

Each storage object needs a stable ID, such as:

```gdscript
@export var storage_id: String = "kitchen_shelf_01"
```

Save item IDs rather than raw scene references. On load, resolve the IDs back to `ItemData` resources.

## 14. Recommended implementation order

Complete the upgrades in this order:

1. Confirm item textures and item resources work.
2. Keep `Inventory.items` as an array and test collecting multiple items.
3. Add `stored_items` to the storage base script.
4. Remove all shelf item-sprite replacement logic.
5. Add the two-column storage transfer menu.
6. Add a second shelf or cabinet to verify reusable storage.
7. Add an explicit `E` interaction prompt.
8. Add a larger map background or `TileMapLayer`.
9. Add `Camera2D` and camera limits.
10. Add an inventory screen.
11. Add stackable quantities.
12. Add save/load support.

## 15. Testing checklist

After each change, test the following:

- The player can move around the map.
- A pickup adds exactly one item.
- Multiple pickups create multiple inventory entries.
- The same item can be added more than once.
- The storage menu opens only for the nearby object.
- Player items appear in the left column.
- Stored items appear in the right column.
- Clicking Add removes the item from the player and adds it to storage.
- Clicking Take removes the item from storage and adds it to the player.
- A full storage object rejects new items.
- Incompatible items cannot be added.
- The shelf artwork never changes when items are transferred.
- Closing and reopening the menu preserves both inventories.

## Target end state

The desired gameplay loop is:

1. The player walks around a map.
2. The player touches or approaches a pickup.
3. The pickup is added to the player inventory.
4. The player approaches a shelf, cabinet, or other storage object.
5. The player presses `E` or interacts with it.
6. The player and storage inventories appear together.
7. The player clicks items to add or take them.
8. The storage object remains visually unchanged.
9. The item data persists in the correct inventory.

This keeps world visuals, item data, player inventory, and storage state separate, making the game easier to expand.
