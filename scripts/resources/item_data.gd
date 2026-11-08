class_name ItemData
extends Resource

enum ItemType { WEAPON, ARMOR, SHIELD, POTION, SPELL_COMPONENT, TOOL, TREASURE, OTHER }

@export var item_name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var item_type: ItemType = ItemType.OTHER
@export var weight: float = 0.0
@export var value_cp: int = 0
@export var stackable: bool = true
@export var max_stack: int = 99
@export var quantity: int = 1

@export_group("Waffe")
@export var damage_dice: String = ""
@export var damage_type: String = ""
@export var weapon_properties: Array[String] = []

@export_group("Rüstung")
@export var base_ac: int = 0
@export var max_dex_bonus: int = 99


func get_value_gp() -> float:
	return value_cp / 100.0

func get_total_weight() -> float:
	return weight * quantity
