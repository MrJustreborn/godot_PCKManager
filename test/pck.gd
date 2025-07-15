@tool
extends EditorScript

func _run() -> void:
	#var exp = EditorExportPlatformLinuxBSD.new()
	#var preset = exp.create_preset()
	#prints(preset.get_custom_features())
	#exp.export_pack_patch(preset, false, "res://dist_test/test_exp.pck")#, ["res://dist_test/test.pck"])
	
	#for i in range(10):
		#var tmp = FileAccess.create_temp(FileAccess.WRITE_READ, "DEL_ME", "ROLF")
		#tmp.store_8(3)
		#print(tmp.get_path_absolute())
		#tmp.close()
	
	var pck_dir = preload("res://addons/PCKManager/PCKDirAccess.gd").new()
	
	print("\n\nNEW:test.pck\n")
	pck_dir.open("res://dist_test/test.pck")
	var p = pck_dir.get_paths()
	for f in p:
		print(f)
	
	print("\n\nNEW:dlc_1.pck\n")
	pck_dir.open("res://dist_test/dlc_1.pck")
	p = pck_dir.get_paths()
	for f in p:
		print(f)
	
	print("\n\nNEW:dlc_2.pck\n")
	pck_dir.open("res://dist_test/dlc_2.pck")
	p = pck_dir.get_paths()
	for f in p:
		print(f)
	
	print("\n\nOLD\n")
	pck_dir.open("res://dist_test/test.pck.bak")
	p = pck_dir.get_paths()
	for f in p:
		print(f)
	#prints(pck_dir.get_buffer("addons/PCKManager/PCKDirAccess.gd.remap").get_string_from_utf8())
	pck_dir.close()

func _run2():
	var packer = PCKPacker.new()
	packer.pck_start("res://test/test.pck", 32, "0000000000000000000000000000000000000000000000000000000000000000", false)
	packer.add_file("res://icon.png","res://icon.png")
	packer.add_file("res://icon2.png","res://icon.png")
	packer.add_file("res://test/icon.png","res://icon.png")
	packer.add_file("res://test/icon2.png","res://icon.png")
	packer.add_file("res://test2/icon.png","res://icon.png")
	packer.add_file("res://test2/icon2.png","res://icon.png")
	packer.flush(true)
	
	
	#{GDPC}{int32_version}{int32_major}{int32_minor}{int32_patch}{int32_flags}{int64_file_base}{int64_dir_base}{files_count}
	#{Path-String}
	
	print("\n\n===============\n")
	
	#file.set_endian_swap(true)
	var file := FileAccess.open("res://test/test.pck", FileAccess.READ)
	
	prints("POS:", file.get_position())
	
	print(str(file.get_32() == 0x43504447))
	prints("POS:", file.get_position())
	print(
		"Version: ", file.get_32(),
		" / Major: ", file.get_32(),
		" / Minor: ", file.get_32(),
		" / Patch: ", file.get_32(),
		" / Flags: ", file.get_32())
	
	prints("POS:", file.get_position())
	
	var file_base_ofs = file.get_64()
	#var dir_base_ofs = file.get_64()
	
	print("File: %X" % file_base_ofs)
	#print("Dir: %X" % dir_base_ofs)
	
	for i in range(16): # Reserved
		prints("Reserved", file.get_position(), file.get_32())

	
	#file.seek(dir_base_ofs)
	
	#var pad = _get_pad(32, file.get_position())
	#for i in range(pad): # Padding
		#prints("PAD", file.get_position(), file.get_8())
	
	var file_count = file.get_32()
	print("Files: ", file_count)
	
	for i in range(file_count):
		#print("__-- File: ",i," --__")
		var length = file.get_32()
		#print("length: ", length)
		
		var path = file.get_buffer(length).get_string_from_utf8()
		print("Path: ", path)
		
		var offset =  file.get_64()
		var size = file.get_64()
		var md5 = file.get_buffer(16)
		print("offset: ", offset, " / Size: ", size, " / md5: ", md5, " / flags: ", file.get_32())
	
		var pos = file.get_position()
		file.seek(file_base_ofs + offset)
		var png = file.get_buffer(size)
		file.seek(pos)
		
		#var ts := FileAccess.open("res://test/test.png", FileAccess.WRITE)
		#ts.store_buffer(png)
		#ts.flush()
	
		print(png.size())
	
	file.close()
	
	#file = FileAccess.open("res://addons/PCKManager/test/test.png", FileAccess.WRITE)
	#file.store_buffer(png)
	#file.close()
	
	print("\n\n===============\n")
	
	pass


func _get_pad(p_alignment: int, p_n: int) -> int:
	var rest := p_n % p_alignment
	var pad := 0
	if rest > 0:
		pad = p_alignment - rest
	return pad
