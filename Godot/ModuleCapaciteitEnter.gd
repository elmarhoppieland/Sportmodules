@tool
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
# ==============================================================================
@onready var label: Label = %Label
@onready var line_edit: LineEdit = %LineEdit
# ==============================================================================

func _ready() -> void:
	if not naam.is_empty():
		label.text = naam + ": "
	if aantal >= 0:
		line_edit.text = str(aantal)
