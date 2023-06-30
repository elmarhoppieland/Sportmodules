extends Node
class_name TreeDijkstra

# ==============================================================================
var root: TreeDijkstraPoint :
	get:
		if is_instance_valid(root) or _no_getters:
			return root
		_no_getters = true
		create_root()
		_no_getters = false
		return root

var _no_getters := false
var point_count := 0
# ==============================================================================
signal finished_cleanup()
# ==============================================================================

func run() -> Array[TreeDijkstraPoint]:
	var time := Time.get_ticks_usec()
	
	while true:
		var point := get_next_point()
		if point.is_disabled():
			push_error("Attempted to continue Dijkstra from a disabled point.")
			return []
		
		if _check_terminate(point):
			print("Finished Dijkstra algorithm after %s seconds." % ((Time.get_ticks_usec() - time) / 1e6))
			return terminate(point)
		
		_create_new_points(point)
		
		point.disabled = true
	
	return []


## Creates a new [member root] and returns it. If there is already a root present,
## simply returns that root instead of creating a new one.
func create_root() -> TreeDijkstraPoint:
	if root:
		return root
	
	root = TreeDijkstraPoint.new()
	
	return root


## Returns the next point to be explored.
func get_next_point() -> TreeDijkstraPoint:
	var override := _get_next_point()
	if override:
		return override
	
	return root.find_best_child()


## Virtual method. If this returns a value, this value will override the return
## value of [method get_next_point]. If this returns [code]null[/code], [method
## get_next_point] will return the normal value.
func _get_next_point() -> TreeDijkstraPoint:
	return null


func add_point(point: TreeDijkstraPoint, parent: TreeDijkstraPoint) -> void:
	parent.add_child(point)
	point_count += 1
	if point_count % 1000 == 0:
		print("Point Count: %s" % point_count)
	
	# debug
	
	for child in parent.get_children() as Array[TreeDijkstraPoint]:
		if child.is_disabled():
			push_error("Invalid parent")
	
	if point.get_meta("student") != parent.get_meta("student") + 1:
		push_error("Invalid student #")


func _create_new_points(origin: TreeDijkstraPoint) -> void:
	pass


func _check_terminate(_best_point: TreeDijkstraPoint) -> bool:
	push_error("_check_terminate() is not overwritten. Aborting Dijkstra algorithm...")
	return true


func terminate(end_point: TreeDijkstraPoint) -> Array[TreeDijkstraPoint]:
	_terminate()
	
	var path: Array[TreeDijkstraPoint] = [end_point]
	
	var start_point := end_point
	while true:
		start_point = start_point.get_parent()
		if start_point == root:
			path.append(root)
			path.reverse()
			
			_handle_cleanup()
			
			return path
		
		path.append(start_point)
	
	_handle_cleanup()
	
	return path


func _terminate() -> void:
	pass


func _handle_cleanup() -> void:
	await get_tree().process_frame
	
	root = null
	finished_cleanup.emit()
