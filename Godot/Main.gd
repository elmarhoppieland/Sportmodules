extends Control
class_name Main

# ==============================================================================
const MATCH_CHECK := "\t\t\t*\r\nKlas\tVoornaam\tAchternaam\tper 1\t\t\t\t\t\tper 2\t\t\t\t\t\tper 3\t\t\t\t\t\tper 4\t\t\t\t\t\r\n*"

const KEUZES_TXT_FILE := "user://keuzes-%s.txt"

const AANTAL_PERIODES := 4
# ==============================================================================
@export_group("Status Label Text", "STATUS_")
@export_multiline var STATUS_NOTHING_IMPORTED := ""
@export_multiline var STATUS_IMPORTING := ""
@export_multiline var STATUS_IMPORTED := ""
@export_multiline var STATUS_GENERATING := ""
@export_multiline var STATUS_GENERATED := ""
# ==============================================================================
var capaciteit_enter_nodes: Array[ModuleCapaciteitEnter] = []
var sporten_list: Array[PackedStringArray] = []
var leerlingen := {}
# ==============================================================================
@onready var capaciteit_label: Label = %CapaciteitLabel
@onready var side_v_box_container: VBoxContainer = %SideVBoxContainer
@onready var genereer_button: Button = %GenereerButton

@onready var dijkstra := %Dijkstra as Dijkstra

@onready var file_dialog: FileDialog = %FileDialog
@onready var alert_dialog: AcceptDialog = %AlertDialog

@onready var status_label: Label = %StatusLabel

@onready var progress_bar_primary: ProgressBar = %ProgressBarPrimary
@onready var progress_label: Label = %ProgressLabel
@onready var progress_bar_secondary: ProgressBar = %ProgressBarSecondary

@onready var cancel_button: Button = %CancelButton
# ==============================================================================
signal indelingen_gegenereerd(indelingen: Array[Dijkstra.Indeling])
# ==============================================================================

func _ready() -> void:
	file_dialog.current_dir = OS.get_executable_path().get_base_dir()
	status_label.text = STATUS_NOTHING_IMPORTED
	
	get_window().files_dropped.connect(func(files: PackedStringArray):
		if files.size() != 1:
			return
		
		_load_from_file(files[0])
	)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_paste"):
		if not is_excel_copied():
			return
		
		_on_clipboard_button_pressed()


## Returns a table as an [Array] of [PackedStringArray]s.
## Each element in the [Array] represents a row. each element in the [PackedStringArray]s
## represents the contents of the cell.
## [br][br]To retrieve the contents of a cell, use the following:
## [codeblock]
## var table = clipboard_get_table()
## var cell_coords = Vector2(1, 0)
## print(table.get_cell(cell_coords.x, cell_coords.y))
## # OR:
## print(table.get_cellv(cell_coords))
## [/codeblock]
func clipboard_get_table(allow_incompatible: bool = false) -> Table:
	if not is_excel_copied(allow_incompatible):
		return Table.new()
	
	var table: Array[PackedStringArray] = []
	
	var size_x := 0
	for line in DisplayServer.clipboard_get().trim_suffix("\r\n").split("\r\n"):
		if size_x == 0:
			size_x = line.get_slice_count("\t")
		
		table.append(line.split("\t"))
	
	return Table.new(table)


## Returns [code]true[/code] if an Excel sheet has been copied. If [code]allow_incompatible[/code]
## is [code]false[/code], returns [code]false[/code] if the copied Excel sheet
## does not match the expected format.
func is_excel_copied(allow_incompatible: bool = false) -> bool:
	if not DisplayServer.clipboard_has():
		return false
	
	var clipboard := DisplayServer.clipboard_get().trim_suffix("\r\n")
	var table_size := Vector2i.ZERO
	if not allow_incompatible:
		if not clipboard.match(MATCH_CHECK):
			return false
	for line in clipboard.split("\r\n"):
		if table_size.x == 0:
			table_size.x = line.get_slice_count("\t")
			if table_size.x < 2:
				return false
			continue
		if line.get_slice_count("\t") != table_size.x:
			return false
	
	return true


func _load_table_from_clipboard() -> void:
	status_label.text = STATUS_IMPORTING
	
	var thread := AutoThread.new(self)
	
	sporten_list.clear()
	
	var table := clipboard_get_table()
	
	capaciteit_label.show()
	
	var y_offset := 0
	while table.get_cell(0, y_offset).is_empty():
		y_offset += 1
	y_offset -= 1
	
	var start_index := 3
	var offset := 3
	LoadingScreen.start(AANTAL_PERIODES, "Periode 1 importeren...", 0, "", LoadingScreen.LinkSettings.new(progress_bar_primary, progress_label))
	for periode in AANTAL_PERIODES:
		LoadingScreen.set_message("Periode %d importeren..." % (periode + 1))
		offset = start_index
		var sporten: PackedStringArray = []
		var index := start_index
		while not table.get_cell(index, y_offset).is_empty():
			sporten.append(table.get_cell(index, y_offset))
			var capaciteit_enter_node := preload("res://ModuleCapaciteitEnter.tscn").instantiate()
			capaciteit_enter_node.naam = table.get_cell(index, y_offset)
			if capaciteit_enter_nodes.is_empty():
				capaciteit_label.add_sibling(capaciteit_enter_node)
			else:
				capaciteit_enter_nodes[-1].add_sibling(capaciteit_enter_node)
			capaciteit_enter_nodes.append(capaciteit_enter_node)
			index += 1
			start_index += 1
		
		sporten_list.append(sporten)
		
		for capaciteit_enter_node in capaciteit_enter_nodes:
			capaciteit_enter_node.aantal = int((table.height() - 2 - y_offset) * 1.3 / sporten.size())
		
		start_index += 1
		
		leerlingen[periode] = [] as Array[Leerling]
		
		thread.start_execution(func():
			for row_index in range(y_offset + 2, table.height()):
				var row := table.get_row(row_index)
				if row[0].is_empty():
					# this row is empty for some reason
					continue
				
				var leerling := Leerling.new([], row[0], row[1], row[2])
				
				for sport_index in sporten.size():
					var value: int = row[sport_index + offset].to_int()
					if value > 0:
						while leerling.choices.size() < value:
							leerling.choices.append("")
						
						leerling.choices[value - 1] = sporten[sport_index]
				
				leerlingen[periode].append(leerling)
		)
		await thread.finished
		
		offset += sporten.size() + 1
		
		LoadingScreen.progress_increment()
	
	status_label.text = STATUS_IMPORTED % [leerlingen[0].size(), sporten_list.size()]
	
	side_v_box_container.propagate_call("show")
	
	return


func __old_code() -> void:
	status_label.text = STATUS_IMPORTING
	
	sporten_list.clear()
	
	var table := clipboard_get_table()
	
	side_v_box_container.propagate_call("show")
	
	var start_index := 3
	var offset := 3
	for periode in AANTAL_PERIODES:
		offset = start_index
		var sporten: PackedStringArray = []
		var index := start_index
		while not table.get_cell(index, 0).is_empty():
			sporten.append(table.get_cell(index, 0))
			var capaciteit_enter_node := preload("res://ModuleCapaciteitEnter.tscn").instantiate()
			capaciteit_enter_node.naam = table.get_cell(index, 0)
			if capaciteit_enter_nodes.is_empty():
				capaciteit_label.add_sibling(capaciteit_enter_node)
			else:
				capaciteit_enter_nodes[-1].add_sibling(capaciteit_enter_node)
			capaciteit_enter_nodes.append(capaciteit_enter_node)
			index += 1
			start_index += 1
		
		sporten_list.append(sporten)
		
		for capaciteit_enter_node in capaciteit_enter_nodes:
			capaciteit_enter_node.aantal = int((table.height() - 2) * 1.3 / sporten.size())
		
		start_index += 1
		
		leerlingen[periode] = [] as Array[Leerling]
		
		for row_index in range(2, table.height()):
			var row := table.get_row(row_index)
			if row[0].is_empty():
				# this row is empty for some reason
				continue
			
			var leerling := Leerling.new([], row[0], row[1], row[2])
			
			for sport_index in sporten.size():
				var value: int = row[sport_index + offset].to_int()
				if value > 0:
					while leerling.choices.size() < value:
						leerling.choices.append("")
					
					leerling.choices[value - 1] = sporten[sport_index]
			
			leerlingen[periode].append(leerling)
		
#		var file := FileAccess.open(KEUZES_TXT_FILE % periode, FileAccess.WRITE)
#		file.store_line("De sporten: %s " % ", ".join(sporten))
#		for leerling in leerlingen[periode]:
#			file.store_line("%s, %s" % [leerling.achternaam, ", ".join(leerling.choices)])
		
		offset += sporten.size() + 1
	
	status_label.text = STATUS_IMPORTED % [leerlingen.size(), sporten_list.size()]


func _load_from_file(file: String) -> void:
	status_label.text = STATUS_IMPORTING
	
	var thread := AutoThread.new(self)
	
	sporten_list.clear()
	
	var sheet := ExcelSheet.new(file)
	if sheet.get_open_error() != OK:
		return
	
	capaciteit_label.show()
	
	var y_offset := 0
	while sheet.get_cell(0, y_offset).is_empty():
		y_offset += 1
	y_offset -= 1
	
	var start_index := 3
	var offset := 3
	LoadingScreen.start(AANTAL_PERIODES, "Periode 1 importeren...", 0, "", LoadingScreen.LinkSettings.new(progress_bar_primary, progress_label))
	for periode in AANTAL_PERIODES:
		LoadingScreen.set_message("Periode %d importeren..." % (periode + 1))
		offset = start_index
		var sporten: PackedStringArray = []
		var index := start_index
		while not sheet.get_cell(index, y_offset).is_empty():
			sporten.append(sheet.get_cell(index, y_offset))
			var capaciteit_enter_node := preload("res://ModuleCapaciteitEnter.tscn").instantiate()
			capaciteit_enter_node.naam = sheet.get_cell(index, y_offset)
			if capaciteit_enter_nodes.is_empty():
				capaciteit_label.add_sibling(capaciteit_enter_node)
			else:
				capaciteit_enter_nodes[-1].add_sibling(capaciteit_enter_node)
			capaciteit_enter_nodes.append(capaciteit_enter_node)
			index += 1
			start_index += 1
		
		sporten_list.append(sporten)
		
		for capaciteit_enter_node in capaciteit_enter_nodes:
			capaciteit_enter_node.aantal = int((sheet.height() - 2 - y_offset) * 1.3 / sporten.size())
		
		start_index += 1
		
		leerlingen[periode] = [] as Array[Leerling]
		
		thread.start_execution(func():
			for row_index in range(y_offset + 2, sheet.height()):
				var row := sheet.get_row(row_index)
				if row[0].is_empty():
					# this row is empty for some reason
					continue
				
				var leerling := Leerling.new([], row[0], row[1], row[2])
				
				for sport_index in sporten.size():
					var value := row[sport_index + offset].to_int()
					if value > 0:
						while leerling.choices.size() < value:
							leerling.choices.append("")
						
						leerling.choices[value - 1] = sporten[sport_index]
				
				leerlingen[periode].append(leerling)
		)
		await thread.finished
		
		offset += sporten.size() + 1
		
		LoadingScreen.progress_increment()
	
	status_label.text = STATUS_IMPORTED % [leerlingen[0].size(), sporten_list.size()]
	
	side_v_box_container.propagate_call("show")


func _on_clipboard_button_pressed() -> void:
	if not is_excel_copied(true):
		return
	
	_load_table_from_clipboard()


func _on_genereer_button_pressed() -> void:
	if FileAccess.file_exists("user://indeling.csv"):
		if not FileAccess.open("user://indeling.csv", FileAccess.READ_WRITE):
			# we cannot open the file
			alert_dialog.show()
			return
	
	var indelingen: Array[Dijkstra.Indeling] = []
	
	status_label.text = STATUS_GENERATING
	
	cancel_button.show()
	
	var thread := AutoThread.new(self)
	thread.start(_genereer_indelingen.bind(indelingen), Thread.PRIORITY_HIGH)
#	await thread.finished
	await LoadingScreen.finished
	
	cancel_button.hide()
	
#	_genereer_indelingen(indelingen)
	
	status_label.text = STATUS_GENERATED
	
	indelingen_gegenereerd.emit(indelingen)
	
#	_load_table_from_indelingen(indelingen)


func _genereer_indelingen(output: Array[Dijkstra.Indeling]) -> void:
	LoadingScreen.start(sporten_list.size(), "Indeling genereren voor periode 1...", leerlingen[0].size(), "", LoadingScreen.LinkSettings.new(progress_bar_primary, progress_label, progress_bar_secondary))
	
	print_rich("[color=aqua]Aantal periodes: %s[/color]" % sporten_list.size())
	
	var capaciteiten: Array[PackedInt32Array] = []
	
	var sport_index := 0
	for periode in sporten_list.size():
		capaciteiten.append(PackedInt32Array())
		for i in sporten_list[periode].size():
			capaciteiten[-1].append(capaciteit_enter_nodes[sport_index].aantal)
			sport_index += 1
	
	for periode in sporten_list.size():
		LoadingScreen.set_step_count_secondary(leerlingen[periode].size(), true)
		var module_caps := capaciteiten[periode]
		if OS.is_debug_build() and not Input.is_key_pressed(KEY_ALT):
			print("Sporten: %s" % [sporten_list[periode]])
			print("Caps: %s" % module_caps)
		
		var students := Dijkstra.get_student_array(leerlingen[periode], sporten_list[periode])
		seed(0) # make sure shuffle() always does the same
		students.shuffle()
		
		var indeling := dijkstra.run_algorithm(students, module_caps)
		
		var score := 0
		
		for module_idx in indeling.size():
			var module := indeling.modules[module_idx]
			module.leerlingen.sort_custom(func(a: Dijkstra.Student, b: Dijkstra.Student):
				return a.achternaam < b.achternaam
			)
			if OS.is_debug_build() and not Input.is_key_pressed(KEY_ALT):
				for leerling in module.leerlingen:
					score += leerling.get_score(module_idx, module_caps.size())
		
		if OS.is_debug_build() and not Input.is_key_pressed(KEY_ALT):
			print("Score: " + str(score))
			
			for module_idx in indeling.size():
				var module := indeling.modules[module_idx]
				var keuzes: Array[PackedInt32Array] = []
				for leerling in module.leerlingen:
					keuzes.append(leerling.choices)
				
				print("Module %s heeft %s leerlingen: %s" % [module_idx, module.size(), keuzes])
		
		output.append(indeling)
		
		LoadingScreen.progress_increment()
		LoadingScreen.set_message("Indeling genereren voor periode %s..." % (periode + 2))


#func _load_table_from_indelingen(indelingen: Array[Dijkstra.Indeling]) -> void:
#	var table := Table.new()
#
#	var row := []
#	for periode in sporten_list.size():
#		for sport in sporten_list[periode]:
#			row.append(sport)
#	table.append_row(row, true)
#
#	var leerling_index := 0
#	while true:
#		row = []
#		for indeling in indelingen:
#			for module in indeling.modules:
#				if module.size() > leerling_index:
#					var leerling := module.leerlingen[leerling_index]
#					row.append("%s - %s %s" % [leerling.klas, leerling.voornaam, leerling.achternaam])
#				else:
#					row.append("")
#			if row.all(func(a: String): return a.is_empty()):
#				var clipboard := ""
#
#				var file := FileAccess.open("user://indeling.csv", FileAccess.WRITE)
#				if not file:
#					push_error("Error while opening 'indeling.csv': %s" % error_string(FileAccess.get_open_error()))
#
#				for table_row in table.rows():
#					clipboard += "\t".join(table_row)
#					clipboard += "\r\n"
#					if file:
#						file.store_csv_line(table_row, ";")
#
#				DisplayServer.clipboard_set(clipboard)
#
#				if file:
#					OS.shell_open(ProjectSettings.globalize_path("user://indeling.csv"))
#
#				return
#			table.append_row(row)
#		leerling_index += 1


func _on_cancel_button_pressed() -> void:
	dijkstra.cancel()
	
	status_label.text = STATUS_IMPORTED % [leerlingen.size(), sporten_list.size()]
	
	cancel_button.hide()
	
	LoadingScreen.progress_cancel()


func _on_indelingen_gegenereerd(indelingen: Array[Dijkstra.Indeling]) -> void:
	var file := FileAccess.open("user://indeling.csv", FileAccess.WRITE)
	if not file:
		push_error("Error while opening 'indeling.csv': %s" % error_string(FileAccess.get_open_error()))
		return
	
	var rows: Array[PackedStringArray] = []
	
	while true:
		if indelingen.all(func(a: Dijkstra.Indeling): return a.modules.all(func(b: Dijkstra.Module): return b.size() <= rows.size())):
			break
		
		rows.append(PackedStringArray())
		
		for i in indelingen.size():
			var indeling := indelingen[i]
			for j in indeling.size():
				var module := indeling.modules[j]
				if rows.size() <= module.size():
					rows[-1].append(str(module.leerlingen[rows.size() - 1]))
				else:
					rows[-1].append("")
			
			rows[-1].append("")
	
	var header: PackedStringArray = []
	for i in indelingen.size():
		var indeling := indelingen[i]
		for j in indeling.size():
			header.append(sporten_list[i][j])
		header.append("")
	
	file.store_csv_line(header, ";")
	
	for row in rows:
		file.store_csv_line(row, ";")
	
	OS.shell_open(ProjectSettings.globalize_path("user://indeling.csv"))
