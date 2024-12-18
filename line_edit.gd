extends LineEdit

var partial_regex = {
	all_number = r'^\d*$',
	number_unit = r'^\d+[mhs]$',
	formatted_time_typing = r'^(\d{1,2}:){1,2}\d{0,2}$',
	formatted_time = r"^\d{1,2}(:\d{1,2}){1,2}$"
}

var full_regex = {
	time_typing = "(" \
	 + partial_regex.all_number + "|" \
	 + partial_regex.number_unit + "|" \
	 + partial_regex.formatted_time_typing \
	 + ")",
	time = "(" + partial_regex.formatted_time + "|" + partial_regex.number_unit + ")"
}

var animation_info = {
	styleboxes = [
		self.get_theme_stylebox("focus"),
		self.get_theme_stylebox("normal"),
	],
	default_border_colors = [],
	new_border_colors = {
		invalid = [
			Color(255, 0, 0, 0.7),
			Color(255, 0, 0, 0.4)
		],
		valid = [
			Color(0, 255, 0, 0.7),
			Color(0, 255, 0, 0.4)
		],
	},
	duration = 0.3,
}

var time_typing_regex := RegEx.create_from_string(full_regex.time_typing)
var time_regex := RegEx.create_from_string(full_regex.time)

var previous_text := ""
var OUTPUT_TIME_PATH := "res://time.txt"

enum SubmissionAnimationType {INVALID, VALID}

func map_submission_animation_type_to_string(type: SubmissionAnimationType):
	match type:
		SubmissionAnimationType.INVALID: return "invalid" 
		SubmissionAnimationType.VALID: return "valid" 
		_:
			push_error("SubmissionAnimationType should either be INVALID or VALID")
	
#
func _on_text_changed(new_text: String) -> void:
	var character_erasaed := new_text.length() < previous_text.length()
	if character_erasaed:
		previous_text = new_text
		return
	var regex_match := time_typing_regex.search(new_text)
	if regex_match == null:
		print("no match")
		self.delete_char_at_caret()
	previous_text = new_text

func format_submission(submission: String) -> String:
	var semicolon_regex := RegEx.create_from_string(partial_regex.formatted_time)
	var is_semincolon_format := semicolon_regex.search(submission) != null
	if not is_semincolon_format:
		return submission
	var formatted_submission = ""
	var numbers := submission.split(":")
	for number in numbers:
		formatted_submission += "%02d" % int(number) + ":"
	formatted_submission = formatted_submission.left(-1)
	return formatted_submission
		
	

func _on_text_submitted(entry_text: String) -> void:
	var invalid_time = time_regex.search(entry_text) == null
	if invalid_time:
		submission_animation("Invalid Time", SubmissionAnimationType.INVALID)
		return
	var file_of_time = FileAccess.open(OUTPUT_TIME_PATH, FileAccess.WRITE)
	if file_of_time == null:
		push_warning(error_string(FileAccess.get_open_error()))
		return
	
	file_of_time.store_string(format_submission(entry_text))
	submission_animation("Timer set", SubmissionAnimationType.VALID)
	
func submission_animation(placeholder: String, type: SubmissionAnimationType):
	var tween := get_tree().create_tween()
	var text_tween := get_tree().create_tween()

	self.text = ""
	self.placeholder_text = ""
	for letter in placeholder:
		text_tween.tween_callback(func(): self.placeholder_text += letter).set_delay(0.03)
	
	for i in animation_info.styleboxes.size():
		var stylebox: StyleBox = animation_info.styleboxes[i]
		var type_string: String = map_submission_animation_type_to_string(type)
		var new_border_color = animation_info.new_border_colors[type_string][i]
		tween.tween_property(
			stylebox,
			"border_color",
			new_border_color,
			animation_info.duration,
		)
		
	if type == SubmissionAnimationType.VALID:
		tween.tween_callback(func(): get_tree().quit()).set_delay(0.1)
		return
		
	for i in animation_info.styleboxes.size():
		var stylebox = animation_info.styleboxes[i]
		var default_border_color = animation_info.default_border_colors[i]
		tween.tween_property(
			stylebox,
			"border_color",
			default_border_color,
			animation_info.duration,
		)

func _ready() -> void:
	for stylebox in animation_info.styleboxes:
		animation_info.default_border_colors.append(stylebox.border_color)
	
