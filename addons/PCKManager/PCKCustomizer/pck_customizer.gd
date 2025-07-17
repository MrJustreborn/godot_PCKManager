extends EditorExportPlugin

const CFG_FILE := "res://pck_manager.cfg"
const CFG_SECTION := "PCK_splits"

var should_split_pck := false
var pck_path := ""
var pck_path_bak := ""
var autoload_paths :Array[String] = []
var forced_files :PackedStringArray = []
var forced_files_internal :Dictionary = {}

func _get_name() -> String:
	return "PCKCustomizer"

func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
	should_split_pck = get_option("export/split_pcks") and !get_option("binary_format/embed_pck")
	pck_path = path.get_basename() + ".pck"
	pck_path_bak = path.get_basename() + ".full.pck.bak"
	
	var main_scene = ProjectSettings.get_setting("application/run/main_scene").get_slice("*res://", 1)
	
	forced_files = get_export_platform().get_forced_export_files();
	forced_files.append("project.binary")
	forced_files.append("default_env.tres")
	forced_files.append("addons/PCKManager/PCKDirectory.gd")
	forced_files.append("icon.png.import")
	forced_files.append(".godot/imported/icon.png-487276ed1e3a0c39cad0279d744ee560.ctex")
	forced_files.append(main_scene)
	for dependency in ResourceLoader.get_dependencies(main_scene):
		forced_files.append(dependency.get_slice("::", 2))
	
	forced_files_internal = get_export_platform().get_internal_export_files(get_export_preset(), is_debug)
	
	var _autoloads = ProjectSettings.get_property_list().filter(func(p): return p.name.begins_with("autoload/"))
	for _a in _autoloads:
		autoload_paths.append("res://" + ProjectSettings.get_setting(_a.name).get_slice("*res://", 1))

func _supports_platform(platform: EditorExportPlatform) -> bool:
	return platform is EditorExportPlatformPC

func _get_export_options(platform: EditorExportPlatform) -> Array[Dictionary]:
	return [{
		"option": {
			"name": "export/split_pcks",
			"type": TYPE_BOOL
		},
		"default_value": false,
		"update_visibility": true
	}]

func _export_end() -> void:
	if should_split_pck:
		prints("Split PCK:", pck_path)
		var old_pck = DirAccess.open(pck_path.get_base_dir())
		if old_pck == null:
			prints("Error opening dir:", DirAccess.get_open_error())
		old_pck.copy(pck_path, pck_path_bak)
		old_pck.remove(pck_path.get_file())
		
		var pck_dir = preload("res://addons/PCKManager/PCKDirAccess.gd").new()
		pck_dir.open(pck_path_bak)
		var all_files = pck_dir.get_paths()
		
		var base_files = []
		#base_files.append_array(forced_files)
		#base_files.append_array(autoload_paths)
		
		var added_files = _filter_paths(pck_dir)
		base_files = all_files.filter(func(item):
			return !added_files.has(item)
		)
		
		added_files = _create_pck(base_files)
		
		all_files = all_files.filter(func(item):
			return !added_files.has(item)
		)
		
		var cfg_file: ConfigFile = ConfigFile.new()
		if !FileAccess.file_exists(CFG_FILE):
			printerr("Cannot open %s" % CFG_FILE)
			return
		cfg_file.load(CFG_FILE)
		
		if cfg_file.has_section(CFG_SECTION):
			var paths = cfg_file.get_section_keys(CFG_SECTION)
			for p in paths:
				_create_pck(
					_filter_paths(pck_dir, p.trim_prefix("res://")),
					pck_path.get_base_dir() + "/" + cfg_file.get_value(CFG_SECTION, p)
				)
		
		if !cfg_file.get_value("settings", "keep_full_pck", true):
			old_pck.remove(pck_path_bak.get_file())
		
	should_split_pck = false
	pck_path = ""
	pck_path_bak = ""
	autoload_paths = []
	forced_files = []
	forced_files_internal = {}

func _filter_paths(pck_dir, path := "dlcs/") -> Array[String]:
	var all_files = pck_dir.get_paths()
	var filtered :Array[String] = []
	
	for file: String in all_files:
		if file.begins_with(path):
			filtered.append(file)
			if file.ends_with(".import") or file.ends_with(".remap"):
				var buff = pck_dir.get_buffer(file)
				var conf = ConfigFile.new()
				conf.parse(buff.get_string_from_utf8())
				var remap_path = conf.get_value("remap", "path")
				filtered.append(remap_path.get_slice("res://", 1))
	
	return filtered

func _create_pck(files, path = pck_path) -> Array[String]:
	var pck_dir = preload("res://addons/PCKManager/PCKDirAccess.gd").new()
	pck_dir.open(pck_path_bak)
	
	var packed_files : Array[String] = []
	
	prints("Create PCK:", path)
	if !DirAccess.dir_exists_absolute(path.get_base_dir()):
		prints("Create folder", path.get_base_dir())
		DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	
	var packer = PCKPacker.new()
	packer.pck_start(path)
	
	var tmp_files :Array[FileAccess] = []
	for ff in files:
		ff = ff.get_slice("res://", 1)
		#prints("Add file", ff)
		var buff = pck_dir.get_buffer(ff)
		if !buff:
			buff = pck_dir.get_buffer(ff + ".remap")
			var conf = ConfigFile.new()
			conf.parse(buff.get_string_from_utf8())
			var remap_path = conf.get_value("remap", "path")
			if remap_path:
				packed_files.append(ff + ".remap")
				tmp_files.append(_add_file(buff, packer, ff + ".remap"))
				
				buff = pck_dir.get_buffer(remap_path.get_slice("res://", 1))
				packed_files.append(remap_path.get_slice("res://", 1))
				tmp_files.append(_add_file(buff, packer, remap_path.get_slice("res://", 1)))
		if buff:
			packed_files.append(ff)
			tmp_files.append(_add_file(buff, packer, ff))
	
	packer.flush()
	for file in tmp_files:
		DirAccess.remove_absolute(file.get_path_absolute())
	
	return packed_files

func _add_file(buff: PackedByteArray, packer: PCKPacker, ff: String) -> FileAccess:
	var tmp = FileAccess.create_temp(FileAccess.WRITE_READ, "pck_customizer", "bin", true)
	tmp.store_buffer(buff)
	tmp.close()
	#prints("pack file", ff, tmp.get_path_absolute())
	packer.add_file(ff, tmp.get_path_absolute())
	return tmp
