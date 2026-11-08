class_name SheetView
extends Control

const ATTRIBUTES: Array = [
	["Stärke", "strength"],
	["Geschicklichkeit", "dexterity"],
	["Konstitution", "constitution"],
	["Intelligenz", "intelligence"],
	["Weisheit", "wisdom"],
	["Charisma", "charisma"],
]

const SAVING_THROWS: Array = [
	["Stärke", "strength"],
	["Geschicklichkeit", "dexterity"],
	["Konstitution", "constitution"],
	["Intelligenz", "intelligence"],
	["Weisheit", "wisdom"],
	["Charisma", "charisma"],
]

const SKILLS: Array = [
	["Akrobatik", "dexterity"],
	["Arkana", "intelligence"],
	["Athletik", "strength"],
	["Auftreten", "charisma"],
	["Einschüchterung", "charisma"],
	["Geschichte", "intelligence"],
	["Heimlichkeit", "dexterity"],
	["Medizin", "wisdom"],
	["Mit Tieren umgehen", "wisdom"],
	["Motiv erkennen", "wisdom"],
	["Natur", "intelligence"],
	["Religion", "intelligence"],
	["Täuschen", "charisma"],
	["Überlebenskunst", "wisdom"],
	["Überzeugen", "charisma"],
	["Untersuchen", "intelligence"],
	["Wahrnehmung", "wisdom"],
]

var _character: CharacterData
var _save_timer: Timer

var _modifier_labels: Dictionary = {}
var _save_throw_labels: Dictionary = {}
var _skill_labels: Dictionary = {}
var _passive_perception_label: Label
var _initiative_label: Label
var _prof_spin: SpinBox

var _spell_dc_label: Label
var _spell_atk_label: Label
var _spell_ability_option: OptionButton
var _slot_buttons: Array = []        # Array of Array[Button], index [level-1][slot]
var _spell_slots_vbox: VBoxContainer
var _spell_list_container: VBoxContainer
var _spell_detail_panels: Array = [] # expanded content per spell


func setup(character: CharacterData) -> void:
	_character = character

	_save_timer = Timer.new()
	_save_timer.wait_time = 2.0
	_save_timer.one_shot = true
	_save_timer.timeout.connect(func(): GameManager.save_current_character())
	add_child(_save_timer)

	_build_ui()
	_update_all_derived_values()


func _build_ui() -> void:
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(margin)

	var root_vbox := VBoxContainer.new()
	root_vbox.add_theme_constant_override("separation", 12)
	margin.add_child(root_vbox)

	root_vbox.add_child(_build_header())
	root_vbox.add_child(HSeparator.new())

	var tabs := TabContainer.new()
	tabs.custom_minimum_size = Vector2(0, 620)
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_vbox.add_child(tabs)

	var tab_main := _build_main_tab()
	tab_main.name = "Attribute & Kampf"
	tabs.add_child(tab_main)

	var tab_skills := _build_skills_tab()
	tab_skills.name = "Fertigkeiten"
	tabs.add_child(tab_skills)

	var tab_spells := _build_spells_tab()
	tab_spells.name = "Zauber"
	tabs.add_child(tab_spells)

	var tab_notes := _build_notes_tab()
	tab_notes.name = "Notizen"
	tabs.add_child(tab_notes)


# ── HEADER ────────────────────────────────────────────────────────────────────

func _build_header() -> Control:
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 6)

	_add_line_field(grid, "Charaktername", "character_name", _character.character_name)
	_add_line_field(grid, "Klasse", "character_class", _character.character_class)
	_add_line_field(grid, "Rasse", "race", _character.race)
	_add_line_field(grid, "Hintergrund", "background", _character.background)
	_add_line_field(grid, "Gesinnung", "alignment", _character.alignment)
	_add_spin_field(grid, "Level", "level", 1, 20, _character.level, func(v: float):
		_character.level = int(v)
		_character.proficiency_bonus = max(2, (_character.level - 1) / 4 + 2)
		if _prof_spin:
			_prof_spin.value = _character.proficiency_bonus
		_update_all_derived_values()
		_schedule_save()
	)

	return grid


func _add_line_field(parent: Control, label: String, prop: String, value: String) -> void:
	var col := VBoxContainer.new()
	var lbl := Label.new()
	lbl.text = label
	col.add_child(lbl)
	var edit := LineEdit.new()
	edit.text = value
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edit.text_changed.connect(func(t: String):
		_character.set(prop, t)
		_schedule_save()
	)
	col.add_child(edit)
	parent.add_child(col)


func _add_spin_field(parent: Control, label: String, prop: String,
		min_v: int, max_v: int, current: int, callback: Callable) -> void:
	var col := VBoxContainer.new()
	var lbl := Label.new()
	lbl.text = label
	col.add_child(lbl)
	var spin := SpinBox.new()
	spin.min_value = min_v
	spin.max_value = max_v
	spin.value = current
	spin.value_changed.connect(callback)
	col.add_child(spin)
	parent.add_child(col)


# ── MAIN TAB (Attribute & Kampf) ──────────────────────────────────────────────

func _build_main_tab() -> Control:
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 24)
	margin.add_child(hbox)

	hbox.add_child(_build_attributes_column())
	hbox.add_child(VSeparator.new())
	hbox.add_child(_build_combat_column())
	hbox.add_child(VSeparator.new())
	hbox.add_child(_build_saving_throws_column())

	return scroll


func _build_attributes_column() -> Control:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)

	var title := Label.new()
	title.text = "ATTRIBUTE"
	vbox.add_child(title)

	for attr in ATTRIBUTES:
		vbox.add_child(_build_attribute_box(attr[0], attr[1]))

	vbox.add_child(HSeparator.new())

	var prof_row := HBoxContainer.new()
	var prof_lbl := Label.new()
	prof_lbl.text = "Übungsbonus:"
	prof_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	prof_row.add_child(prof_lbl)

	_prof_spin = SpinBox.new()
	_prof_spin.min_value = 2
	_prof_spin.max_value = 6
	_prof_spin.value = _character.proficiency_bonus
	_prof_spin.custom_minimum_size = Vector2(72, 0)
	_prof_spin.value_changed.connect(func(v: float):
		_character.proficiency_bonus = int(v)
		_update_all_derived_values()
		_schedule_save()
	)
	prof_row.add_child(_prof_spin)
	vbox.add_child(prof_row)

	return vbox


func _build_attribute_box(label_text: String, property: String) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(148, 0)

	var inner := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		inner.add_theme_constant_override("margin_" + side, 4)
	panel.add_child(inner)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	inner.add_child(vbox)

	var lbl := Label.new()
	lbl.text = label_text.to_upper()
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl)

	var mod_label := Label.new()
	mod_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mod_label.add_theme_font_size_override("font_size", 20)
	_modifier_labels[property] = mod_label
	vbox.add_child(mod_label)

	var spin := SpinBox.new()
	spin.min_value = 1
	spin.max_value = 30
	spin.value = int(_character.get(property))
	spin.value_changed.connect(func(v: float):
		_character.set(property, int(v))
		_update_all_derived_values()
		_schedule_save()
	)
	vbox.add_child(spin)

	return panel


func _build_combat_column() -> Control:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	vbox.custom_minimum_size = Vector2(190, 0)

	var title := Label.new()
	title.text = "KAMPF"
	vbox.add_child(title)

	vbox.add_child(_build_spin_row("Rüstungsklasse", "armor_class", 0, 30, _character.armor_class))

	var init_row := HBoxContainer.new()
	var init_lbl := Label.new()
	init_lbl.text = "Initiative:"
	init_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	init_row.add_child(init_lbl)
	_initiative_label = Label.new()
	_initiative_label.custom_minimum_size = Vector2(42, 0)
	_initiative_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	init_row.add_child(_initiative_label)
	vbox.add_child(init_row)

	vbox.add_child(_build_spin_row("Bewegungsrate (m)", "speed", 0, 60, _character.speed))
	vbox.add_child(HSeparator.new())

	var hp_title := Label.new()
	hp_title.text = "TREFFERPUNKTE"
	vbox.add_child(hp_title)
	vbox.add_child(_build_spin_row("Maximum", "max_hp", 1, 999, _character.max_hp))
	vbox.add_child(_build_spin_row("Aktuell", "current_hp", 0, 999, _character.current_hp))
	vbox.add_child(_build_spin_row("Temporär", "temp_hp", 0, 999, _character.temp_hp))

	return vbox


func _build_spin_row(label_text: String, property: String,
		min_v: int, max_v: int, current: int) -> Control:
	var hbox := HBoxContainer.new()
	var lbl := Label.new()
	lbl.text = label_text + ":"
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(lbl)
	var spin := SpinBox.new()
	spin.min_value = min_v
	spin.max_value = max_v
	spin.value = current
	spin.custom_minimum_size = Vector2(78, 0)
	spin.value_changed.connect(func(v: float):
		_character.set(property, int(v))
		_schedule_save()
	)
	hbox.add_child(spin)
	return hbox


func _build_saving_throws_column() -> Control:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	vbox.custom_minimum_size = Vector2(210, 0)

	var title := Label.new()
	title.text = "RETTUNGSWÜRFE"
	vbox.add_child(title)

	for st in SAVING_THROWS:
		vbox.add_child(_build_saving_throw_row(st[0], st[1]))

	return vbox


func _build_saving_throw_row(name_text: String, attr_prop: String) -> Control:
	var hbox := HBoxContainer.new()

	var check := CheckBox.new()
	check.button_pressed = name_text in _character.saving_throw_proficiencies
	check.toggled.connect(func(on: bool):
		if on and not name_text in _character.saving_throw_proficiencies:
			_character.saving_throw_proficiencies.append(name_text)
		elif not on:
			_character.saving_throw_proficiencies.erase(name_text)
		_update_all_derived_values()
		_schedule_save()
	)
	hbox.add_child(check)

	var val_lbl := Label.new()
	val_lbl.custom_minimum_size = Vector2(40, 0)
	val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_save_throw_labels[attr_prop] = val_lbl
	hbox.add_child(val_lbl)

	var name_lbl := Label.new()
	name_lbl.text = "  " + name_text
	hbox.add_child(name_lbl)

	return hbox


# ── SKILLS TAB ────────────────────────────────────────────────────────────────

func _build_skills_tab() -> Control:
	var scroll := ScrollContainer.new()

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	margin.add_child(vbox)

	var passive_row := HBoxContainer.new()
	var passive_lbl := Label.new()
	passive_lbl.text = "Passive Wahrnehmung:"
	passive_row.add_child(passive_lbl)
	_passive_perception_label = Label.new()
	_passive_perception_label.custom_minimum_size = Vector2(30, 0)
	_passive_perception_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	passive_row.add_child(_passive_perception_label)
	vbox.add_child(passive_row)
	vbox.add_child(HSeparator.new())

	for skill in SKILLS:
		vbox.add_child(_build_skill_row(skill[0], skill[1]))

	return scroll


func _build_skill_row(skill_name: String, attr_prop: String) -> Control:
	var hbox := HBoxContainer.new()

	var check := CheckBox.new()
	check.button_pressed = skill_name in _character.skill_proficiencies
	check.toggled.connect(func(on: bool):
		if on and not skill_name in _character.skill_proficiencies:
			_character.skill_proficiencies.append(skill_name)
		elif not on:
			_character.skill_proficiencies.erase(skill_name)
		_update_all_derived_values()
		_schedule_save()
	)
	hbox.add_child(check)

	var bonus_lbl := Label.new()
	bonus_lbl.custom_minimum_size = Vector2(40, 0)
	bonus_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_skill_labels[skill_name] = bonus_lbl
	hbox.add_child(bonus_lbl)

	var name_lbl := Label.new()
	name_lbl.text = "  %s  (%s)" % [skill_name, _attr_abbr(attr_prop)]
	hbox.add_child(name_lbl)

	return hbox


# ── NOTES TAB ─────────────────────────────────────────────────────────────────

func _build_notes_tab() -> Control:
	var scroll := ScrollContainer.new()

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	vbox.add_child(_build_text_section(
		"Eigenschaften & Fähigkeiten", "features_and_traits", _character.features_and_traits))
	vbox.add_child(_build_text_section(
		"Notizen", "notes", _character.notes))
	vbox.add_child(_build_text_section(
		"Hintergrundgeschichte", "backstory", _character.backstory))

	return scroll


func _build_text_section(title: String, property: String, value: String) -> Control:
	var vbox := VBoxContainer.new()
	var lbl := Label.new()
	lbl.text = title
	vbox.add_child(lbl)
	var text_edit := TextEdit.new()
	text_edit.text = value
	text_edit.custom_minimum_size = Vector2(0, 130)
	text_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	text_edit.text_changed.connect(func():
		_character.set(property, text_edit.text)
		_schedule_save()
	)
	vbox.add_child(text_edit)
	return vbox


# ── ZAUBER TAB ────────────────────────────────────────────────────────────────

func _build_spells_tab() -> Control:
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	vbox.add_child(_build_spell_stats_header())
	vbox.add_child(HSeparator.new())
	vbox.add_child(_build_spell_slots_section())
	vbox.add_child(HSeparator.new())
	vbox.add_child(_build_spell_list_section())

	return scroll


func _build_spell_stats_header() -> Control:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)

	# ZAUBER-SG
	var dc_panel := PanelContainer.new()
	dc_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var dc_inner := VBoxContainer.new()
	dc_inner.add_theme_constant_override("separation", 2)
	var dc_margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		dc_margin.add_theme_constant_override("margin_" + side, 8)
	dc_panel.add_child(dc_margin)
	dc_margin.add_child(dc_inner)
	var dc_title := Label.new()
	dc_title.text = "ZAUBER-SG"
	dc_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dc_title.add_theme_font_size_override("font_size", 10)
	dc_inner.add_child(dc_title)
	_spell_dc_label = Label.new()
	_spell_dc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_spell_dc_label.add_theme_font_size_override("font_size", 22)
	dc_inner.add_child(_spell_dc_label)
	hbox.add_child(dc_panel)

	# ANGRIFF
	var atk_panel := PanelContainer.new()
	atk_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var atk_inner := VBoxContainer.new()
	atk_inner.add_theme_constant_override("separation", 2)
	var atk_margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		atk_margin.add_theme_constant_override("margin_" + side, 8)
	atk_panel.add_child(atk_margin)
	atk_margin.add_child(atk_inner)
	var atk_title := Label.new()
	atk_title.text = "ANGRIFF"
	atk_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	atk_title.add_theme_font_size_override("font_size", 10)
	atk_inner.add_child(atk_title)
	_spell_atk_label = Label.new()
	_spell_atk_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_spell_atk_label.add_theme_font_size_override("font_size", 22)
	atk_inner.add_child(_spell_atk_label)
	hbox.add_child(atk_panel)

	# FÄHIGKEIT
	var ab_panel := PanelContainer.new()
	ab_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var ab_inner := VBoxContainer.new()
	ab_inner.add_theme_constant_override("separation", 2)
	var ab_margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		ab_margin.add_theme_constant_override("margin_" + side, 8)
	ab_panel.add_child(ab_margin)
	ab_margin.add_child(ab_inner)
	var ab_title := Label.new()
	ab_title.text = "ZAUBERFÄHIGKEIT"
	ab_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ab_title.add_theme_font_size_override("font_size", 10)
	ab_inner.add_child(ab_title)
	_spell_ability_option = OptionButton.new()
	_spell_ability_option.add_item("—")
	_spell_ability_option.add_item("STR")
	_spell_ability_option.add_item("GES")
	_spell_ability_option.add_item("KON")
	_spell_ability_option.add_item("INT")
	_spell_ability_option.add_item("WEI")
	_spell_ability_option.add_item("CHA")
	var _ability_map: Array = ["", "strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma"]
	var cur_idx: int = _ability_map.find(_character.spellcasting_ability)
	_spell_ability_option.selected = max(0, cur_idx)
	_spell_ability_option.item_selected.connect(func(idx: int):
		_character.spellcasting_ability = _ability_map[idx]
		_update_spell_stats()
		_schedule_save()
	)
	ab_inner.add_child(_spell_ability_option)
	hbox.add_child(ab_panel)

	_update_spell_stats()
	return hbox


func _build_spell_slots_section() -> Control:
	var vbox := VBoxContainer.new()
	_spell_slots_vbox = vbox
	vbox.add_theme_constant_override("separation", 6)
	_populate_spell_slots(vbox)
	return vbox


func _populate_spell_slots(vbox: VBoxContainer) -> void:
	var title_row := HBoxContainer.new()
	var title := Label.new()
	title.text = "ZAUBERSLOTS"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title)
	var reset_btn := Button.new()
	reset_btn.text = "↺ Reset"
	reset_btn.pressed.connect(_reset_spell_slots)
	title_row.add_child(reset_btn)
	vbox.add_child(title_row)

	_slot_buttons.clear()
	for level in range(1, 10):
		var max_slots: int = _character.spell_slots_max[level - 1]
		_slot_buttons.append([])

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)

		var lbl := Label.new()
		lbl.text = "%d. Grad" % level
		lbl.custom_minimum_size = Vector2(64, 0)
		row.add_child(lbl)

		var slots_hbox := HBoxContainer.new()
		slots_hbox.add_theme_constant_override("separation", 4)
		slots_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		for slot in range(max_slots):
			var btn := Button.new()
			btn.custom_minimum_size = Vector2(28, 28)
			btn.text = "●" if slot < _character.spell_slots_used[level - 1] else "○"
			var lvl := level
			var s := slot
			btn.pressed.connect(func(): _toggle_spell_slot(lvl, s))
			slots_hbox.add_child(btn)
			_slot_buttons[level - 1].append(btn)
		row.add_child(slots_hbox)

		var count_lbl := Label.new()
		var used_count: int = _character.spell_slots_used[level - 1]
		count_lbl.text = "%d/%d" % [max_slots - used_count, max_slots]
		count_lbl.custom_minimum_size = Vector2(36, 0)
		count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(count_lbl)

		var max_spin := SpinBox.new()
		max_spin.min_value = 0
		max_spin.max_value = 9
		max_spin.value = max_slots
		max_spin.custom_minimum_size = Vector2(60, 0)
		max_spin.suffix = "max"
		var lvl2 := level
		max_spin.value_changed.connect(func(v: float):
			_character.spell_slots_max[lvl2 - 1] = int(v)
			_character.spell_slots_used[lvl2 - 1] = mini(_character.spell_slots_used[lvl2 - 1], int(v))
			_rebuild_spell_slots()
			_schedule_save()
		)
		row.add_child(max_spin)

		if max_slots == 0:
			row.visible = false
		vbox.add_child(row)

	var any_slots: bool = _character.spell_slots_max.any(func(v: int) -> bool: return v > 0)
	if not any_slots:
		var hint := Label.new()
		hint.text = "Keine Slots konfiguriert. Max-Wert anpassen."
		hint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		vbox.add_child(hint)


func _rebuild_spell_slots() -> void:
	for child in _spell_slots_vbox.get_children().duplicate():
		child.free()
	_populate_spell_slots(_spell_slots_vbox)


func _toggle_spell_slot(level: int, slot: int) -> void:
	var used: int = _character.spell_slots_used[level - 1]
	var max_s: int = _character.spell_slots_max[level - 1]
	if slot < used:
		_character.spell_slots_used[level - 1] = slot
	elif slot >= used and used < max_s:
		_character.spell_slots_used[level - 1] = slot + 1
	_update_slot_display()
	_schedule_save()


func _update_slot_display() -> void:
	for level in range(1, 10):
		var max_s: int = _character.spell_slots_max[level - 1]
		if max_s == 0:
			continue
		var level_btns: Array = _slot_buttons[level - 1] if level - 1 < _slot_buttons.size() else []
		for s in level_btns.size():
			var used: bool = s < _character.spell_slots_used[level - 1]
			(level_btns[s] as Button).text = "●" if used else "○"


func _reset_spell_slots() -> void:
	for i in 9:
		_character.spell_slots_used[i] = 0
	_update_slot_display()
	_schedule_save()


func _build_spell_list_section() -> Control:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)

	var header_row := HBoxContainer.new()
	var header_lbl := Label.new()
	header_lbl.text = "ZAUBER (%d)" % _character.spells.size()
	header_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(header_lbl)
	var add_btn := Button.new()
	add_btn.text = "+ Zauber"
	add_btn.pressed.connect(_show_add_spell_dialog)
	header_row.add_child(add_btn)
	vbox.add_child(header_row)

	_spell_list_container = VBoxContainer.new()
	_spell_list_container.add_theme_constant_override("separation", 4)
	vbox.add_child(_spell_list_container)

	_rebuild_spell_list()
	return vbox


func _rebuild_spell_list() -> void:
	for child in _spell_list_container.get_children():
		child.queue_free()
	_spell_detail_panels.clear()

	var sorted_spells := _character.spells.duplicate()
	sorted_spells.sort_custom(func(a: SpellData, b: SpellData) -> bool:
		return a.spell_level < b.spell_level
	)

	for spell: SpellData in sorted_spells:
		_spell_list_container.add_child(_build_spell_card(spell))


func _build_spell_card(spell: SpellData) -> Control:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var card_vbox := VBoxContainer.new()
	card_vbox.add_theme_constant_override("separation", 0)
	card.add_child(card_vbox)

	# ── Collapsed header (always visible) ───────────────────────────────────
	var header_margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		header_margin.add_theme_constant_override("margin_" + side, 6)
	card_vbox.add_child(header_margin)

	var header_hbox := HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 6)
	header_margin.add_child(header_hbox)

	# Level badge
	var level_lbl := Label.new()
	level_lbl.text = "C" if spell.is_cantrip() else str(spell.spell_level)
	level_lbl.custom_minimum_size = Vector2(18, 0)
	level_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_hbox.add_child(level_lbl)

	# Spell name
	var name_lbl := Label.new()
	name_lbl.text = spell.spell_name
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	header_hbox.add_child(name_lbl)

	# Action type tag
	var action_lbl := Label.new()
	action_lbl.text = _action_abbr(spell.action_type)
	action_lbl.add_theme_color_override("font_color", _action_color(spell.action_type))
	header_hbox.add_child(action_lbl)

	# Concentration / Ritual marker
	if spell.concentration:
		var conc := Label.new()
		conc.text = "K"
		conc.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
		header_hbox.add_child(conc)
	if spell.ritual:
		var rit := Label.new()
		rit.text = "R"
		rit.add_theme_color_override("font_color", Color(0.9, 0.7, 0.2))
		header_hbox.add_child(rit)

	# Damage badge
	if not spell.damage_dice.is_empty():
		var dmg_lbl := Label.new()
		dmg_lbl.text = "%s %s" % [spell.damage_dice, spell.damage_type]
		dmg_lbl.add_theme_color_override("font_color", _damage_color(spell.damage_type))
		header_hbox.add_child(dmg_lbl)

	# Higher level indicator
	if not spell.higher_levels.is_empty() and not spell.is_cantrip():
		var up_lbl := Label.new()
		up_lbl.text = "↑"
		up_lbl.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5))
		header_hbox.add_child(up_lbl)

	# Expand button
	var expand_btn := Button.new()
	expand_btn.text = "▼"
	expand_btn.flat = true
	header_hbox.add_child(expand_btn)

	# ── Expanded detail panel (hidden by default) ────────────────────────────
	var detail := _build_spell_detail(spell)
	detail.visible = false
	card_vbox.add_child(detail)
	_spell_detail_panels.append(detail)

	var detail_ref := detail
	expand_btn.pressed.connect(func():
		detail_ref.visible = not detail_ref.visible
		expand_btn.text = "▲" if detail_ref.visible else "▼"
	)

	return card


func _build_spell_detail(spell: SpellData) -> Control:
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 8)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)

	vbox.add_child(HSeparator.new())

	# Meta row: Aktion | Reichweite | Dauer | Komponenten
	var meta_hbox := HBoxContainer.new()
	meta_hbox.add_theme_constant_override("separation", 12)

	var act_col := _detail_col("AKTION", spell.action_type)
	meta_hbox.add_child(act_col)

	var range_col := _detail_col("REICHWEITE", spell.spell_range)
	meta_hbox.add_child(range_col)

	var dur_text: String = spell.duration
	if spell.concentration:
		dur_text += " (K)"
	var dur_col := _detail_col("DAUER", dur_text)
	meta_hbox.add_child(dur_col)

	if not spell.components.is_empty():
		var comp_col := _detail_col("KOMPONENTEN", spell.components)
		meta_hbox.add_child(comp_col)

	vbox.add_child(meta_hbox)

	# Description
	if not spell.description.is_empty():
		var desc_lbl := Label.new()
		desc_lbl.text = spell.description
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.add_child(desc_lbl)

	# Higher levels — highlighted block
	if not spell.higher_levels.is_empty():
		var hl_panel := PanelContainer.new()
		var hl_margin := MarginContainer.new()
		for side in ["left", "right", "top", "bottom"]:
			hl_margin.add_theme_constant_override("margin_" + side, 6)
		hl_panel.add_child(hl_margin)
		var hl_vbox := VBoxContainer.new()
		hl_vbox.add_theme_constant_override("separation", 2)
		hl_margin.add_child(hl_vbox)
		var hl_title := Label.new()
		hl_title.text = "AUF HÖHEREM GRAD:"
		hl_title.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5))
		hl_title.add_theme_font_size_override("font_size", 11)
		hl_vbox.add_child(hl_title)
		var hl_text := Label.new()
		hl_text.text = spell.higher_levels
		hl_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		hl_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hl_vbox.add_child(hl_text)
		vbox.add_child(hl_panel)

	# Delete button
	var del_btn := Button.new()
	del_btn.text = "Zauber entfernen"
	var spell_ref := spell
	del_btn.pressed.connect(func():
		var real_idx := _character.spells.find(spell_ref)
		if real_idx >= 0:
			_character.spells.remove_at(real_idx)
			_rebuild_spell_list()
			_schedule_save()
	)
	vbox.add_child(del_btn)

	return margin


func _detail_col(title: String, value: String) -> Control:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 1)
	var t := Label.new()
	t.text = title
	t.add_theme_font_size_override("font_size", 9)
	t.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	col.add_child(t)
	var v := Label.new()
	v.text = value
	v.add_theme_font_size_override("font_size", 12)
	col.add_child(v)
	return col


func _action_abbr(action_type: String) -> String:
	match action_type:
		"Aktion":       return "Akt"
		"Bonus-Aktion": return "Bonus"
		"Reaktion":     return "Reak"
		"1 Minute":     return "1 Min"
		"Ritual":       return "Ritual"
	return action_type.left(5)


func _action_color(action_type: String) -> Color:
	match action_type:
		"Aktion":       return Color(0.4, 0.7, 1.0)
		"Bonus-Aktion": return Color(1.0, 0.75, 0.2)
		"Reaktion":     return Color(0.8, 0.4, 1.0)
	return Color(0.7, 0.7, 0.7)


func _damage_color(damage_type: String) -> Color:
	match damage_type.to_lower():
		"feuer":         return Color(1.0, 0.45, 0.1)
		"kälte", "kalt": return Color(0.4, 0.8, 1.0)
		"blitz":         return Color(1.0, 1.0, 0.2)
		"gift":          return Color(0.3, 0.9, 0.3)
		"säure":         return Color(0.5, 0.9, 0.1)
		"nekrotisch":    return Color(0.6, 0.2, 0.8)
		"heilig":        return Color(1.0, 0.9, 0.3)
		"psychisch":     return Color(1.0, 0.4, 0.7)
		"kraft":         return Color(0.9, 0.9, 1.0)
		"knall", "knallend": return Color(0.7, 0.7, 0.8)
		"donner":        return Color(0.5, 0.6, 1.0)
		"hieb", "stich", "wucht": return Color(0.8, 0.6, 0.4)
	return Color(0.8, 0.8, 0.8)


func _show_add_spell_dialog() -> void:
	var win := Window.new()
	win.title = "Zauber hinzufügen"
	win.size = Vector2i(460, 560)
	win.exclusive = true
	add_child(win)

	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	win.add_child(panel)

	var outer := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		outer.add_theme_constant_override("margin_" + side, 12)
	panel.add_child(outer)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	outer.add_child(vbox)

	var spell := SpellData.new()

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 6)
	vbox.add_child(grid)

	var _dialog_fields: Dictionary = {}

	var _add_text_row := func(label: String, prop: String, default: String) -> void:
		var lbl := Label.new()
		lbl.text = label
		grid.add_child(lbl)
		var edit := LineEdit.new()
		edit.text = default
		edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		edit.text_changed.connect(func(t: String): spell.set(prop, t))
		grid.add_child(edit)

	_add_text_row.call("Name", "spell_name", "")
	_add_text_row.call("Schaden (Würfel)", "damage_dice", "")
	_add_text_row.call("Schadenstyp", "damage_type", "")
	_add_text_row.call("Reichweite", "spell_range", "18m")
	_add_text_row.call("Dauer", "duration", "Sofort")
	_add_text_row.call("Komponenten", "components", "V, S")
	_add_text_row.call("Rettungswurf (Attribut)", "save_ability", "")

	# Spell level
	var lvl_lbl := Label.new()
	lvl_lbl.text = "Grad"
	grid.add_child(lvl_lbl)
	var lvl_spin := SpinBox.new()
	lvl_spin.min_value = 0
	lvl_spin.max_value = 9
	lvl_spin.value = 0
	lvl_spin.value_changed.connect(func(v: float): spell.spell_level = int(v))
	grid.add_child(lvl_spin)

	# Action type
	var act_lbl := Label.new()
	act_lbl.text = "Aktionstyp"
	grid.add_child(act_lbl)
	var act_option := OptionButton.new()
	for opt in ["Aktion", "Bonus-Aktion", "Reaktion", "1 Minute", "Ritual"]:
		act_option.add_item(opt)
	act_option.item_selected.connect(func(idx: int):
		spell.action_type = act_option.get_item_text(idx)
	)
	grid.add_child(act_option)

	# Concentration + Ritual checkboxes
	var flags_hbox := HBoxContainer.new()
	var conc_check := CheckBox.new()
	conc_check.text = "Konzentration"
	conc_check.toggled.connect(func(on: bool): spell.concentration = on)
	flags_hbox.add_child(conc_check)
	var rit_check := CheckBox.new()
	rit_check.text = "Ritual"
	rit_check.toggled.connect(func(on: bool): spell.ritual = on)
	flags_hbox.add_child(rit_check)
	var flags_lbl := Label.new()
	flags_lbl.text = "Flags"
	grid.add_child(flags_lbl)
	grid.add_child(flags_hbox)

	# Description
	var desc_lbl := Label.new()
	desc_lbl.text = "Beschreibung"
	vbox.add_child(desc_lbl)
	var desc_edit := TextEdit.new()
	desc_edit.custom_minimum_size = Vector2(0, 80)
	desc_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desc_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	desc_edit.text_changed.connect(func(): spell.description = desc_edit.text)
	vbox.add_child(desc_edit)

	# Higher levels
	var hl_lbl := Label.new()
	hl_lbl.text = "Auf höherem Grad"
	vbox.add_child(hl_lbl)
	var hl_edit := TextEdit.new()
	hl_edit.custom_minimum_size = Vector2(0, 60)
	hl_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hl_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	hl_edit.text_changed.connect(func(): spell.higher_levels = hl_edit.text)
	vbox.add_child(hl_edit)

	# Buttons
	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 8)
	vbox.add_child(btn_row)

	var ok_btn := Button.new()
	ok_btn.text = "Hinzufügen"
	ok_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ok_btn.pressed.connect(func():
		if spell.spell_name.strip_edges().is_empty():
			return
		_character.spells.append(spell)
		_rebuild_spell_list()
		_schedule_save()
		win.queue_free()
	)
	btn_row.add_child(ok_btn)

	var cancel_btn := Button.new()
	cancel_btn.text = "Abbrechen"
	cancel_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cancel_btn.pressed.connect(func(): win.queue_free())
	btn_row.add_child(cancel_btn)

	win.popup_centered()


func _update_spell_stats() -> void:
	if _spell_dc_label:
		_spell_dc_label.text = str(_character.get_spell_dc())
	if _spell_atk_label:
		var bonus: int = _character.get_spell_attack_bonus()
		_spell_atk_label.text = _fmt(bonus)


# ── CALCULATED VALUES ─────────────────────────────────────────────────────────

func _update_all_derived_values() -> void:
	for attr in ATTRIBUTES:
		var prop: String = attr[1]
		if _modifier_labels.has(prop):
			var mod := _character.get_modifier(int(_character.get(prop)))
			_modifier_labels[prop].text = _fmt(mod)

	for st in SAVING_THROWS:
		var prop: String = st[1]
		var name_text: String = st[0]
		if _save_throw_labels.has(prop):
			var base := _character.get_modifier(int(_character.get(prop)))
			var prof := _character.proficiency_bonus if name_text in _character.saving_throw_proficiencies else 0
			_save_throw_labels[prop].text = _fmt(base + prof)

	for skill in SKILLS:
		var skill_name: String = skill[0]
		var attr_prop: String = skill[1]
		if _skill_labels.has(skill_name):
			var base := _character.get_modifier(int(_character.get(attr_prop)))
			var prof := _character.proficiency_bonus if skill_name in _character.skill_proficiencies else 0
			_skill_labels[skill_name].text = _fmt(base + prof)

	if _initiative_label:
		_initiative_label.text = _fmt(_character.get_initiative())

	if _passive_perception_label:
		_passive_perception_label.text = str(_character.get_passive_perception())

	_update_spell_stats()


# ── HELPERS ───────────────────────────────────────────────────────────────────

func _schedule_save() -> void:
	if _save_timer:
		_save_timer.stop()
		_save_timer.start()


func _fmt(value: int) -> String:
	return "+%d" % value if value >= 0 else str(value)


func _attr_abbr(property: String) -> String:
	match property:
		"strength":     return "STR"
		"dexterity":    return "GES"
		"constitution": return "KON"
		"intelligence": return "INT"
		"wisdom":       return "WEI"
		"charisma":     return "CHA"
	return property.left(3).to_upper()
