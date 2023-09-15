extends PopupPanel

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
