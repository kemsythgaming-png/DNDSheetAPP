extends Control

var _char_list_container: VBoxContainer
var _sheet_container: Control
var _no_char_label: Label


func _ready() -> void:
	_build_ui()
	GameManager.characters_changed.connect(_refresh_character_list)
	GameManager.character_loaded.connect(_on_character_loaded)
	_refresh_character_list()


func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var hbox := HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(hbox)

	# --- Sidebar ---
	var sidebar := PanelContainer.new()
	sidebar.custom_minimum_size = Vector2(240, 0)
	hbox.add_child(sidebar)

	var sidebar_inner := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		sidebar_inner.add_theme_constant_override("margin_" + side, 8)
	sidebar.add_child(sidebar_inner)

	var sidebar_vbox := VBoxContainer.new()
	sidebar_vbox.add_theme_constant_override("separation", 6)
	sidebar_inner.add_child(sidebar_vbox)

	var title := Label.new()
	title.text = "D&D Charaktere"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sidebar_vbox.add_child(title)
	sidebar_vbox.add_child(HSeparator.new())

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sidebar_vbox.add_child(scroll)

	_char_list_container = VBoxContainer.new()
	_char_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_char_list_container.add_theme_constant_override("separation", 4)
	scroll.add_child(_char_list_container)

	sidebar_vbox.add_child(HSeparator.new())

	var new_btn := Button.new()
	new_btn.text = "+ Neuer Charakter"
	new_btn.pressed.connect(_show_new_character_dialog)
	sidebar_vbox.add_child(new_btn)

	# --- Trennlinie ---
	hbox.add_child(VSeparator.new())

	# --- Hauptbereich ---
	_sheet_container = Control.new()
	_sheet_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sheet_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_child(_sheet_container)

	_no_char_label = Label.new()
	_no_char_label.text = "Wähle einen Charakter\noder erstelle einen neuen."
	_no_char_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_no_char_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_no_char_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_sheet_container.add_child(_no_char_label)


func _refresh_character_list() -> void:
	for child in _char_list_container.get_children():
		child.queue_free()

	for i in GameManager.characters.size():
		var character := GameManager.characters[i]
		var row := HBoxContainer.new()

		var btn := Button.new()
		btn.text = "%s\n%s %s · Lvl %d" % [
			character.character_name,
			character.race,
			character.character_class,
			character.level,
		]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		btn.autowrap_mode = TextServer.AUTOWRAP_OFF
		var idx := i
		btn.pressed.connect(func(): GameManager.load_character(idx))
		row.add_child(btn)

		var del_btn := Button.new()
		del_btn.text = "✕"
		del_btn.custom_minimum_size = Vector2(32, 0)
		del_btn.pressed.connect(func(): _confirm_delete(idx))
		row.add_child(del_btn)

		_char_list_container.add_child(row)


func _on_character_loaded(_character: CharacterData) -> void:
	for child in _sheet_container.get_children():
		if child != _no_char_label:
			child.queue_free()
	_no_char_label.visible = false

	var sheet := SheetView.new()
	sheet.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sheet.setup(_character)
	_sheet_container.add_child(sheet)


func _show_new_character_dialog() -> void:
	var win := Window.new()
	win.title = "Neuer Charakter"
	win.size = Vector2i(320, 148)
	win.exclusive = true
	win.unresizable = true

	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	win.add_child(panel)

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 12)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	var lbl := Label.new()
	lbl.text = "Charaktername:"
	vbox.add_child(lbl)

	var edit := LineEdit.new()
	edit.placeholder_text = "z.B. Aria Sturmwind"
	vbox.add_child(edit)

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 8)
	vbox.add_child(btn_row)

	var ok_btn := Button.new()
	ok_btn.text = "Erstellen"
	ok_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_row.add_child(ok_btn)

	var cancel_btn := Button.new()
	cancel_btn.text = "Abbrechen"
	cancel_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cancel_btn.pressed.connect(func(): win.queue_free())
	btn_row.add_child(cancel_btn)

	add_child(win)
	win.popup_centered()

	var do_create := func():
		var name := edit.text.strip_edges()
		if name.is_empty():
			name = "Unbenannter Charakter"
		GameManager.create_new_character(name)
		GameManager.load_character(GameManager.characters.size() - 1)
		win.queue_free()

	ok_btn.pressed.connect(do_create)
	edit.text_submitted.connect(func(_t: String): do_create.call())


func _confirm_delete(index: int) -> void:
	if index < 0 or index >= GameManager.characters.size():
		return
	var char_name := GameManager.characters[index].character_name

	var dialog := ConfirmationDialog.new()
	dialog.title = "Charakter löschen"
	dialog.dialog_text = "Charakter \"%s\" wirklich löschen?" % char_name
	dialog.exclusive = true
	add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(func():
		GameManager.delete_character(index)
		dialog.queue_free()
	)
	dialog.canceled.connect(func(): dialog.queue_free())
