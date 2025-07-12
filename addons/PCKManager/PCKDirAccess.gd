extends RefCounted

var pck_path_impl : Dictionary[int, Callable] = {
	0: _pck_path_v0,
	2 : _pck_path_v2
}

var pck_get_file_impl : Dictionary[int, Callable] = {
	2 : _pck_get_file_v2
}

var file : FileAccess

func open(pck_path: String) -> void:
	if FileAccess.file_exists(pck_path):
		file = FileAccess.open(pck_path, FileAccess.READ)

func close() -> void:
	if file && file.is_open():
		file.close()

func get_paths() -> Array[String]:
	file.seek(0)
	var pck_files : Array[String] = []
	
	if file.get_32() != 0x43504447: #magic
		printerr("%s is not a valid PCK file" % file.get_path_absolute())
		return pck_files
	
	var version = file.get_32()
	
	if !pck_path_impl.has(version):
		printerr("%s has an unsupported version %s" % [file.get_path_absolute(), version])
		return pck_files
		
	pck_files = pck_path_impl[version].call()
	return pck_files

func get_buffer(filename: String) -> PackedByteArray:
	file.seek(0)
	
	if file.get_32() != 0x43504447: #magic
		printerr("%s is not a valid PCK file" % file.get_path_absolute())
		return []
	
	var version = file.get_32()
	
	if !pck_get_file_impl.has(version):
		printerr("%s has an unsupported version %s" % [file.get_path_absolute(), version])
		return []
	
	return pck_get_file_impl[version].call(filename)

func _pck_get_file_v2(filename: String) -> PackedByteArray:
	var major = file.get_32()
	var minor = file.get_32()
	var patch = file.get_32()
	var flags = file.get_32()

	var version_str = "%d.%d.%d" % [major, minor, patch]
	
	var file_base_ofs = file.get_64()
	
	for i in range(16): # Reserved
		file.get_32()
	
	var file_count = file.get_32()
	for i in range(file_count):
		var length = file.get_32()
		
		var path = file.get_buffer(length).get_string_from_utf8()
		
		var offset =  file.get_64()
		var size = file.get_64()
		var md5 = file.get_buffer(16)
		var flags_file = file.get_32()
		
		if path == filename:
			var pos = file.get_position()
			file.seek(file_base_ofs + offset)
			return file.get_buffer(size)
	return []

func _pck_path_v0() -> Array[String]:
	var files : Array[String] = []
	
	var major = file.get_32()
	var minor = file.get_32()
	var rev = file.get_32()
	
	for i in range(16): #reserved bytes
		file.get_32()
	
	var file_count = file.get_32()
		
	for i in range(file_count):
		var length = file.get_32()
		
		var path = file.get_buffer(length).get_string_from_utf8()
		files.append(path)
		
		var offset =  file.get_64()
		var size = file.get_64()
		var md5 = file.get_buffer(16)
	
	return files

func _pck_path_v2() -> Array[String]:
	var files : Array[String] = []
	
	var major = file.get_32()
	var minor = file.get_32()
	var patch = file.get_32()
	var flags = file.get_32()

	var version_str = "%d.%d.%d" % [major, minor, patch]
	
	var file_base_ofs = file.get_64()
	
	for i in range(16): # Reserved
		file.get_32()
	
	var file_count = file.get_32()
	for i in range(file_count):
		var length = file.get_32()
		
		var path = file.get_buffer(length).get_string_from_utf8()
		files.append(path)
		
		var offset =  file.get_64()
		var size = file.get_64()
		var md5 = file.get_buffer(16)
		var flags_file = file.get_32()
		
		if path == "test/pck.gd.remap":#"project.binary":
			var pos = file.get_position()
			file.seek(file_base_ofs + offset)
			var settings = file.get_buffer(size)
			file.seek(pos)
			prints("Project.bin: \n", settings.get_string_from_utf8())
	
	return files
