extends Control
class_name Main

# ==============================================================================
const MATCH_CHECK := "\t\t\t*\r\nKlas\tVoornaam\tAchternaam\tper 1\t\t\t\t\t\tper 2\t\t\t\t\t\tper 3\t\t\t\t\t\tper 4\t\t\t\t\t\r\n*"

const KEUZES_TXT_FILE := "user://keuzes-%s.txt"

const AANTAL_PERIODES := 4
# ==============================================================================
var capaciteit_enter_nodes: Array[ModuleCapaciteitEnter] = []
var sporten_list: Array[PackedStringArray] = []
var leerlingen := {}
# ==============================================================================
@onready var _table_grid: GridContainer = %TableGrid
@onready var capaciteit_label: Label = %CapaciteitLabel
@onready var side_v_box_container: VBoxContainer = %SideVBoxContainer
@onready var dijkstra := %Dijkstra as Dijkstra
# ==============================================================================
signal indelingen_gegenereerd(indelingen: Array[Dijkstra.Indeling])
# ==============================================================================

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("paste"):
		if not is_excel_copied():
			return
		
		_on_clipboard_button_pressed()


func show_table(table: Table) -> void:
	_table_grid.columns = table.width()
	
	hide()
	
	for row in table.rows():
		for column in row:
			var item := TableItem.instantiate()
			item.text = str(column)
			if not column.is_empty():
				item.name = column
			_table_grid.add_child(item)
	
	show()


## Returns a table as an [Array] of [PackedStringArray]s.
## Each element in the [Array] represents a row. each element in the [PackedStringArray]s
## represents the contents of the cell.
## [br][br]To retrieve the contents of a cell, use the following:
## [codeblock]
## var table = clipboard_get_table()
## var cell_coords = Vector2(1, 0)
## print(table[cell_coords.y][cell_coords.x])
## [/codeblock]
## [br][br][b]Note:[/b] The order of the cell coords is reversed when retrieving
## the cell. The first coordinate is the y coordinate, the second is the x.
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
	for child in _table_grid.get_children():
		child.queue_free()
	
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


func _on_clipboard_button_pressed() -> void:
	if not is_excel_copied(true):
		return
	
	_load_table_from_clipboard()
	
	show_table(clipboard_get_table())


func _on_genereer_button_pressed() -> void:
	var indelingen: Array[Dijkstra.Indeling] = []
	
#	var thread := Thread.new()
#	thread.start(_genereer_indelingen.bind(indelingen), Thread.PRIORITY_NORMAL)
#	await indelingen_gegenereerd
#	thread.wait_to_finish()
	
	_genereer_indelingen(indelingen)
	await indelingen_gegenereerd
	
	_load_table_from_indelingen(indelingen)


func _genereer_indelingen(output: Array[Dijkstra.Indeling]) -> void:
	LoadingScreen.start(sporten_list.size(), "Indeling genereren voor periode 1...", leerlingen[0].size())
	
	print_rich("[color=aqua]Aantal periodes: %s[/color]" % sporten_list.size())
	
	var capaciteiten: Array[PackedInt32Array] = []
	
	var sport_index := 0
	for periode in sporten_list.size():
		capaciteiten.append(PackedInt32Array())
		for i in sporten_list[periode].size():
			capaciteiten[-1].append(capaciteit_enter_nodes[sport_index].aantal)
			sport_index += 1
	
	for periode in sporten_list.size():
		var thread := AutoThread.new(self)
		thread.start_execution(func():
			LoadingScreen.set_step_count_secondary(leerlingen[periode].size(), true)
			var module_caps := capaciteiten[periode]
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
				for leerling in module.leerlingen:
					score += leerling.get_score(module_idx, module_caps.size())
			
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
		)
		print("t1")
		await thread.finished
		print("t2")
		await dijkstra.finished_cleanup
		print("t3")
	
	indelingen_gegenereerd.emit()


func _load_table_from_indelingen(indelingen: Array[Dijkstra.Indeling]) -> void:
	var table := Table.new()
	
	for child in _table_grid.get_children():
		child.queue_free()
	
	var row := []
	for periode in sporten_list.size():
		for sport in sporten_list[periode]:
			row.append(sport)
	table.append_row(row, true)
	
	var leerling_index := 0
	while true:
		row = []
		for indeling in indelingen:
			for module in indeling.modules:
				if module.size() > leerling_index:
					var leerling := module.leerlingen[leerling_index]
					row.append("%s - %s %s" % [leerling.klas, leerling.voornaam, leerling.achternaam])
				else:
					row.append("")
			if row.all(func(a: String): return a.is_empty()):
				var clipboard := ""
				
				var file := FileAccess.open("user://indeling.csv", FileAccess.WRITE)
				if not file:
					push_error("Error while opening 'indeling.csv': %s" % error_string(FileAccess.get_open_error()))
				
				for table_row in table.rows():
					clipboard += "\t".join(table_row)
					clipboard += "\r\n"
					if file:
						file.store_csv_line(table_row, ";")
				
				DisplayServer.clipboard_set(clipboard)
				
				if file:
					OS.shell_open(ProjectSettings.globalize_path("user://indeling.csv"))
				
				show_table(table)
				
				return
			table.append_row(row)
		leerling_index += 1
