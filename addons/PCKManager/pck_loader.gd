extends Node


func _init() -> void:
	var load := true
	if ProjectSettings.has_setting("PCKLoader/autoload"):
		load = ProjectSettings.get("PCKLoader/autoload")
	
	if !load:
		prints("Autoload disabled! - Skipping PCK initial loading")
		return
	
	if OS.has_feature("editor") and false:
		prints("Running from editor! - Skipping PCK initial loading")
	else:
		load_pck_files()

func load_pck_files(path: String = "", suppress_errors: bool = true) -> bool:
	var base_path := OS.get_executable_path().get_base_dir()
	if !path.is_empty():
		base_path += "/" + path
	return _load_pck_files_recursive(base_path, suppress_errors)

func _load_pck_files_recursive(path: String, suppress_errors: bool) -> bool:
	var base_pck := OS.get_executable_path().get_basename() + ".pck"
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("Failed to open directory: " + path)
		if !suppress_errors: 
			return false

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if dir.current_is_dir() and file_name != "." and file_name != "..":
			var result := _load_pck_files_recursive(path + "/" + file_name, suppress_errors)
			if !suppress_errors and !result:
				return false
		elif file_name.to_lower().ends_with(".pck"):
			var full_path := path + "/" + file_name
			if full_path == base_pck:
				file_name = dir.get_next()
				continue
			prints("Loading PCK:", full_path)
			var success := ProjectSettings.load_resource_pack(full_path)
			if not success:
				push_error("Failed to load: " + full_path)
				if !suppress_errors:
					return false
		file_name = dir.get_next()
	dir.list_dir_end()
	
	return true
