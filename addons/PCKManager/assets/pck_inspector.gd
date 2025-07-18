@tool
extends HBoxContainer

var folder_path := ""

func _setup_files() -> void:
	%PCKFiles.clear()
	var root = %PCKFiles.create_item()
	root.set_text(0, folder_path.get_file())
	root.set_icon(0, get_theme_icon("Folder", "EditorIcons"))
	root.set_selectable(0, false)
	
	_populate_tree(root, folder_path)

func _populate_tree(root: TreeItem, path) -> void:
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	var dir_name = dir.get_next()
	while dir_name != "":
		if dir.current_is_dir():
			var item = %PCKFiles.create_item(root)
			item.set_text(0, dir_name)
			item.set_icon(0, get_theme_icon("Folder", "EditorIcons"))
			item.set_selectable(0, false)
			_populate_tree(item, path + "/" + dir_name)
		elif dir_name.ends_with(".pck"):
			var item :TreeItem = %PCKFiles.create_item(root)
			item.set_text(0, dir_name)
			item.set_icon(0, get_theme_icon("Object", "EditorIcons"))
			item.collapsed = true
			item.set_selectable(0, false)
			_populate_pck_tree(item, path + "/" + dir_name)
		dir_name = dir.get_next()
	dir.list_dir_end()

func _populate_pck_tree(root: TreeItem, pck_path: String) -> void:
	var pck_dir = preload("res://addons/PCKManager/PCKDirAccess.gd").new()
	pck_dir.open(pck_path)
	var existing_items = {}  # To track existing nodes by path
	
	for full_path in pck_dir.get_paths():
		var parts = full_path.split("/")
		var current_parent = root
		var current_path = ""
		
		for part in parts:
			if part == "":
				continue
			current_path += "/" + part
			if not existing_items.has(current_path):
				var item :TreeItem = %PCKFiles.create_item(current_parent)
				item.set_text(0, part)
				item.set_metadata(0, [pck_path, current_path])
				item.collapsed = true
				existing_items[current_path] = item
				current_parent = item
			else:
				current_parent = existing_items[current_path]

func _on_open_folder_pressed() -> void:
	$FileDialog.popup_centered()

func _on_file_dialog_dir_selected(dir: String) -> void:
	folder_path = dir
	_setup_files()

func _on_pck_files_item_selected() -> void:
	var pck_dir = preload("res://addons/PCKManager/PCKDirAccess.gd").new()
	var is_file = %PCKFiles.get_selected().get_child_count() < 1
	var pck_path : String = %PCKFiles.get_selected().get_metadata(0)[0]
	var file_path : String = %PCKFiles.get_selected().get_metadata(0)[1].trim_prefix("/")
	if is_file:
		pck_dir.open(pck_path)
		if file_path.ends_with(".import")\
		or file_path.ends_with(".remap"):
			%PCKFileInfo.text = pck_dir.get_buffer(file_path).get_string_from_utf8()
		else:
			%PCKFileInfo.text = "File not supported"
	else:
		%PCKFileInfo.text = ""
