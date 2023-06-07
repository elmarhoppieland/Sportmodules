extends Control
class_name Main

# ==============================================================================
const MATCH_CHECK := "\t\t\t*\r\nKlas\tVoornaam\tAchternaam\tper 1\t\t\t\t\t\tper 2\t\t\t\t\t\tper 3\t\t\t\t\t\tper 4\t\t\t\t\t\r\n*"

const KEUZES_TXT_FILE := "user://keuzes-%s.txt"

const AANTAL_PERIODES := 4
# ==============================================================================
@onready var _table_grid: GridContainer = %TableGrid
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
			item.text = column
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
		if not "\r\n" in clipboard:
			return false
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
	
	var table := clipboard_get_table(true)
	
	var start_index := 3
	for periode in AANTAL_PERIODES:
		var sporten: PackedStringArray = []
		var index := start_index
		while not table.get_cell(index, 0).is_empty():
			sporten.append(table.get_cell(index, 0))
			index += 1
			start_index += 1
		
		start_index += 1
		
		var leerlingen: Array[Leerling] = []
		
		for row_index in range(2, table.height()):
			var row := table.get_row(row_index)
			if row[0].is_empty():
				# this row is empty for some reason
				continue
			
			var leerling := Leerling.new([], row[0], row[1], row[2])
			
			for sport_index in sporten.size():
				var value: int = row[3 + sport_index].to_int()
				if value > 0:
					while leerling.choices.size() < value:
						leerling.choices.append("")
					
					leerling.choices[value - 1] = sporten[sport_index]
			
			leerlingen.append(leerling)
		
		var file := FileAccess.open(KEUZES_TXT_FILE % periode, FileAccess.WRITE)
		file.store_line("De sporten: %s " % ", ".join(sporten))
		for leerling in leerlingen:
			file.store_line("%s, %s" % [leerling.achternaam, ", ".join(leerling.choices)])


func _on_clipboard_button_pressed() -> void:
	if not is_excel_copied(true):
		return
	
	var time := Time.get_ticks_usec()
	print("Loading the table from clipboard...")
	
	var thread := AutoThread.new(self)
	thread.start_execution(_load_table_from_clipboard)
	
	await thread.finished
	
	print("Finished loading after %s seconds." % ((Time.get_ticks_usec() - time) / 1e6))
	time = Time.get_ticks_usec()
	
	print("Loading the table from the clipboard...")
	
	thread.start_execution(clipboard_get_table)
	thread.finished.connect(func(table: Table):
		print("Finished loading after %s seconds." % ((Time.get_ticks_usec() - time) / 1e6))
		time = Time.get_ticks_usec()
		
		print("Showing the table...")
		show_table(table)
		print("Finished showing after %s seconds. " % ((Time.get_ticks_usec() - time) / 1e6))
	)