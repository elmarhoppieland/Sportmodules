extends RefCounted
class_name Table

## A 2-dimensional version of [Array].

# ==============================================================================
var _table: Array[Array] = []
# ==============================================================================

func _init(table: Array = []) -> void:
	assign(table)


## Assigns elements of another table into the table. Resizes the table to match
## [code]table[/code]. Performs type conversions if the array is typed.
func assign(table: Array) -> void:
	_table.assign(table)


## Appends 1 column to the end of the table.
## [br][br][b]Note:[/b] This method is slower than [method append_row]. Consider
## using that instead.
func append_column(column: Array) -> void:
	if column.size() != height():
		return
	
	for i in height():
		var value = column[i]
		_table[i].append(value)


## Appends 1 row and the end of the table.
func append_row(row: Array) -> void:
	if row.size() != width():
		return
	
	_table.append(row)


## Returns the contents of the cell at the given [code]x[/code] and [code]y[/code].
func get_cell(x: int, y: int) -> Variant:
	return get_cellv(Vector2i(x, y))


## Same as [method get_cell], but uses a [Vector2i].
func get_cellv(cell: Vector2i) -> Variant:
	return _table[cell.y][cell.x]


## Returns the size of the table.
func size() -> Vector2i:
	if _table.is_empty():
		return Vector2i.ZERO
	
	return Vector2i(_table[0].size(), _table.size())


## Returns [code]true[/code] if the table is empty.
func is_empty() -> bool:
	return _table.is_empty()


## Returns the number of columns in the table.
func width() -> int:
	if _table.is_empty():
		return 0
	
	return _table[0].size()


## Returns the number of rows in the table.
func height() -> int:
	return _table.size()


## Returns the row at index [code]idx[/code].
func get_row(idx: int) -> Array:
	return _table[idx]


## Returns an [Array] of all rows.
func rows() -> Array[Array]:
	return _table
