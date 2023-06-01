extends Control
class_name Main

# ==============================================================================
const MATCH_CHECK := "\t\t\t*\r\nKlas\tVoornaam\tAchternaam\tper 1\t\t\t\t\t\tper 2\t\t\t\t\t\tper 3\t\t\t\t\t\tper 4\t\t\t\t\t\r\n*"

const KEUZES_TXT_FILE := "user://keuzes.txt"
# ==============================================================================
@onready var table_grid: GridContainer = %TableGrid
# ==============================================================================

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("paste"):
		if not is_excel_copied():
			return
		
		for child in table_grid.get_children():
			child.queue_free()
		
		var table := clipboard_get_table()
		table_grid.columns = table[0].size() # any index will do here
		
		for row in table:
			for column in row:
				var item := TableItem.instantiate()
				item.text = column
				if not column.is_empty():
					item.name = column
				table_grid.add_child(item)
		
		var sporten: PackedStringArray = []
		var index := 3
		while not table[0][index].is_empty():
			sporten.append(table[0][index])
			index += 1
		
		var leerlingen: Array[Leerling] = []
		
		for row_index in range(2, table.size()):
			var row := table[row_index]
			
			var leerling := Leerling.new([], row[0], row[1], row[2])
			
			for sport_index in sporten.size():
				var value := row[3 + sport_index].to_int()
				if value > 0:
					while leerling.choices.size() < value:
						leerling.choices.append("")
					
					leerling.choices[value - 1] = sporten[sport_index]
			
			leerlingen.append(leerling)
		
		var file := FileAccess.open(KEUZES_TXT_FILE, FileAccess.WRITE)
		file.store_line("De sporten: %s " % ", ".join(sporten))
		for leerling in leerlingen:
			file.store_line("%s, %s" % [leerling.achternaam, ", ".join(leerling.choices)])


func clipboard_get_table() -> Array[PackedStringArray]:
	if not is_excel_copied():
		return []
	
	var table: Array[PackedStringArray] = []
	
	var size_x := 0
	for line in DisplayServer.clipboard_get().trim_suffix("\r\n").split("\r\n"):
		if size_x == 0:
			size_x = line.get_slice_count("\t")
		
		table.append(line.split("\t"))
	
	return table


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
