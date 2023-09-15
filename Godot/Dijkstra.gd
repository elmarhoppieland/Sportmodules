extends TreeDijkstra
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
