extends RefCounted
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
