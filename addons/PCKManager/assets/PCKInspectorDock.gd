tool
extends Control

onready var tree = get_node("VBoxContainer/VSplitContainer/Tree")
onready var itemList = get_node("VBoxContainer/VSplitContainer/ItemList")
onready var lineEdit = get_node("VBoxContainer/HBoxContainer/LineEdit")
var PCKDir = preload("res://addons/PCKManager/PCKDirectory.gd")
var pckDir = PCKDir.new(false)

func _ready():
	$VBoxContainer/HBoxContainer/Button.icon = get_icon("Search", "EditorIcons")

func _parseFiles():
	tree.clear()
	
	var root = tree.create_item()
	var n = lineEdit.text.split("/")
	n = n[n.size()-1]
	root.set_text(0,n)
	root.set_icon(0,get_icon("File", "EditorIcons"))
	
	var drive_names = []
	for drives in pckDir.get_drive_count():
		var drive = pckDir.get_drive(drives)
		drive_names.append(drive)
		var item = tree.create_item(root)
		item.set_text(0,drive)
		item.set_icon(0,get_icon("Filesystem", "EditorIcons"))
		
		pckDir.change_dir(drive)
		pckDir.list_dir_begin(true)
		var s = pckDir.get_next()
		var files = []
		var dirs = []
		while(s != ""):
			if pckDir.current_is_dir():
				var dir = tree.create_item(item)
				dir.set_text(0,s)
				dir.set_icon(0,get_icon("Folder", "EditorIcons"))
				dirs.append(s)
				_addDir(dir, pckDir.get_current_dir()+s, PCKDir.new(false,pckDir.get_raw()))
			else:
				files.append(s)
			s = pckDir.get_next()
		item.set_metadata(0,{"dirs":dirs,"files":files,"cur_dir":pckDir.get_current_dir()})
	root.set_metadata(0,{"dirs":drive_names,"files":{},"cur_dir":""})

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
	root.set_metadata(0,{"dirs":dirs,"files":files,"cur_dir":pckDirAccess.get_current_dir()})

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
	var idx = 0
	
	for d in dirs:
		itemList.add_item(d,get_icon("Folder", "EditorIcons"))
		itemList.set_item_metadata(idx,data["cur_dir"])
		idx+=1
	for f in files:
		itemList.add_item(f,get_icon("File", "EditorIcons"))
		itemList.set_item_metadata(idx,data["cur_dir"])
		idx+=1


func _on_ItemList_item_activated( index ):
	itemList.get_item_text(index)
	tree.get_selected().get_parent().select(0)


func _on_ItemList_item_rmb_selected( index, at_position ):
	itemList.get_node("PopupMenu").clear()
	
	itemList.get_node("PopupMenu").add_item("Save to disc",0)
	itemList.get_node("PopupMenu").set_item_metadata(0,index)
	
	itemList.get_node("PopupMenu").set_position(itemList.get_global_position() + at_position)
	itemList.get_node("PopupMenu").popup()


func _on_PopupMenu_id_pressed( ID ):
	var idx = itemList.get_node("PopupMenu").get_item_metadata(ID)
	print(itemList.get_item_metadata(idx))
	print(pckDir.get_pck_path_for_ressource("res://"))
	pckDir.extract_to("res://icon.png", "res://icon_neu.png")
