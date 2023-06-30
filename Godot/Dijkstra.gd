extends TreeDijkstra
class_name Dijkstra

# ==============================================================================
var students: Array[Student] = []
var module_caps: PackedInt32Array = []
# ==============================================================================

func run_algorithm(_students: Array[Student], _module_caps: PackedInt32Array) -> Indeling:
	if _students.is_empty() or _module_caps.is_empty():
		push_error("Not all data is filled. Aborting Dijkstra algorithm...")
		return null
	
	students = _students
	module_caps = _module_caps
	
	root.set_meta("student", -1)
	
	var empty_module_sizes: PackedInt32Array = []
	empty_module_sizes.resize(module_caps.size())
	root.set_meta("module_sizes", empty_module_sizes)
	
	var r := run()
	
	var indeling := Indeling.new()
	for i in module_caps.size():
		indeling.modules.append(Module.new())
	
	for point in r:
		if point == root:
			continue
		
		var student_idx: int = point.get_meta("student")
		if student_idx < students.size():
			indeling.modules[point.get_meta("module")].append(students[student_idx])
	
	return indeling


func _create_new_points(origin: TreeDijkstraPoint) -> void:
	if origin.is_disabled():
		push_error("Attempted to create new points from a disabled origin.")
		return
	if origin.get_child_count():
		push_error("Attempted to create new points from a used origin.")
		return
	
	for module_idx in module_caps.size():
		if origin.get_meta("module_sizes")[module_idx] >= module_caps[module_idx]:
			continue
		
		var point := TreeDijkstraPoint.new()
		var student_idx: int = origin.get_meta("student") + 1
		var student := students[student_idx]
		
		point.score = student.get_score(module_idx, module_caps.size() - 1)
		
		point.set_meta("student", student_idx)
		
		point.set_meta("module_sizes", origin.get_meta("module_sizes").duplicate())
		point.get_meta("module_sizes")[module_idx] += 1
		
		point.set_meta("module", module_idx)
		
		add_point(point, origin)


func _check_terminate(best_point: TreeDijkstraPoint) -> bool:
	return best_point.get_meta("student") + 1 >= students.size()


static func get_student_array(leerlingen: Array[Leerling], modules: PackedStringArray) -> Array[Student]:
	@warning_ignore("shadowed_variable")
	var students: Array[Student] = []
	
	for leerling in leerlingen:
		var keuzes: PackedInt32Array = []
		
		for choice in leerling.choices:
			keuzes.append(modules.find(choice))
		
		if keuzes.is_empty():
			continue
		
		students.append(Student.new(keuzes, leerling.klas, leerling.voornaam, leerling.achternaam))
	
	return students


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
