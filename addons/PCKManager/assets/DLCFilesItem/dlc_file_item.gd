@tool
extends HBoxContainer

func _ready() -> void:
	$Logo.texture = get_theme_icon("Object", "EditorIcons")

func set_title(title: String) -> void:
	$Title.text = title

func set_path(path: String) -> void:
	$Path.text = path
