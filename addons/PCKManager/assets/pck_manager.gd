@tool
extends Control

@onready var dlc_file_tree: Tree = %DLCFileTree


func _ready() -> void:
	dlc_file_tree.columns = 1
	dlc_file_tree.hide_root = false
	dlc_file_tree.allow_reselect = true
	
	var root = dlc_file_tree.create_item()
	#root.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	root.set_text(0, "res://")
	root.set_icon(0, get_theme_icon("Folder", "EditorIcons"))
	#root.set_checked(0, false)
	#root.set_editable(0, true)

	_populate_folders("res://", root)

func _populate_folders(path: String, parent: TreeItem, collapsed := false) -> void:
	var dir = DirAccess.open(path)
	if dir:
		for folder_name in dir.get_directories():
			if folder_name.begins_with("."):
				continue
			
			var full_path = path.path_join(folder_name)

			var item = dlc_file_tree.create_item(parent)
			item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
			item.set_text(0, folder_name)
			item.set_icon(0, get_theme_icon("Folder", "EditorIcons"))
			item.set_checked(0, false)
			item.set_editable(0, true)
			if folder_name == "addons" || collapsed:
				item.collapsed = true

			_populate_folders(full_path, item, folder_name == "addons")

func get_checked_folders() -> Array[String]:
	var result: Array[String] = []
	var root = dlc_file_tree.get_root()
	_collect_checked_folders(root, "res://", result)
	return result

func _collect_checked_folders(item: TreeItem, current_path: String, result: Array[String]) -> void:
	if item == null:
		return

	if item.get_cell_mode(0) == TreeItem.CELL_MODE_CHECK and item.is_checked(0):
		result.append(current_path)

	var child = item.get_first_child()
	while child:
		var sub_path = current_path.path_join(child.get_text(0))
		_collect_checked_folders(child, sub_path, result)
		child = child.get_next()


func _on_dlc_file_tree_item_edited() -> void:
	prints(get_checked_folders())
