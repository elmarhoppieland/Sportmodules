extends RefCounted
class_name ExcelSheet

# ==============================================================================
const USER_DIRECTORY := "user://ExcelReader"
# ==============================================================================
var zip: ZIPReader

var strings: PackedStringArray = []

var open_error := OK
# ==============================================================================

func _init(path: String) -> void:
	zip = ZIPReader.new()
	open_error = zip.open(path)
	if open_error:
		push_error("An error occured when trying to open zip file %s: %s." % [path, error_string(open_error)])
		return
	
	strings = ExcelSheet.get_strings(zip.read_file("xl/sharedStrings.xml").get_string_from_utf8())


func get_open_error() -> Error:
	return open_error


func close() -> void:
	zip.close()


func get_cell(x: int, y: int, sheet_idx: int = 1) -> String:
	var sheet_data_string := zip.read_file("xl/worksheets/sheet%d.xml" % sheet_idx).get_string_from_utf8().get_slice("<sheetData>", 1).get_slice("</sheetData>", 0)
	
	var row_data_string := sheet_data_string.get_slice("r=\"%d\"" % (y + 1), 1).get_slice("</row>", 0)
	row_data_string = row_data_string.trim_prefix(row_data_string.get_slice(">", 0) + ">")
	
	var cell_x_pos := 0
	var cell_data := ""
	for i in row_data_string.trim_prefix("<").trim_suffix(">").get_slice_count("><"):
		var data_slice := row_data_string.trim_prefix("<").trim_suffix(">").get_slice("><", i)
		match data_slice[0]:
			"c": # cell data
				if cell_x_pos == x + 1:
					return ""
				cell_x_pos += 1
				if cell_x_pos == x + 1:
					cell_data = data_slice
			"v": # value
				if cell_x_pos != x + 1:
					continue
				
				var index := data_slice.to_int()
				
				if "t=\"s\"" in cell_data:
					return strings[index]
				return str(index)
	
	return "<-!- NOT FOUND -!->"


func get_row(y: int, sheet_idx: int = 1) -> PackedStringArray:
	var sheet_data_string := zip.read_file("xl/worksheets/sheet%d.xml" % sheet_idx).get_string_from_utf8().get_slice("<sheetData>", 1).get_slice("</sheetData>", 0)
	
	var row: PackedStringArray = []
	
	var row_data_string := sheet_data_string.get_slice("r=\"%d\"" % (y + 1), 1).get_slice("</row>", 0)
	row_data_string = row_data_string.trim_prefix(row_data_string.get_slice(">", 0) + ">")
	
	var cell_x_pos := 0
	var cell_data := ""
	var waiting_for_value := false
	for i in row_data_string.trim_prefix("<").trim_suffix(">").get_slice_count("><"):
		var data_slice := row_data_string.trim_prefix("<").trim_suffix(">").get_slice("><", i)
		match data_slice[0]:
			"c": # cell data
				cell_x_pos += 1
				cell_data = data_slice
				
				if waiting_for_value:
					row.append("")
				
				waiting_for_value = true
			"v": # value
				var index := data_slice.to_int()
				
				if "t=\"s\"" in cell_data:
					row.append(strings[index])
				else:
					row.append(str(index))
				
				waiting_for_value = false
	
	return row


func rows(sheet_idx: int = 1) -> Array[PackedStringArray]:
	var rows: Array[PackedStringArray] = []
	
	for i in height(sheet_idx):
		rows.append(get_row(i, sheet_idx))
	
	return rows


func height(sheet_idx: int = 1) -> int:
	var sheet_data_string := zip.read_file("xl/worksheets/sheet%d.xml" % sheet_idx).get_string_from_utf8()
	
	return sheet_data_string.get_slice("<row r=\"", sheet_data_string.get_slice_count("<row r=\"") - 1).get_slice("\"", 0).to_int()


static func get_strings(shared_strings_file_text: String) -> PackedStringArray:
	var strings_data = shared_strings_file_text.trim_prefix(shared_strings_file_text.get_slice("<si>", 0))
	
	return strings_data.trim_prefix("<si><t>").trim_suffix("</t></si></sst>").split("</t></si><si><t>")
