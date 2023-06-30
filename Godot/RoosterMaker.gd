extends RefCounted
class_name RoosterMaker

# ==============================================================================

static func get_student_array(leerlingen: Array[Leerling], modules: PackedStringArray) -> Array[Student]:
	var students: Array[Student] = []
	
	for leerling in leerlingen:
		var keuzes: PackedInt32Array = []
		
		for choice in leerling.choices:
			keuzes.append(modules.find(choice))
		
		if keuzes.is_empty():
			continue
		
		students.append(Student.new(keuzes, leerling.klas, leerling.voornaam, leerling.achternaam))
	
	return students


static func dijkstra(leerlingen: Array[Student], module_caps: PackedInt32Array) -> Indeling:
	seed(0) # make sure shuffle() always returns does the same
	leerlingen.shuffle()
	
	var vertexes: Array[Vertex] = [Vertex.new()]
	
	while true:
		# find the vertex with the lowest score
		var vertex_idx := -1
		for i in vertexes.size():
			var vertex := vertexes[i]
			if vertex_idx < 0 or (vertex.score >= 0 and vertex.score < vertexes[vertex_idx].score):
				vertex_idx = i
		
		var vertex := vertexes[vertex_idx]
		
		if vertex.steps.size() >= leerlingen.size():
			return _terminate_algorithm(leerlingen, vertex, module_caps.size())
		
		# this is the student that should now be assigned a module
		var leerling := leerlingen[vertex.steps.size()]
		
		for module_idx in module_caps.size():
			if vertex.steps.count(module_idx) >= module_caps[module_idx]:
				# this module is full - do not add a vertex for it
				continue
			
			var steps := vertex.steps.duplicate()
			var score := vertex.score + leerling.get_score(module_idx, module_caps.size() - 1)
			
			steps.append(module_idx)
			
			vertexes.append(Vertex.new(steps, score))
		
		vertexes.remove_at(vertex_idx)
	
	push_error("Dijkstra failed to terminate. Returning null.")
	return null


static func _terminate_algorithm(leerlingen: Array[Student], vertex: Vertex, module_count: int) -> Indeling:
	var indeling := Indeling.new()
	for i in module_count:
		indeling.modules.append(Module.new())
	
	for i in leerlingen.size():
		var leerling := leerlingen[i]
		var step := vertex.steps[i]
		indeling.modules[step].append(leerling)
	
	for module in indeling.modules:
		module.leerlingen.sort_custom(func(a: Student, b: Student) -> bool:
			return a.achternaam < b.achternaam
		)
	
	return indeling


static func get_score(keuze_idx: int) -> int:
	return keuze_idx ** 2


class Vertex extends RefCounted:
	var steps: PackedInt32Array = []
	var score := -1
	
	func _init(_steps: PackedInt32Array = [], _score: int = 0) -> void:
		steps = _steps
		score = _score


class Student extends RefCounted:
	var keuzes: PackedInt32Array = []
	var klas := ""
	var voornaam := ""
	var achternaam := ""
	
	func _init(_keuzes: PackedInt32Array = [], _klas: String = "", _voornaam: String = "", _achternaam: String = "") -> void:
		keuzes = _keuzes
		klas = _klas
		voornaam = _voornaam
		achternaam = _achternaam
	
	
	func get_score(module_idx: int, fallback_idx: int) -> int:
		if module_idx in keuzes:
			return RoosterMaker.get_score(keuzes.find(module_idx))
		else:
			return RoosterMaker.get_score(fallback_idx)


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
