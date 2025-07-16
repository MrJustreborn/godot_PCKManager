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
			if folder_name.begins_with(".") || folder_name == "addons":
				continue
			
			var full_path = path.path_join(folder_name)

			var item = dlc_file_tree.create_item(parent)
			item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
			item.set_text(0, folder_name)
			item.set_icon(0, get_theme_icon("Folder", "EditorIcons"))
			item.set_checked(0, false)
			item.set_editable(0, true)
			#if folder_name == "addons" || collapsed:
				#item.collapsed = true
			item.collapsed = collapsed

			_populate_folders(full_path, item)

func get_checked_folders() -> Array[String]:
	var result: Array[String] = []
	var root = dlc_file_tree.get_root()
	_collect_checked_folders(root, "res://", result)
	return result

func get_top_level_checked_folders() -> Array[String]:
	var result: Array[String] = []
	var root = dlc_file_tree.get_root()
	_collect_top_checked(root, "res://", false, result)
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

func _collect_top_checked(item: TreeItem, current_path: String, parent_checked: bool, result: Array[String]) -> void:
	if item == null:
		return

	var is_checked = item.get_cell_mode(0) == TreeItem.CELL_MODE_CHECK and item.is_checked(0)

	# If a parent is already checked, skip this item and its children
	if parent_checked:
		return

	# If this item is checked and its parent was not, it's a top-level selected folder
	if is_checked:
		result.append(current_path)
		parent_checked = true  # prevent children from being added

	var child = item.get_first_child()
	while child:
		var sub_path = current_path.path_join(child.get_text(0))
		_collect_top_checked(child, sub_path, parent_checked, result)
		child = child.get_next()




func _propagate_check_to_children(item: TreeItem, checked: bool) -> void:
	var child := item.get_first_child()
	while child:
		if child.get_cell_mode(0) == TreeItem.CELL_MODE_CHECK:
			child.set_checked(0, checked)
		_propagate_check_to_children(child, checked)
		child = child.get_next()

func _uncheck_parents(item: TreeItem) -> void:
	var parent := item.get_parent()
	while parent:
		if parent.get_cell_mode(0) == TreeItem.CELL_MODE_CHECK:
			parent.set_checked(0, false)
		parent = parent.get_parent()

func _uncheck_siblings(item: TreeItem) -> void:
	var parent := item.get_parent()
	if parent == null:
		return

	var sibling := parent.get_first_child()
	while sibling:
		if sibling != item and sibling.get_cell_mode(0) == TreeItem.CELL_MODE_CHECK:
			sibling.set_checked(0, false)
			# Also uncheck all children of the sibling
			_propagate_check_to_children(sibling, false)
		sibling = sibling.get_next()

func _on_dlc_file_tree_item_edited() -> void:
	var edited_item := dlc_file_tree.get_edited()
	if edited_item == null:
		return

	var is_checked := edited_item.is_checked(0)

	if is_checked:
		_propagate_check_to_children(edited_item, true)
	else:
		# Uncheck siblings only if parent was checked
		var parent := edited_item.get_parent()
		if parent and parent.get_cell_mode(0) == TreeItem.CELL_MODE_CHECK and parent.is_checked(0):
			_uncheck_siblings(edited_item)
				# Uncheck all parent folders
		_uncheck_parents(edited_item)

	print("\nDLCs:")
	#prints(get_checked_folders())
	var selected_top_folders = get_top_level_checked_folders()
	for path in selected_top_folders:
		prints("DLC-PCK",path)
