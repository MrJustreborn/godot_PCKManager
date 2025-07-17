extends Node


func _ready():
	prints(
		ResourceLoader.has_cached("res://dlcs/dlc_1/icon.png"),
		ResourceLoader.has_cached("res://dlcs/dlc_2/icon.png")
		)
	#if ResourceLoader.exists("res://dlcs/dlc_1/icon.png"):
		#$Icon.texture = load("res://dlcs/dlc_1/icon.png")
	#elif ResourceLoader.exists("res://dlcs/dlc_2/icon.png"):
		#$Icon.texture = load("res://dlcs/dlc_2/icon.png")
	
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_file("res://test/test_scene_2.tscn")
	
func test() -> void:
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
	dir.add_pck("res://test/test_old.pck",false)
	
	print("===list new dirs===")
	
	dir.change_dir("res://")
	dir.list_dir_begin(true)
	
	s = dir.get_next()
	while(s != ""):
		print(s, " -> ", dir.current_is_dir())
		s = dir.get_next()
	
