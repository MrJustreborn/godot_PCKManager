extends RefCounted

var pck_impl : Dictionary[int, Callable] = {
	0: pck_v0,
	2 : pck_v2
}

func get_paths(pck_path: String) -> Array[String]:
	var file : FileAccess
	var pck_files = []
	
	if FileAccess.file_exists(pck_path):
		file = FileAccess.open(pck_path, FileAccess.READ)
		if file.get_32() != 0x43504447: #magic
			printerr("%s is not a valid PCK file" % pck_path)
			file.close()
			return pck_files
		
		var version = file.get_32()
		
		if !pck_impl.has(version):
			printerr("%s has an unsupported version %s" % [pck_path, version])
			file.close()
			return pck_files
		
		pck_files = pck_impl[version].call(file)
		file.close()
	return pck_files

func pck_v0(file: FileAccess) -> Array[String]:
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

func pck_v2(file: FileAccess) -> Array[String]:
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
	
	return files
