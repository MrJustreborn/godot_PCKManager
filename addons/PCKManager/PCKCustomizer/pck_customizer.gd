extends EditorExportPlugin

const CFG_FILE := "res://pck_manager.cfg"
const CFG_SECTION := "PCK_splits"

var should_split_pck := false
var pck_path := ""
var pck_path_bak := ""

func _get_name() -> String:
	return "PCKCustomizer"

func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
	should_split_pck = get_option("export/split_pcks") and !get_option("binary_format/embed_pck")
	pck_path = path.get_basename() + ".pck"
	pck_path_bak = path.get_basename() + ".full.pck.bak"

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
		
		var cfg_file: ConfigFile = ConfigFile.new()
		if !FileAccess.file_exists(CFG_FILE):
			printerr("Cannot open %s" % CFG_FILE)
			return
		cfg_file.load(CFG_FILE)
		
		var old_pck = DirAccess.open(pck_path.get_base_dir())
		if old_pck == null:
			prints("Error opening dir:", DirAccess.get_open_error())
		old_pck.copy(pck_path, pck_path_bak)
		old_pck.remove(pck_path.get_file())
		
		var pck_dir = preload("res://addons/PCKManager/PCKDirAccess.gd").new()
		pck_dir.open(pck_path_bak)
		var all_files = pck_dir.get_paths()
		
		var base_files = []
		var split_files = []
		if cfg_file.has_section(CFG_SECTION):
			var paths = cfg_file.get_section_keys(CFG_SECTION)
			for p in paths:
				split_files.append_array(_filter_paths(pck_dir,  p.trim_prefix("res://")))
		
		base_files = all_files.filter(func(item):
			return !split_files.has(item)
		)
		
		_create_pck(base_files)
		
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

func _filter_paths(pck_dir, path) -> Array[String]:
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
		prints(" > Create folder", path.get_base_dir())
		DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	
	if FileAccess.file_exists(path):
		prints(" >", path, " already exists, deleting")
		DirAccess.remove_absolute(path)
	
	var packer = PCKPacker.new()
	packer.pck_start(path)
	
	var tmp_files :Array[FileAccess] = []
	for ff in files:
		ff = ff.get_slice("res://", 1)
		var buff = pck_dir.get_buffer(ff)
		if buff == null:
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
		if buff is PackedByteArray:
			if buff.is_empty():
				printerr("Empty buffer for file " + ff)
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
	packer.add_file(ff, tmp.get_path_absolute())
	return tmp
