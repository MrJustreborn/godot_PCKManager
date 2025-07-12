extends EditorExportPlugin

#var flag_main := false
#var flag_second := false

var should_split_pck := false
var pck_path := ""
var autoload_paths :Array[String] = []
var forced_files :Array[String] = []
var forced_files_internal :Dictionary[String, PackedByteArray] = {}

func _get_name() -> String:
	return "PCKCustomizer"

func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
	should_split_pck = get_option("export/split_pcks") and !get_option("binary_format/embed_pck")
	pck_path = path.get_basename() + ".pck"
	
	forced_files = get_export_platform().get_forced_export_files();
	forced_files_internal = get_export_platform().get_internal_export_files(get_export_preset(), is_debug)
	
	var _autoloads = ProjectSettings.get_property_list().filter(func(p): return p.name.begins_with("autoload/"))
	for _a in _autoloads:
		autoload_paths.append(ProjectSettings.get_setting(_a.name))

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
		old_pck.copy(pck_path, pck_path + ".bak")
		old_pck.remove(pck_path.get_file())
	
	should_split_pck = false
	pck_path = ""
	autoload_paths = []
	forced_files = []
	forced_files_internal = {}

func split_pck() -> void:
	var pck_dir = preload("res://addons/PCKManager/PCKDirAccess.gd").new()
