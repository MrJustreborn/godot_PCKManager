tool
extends Control

onready var tree = get_node("VBoxContainer/VSplitContainer/Tree")
onready var itemList = get_node("VBoxContainer/VSplitContainer/ItemList")
onready var lineEdit = get_node("VBoxContainer/HBoxContainer/LineEdit")
var PCKDir = preload("res://addons/PCKManager/PCKDirectory.gd")
var pckDir = PCKDir.new(false)

func _parseFiles():
	tree.clear()
	
	var root = tree.create_item()
	var n = lineEdit.text.split("/")
	n = n[n.size()-1]
	root.set_text(0,n)
	
	var drive_names = []
	for drives in pckDir.get_drive_count():
		var drive = pckDir.get_drive(drives)
		drive_names.append(drive)
		var item = tree.create_item(root)
		item.set_text(0,drive)
		
		pckDir.change_dir(drive)
		pckDir.list_dir_begin(true)
		var s = pckDir.get_next()
		var files = []
		var dirs = []
		while(s != ""):
			if pckDir.current_is_dir():
				var dir = tree.create_item(item)
				dir.set_text(0,s)
				dirs.append(s)
				_addDir(dir, pckDir.get_current_dir()+s, PCKDir.new(false,pckDir.get_raw()))
			else:
				files.append(s)
			s = pckDir.get_next()
		item.set_metadata(0,{"dirs":dirs,"files":files})
	root.set_metadata(0,{"dirs":drive_names,"files":{}})

func _addDir( root, path, pckDirAccess ):
	pckDirAccess.change_dir(path)
	pckDirAccess.list_dir_begin(true)
	var s = pckDirAccess.get_next()
	var files = []
	var dirs = []
	while(s != ""):
		if pckDirAccess.current_is_dir():
			var dir = tree.create_item(root)
			dir.set_text(0,s)
			dirs.append(s)
			_addDir(dir, pckDirAccess.get_current_dir()+s, PCKDir.new(false,pckDir.get_raw()))
		else:
			files.append(s)
		s = pckDirAccess.get_next()
	root.set_metadata(0,{"dirs":dirs,"files":files})

func _on_Button_pressed():
	$FileDialog.popup()


func _on_FileDialog_file_selected( path ):
	lineEdit.text = path
	
	pckDir.reset()
	pckDir.add_pck(path, false)
	
	_parseFiles()


func _on_Tree_item_selected():
	itemList.clear()
	var data = tree.get_selected().get_metadata(0)
	if data == null:
		return
	var dirs = data["dirs"]
	var files = data["files"]
	
	for d in dirs:
		itemList.add_item(d)
	for f in files:
		itemList.add_item(f)


func _on_ItemList_item_activated( index ):
	itemList.get_item_text(index)
	tree.get_selected().get_parent().select(0)
