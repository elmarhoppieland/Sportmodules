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

var canceled := false

var _no_getters := false
var _next_point_override: TreeDijkstraPoint

var _point_count := 0
var points: Array[TreeDijkstraPoint] = []
var point_scores: Array[int] = []
# ==============================================================================
signal finished_cleanup()
signal finished_algorithm(path: Array[TreeDijkstraPoint])
signal algorithm_step(best_point: TreeDijkstraPoint)
# ==============================================================================

## Runs the algorithm. Returns the created path as an [Array] of [TreeDijkstraPoint]s.
func run() -> PackedByteArray:
	var time := Time.get_ticks_usec()
	
	canceled = false
	_next_point_override = null
	
	points = [root]
	point_scores = [0]
	
	while true:
		if canceled:
			_handle_cleanup()
			return []
		
		var point := get_next_point()
		
#		if point.is_disabled():
#			push_error("Attempted to continue Dijkstra from a disabled point.")
#			return []
		
		(func():
			algorithm_step.emit(point)
		).call_deferred()
		
		if _check_terminate(point):
			print("Finished Dijkstra algorithm after %s seconds." % ((Time.get_ticks_usec() - time) / 1e6))
			return terminate(point)
		
		_next_point_override = null
		
		_get_point_children(point)
		
		var index := points.find(point)
		points.remove_at(index)
		point_scores.remove_at(index)
	
	return []


## Cancels the algorithm, forcing [method run] to quit immediately and to return an empty [PackedByteArray].
func cancel() -> void:
	print("Queuing a cancel...")
	canceled = true


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
	
	if _next_point_override:
		return _next_point_override
	
	return points[point_scores.find(point_scores.min())]
	
	return root.find_best_child()


## Virtual method. If this returns a value, this value will override the return
## value of [method get_next_point]. If this returns [code]null[/code], [method
## get_next_point] will return the default value.
func _get_next_point() -> TreeDijkstraPoint:
	return null


func add_point(parent: TreeDijkstraPoint, score: int, idx: int, meta_values: Dictionary = {}) -> void:
	var point := TreeDijkstraPoint.new()
	
	for identifier in meta_values:
		parent.set_meta(identifier, meta_values[identifier])
	
	point.path = parent.path.duplicate()
	point.path.append(idx)
	
	point.score = parent.score + score
	
	points.append(point)
	point_scores.append(point.score)
	
	if score == 0:
		_next_point_override = point


func _get_point_children(parent: TreeDijkstraPoint) -> void:
	pass


func _check_terminate(_best_point: TreeDijkstraPoint) -> bool:
	push_error("_check_terminate() is not overwritten. Aborting Dijkstra algorithm...")
	return true


func terminate(end_point: TreeDijkstraPoint, perform_cleanup: bool = true) -> PackedByteArray:
	_terminate()
	
	return end_point.path
	
	var path: Array[TreeDijkstraPoint] = [end_point]
	
	var start_point := end_point
	while true:
		start_point = start_point.get_parent()
		if start_point == root:
			path.append(root)
			path.reverse()
			
			(func(): finished_algorithm.emit(path)).call_deferred()
			
			if perform_cleanup:
				_handle_cleanup()
			
			return path
		
		path.append(start_point)
	
	if perform_cleanup:
		_handle_cleanup()
	
	return path


func _terminate() -> void:
	pass


func _handle_cleanup() -> void:
	root = null
	
	canceled = false
	_point_count = 0
	points.clear()
	point_scores.clear()
	
	(func(): finished_cleanup.emit()).call_deferred()
