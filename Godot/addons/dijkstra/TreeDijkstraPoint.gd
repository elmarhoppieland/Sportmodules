extends Object
class_name TreeDijkstraPoint

# ==============================================================================
var score := 0

var disabled := false : get = is_disabled

var all_children_are_worse := false

var children: Array[TreeDijkstraPoint] = [] : get = get_children
var parent: TreeDijkstraPoint : get = get_parent
# ==============================================================================
signal freed()
# ==============================================================================

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_freed()


func _freed() -> void:
	for child in get_children():
		child.free()
	freed.emit()


func find_best_child() -> TreeDijkstraPoint:
	var best_child := self
	
	if all_children_are_worse:
		return self
	
	for child in get_children() as Array[TreeDijkstraPoint]:
		var child_best_child := child.find_best_child()
		if child_best_child.is_better_than(best_child):
			best_child = child_best_child
	
	if is_disabled() and best_child == self:
		all_children_are_worse = true
		return self
	
	return best_child


func is_better_than(check_point: TreeDijkstraPoint) -> bool:
	if is_disabled():
		return false
	if check_point.is_disabled():
		return true
	
	return score < check_point.score


func add_child(child: TreeDijkstraPoint = TreeDijkstraPoint.new()) -> void:
	child.parent = self
	children.append(child)


func is_disabled() -> bool:
	return disabled


func get_children() -> Array[TreeDijkstraPoint]:
	return children


func get_parent() -> TreeDijkstraPoint:
	return parent


func get_child_count() -> int:
	return children.size()
