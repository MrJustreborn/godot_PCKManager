extends Node


func _init() -> void:
	var base_path = OS.get_executable_path().get_base_dir()
	ProjectSettings.load_resource_pack(base_path + "/dlc_1.pck")
	ProjectSettings.load_resource_pack(base_path + "/dlc_2.pck")
