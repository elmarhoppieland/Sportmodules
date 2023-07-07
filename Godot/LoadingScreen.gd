extends PopupPanel

# ==============================================================================
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var message_label: Label = %MessageLabel
@onready var progress_bar_secondary: ProgressBar = %ProgressBar2
@onready var message_label_secondary: Label = %MessageLabel2
# ==============================================================================
signal finished()
# ==============================================================================

func _ready() -> void:
	hide()
	
	popup_window = false


func start(step_count: int, start_message: String, step_count_secondary: int = 0, secondary_message: String = "") -> void:
	set_step_count(step_count, true)
	
	set_message(start_message)
	
	popup_centered.call_deferred()
	
	if step_count_secondary <= 0:
		progress_bar_secondary.hide()
		message_label_secondary.hide()
		return
	
	progress_bar_secondary.show()
	set_step_count_secondary(step_count_secondary, true)
	
	if secondary_message.is_empty():
		message_label_secondary.hide()
		return
	
	message_label_secondary.show()
	set_message_secondary(secondary_message)


func set_message(message: String) -> void:
	message_label.text = message


func set_message_secondary(message: String) -> void:
	message_label_secondary.text = message


func set_step_count(step_count: int, reset_value: bool = false) -> void:
	progress_bar.max_value = step_count
	if reset_value:
		progress_bar.value = 0


func set_step_count_secondary(step_count: int, reset_value: bool = false) -> void:
	progress_bar_secondary.max_value = step_count
	if reset_value:
		progress_bar_secondary.value = 0


func progress_increment() -> void:
	progress_bar.value += 1
	if progress_bar.value >= progress_bar.max_value:
		progress_finish()


func progress_increment_secondary() -> void:
	progress_bar_secondary.value += 1
	if progress_bar_secondary.value >= progress_bar_secondary.max_value:
		progress_finish_secondary()


func progress_set(step: int) -> void:
	progress_bar.value = step
	if progress_bar.value >= progress_bar.max_value:
		progress_finish()


func progress_set_secondary(step: int) -> void:
	progress_bar_secondary.value = step
	if progress_bar_secondary.value >= progress_bar_secondary.max_value:
		progress_finish_secondary()


func progress_finish() -> void:
	finished.emit()
	hide()


func progress_finish_secondary() -> void:
	pass
