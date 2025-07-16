@tool
extends HBoxContainer

func _ready() -> void:
	$Logo.texture = get_theme_icon("Object", "EditorIcons")

func set_title(title: String) -> void:
	$Title.text = title

func get_title() -> String:
	return $Title.text

func set_pck_path(path: String) -> void:
	$Path.text = path

func get_pck_path() -> String:
	return $Path.text

func set_error(err: bool) -> void:
	if err:
		$Logo.texture = get_theme_icon("NodeWarning", "EditorIcons")
	else:
		$Logo.texture = get_theme_icon("Object", "EditorIcons")
