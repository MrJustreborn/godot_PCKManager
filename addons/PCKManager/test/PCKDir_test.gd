extends Node


func _ready():
	var dir = load("res://addons/PCKManager/PCKDirectory.gd").new()
	
	dir.change_dir("res://addons/PCKManager/test/")
	dir.list_dir_begin(true)
	
	print("===list dirs===")
	
	var s = dir.get_next()
	while(s != ""):
		print(s, " -> ", dir.current_is_dir())
		s = dir.get_next()
	
	dir.change_dir(".././/")
	dir.list_dir_begin(true)
	
	s = dir.get_next()
	while(s != ""):
		print(s, " -> ", dir.current_is_dir())
		s = dir.get_next()
	
	print("===add dirs===")
	
	print("common: ",dir.get_common_paths("res://test.pck"))
	dir.add_pck("res://addons/PCKManager/test/test.pck",false)
	
	print("===list new dirs===")
	
	dir.change_dir("res://")
	dir.list_dir_begin(true)
	
	s = dir.get_next()
	while(s != ""):
		print(s, " -> ", dir.current_is_dir())
		s = dir.get_next()
	

