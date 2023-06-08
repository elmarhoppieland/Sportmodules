extends RefCounted
class_name RoosterMaker

# ==============================================================================

static func get_student_array(leerlingen: Array[Leerling], modules: PackedStringArray) -> Array[Student]:
	var students: Array[Student] = []
	
	for leerling in leerlingen:
		var keuzes: PackedInt32Array = []
		
		for choice in leerling.choices:
			keuzes.append(modules.find(choice))
		
		students.append(Student.new(keuzes))
	
	return students


static func dijkstra(leerlingen: Array[Student], module_caps: PackedInt32Array) -> Array[Module]:
	var vertexes: Array[Vertex] = [Vertex.new()]
	
	while true:
		var vertex_idx := -1
		for i in vertexes.size():
			var vertex := vertexes[i]
			if vertex_idx < 0 or (vertex.score >= 0 and vertex.score < vertexes[vertex_idx].score):
				vertex_idx = i
		
		var vertex := vertexes[vertex_idx]
		if leerlingen.size() <= vertex.steps.size():
			# terminate algorithm
			var indeling: Array[Module] = []
			for i in module_caps.size():
				indeling.append(Module.new())
			for i in leerlingen.size():
				var leerling := leerlingen[i]
				var step := vertex.steps[i]
				indeling[step].append(leerling)
			return indeling
		
		var leerling := leerlingen[vertex.steps.size()]
		
		for module_idx in module_caps.size():
			if vertex.steps.count(module_idx) >= module_caps[module_idx]:
				continue
			
			var steps := vertex.steps.duplicate()
			var score := vertex.score + get_score(leerling.keuzes.find(module_idx) if module_idx in leerling.keuzes else module_caps.size() - 1)
			
			steps.append(module_idx)
			
			vertexes.append(Vertex.new(steps, score))
		
		vertexes.remove_at(vertex_idx)
	
	push_error("Dijkstra failed to terminate. Returning an empty array.")
	return []


static func get_score(keuze_idx: int) -> int:
	return keuze_idx ** 2


class Vertex extends RefCounted:
	var steps: PackedInt32Array = []
	var score := -1
	
	func _init(_steps: PackedInt32Array = [], _score: int = -1) -> void:
		steps = _steps
		score = _score


class Student extends RefCounted:
	var keuzes: PackedInt32Array = []
	
	func _init(_keuzes: PackedInt32Array = []) -> void:
		keuzes = _keuzes


class Module extends RefCounted:
	var leerlingen: Array[Student] = []
	
	func _init(_leerlingen: Array[Student] = []) -> void:
		leerlingen = _leerlingen
	
	
	func append(leerling: Student) -> void:
		leerlingen.append(leerling)
	
	
	func size() -> int:
		return leerlingen.size()
