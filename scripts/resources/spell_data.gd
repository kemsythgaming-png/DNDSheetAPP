class_name SpellData
extends Resource

@export var spell_name: String = ""
@export var description: String = ""
@export_range(0, 9) var spell_level: int = 0
@export var school: String = ""
@export var casting_time: String = "1 Aktion"
@export var spell_range: String = "Berührung"
@export var components: String = "V, S"
@export var duration: String = "Sofort"
@export var concentration: bool = false
@export var ritual: bool = false
@export var damage_dice: String = ""
@export var damage_type: String = ""
@export var action_type: String = "Aktion"  # Aktion | Bonus-Aktion | Reaktion | 1 Minute | Ritual
@export var save_ability: String = ""
@export var classes: Array[String] = []
@export var higher_levels: String = ""


func is_cantrip() -> bool:
	return spell_level == 0

func get_level_string() -> String:
	if is_cantrip():
		return "Zaubertrick"
	return "Grad %d" % spell_level
