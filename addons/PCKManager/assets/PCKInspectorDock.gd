tool
extends Control

onready var tree = get_node("VBoxContainer/VSplitContainer/Tree")
onready var lineEdit = get_node("VBoxContainer/HBoxContainer/LineEdit")
var PCKDir = preload("res://addons/PCKManager/PCKDirectory.gd")
var pckDir = PCKDir.new(false)

func _ready():
	var item = tree.create_item()
	item.set_text(0,"1")
	
	var item2 = tree.create_item(item)
	item2.set_text(0,"2")
	
	var item3 = tree.create_item(item)
	item3.set_text(0,"1-2")

func _parseFiles():
	tree.clear()
	
	var root = tree.create_item()
	var n = lineEdit.text.split("/")
	n = n[n.size()-1]
	root.set_text(0,n)
	
	for drives in pckDir.get_drive_count():
		var drive = pckDir.get_drive(drives)
		var item = tree.create_item(root)
		item.set_text(0,drive)
		
		pckDir.change_dir(drive)
		pckDir.list_dir_begin(true)
		var s = pckDir.get_next()
		var files = []
		while(s != ""):
			if pckDir.current_is_dir():
				var dir = tree.create_item(item)
				dir.set_text(0,s)
				files.append(s)
				_addDir(dir, pckDir.get_current_dir()+s, PCKDir.new(false,pckDir.get_raw()))
			else:
				files.append(s)
			s = pckDir.get_next()
		var file = tree.create_item(item)
		file.set_text(0,str(files))

func _addDir( root, path, pckDirAccess ):
	pckDirAccess.change_dir(path)
	pckDirAccess.list_dir_begin(true)
	var s = pckDirAccess.get_next()
	while(s != ""):
		if pckDirAccess.current_is_dir():
			var dir = tree.create_item(root)
			dir.set_text(0,s)
			_addDir(dir, pckDirAccess.get_current_dir()+s, PCKDir.new(false,pckDir.get_raw()))
		else:
			var file = tree.create_item(root)
			file.set_text(0,s)
		s = pckDirAccess.get_next()

func _on_Button_pressed():
	$FileDialog.popup()


func _on_FileDialog_file_selected( path ):
	lineEdit.text = path
	
	pckDir.reset()
	pckDir.add_pck(path, false)
	
	_parseFiles()


func _on_Tree_item_selected():
	print(tree.get_selected().get_text(0))
	print(tree.get_selected().get_parent().get_text(0))
