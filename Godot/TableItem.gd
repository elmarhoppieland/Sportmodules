@tool
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
