GDPC                 �	                                                                         X   res://.godot/exported/133200997/export-524a625e5856f3e7f4ea7d6baa2a04b6-TableItem.scn    �      P      �L��WX$'
�#��    d   res://.godot/exported/133200997/export-9f4f8fea5b3f38b4678c563ed7bbc8dc-ModuleCapaciteitEnter.scn   ��      &      чFI���g�K��c     P   res://.godot/exported/133200997/export-bcb0d2eb5949c52b6a65bfe9de3e985b-Main.scnp�      i      �Y��@�t.J�4v�I�<    \   res://.godot/exported/133200997/export-f35a01a76a1504d4d82bb4e0d87dd93d-LoadingScreen.scn    ^      �      �[ާ:�~4$%��    ,   res://.godot/global_script_class_cache.cfg  @�            ֯"���cҚ�3ڹц    D   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex�8      ^      2��r3��MgB�[79       res://.godot/uid_cache.bin  ��      �       ���%|��Վ��\-       res://Dijkstra.gd   �*            ��O�gnZ�-��V�x       res://Leerling.gd   �F      �      ��~|���rB��X�       res://LoadingScreen.gd  �I      O      \�|/����0r��        res://LoadingScreen.tscn.remap  p�      j       ��p��BE����g��       res://Main.gd   �d      �>      ���Z�N3+3�i=%�:�       res://Main.tscn.remap   ��      a       3 J�M�B�b��}�        res://ModuleCapaciteitEnter.gd  �      �      'T1�+s���v��    (   res://ModuleCapaciteitEnter.tscn.remap  P�      r       ���W{k!�zQ��       res://Table.gd  ��      �      i�������t�|:O�       res://TableItem.gd  ��      �      z�I�l�,�u�9��T       res://TableItem.tscn.remap  ��      f       U+A�	�^I���8��    (   res://addons/AutoThread/AutoThread.gd           <      "q�:w�G�J#U�`jM    ,   res://addons/AutoThread/AutoThreadMain.gd   @      �       ��k�E�fv������    ,   res://addons/AutoThread/RequestBlocker.gd          �      �6)8j(���Y��;    (   res://addons/dijkstra/TreeDijkstra.gd    	      �      E�n��,u����r���    ,   res://addons/dijkstra/TreeDijkstraMain.gd   �      �       ��k�E�fv������    ,   res://addons/dijkstra/TreeDijkstraPoint.gd  `            ?V�/f�:AdU�    (   res://addons/excelreader/ExcelSheet.gd  0      G      "�)�Zp�"�����    (   res://addons/excelreader/excelreader.gd p      �       ��k�E�fv������       res://icon.svg  `�      N      ]��s�9^w/�����       res://icon.svg.import    F      �       n<�i�9�l�oPL       res://project.binary`�            ���*Ce:'a�G�    }�lextends Thread
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
���p@tool
extends EditorPlugin


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
p#2`3]� ?�F�?extends RefCounted
class_name RequestBlocker

# ==============================================================================
var can_request := true
# ==============================================================================
signal lowered()
# ==============================================================================

func block() -> void:
	can_request = false


func lower() -> void:
	can_request = true
	lowered.emit()


func wait() -> void:
	while not can_request:
		await lowered
	
	block()
�*4Hextends Node
class_name TreeDijkstra

# ==============================================================================
@export var max_points := 100_000
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
	
	if points.size() >= max_points:
		cancel()


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
�S:}���@tool
extends EditorPlugin


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
�RPCQ��?����~"extends RefCounted
class_name TreeDijkstraPoint

# ==============================================================================
var score := 0

var path := PackedByteArray()
# ==============================================================================
0���9Q��w}�k+@tool
extends EditorPlugin


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
q)�f7�Aa���8extends RefCounted
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
� t�� �extends TreeDijkstra
class_name Dijkstra

# ==============================================================================
var students: Array[Student] = []
var module_caps: PackedInt32Array = []

var last_indeling: Indeling
# ==============================================================================

func _ready() -> void:
	algorithm_step.connect(func _on_algorithm_step(best_point: TreeDijkstraPoint):
		LoadingScreen.progress_set_secondary(best_point.path.size())
	)


func run_algorithm(_students: Array[Student], _module_caps: PackedInt32Array) -> Indeling:
	if _students.is_empty() or _module_caps.is_empty():
		push_error("Not all data is filled. Aborting Dijkstra algorithm...")
		return null
	
	students = _students
	module_caps = _module_caps
	
	print_rich("[color=aqua]Starting algorithm...[/color]")
	run()
	print_rich("[color=aqua]Finished algorithm.[/color]")
	
	return last_indeling


func _get_point_children(parent: TreeDijkstraPoint) -> void:
	var student_idx: int = parent.path.size()
	var student := students[student_idx]
	
	for module_idx in module_caps.size():
		if parent.path.count(module_idx) >= module_caps[module_idx]:
			continue
		
		var score := student.get_score(module_idx, module_caps.size() - 1)
		
		add_point(parent, score, module_idx)


func _check_terminate(best_point: TreeDijkstraPoint) -> bool:
	return best_point.path.size() >= students.size()


func terminate(final_point: TreeDijkstraPoint, perform_cleanup: bool = true) -> PackedByteArray:
	var path := super(final_point, false)
	
	last_indeling = get_indeling_from_path(final_point.path)
	
	if perform_cleanup:
		_handle_cleanup()
	
	return path


static func get_student_array(leerlingen: Array[Leerling], modules: PackedStringArray) -> Array[Student]:
	var student_array: Array[Student] = []
	
	for leerling in leerlingen:
		var keuzes: PackedInt32Array = []
		
		for choice in leerling.choices:
			keuzes.append(modules.find(choice))
		
		if keuzes.is_empty():
			continue
		
		student_array.append(Student.new(keuzes, leerling.klas, leerling.voornaam, leerling.achternaam))
	
	return student_array


func get_indeling_from_path(path: PackedByteArray) -> Indeling:
	var indeling := Indeling.new()
	for i in module_caps.size():
		indeling.modules.append(Module.new())
	
	for i in path.size():
		var module_idx := path[i]
		
		if i < students.size():
			indeling.modules[module_idx].append(students[i])
	
	return indeling


static func get_score(choice_idx: int) -> int:
	return choice_idx ** 2


class Student extends RefCounted:
	var choices: PackedInt32Array = []
	var klas := ""
	var voornaam := ""
	var achternaam := ""
	
	func _init(_choices: PackedInt32Array = [], _klas: String = "", _voornaam: String = "", _achternaam: String = "") -> void:
		choices = _choices
		klas = _klas
		voornaam = _voornaam
		achternaam = _achternaam
	
	
	func get_score(module_idx: int, fallback_idx: int) -> int:
		if module_idx in choices:
			return Dijkstra.get_score(choices.find(module_idx))
		else:
			return Dijkstra.get_score(fallback_idx)
	
	
	func _to_string() -> String:
		return "%s - %s %s" % [klas, voornaam, achternaam]


class Module extends RefCounted:
	var leerlingen: Array[Student] = []
	
	func _init(_leerlingen: Array[Student] = []) -> void:
		leerlingen = _leerlingen
	
	
	func append(leerling: Student) -> void:
		leerlingen.append(leerling)
	
	
	func size() -> int:
		return leerlingen.size()


class Indeling extends RefCounted:
	var modules: Array[Module] = []
	
	func _init(_modules: Array[Module] = []) -> void:
		modules = _modules
	
	
	func size() -> int:
		return modules.size()
��6,��'�Zr�$8cGST2   �   �      ����               � �        &  RIFF  WEBPVP8L  /������!"2�H�l�m�l�H�Q/H^��޷������d��g�(9�$E�Z��ߓ���'3���ض�U�j��$�՜ʝI۶c��3� [���5v�ɶ�=�Ԯ�m���mG�����j�m�m�_�XV����r*snZ'eS�����]n�w�Z:G9�>B�m�It��R#�^�6��($Ɓm+q�h��6�4mb�h3O���$E�s����A*DV�:#�)��)�X/�x�>@\�0|�q��m֋�d�0ψ�t�!&����P2Z�z��QF+9ʿ�d0��VɬF�F� ���A�����j4BUHp�AI�r��ِ���27ݵ<�=g��9�1�e"e�{�(�(m�`Ec\]�%��nkFC��d���7<�
V�Lĩ>���Qo�<`�M�$x���jD�BfY3�37�W��%�ݠ�5�Au����WpeU+.v�mj��%' ��ħp�6S�� q��M�׌F�n��w�$$�VI��o�l��m)��Du!SZ��V@9ד]��b=�P3�D��bSU�9�B���zQmY�M~�M<��Er�8��F)�?@`�:7�=��1I]�������3�٭!'��Jn�GS���0&��;�bE�
�
5[I��=i�/��%�̘@�YYL���J�kKvX���S���	�ڊW_�溶�R���S��I��`��?֩�Z�T^]1��VsU#f���i��1�Ivh!9+�VZ�Mr�טP�~|"/���IK
g`��MK�����|CҴ�ZQs���fvƄ0e�NN�F-���FNG)��W�2�JN	��������ܕ����2
�~�y#cB���1�YϮ�h�9����m������v��`g����]1�)�F�^^]Rץ�f��Tk� s�SP�7L�_Y�x�ŤiC�X]��r�>e:	{Sm�ĒT��ubN����k�Yb�;��Eߝ�m�Us�q��1�(\�����Ӈ�b(�7�"�Yme�WY!-)�L���L�6ie��@�Z3D\?��\W�c"e���4��AǘH���L�`L�M��G$𩫅�W���FY�gL$NI�'������I]�r��ܜ��`W<ߛe6ߛ�I>v���W�!a��������M3���IV��]�yhBҴFlr�!8Մ�^Ҷ�㒸5����I#�I�ڦ���P2R���(�r�a߰z����G~����w�=C�2������C��{�hWl%��и���O������;0*��`��U��R��vw�� (7�T#�Ƨ�o7�
�xk͍\dq3a��	x p�ȥ�3>Wc�� �	��7�kI��9F}�ID
�B���
��v<�vjQ�:a�J�5L&�F�{l��Rh����I��F�鳁P�Nc�w:17��f}u}�Κu@��`� @�������8@`�
�1 ��j#`[�)�8`���vh�p� P���׷�>����"@<�����sv� ����"�Q@,�A��P8��dp{�B��r��X��3��n$�^ ��������^B9��n����0T�m�2�ka9!�2!���]
?p ZA$\S��~B�O ��;��-|��
{�V��:���o��D��D0\R��k����8��!�I�-���-<��/<JhN��W�1���(�#2:E(*�H���{��>��&!��$| �~�+\#��8�> �H??�	E#��VY���t7���> 6�"�&ZJ��p�C_j����	P:�~�G0 �J��$�M���@�Q��Yz��i��~q�1?�c��Bߝϟ�n�*������8j������p���ox���"w���r�yvz U\F8��<E��xz�i���qi����ȴ�ݷ-r`\�6����Y��q^�Lx�9���#���m����-F�F.-�a�;6��lE�Q��)�P�x�:-�_E�4~v��Z�����䷳�:�n��,㛵��m�=wz�Ξ;2-��[k~v��Ӹ_G�%*�i� ����{�%;����m��g�ez.3���{�����Kv���s �fZ!:� 4W��޵D��U��
(t}�]5�ݫ߉�~|z��أ�#%���ѝ܏x�D4�4^_�1�g���<��!����t�oV�lm�s(EK͕��K�����n���Ӌ���&�̝M�&rs�0��q��Z��GUo�]'G�X�E����;����=Ɲ�f��_0�ߝfw�!E����A[;���ڕ�^�W"���s5֚?�=�+9@��j������b���VZ^�ltp��f+����Z�6��j�`�L��Za�I��N�0W���Z����:g��WWjs�#�Y��"�k5m�_���sh\���F%p䬵�6������\h2lNs�V��#�t�� }�K���Kvzs�>9>�l�+�>��^�n����~Ěg���e~%�w6ɓ������y��h�DC���b�KG-�d��__'0�{�7����&��yFD�2j~�����ټ�_��0�#��y�9��P�?���������f�fj6͙��r�V�K�{[ͮ�;4)O/��az{�<><__����G����[�0���v��G?e��������:���١I���z�M�Wۋ�x���������u�/��]1=��s��E&�q�l�-P3�{�vI�}��f��}�~��r�r�k�8�{���υ����O�֌ӹ�/�>�}�t	��|���Úq&���ݟW����ᓟwk�9���c̊l��Ui�̸z��f��i���_�j�S-|��w�J�<LծT��-9�����I�®�6 *3��y�[�.Ԗ�K��J���<�ݿ��-t�J���E�63���1R��}Ғbꨝט�l?�#���ӴQ��.�S���U
v�&�3�&O���0�9-�O�kK��V_gn��k��U_k˂�4�9�v�I�:;�w&��Q�ҍ�
��fG��B��-����ÇpNk�sZM�s���*��g8��-���V`b����H���
3cU'0hR
�w�XŁ�K݊�MV]�} o�w�tJJ���$꜁x$��l$>�F�EF�޺�G�j�#�G�t�bjj�F�б��q:�`O�4�y�8`Av<�x`��&I[��'A�˚�5��KAn��jx ��=Kn@��t����)�9��=�ݷ�tI��d\�M�j�B�${��G����VX�V6��f�#��V�wk ��W�8�	����lCDZ���ϖ@���X��x�W�Utq�ii�D($�X��Z'8Ay@�s�<�x͡�PU"rB�Q�_�Q6  ��[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://cylx1tadrrofy"
path="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"
metadata={
"vram_texture": false
}
 �]2J��,b��=���extends RefCounted
class_name Leerling

# ==============================================================================
var choices: PackedStringArray = []

var klas := ""
var voornaam := ""
var achternaam := ""
# ==============================================================================

func _init(_choices: PackedStringArray = [], _klas: String = "", _voornaam: String = "", _achternaam: String = "") -> void:
	choices = _choices
	klas = _klas
	voornaam = _voornaam
	achternaam = _achternaam


func _to_string() -> String:
	var json := {}
	
	for property in get_script().get_script_property_list():
		if not property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			continue
		
		json[property.name] = get(property.name)
	
	return JSON.stringify(json)
�~���y!K���extends PopupPanel

# ==============================================================================
var is_linked := false
# ==============================================================================
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var message_label: Label = %MessageLabel
@onready var progress_bar_secondary: ProgressBar = %ProgressBar2
@onready var message_label_secondary: Label = %MessageLabel2

@onready var default_link_settings := LinkSettings.new(progress_bar, message_label, progress_bar_secondary, message_label_secondary)
# ==============================================================================
signal finished()
# ==============================================================================

func _ready() -> void:
	hide()
	
	popup_window = false


func start(step_count: int, start_message: String, step_count_secondary: int = 0, secondary_message: String = "", link_settings: LinkSettings = null) -> void:
	(func():
		if link_settings:
			set_link(link_settings)
		else:
			remove_link()
		
		progress_bar.show()
		progress_bar.value = 0
		
		set_step_count(step_count, true)
		
		if message_label:
			message_label.show()
			set_message(start_message)
		
		if not is_linked:
			popup_centered.call_deferred()
		
		if not progress_bar_secondary:
			return
		
		if step_count_secondary <= 0:
			progress_bar_secondary.hide()
			if message_label_secondary:
				message_label_secondary.hide()
			return
		
		progress_bar_secondary.show()
		progress_bar_secondary.value = 0
		set_step_count_secondary(step_count_secondary, true)
		
		if not message_label_secondary:
			return
		
		if secondary_message.is_empty():
			message_label_secondary.hide()
			return
		
		message_label_secondary.show()
		set_message_secondary(secondary_message)
	).call_deferred()


func set_message(message: String) -> void:
	message_label.set_deferred("text", message)


func set_message_secondary(message: String) -> void:
	message_label_secondary.set_deferred("text", message)


func set_step_count(step_count: int, reset_value: bool = false) -> void:
	progress_bar.set_deferred("max_value", step_count)
	if reset_value:
		progress_bar.set_deferred("value", 0)


func set_step_count_secondary(step_count: int, reset_value: bool = false) -> void:
	progress_bar_secondary.set_deferred("max_value", step_count)
	if reset_value:
		progress_bar_secondary.set_deferred("value", 0)


func progress_increment() -> void:
	(func():
		progress_bar.value += 1
		if progress_bar.value >= progress_bar.max_value:
			progress_finish()
	).call_deferred()


func progress_increment_secondary() -> void:
	(func():
		progress_bar_secondary.value += 1
		if progress_bar_secondary.value >= progress_bar_secondary.max_value:
			progress_finish_secondary()
	).call_deferred()


func progress_set(step: int) -> void:
	(func():
		progress_bar.value = step
		if step >= progress_bar.max_value:
			progress_finish()
	).call_deferred()


func progress_set_secondary(step: int) -> void:
	(func():
		progress_bar_secondary.value = step
		if progress_bar_secondary.value >= progress_bar_secondary.max_value:
			progress_finish_secondary()
	).call_deferred()


func progress_finish() -> void:
	progress_cancel()
	
	(func(): finished.emit()).call_deferred()


func progress_cancel() -> void:
	if is_linked:
		if progress_bar:
			progress_bar.hide.call_deferred()
		if message_label:
			message_label.hide.call_deferred()
		if progress_bar_secondary:
			progress_bar_secondary.hide.call_deferred()
		if message_label_secondary:
			message_label_secondary.hide.call_deferred()
	else:
		hide.call_deferred()


func progress_finish_secondary() -> void:
	pass


func set_link(link_settings: LinkSettings) -> void:
	is_linked = true
	
	progress_bar = link_settings.progress_bar
	message_label = link_settings.message_label
	progress_bar_secondary = link_settings.progress_bar_secondary
	message_label_secondary = link_settings.message_label_secondary


func remove_link() -> void:
	set_link(default_link_settings)
	is_linked = false


class LinkSettings extends RefCounted:
	var progress_bar: ProgressBar
	var message_label: Label
	var progress_bar_secondary: ProgressBar
	var message_label_secondary: Label
	
	func _init(_progress_bar: ProgressBar = null, _message_label: Label = null, _progress_bar_secondary: ProgressBar = null, _message_label_secondary: Label = null) -> void:
		if _progress_bar:
			progress_bar = _progress_bar
		if _message_label:
			message_label = _message_label
		if _progress_bar_secondary:
			progress_bar_secondary = _progress_bar_secondary
		if _message_label_secondary:
			message_label_secondary = _message_label_secondary
	
	
	func with_progress_bar(_progress_bar: ProgressBar) -> LinkSettings:
		progress_bar = _progress_bar
		return self
	
	
	func with_message_label(_message_label: Label) -> LinkSettings:
		message_label = _message_label
		return self
	
	
	func with_progress_bar_secondary(_progress_bar_secondary: ProgressBar) -> LinkSettings:
		progress_bar_secondary = _progress_bar_secondary
		return self
	
	
	func with_message_label_secondary(_message_label_secondary: Label) -> LinkSettings:
		message_label_secondary = _message_label_secondary
		return self
uRSRC                     PackedScene            ��������                                                  resource_local_to_scene    resource_name    line_spacing    font 
   font_size    font_color    outline_size    outline_color    shadow_size    shadow_color    shadow_offset    script 	   _bundled       Script    res://LoadingScreen.gd ��������      local://LabelSettings_kw8wo �         local://PackedScene_44h53 �         LabelSettings          ��0?��0?��0?  �?         PackedScene          	         names "         LoadingScreen    size    visible    always_on_top    script    PopupPanel    VBoxContainer    offset_left    offset_top    offset_right    offset_bottom    Label    layout_mode    text    ProgressBar    unique_name_in_owner    custom_minimum_size    value    MessageLabel    label_settings    ProgressBar2    MessageLabel2    	   variants       -     d                        �@     �C     �B         	   Laden... 
     �C         �A      Initializing...                        node_count             nodes     i   ��������       ����                                              ����               	      
                       ����                                ����                        	                    ����                  
                          ����                              	                    ����                        
                   conn_count              conns               node_paths              editable_instances              version             RSRC��extends Control
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
����RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name    line_spacing    font 
   font_size    font_color    outline_size    outline_color    shadow_size    shadow_color    shadow_offset    script 	   _bundled       Script    res://Main.gd ��������   Script    res://Dijkstra.gd ��������      local://LabelSettings_c1tco [         local://LabelSettings_4eklh �         local://LabelSettings_3f4hf �         local://LabelSettings_v5xlb �         local://PackedScene_5s0j7          LabelSettings                      LabelSettings                   ��0?��0?��0?  �?         LabelSettings                      LabelSettings                      PackedScene          	         names "   M      Main    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    script    STATUS_NOTHING_IMPORTED    STATUS_IMPORTING    STATUS_IMPORTED    STATUS_GENERATING    STATUS_GENERATED    Control    HSplitContainer    PanelContainer    size_flags_horizontal    VBoxContainer    size_flags_vertical $   theme_override_constants/separation    StatusLabel    unique_name_in_owner    text    label_settings    horizontal_alignment    vertical_alignment    autowrap_mode    Label    ProgressBarPrimary    visible    custom_minimum_size $   theme_override_font_sizes/font_size    ProgressBar    ProgressLabel    ProgressBarSecondary    CancelButton    Button    PanelContainer2    ScrollContainer    horizontal_scroll_mode    MarginContainer %   theme_override_constants/margin_left $   theme_override_constants/margin_top &   theme_override_constants/margin_right '   theme_override_constants/margin_bottom    SideVBoxContainer    ClipboardButton    FileButton    HSeparator    CapaciteitLabel    HSeparator2    GenereerButton 	   Dijkstra    max_points    Node    FileDialog    title    initial_position    size    ok_button_text 
   file_mode    access    filters    AlertDialog    unresizable    dialog_text    dialog_autowrap    AcceptDialog    _on_indelingen_gegenereerd    indelingen_gegenereerd    _on_cancel_button_pressed    pressed    _on_clipboard_button_pressed    show    _on_genereer_button_pressed    _load_from_file    file_selected    	   variants    *                    �?                   b   Er zijn geen keuzes geïmporteerd.
Gebruik de knoppen aan de rechterkant om keuzes te importeren.       Keuzes worden geïmporteerd.    �   Keuzes van %d leerlingen geladen voor %d periodes.

De capaciteiten kunnen aan de rechterkant worden aangegeven.
Daaronder kunnen de indelingen worden gegenereerd met de knop 'Genereer Indelingen'.    e   De indeling wordt gegenereerd. Zodra deze klaar is, wordt een Excel-bestand geopend met de indeling.    �   De indeling is gegenereerd. Deze is opgeslagen in het Excel-bestand dat net is geopend.

Als deze indeling niet goed is, kan er een nieuwe gegenereerd worden.
Hiervoor moet eerst het Excel-bestand gesloten worden.                             
      3   Keuzes van %d leerlingen geladen voor %d periodes.                  
      D                Sample Text...                   
   Annuleren                    Importeer Keuzes                Van Klembord...       Van Bestand...       Capaciteit modules                Genereer Indelingen             ���       Open a File -      �        Open "         *.xlsx    *.csv       Let op! -   g  �      {   Kan indeling.csv niet openen. Waarschijnlijk is dit bestand al geopend in Excel. Sluit het bestand en probeer het opnieuw.       node_count             nodes     �  ��������       ����                                                    	      
               	                     ����      
                                                  ����                                 ����                                      ����                                    
      
                          ����                                 ����                                                           !   ����                                    
      
                  "   ����                                                        $   #   ����                                                     %   ����             
       &   &   ����         '                 (   (   ����                       )      *      +      ,                    -   ����                                ����                        
      
              $   .   ����                                $   /   ����                                0   0   ����                       1   ����                                    
      
              0   2   ����                          $   3   ����                                              6   4   ����            !   5   "               7   7   ����         8   #   9      :   $   ;   %   <      =      >   &               C   ?   ����         8   '   9      :   (   @      A   )   B                conn_count             conns     *           E   D              	       G   F                     G   H                    G   I                     G   J                     L   K                    node_paths              editable_instances              version             RSRCylTLr@tool
extends HBoxContainer
class_name ModuleCapaciteitEnter

# ==============================================================================
@export_placeholder("Naam Module") var naam := "" :
	set(value):
		naam = value
		if label:
			if value.is_empty():
				label.text = "Module #: "
			else:
				label.text = naam + ": "
@export var aantal := -1 :
	set(value):
		aantal = value
		if line_edit:
			if aantal < 0:
				line_edit.clear()
			else:
				line_edit.text = str(value)
	get:
		if not line_edit:
			return aantal
		if line_edit.text.is_empty():
			return 10 ** 3
		return line_edit.text.to_int()
# ==============================================================================
@onready var label: Label = %Label
@onready var line_edit: LineEdit = %LineEdit
# ==============================================================================

func _ready() -> void:
	if not naam.is_empty():
		label.text = naam + ": "
	if aantal >= 0:
		line_edit.text = str(aantal)
��?RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://ModuleCapaciteitEnter.gd ��������      local://PackedScene_s0s84          PackedScene          	         names "         ModuleCapaciteitEnter    offset_right    offset_bottom    size_flags_horizontal    script    aantal    HBoxContainer    Label    unique_name_in_owner    layout_mode    text 	   LineEdit    select_all_on_focus    	   variants    	        C     �A                                         Module #:        0       node_count             nodes     1   ��������       ����                                                    ����         	            
                        ����         	            
                      conn_count              conns               node_paths              editable_instances              version             RSRC�_&h5�djextends RefCounted
class_name Table

## A 2-dimensional version of [Array].

# ==============================================================================
var _table: Array[Array] = []
# ==============================================================================

func _init(table: Array = []) -> void:
	assign(table)


func set_width(w: int) -> void:
	if w == width():
		return
	
	if w < width():
		for row in rows():
			row.resize(w)
		return
	if w > width():
		for row in rows():
			while row.size() < w:
				row.append(null)
		return


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


## Appends 1 row to the end of the table.
func append_row(row: Array, resize: bool = false) -> void:
	if row.size() != width() and not resize:
		return
	if resize:
		set_width(row.size())
	
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
��S�ُj�@tool
extends MarginContainer
class_name TableItem

# ==============================================================================
const SCENE := preload("res://TableItem.tscn")
# ==============================================================================
@export var text := "" :
	set(value):
		text = value
		if label:
			label.text = value
@export_enum("Left", "Center", "Right", "Fill") var alignment := 1 :
	set(value):
		alignment = value
		if label:
			label.horizontal_alignment = value as HorizontalAlignment
# ==============================================================================
@onready var label: Label = %Label
# ==============================================================================

func _ready() -> void:
	label.text = text
	label.horizontal_alignment = alignment as HorizontalAlignment


static func instantiate() -> TableItem:
	return SCENE.instantiate()
RSRC                     PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://TableItem.gd ��������      local://PackedScene_612k2 
         PackedScene          	         names "      
   TableItem    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    size_flags_horizontal    size_flags_vertical    script    MarginContainer    ReferenceRect    layout_mode    border_color    editor_only    Label    unique_name_in_owner    horizontal_alignment    	   variants            �?                         �� ?�� ?�� ?  �?                         node_count             nodes     /   ��������       ����                                                           	   	   ����   
                                    ����         
                      conn_count              conns               node_paths              editable_instances              version             RSRC[remap]

path="res://.godot/exported/133200997/export-f35a01a76a1504d4d82bb4e0d87dd93d-LoadingScreen.scn"
�����.[remap]

path="res://.godot/exported/133200997/export-bcb0d2eb5949c52b6a65bfe9de3e985b-Main.scn"
v/}�2dD������[remap]

path="res://.godot/exported/133200997/export-9f4f8fea5b3f38b4678c563ed7bbc8dc-ModuleCapaciteitEnter.scn"
����V.7��&\&�^[remap]

path="res://.godot/exported/133200997/export-524a625e5856f3e7f4ea7d6baa2a04b6-TableItem.scn"

��p*���list=Array[Dictionary]([{
"base": &"Thread",
"class": &"AutoThread",
"icon": "",
"language": &"GDScript",
"path": "res://addons/AutoThread/AutoThread.gd"
}, {
"base": &"TreeDijkstra",
"class": &"Dijkstra",
"icon": "",
"language": &"GDScript",
"path": "res://Dijkstra.gd"
}, {
"base": &"RefCounted",
"class": &"ExcelSheet",
"icon": "",
"language": &"GDScript",
"path": "res://addons/excelreader/ExcelSheet.gd"
}, {
"base": &"RefCounted",
"class": &"Leerling",
"icon": "",
"language": &"GDScript",
"path": "res://Leerling.gd"
}, {
"base": &"Control",
"class": &"Main",
"icon": "",
"language": &"GDScript",
"path": "res://Main.gd"
}, {
"base": &"HBoxContainer",
"class": &"ModuleCapaciteitEnter",
"icon": "",
"language": &"GDScript",
"path": "res://ModuleCapaciteitEnter.gd"
}, {
"base": &"RefCounted",
"class": &"RequestBlocker",
"icon": "",
"language": &"GDScript",
"path": "res://addons/AutoThread/RequestBlocker.gd"
}, {
"base": &"RefCounted",
"class": &"RoosterMaker",
"icon": "",
"language": &"GDScript",
"path": "res://RoosterMaker.gd"
}, {
"base": &"RefCounted",
"class": &"Table",
"icon": "",
"language": &"GDScript",
"path": "res://Table.gd"
}, {
"base": &"MarginContainer",
"class": &"TableItem",
"icon": "",
"language": &"GDScript",
"path": "res://TableItem.gd"
}, {
"base": &"Node",
"class": &"TreeDijkstra",
"icon": "",
"language": &"GDScript",
"path": "res://addons/dijkstra/TreeDijkstra.gd"
}, {
"base": &"RefCounted",
"class": &"TreeDijkstraPoint",
"icon": "",
"language": &"GDScript",
"path": "res://addons/dijkstra/TreeDijkstraPoint.gd"
}])
���D�B)u%<svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><g transform="translate(32 32)"><path d="m-16-32c-8.86 0-16 7.13-16 15.99v95.98c0 8.86 7.13 15.99 16 15.99h96c8.86 0 16-7.13 16-15.99v-95.98c0-8.85-7.14-15.99-16-15.99z" fill="#363d52"/><path d="m-16-32c-8.86 0-16 7.13-16 15.99v95.98c0 8.86 7.13 15.99 16 15.99h96c8.86 0 16-7.13 16-15.99v-95.98c0-8.85-7.14-15.99-16-15.99zm0 4h96c6.64 0 12 5.35 12 11.99v95.98c0 6.64-5.35 11.99-12 11.99h-96c-6.64 0-12-5.35-12-11.99v-95.98c0-6.64 5.36-11.99 12-11.99z" fill-opacity=".4"/></g><g stroke-width="9.92746" transform="matrix(.10073078 0 0 .10073078 12.425923 2.256365)"><path d="m0 0s-.325 1.994-.515 1.976l-36.182-3.491c-2.879-.278-5.115-2.574-5.317-5.459l-.994-14.247-27.992-1.997-1.904 12.912c-.424 2.872-2.932 5.037-5.835 5.037h-38.188c-2.902 0-5.41-2.165-5.834-5.037l-1.905-12.912-27.992 1.997-.994 14.247c-.202 2.886-2.438 5.182-5.317 5.46l-36.2 3.49c-.187.018-.324-1.978-.511-1.978l-.049-7.83 30.658-4.944 1.004-14.374c.203-2.91 2.551-5.263 5.463-5.472l38.551-2.75c.146-.01.29-.016.434-.016 2.897 0 5.401 2.166 5.825 5.038l1.959 13.286h28.005l1.959-13.286c.423-2.871 2.93-5.037 5.831-5.037.142 0 .284.005.423.015l38.556 2.75c2.911.209 5.26 2.562 5.463 5.472l1.003 14.374 30.645 4.966z" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 919.24059 771.67186)"/><path d="m0 0v-47.514-6.035-5.492c.108-.001.216-.005.323-.015l36.196-3.49c1.896-.183 3.382-1.709 3.514-3.609l1.116-15.978 31.574-2.253 2.175 14.747c.282 1.912 1.922 3.329 3.856 3.329h38.188c1.933 0 3.573-1.417 3.855-3.329l2.175-14.747 31.575 2.253 1.115 15.978c.133 1.9 1.618 3.425 3.514 3.609l36.182 3.49c.107.01.214.014.322.015v4.711l.015.005v54.325c5.09692 6.4164715 9.92323 13.494208 13.621 19.449-5.651 9.62-12.575 18.217-19.976 26.182-6.864-3.455-13.531-7.369-19.828-11.534-3.151 3.132-6.7 5.694-10.186 8.372-3.425 2.751-7.285 4.768-10.946 7.118 1.09 8.117 1.629 16.108 1.846 24.448-9.446 4.754-19.519 7.906-29.708 10.17-4.068-6.837-7.788-14.241-11.028-21.479-3.842.642-7.702.88-11.567.926v.006c-.027 0-.052-.006-.075-.006-.024 0-.049.006-.073.006v-.006c-3.872-.046-7.729-.284-11.572-.926-3.238 7.238-6.956 14.642-11.03 21.479-10.184-2.264-20.258-5.416-29.703-10.17.216-8.34.755-16.331 1.848-24.448-3.668-2.35-7.523-4.367-10.949-7.118-3.481-2.678-7.036-5.24-10.188-8.372-6.297 4.165-12.962 8.079-19.828 11.534-7.401-7.965-14.321-16.562-19.974-26.182 4.4426579-6.973692 9.2079702-13.9828876 13.621-19.449z" fill="#478cbf" transform="matrix(4.162611 0 0 -4.162611 104.69892 525.90697)"/><path d="m0 0-1.121-16.063c-.135-1.936-1.675-3.477-3.611-3.616l-38.555-2.751c-.094-.007-.188-.01-.281-.01-1.916 0-3.569 1.406-3.852 3.33l-2.211 14.994h-31.459l-2.211-14.994c-.297-2.018-2.101-3.469-4.133-3.32l-38.555 2.751c-1.936.139-3.476 1.68-3.611 3.616l-1.121 16.063-32.547 3.138c.015-3.498.06-7.33.06-8.093 0-34.374 43.605-50.896 97.781-51.086h.066.067c54.176.19 97.766 16.712 97.766 51.086 0 .777.047 4.593.063 8.093z" fill="#478cbf" transform="matrix(4.162611 0 0 -4.162611 784.07144 817.24284)"/><path d="m0 0c0-12.052-9.765-21.815-21.813-21.815-12.042 0-21.81 9.763-21.81 21.815 0 12.044 9.768 21.802 21.81 21.802 12.048 0 21.813-9.758 21.813-21.802" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 389.21484 625.67104)"/><path d="m0 0c0-7.994-6.479-14.473-14.479-14.473-7.996 0-14.479 6.479-14.479 14.473s6.483 14.479 14.479 14.479c8 0 14.479-6.485 14.479-14.479" fill="#414042" transform="matrix(4.162611 0 0 -4.162611 367.36686 631.05679)"/><path d="m0 0c-3.878 0-7.021 2.858-7.021 6.381v20.081c0 3.52 3.143 6.381 7.021 6.381s7.028-2.861 7.028-6.381v-20.081c0-3.523-3.15-6.381-7.028-6.381" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 511.99336 724.73954)"/><path d="m0 0c0-12.052 9.765-21.815 21.815-21.815 12.041 0 21.808 9.763 21.808 21.815 0 12.044-9.767 21.802-21.808 21.802-12.05 0-21.815-9.758-21.815-21.802" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 634.78706 625.67104)"/><path d="m0 0c0-7.994 6.477-14.473 14.471-14.473 8.002 0 14.479 6.479 14.479 14.473s-6.477 14.479-14.479 14.479c-7.994 0-14.471-6.485-14.471-14.479" fill="#414042" transform="matrix(4.162611 0 0 -4.162611 656.64056 631.05679)"/></g></svg>
W-   �Z�)F�Y   res://icon.svg]��ӓ�N   res://LoadingScreen.tscng�8�.4)*   res://Main.tscn��|��(sM    res://ModuleCapaciteitEnter.tscn	F�����7   res://TableItem.tscn���f.TFECFG      application/config/name         Sportmodules   application/run/main_scene         res://Main.tscn    application/config/features$   "         4.1    Forward Plus       application/config/icon         res://icon.svg     autoload/LoadingScreen$         *res://LoadingScreen.tscn      editor_plugins/enabled�   "      #   res://addons/AutoThread/plugin.cfg  !   res://addons/dijkstra/plugin.cfg    $   res://addons/excelreader/plugin.cfg !   filesystem/import/blender/enabled          ������3�m