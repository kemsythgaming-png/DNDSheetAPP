extends Node

signal character_loaded(character: CharacterData)
signal character_saved(character: CharacterData)
signal characters_changed

var current_character: CharacterData = null
var characters: Array[CharacterData] = []


func _ready() -> void:
	characters = SaveSystem.load_all_characters()


func create_new_character(character_name: String) -> CharacterData:
	var character := CharacterData.new()
	character.character_name = character_name
	characters.append(character)
	SaveSystem.save_character(character)
	characters_changed.emit()
	return character


func load_character(index: int) -> void:
	if index >= 0 and index < characters.size():
		current_character = characters[index]
		character_loaded.emit(current_character)


func save_current_character() -> void:
	if current_character:
		SaveSystem.save_character(current_character)
		character_saved.emit(current_character)


func delete_character(index: int) -> void:
	if index < 0 or index >= characters.size():
		return
	var character := characters[index]
	if current_character == character:
		current_character = null
	SaveSystem.delete_character(character.character_name)
	characters.remove_at(index)
	characters_changed.emit()
