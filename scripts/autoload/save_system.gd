extends Node

signal save_completed
signal load_completed

const SAVE_DIR: String = "user://saves/"
const CHARACTERS_FILE: String = "user://saves/characters.json"


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)


func save_character(character: CharacterData) -> void:
	var all_characters: Array = _load_raw()
	var found: bool = false
	for i in all_characters.size():
		if all_characters[i].get("character_name") == character.character_name:
			all_characters[i] = _to_dict(character)
			found = true
			break
	if not found:
		all_characters.append(_to_dict(character))
	_write_json(CHARACTERS_FILE, all_characters)
	save_completed.emit()


func load_all_characters() -> Array[CharacterData]:
	var raw: Array = _load_raw()
	var characters: Array[CharacterData] = []
	for dict in raw:
		characters.append(_from_dict(dict))
	load_completed.emit()
	return characters


func has_save() -> bool:
	return FileAccess.file_exists(CHARACTERS_FILE)


func delete_character(character_name: String) -> void:
	var all_characters: Array = _load_raw()
	all_characters = all_characters.filter(
		func(c: Dictionary) -> bool: return c.get("character_name") != character_name
	)
	_write_json(CHARACTERS_FILE, all_characters)


func _load_raw() -> Array:
	if not FileAccess.file_exists(CHARACTERS_FILE):
		return []
	var file := FileAccess.open(CHARACTERS_FILE, FileAccess.READ)
	if not file:
		return []
	var json_string: String = file.get_as_text()
	file.close()
	var json := JSON.new()
	if json.parse(json_string) != OK:
		push_error("SaveSystem: JSON konnte nicht gelesen werden.")
		return []
	return json.get_data()


func _write_json(path: String, data: Variant) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		push_error("SaveSystem: Datei konnte nicht geöffnet werden: " + path)
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


func _to_dict(c: CharacterData) -> Dictionary:
	return {
		"character_name": c.character_name,
		"character_class": c.character_class,
		"race": c.race,
		"background": c.background,
		"alignment": c.alignment,
		"level": c.level,
		"experience": c.experience,
		"strength": c.strength,
		"dexterity": c.dexterity,
		"constitution": c.constitution,
		"intelligence": c.intelligence,
		"wisdom": c.wisdom,
		"charisma": c.charisma,
		"max_hp": c.max_hp,
		"current_hp": c.current_hp,
		"temp_hp": c.temp_hp,
		"armor_class": c.armor_class,
		"initiative_bonus": c.initiative_bonus,
		"speed": c.speed,
		"proficiency_bonus": c.proficiency_bonus,
		"skill_proficiencies": c.skill_proficiencies,
		"saving_throw_proficiencies": c.saving_throw_proficiencies,
		"equipment": c.equipment,
		"copper": c.copper,
		"silver": c.silver,
		"electrum": c.electrum,
		"gold": c.gold,
		"platinum": c.platinum,
		"features_and_traits": c.features_and_traits,
		"notes": c.notes,
		"backstory": c.backstory,
		"spellcasting_ability": c.spellcasting_ability,
		"spell_slots_max": c.spell_slots_max,
		"spell_slots_used": c.spell_slots_used,
		"spells": c.spells.map(func(s: SpellData) -> Dictionary: return _spell_to_dict(s)),
	}


func _from_dict(d: Dictionary) -> CharacterData:
	var c := CharacterData.new()
	c.character_name = d.get("character_name", "Unbenannt")
	c.character_class = d.get("character_class", "Krieger")
	c.race = d.get("race", "Mensch")
	c.background = d.get("background", "")
	c.alignment = d.get("alignment", "Neutral")
	c.level = d.get("level", 1)
	c.experience = d.get("experience", 0)
	c.strength = d.get("strength", 10)
	c.dexterity = d.get("dexterity", 10)
	c.constitution = d.get("constitution", 10)
	c.intelligence = d.get("intelligence", 10)
	c.wisdom = d.get("wisdom", 10)
	c.charisma = d.get("charisma", 10)
	c.max_hp = d.get("max_hp", 10)
	c.current_hp = d.get("current_hp", 10)
	c.temp_hp = d.get("temp_hp", 0)
	c.armor_class = d.get("armor_class", 10)
	c.initiative_bonus = d.get("initiative_bonus", 0)
	c.speed = d.get("speed", 9)
	c.proficiency_bonus = d.get("proficiency_bonus", 2)
	c.skill_proficiencies = d.get("skill_proficiencies", [])
	c.saving_throw_proficiencies = d.get("saving_throw_proficiencies", [])
	c.equipment = d.get("equipment", [])
	c.copper = d.get("copper", 0)
	c.silver = d.get("silver", 0)
	c.electrum = d.get("electrum", 0)
	c.gold = d.get("gold", 0)
	c.platinum = d.get("platinum", 0)
	c.features_and_traits = d.get("features_and_traits", "")
	c.notes = d.get("notes", "")
	c.backstory = d.get("backstory", "")
	c.spellcasting_ability = d.get("spellcasting_ability", "")
	var slots_max: Array = d.get("spell_slots_max", [0,0,0,0,0,0,0,0,0])
	var slots_used: Array = d.get("spell_slots_used", [0,0,0,0,0,0,0,0,0])
	c.spell_slots_max.resize(9)
	c.spell_slots_used.resize(9)
	for i in 9:
		c.spell_slots_max[i] = int(slots_max[i]) if i < slots_max.size() else 0
		c.spell_slots_used[i] = int(slots_used[i]) if i < slots_used.size() else 0
	var raw_spells: Array = d.get("spells", [])
	c.spells.clear()
	for sd in raw_spells:
		c.spells.append(_spell_from_dict(sd))
	return c


func _spell_to_dict(s: SpellData) -> Dictionary:
	return {
		"spell_name": s.spell_name,
		"description": s.description,
		"spell_level": s.spell_level,
		"school": s.school,
		"action_type": s.action_type,
		"casting_time": s.casting_time,
		"spell_range": s.spell_range,
		"components": s.components,
		"duration": s.duration,
		"concentration": s.concentration,
		"ritual": s.ritual,
		"damage_dice": s.damage_dice,
		"damage_type": s.damage_type,
		"save_ability": s.save_ability,
		"higher_levels": s.higher_levels,
	}


func _spell_from_dict(d: Dictionary) -> SpellData:
	var s := SpellData.new()
	s.spell_name = d.get("spell_name", "")
	s.description = d.get("description", "")
	s.spell_level = d.get("spell_level", 0)
	s.school = d.get("school", "")
	s.action_type = d.get("action_type", "Aktion")
	s.casting_time = d.get("casting_time", "1 Aktion")
	s.spell_range = d.get("spell_range", "Berührung")
	s.components = d.get("components", "V, S")
	s.duration = d.get("duration", "Sofort")
	s.concentration = d.get("concentration", false)
	s.ritual = d.get("ritual", false)
	s.damage_dice = d.get("damage_dice", "")
	s.damage_type = d.get("damage_type", "")
	s.save_ability = d.get("save_ability", "")
	s.higher_levels = d.get("higher_levels", "")
	return s
