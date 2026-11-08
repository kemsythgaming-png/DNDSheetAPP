class_name CharacterData
extends Resource

@export var character_name: String = "Unbenannter Charakter"
@export var character_class: String = "Krieger"
@export var race: String = "Mensch"
@export var background: String = ""
@export var alignment: String = "Neutral"
@export var level: int = 1
@export var experience: int = 0

@export_group("Attribute")
@export_range(1, 30) var strength: int = 10
@export_range(1, 30) var dexterity: int = 10
@export_range(1, 30) var constitution: int = 10
@export_range(1, 30) var intelligence: int = 10
@export_range(1, 30) var wisdom: int = 10
@export_range(1, 30) var charisma: int = 10

@export_group("Trefferpunkte")
@export var max_hp: int = 10
@export var current_hp: int = 10
@export var temp_hp: int = 0

@export_group("Kampf")
@export var armor_class: int = 10
@export var initiative_bonus: int = 0
@export var speed: int = 9

@export_group("Fertigkeiten")
@export var proficiency_bonus: int = 2
@export var skill_proficiencies: Array[String] = []
@export var saving_throw_proficiencies: Array[String] = []

@export_group("Ausrüstung und Notizen")
@export var equipment: Array[String] = []
@export var copper: int = 0
@export var silver: int = 0
@export var electrum: int = 0
@export var gold: int = 0
@export var platinum: int = 0
@export var features_and_traits: String = ""
@export var notes: String = ""
@export var backstory: String = ""

@export_group("Magie")
@export var spellcasting_ability: String = ""
@export var spells: Array[SpellData] = []
@export var spell_slots_max: Array[int] = [0, 0, 0, 0, 0, 0, 0, 0, 0]
@export var spell_slots_used: Array[int] = [0, 0, 0, 0, 0, 0, 0, 0, 0]


func get_modifier(attribute: int) -> int:
	return (attribute - 10) / 2

func get_strength_modifier() -> int:
	return get_modifier(strength)

func get_dexterity_modifier() -> int:
	return get_modifier(dexterity)

func get_constitution_modifier() -> int:
	return get_modifier(constitution)

func get_intelligence_modifier() -> int:
	return get_modifier(intelligence)

func get_wisdom_modifier() -> int:
	return get_modifier(wisdom)

func get_charisma_modifier() -> int:
	return get_modifier(charisma)

func get_initiative() -> int:
	return get_dexterity_modifier() + initiative_bonus

func get_passive_perception() -> int:
	var bonus: int = proficiency_bonus if "Wahrnehmung" in skill_proficiencies else 0
	return 10 + get_wisdom_modifier() + bonus


func get_spell_dc() -> int:
	if spellcasting_ability.is_empty():
		return 8 + proficiency_bonus
	return 8 + proficiency_bonus + get_modifier(int(get(spellcasting_ability)))


func get_spell_attack_bonus() -> int:
	if spellcasting_ability.is_empty():
		return proficiency_bonus
	return proficiency_bonus + get_modifier(int(get(spellcasting_ability)))
