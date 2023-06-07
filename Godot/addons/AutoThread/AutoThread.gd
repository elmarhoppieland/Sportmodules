extends Thread
class_name AutoThread

## A [Thread] that automatically finishes.

# ==============================================================================
var _ref: Node
var _tree: SceneTree

var _execution_blocker := RequestBlocker.new()
# ==============================================================================
## Emitted when an execution has finished.
signal finished(value: Variant)
# ==============================================================================

func _init(ref_node: Node = null) -> void:
	_ref = ref_node
	if _ref:
		_tree = _ref.get_tree()
		_ref.tree_exiting.connect(func(): finish())


## Starts a new execution. See [method Thread.start] for more information.
## If [code]return_value[/code] is [code]true[/code], the value returned by the
## thread will be emitted into [signal finished].
## [br][br][b]Note:[/b] Only 1 [Callable] can be executed per [Thread]. If this
## method is called while a callable is still being executed, the execution will
## be queued and only run when this thread is free.
func start_execution(callable: Callable, priority: Priority = PRIORITY_NORMAL) -> Error:
	await _execution_blocker.wait()
	
	if _ref:
		_start()
	
	return start(callable, priority)


## Finises the current execution. Similar to [method Thread.wait_to_finish].
func finish() -> Variant:
	var value: Variant = wait_to_finish()
	
	finished.emit(value)
	
	_execution_blocker.lower()
	
	return value


func _start() -> void:
	await _tree.process_frame
	
	if not _tree:
		return
	while is_alive():
		await _tree.process_frame
	if is_started():
		finish()
