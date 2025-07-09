extends RefCounted

var files = {}
var file_to_pck = {}

var list_dirs = []
var list_files = []

var cur_dir = "res://"
var is_cur_dir = false


func _init(addProject=true, preFill={}):
	files=preFill
	if !addProject:
		return
	var dir = DirAccess.open(cur_dir)
	
	if !files.has(dir.get_current_dir()):
		files[dir.get_current_dir()]={}
	
	dir.list_dir_begin()
	
	var s = dir.get_next()
	while(s != ""):
		if !files[dir.get_current_dir()].has(s):
			if dir.current_is_dir():
				if s != "..":
					files[dir.get_current_dir()][s] = _getDirs(dir.get_current_dir(), s)
					file_to_pck[dir.get_current_dir()] = null
			else:
				files[dir.get_current_dir()][s] = null
				file_to_pck[dir.get_current_dir()] = null
		s = dir.get_next()

func _getDirs( basePath, path ):
	if path == "." || path == "..":
		return {}
	elif path == null:
		return null

	var files={}
	
	var dir = DirAccess.open(basePath)
	dir.change_dir(path)
	
	dir.list_dir_begin()
	
	var s = dir.get_next()
	while(s != ""):
		if !files.has(s):
			if dir.current_is_dir():
				files[s] = _getDirs(dir.get_current_dir(), s)
				file_to_pck[dir.get_current_dir()] = null
			else:
				files[s] = null
				file_to_pck[dir.get_current_dir()] = null
		s = dir.get_next()
	
	return files

func _addPCKFile( path, fromPCK ):
	file_to_pck[path] = fromPCK
	var drive = "res"
	var dirs: Array
	
	if path.find("://")>0:
		drive = path.split("://")[0]
		dirs = path.split("://")[1].split("/")
	else:
		dirs = path.split("/")
	
	var file = dirs[dirs.size()-1]
	dirs.remove_at(dirs.size()-1)
	
	if !files.has(drive+"://"):
		files[drive+"://"]={}
	
	var patch = {}
	patch[drive+"://"] = _addPCKPath( dirs, file)
	
	_merge_files(files, patch)

func _merge_files(target, patch):
	for key in patch:
		if target.has(key):
			var tv = target[key]
			if typeof(tv) == TYPE_DICTIONARY:
				_merge_files(tv, patch[key])
			else:
				target[key] = patch[key]
		else:
			target[key] = patch[key]

func _addPCKPath( dirs: Array, file ):
	var files={}
	
	if dirs.size()>0:
		var dir = dirs[0]
		if !files.has(dir):
			dirs.remove_at(0)
			files[dir]=_addPCKPath( dirs, file)
	else:
		return {file:null}
	return files;

func get_pck_path_for_ressource( path ):
	if file_to_pck.has(path):
		return file_to_pck[path]
	return null

func ressource_is_extractable( path ):
	return self.get_pck_path_for_ressource(path) != null

func get_ressource_buffer( path ):
	var buffer = null
	var pck_path = self.get_pck_path_for_ressource(path)
	if pck_path == null:
		return buffer
	
	var file : FileAccess
	if FileAccess.file_exists(pck_path):
		file = FileAccess.open(pck_path, FileAccess.READ)
		if file.get_32() != 0x43504447: #magic
			file.close()
			return buffer
		var version = file.get_32()
		var major = file.get_32()
		var minor = file.get_32()
		var rev = file.get_32()
		
		for i in range(16): #reserved bytes
			file.get_32()
		
		var file_count = file.get_32()
		
		for i in range(file_count):
			var length = file.get_32()
			
			var file_path = file.get_buffer(length).get_string_from_utf8()
			
			var offset =  file.get_64()
			var size = file.get_64()
			var md5 = file.get_buffer(16)
			
			if file_path == path:
				file.seek(offset)
				buffer = file.get_buffer(size)
				break
			
		file.close()
	return buffer

func extract_to( resPath, toPath ):
	var buff = self.get_ressource_buffer(resPath)
	if buff != null:
		var file = FileAccess.open(toPath, FileAccess.WRITE)
		file.store_buffer(buff)
		file.close()

func reset():
	files={}
	file_to_pck={}

func get_raw():
	return files

func get_pck_files( pck_path ):
	var file : FileAccess
	var pck_files = []
	
	if FileAccess.file_exists(pck_path):
		file = FileAccess.open(pck_path, FileAccess.READ)
		
		if file.get_32() != 0x43504447: #magic
			file.close()
			return pck_files
		var version = file.get_32()
		var major = file.get_32()
		var minor = file.get_32()
		var rev = file.get_32()
		
		for i in range(16): #reserved bytes
			file.get_32()
		
		var file_count = file.get_32()
		
		for i in range(file_count):
			var length = file.get_32()
			
			var path = file.get_buffer(length).get_string_from_utf8()
			pck_files.append(path)
			
			var offset =  file.get_64()
			var size = file.get_64()
			var md5 = file.get_buffer(16)
		file.close()
	return pck_files

func add_pck( pck_path, addToProject=true ):
	if (addToProject):
		ProjectSettings.load_resource_pack( pck_path )
	
	var paths = self.get_pck_files(pck_path)
	for p in paths:
		_addPCKFile(p, pck_path)

func get_common_paths( pck_path ):
	var common = []
	var pckPaths = self.get_pck_files( pck_path )
	
	for p in pckPaths:
		if self.file_exists(p):
			common.append(p)
	
	return common

func change_dir( toDir ):
	var isAbsolute = toDir.find("://")>0
	
	if isAbsolute:
		if self.dir_exists(toDir):
			cur_dir = toDir
	else:
		var dirs = toDir.split("/")
		var curDirs = cur_dir.split("/")
		curDirs.remove_at(1) #remove emty index from '//' in 'res://'
		
		if curDirs[curDirs.size()-1] == "":
			curDirs.remove_at(curDirs.size()-1)
		
		for d in dirs:
			if d == "..":
				if curDirs.size() <= 1:
					return
				curDirs.remove_at(curDirs.size()-1)
				continue
			if d == "." || d == "":
				continue
			curDirs.append(d)
		
		var absPath = curDirs[0]+"/"
		curDirs.remove_at(0)
		if curDirs.size()<1:
			absPath+="/"
		for p in curDirs:
			absPath+="/"+p
		self.change_dir(absPath+"/")

func get_current_dir(include_drive := true):
	return cur_dir

func current_is_dir():
	return is_cur_dir

func dir_exists( path ):
	var isAbsolute = path.find("://")>0
	
	if isAbsolute:
		var drive = "res"
		var dirs
		
		drive = path.split("://")[0]
		dirs = path.split("://")[1].split("/")
		
		return _hasDir(files[drive+"://"], dirs)
	else:
		var dirs = path.split("/")
		var curDirs = cur_dir.split("/")
		curDirs.remove_at(1) #remove emty index from '//' in 'res://'
		
		if curDirs[curDirs.size()-1] == "":
			curDirs.remove_at(curDirs.size()-1)
		
		for d in dirs:
			if d == "..":
				if curDirs.size() <= 1:
					return
				curDirs.remove_at(curDirs.size()-1)
				continue
			if d == "." || d == "":
				continue
			curDirs.append(d)
		
		var absPath = curDirs[0]+"/"
		curDirs.remove_at(0)
		if curDirs.size()<1:
			absPath+="/"
		for p in curDirs:
			absPath+="/"+p
		return self.dir_exists(absPath)
func _hasDir( dic, dirs ):
	if dirs.size()>0:
		var dir = dirs[0]
		if dic.has(dir):
			dirs.remove_at(0)
			return _hasDir(dic[dir], dirs)
		elif dir == "":
			dirs.remove_at(0)
			return _hasDir(dic, dirs)
		return false
	return true

func file_exists( path ):
	return self.dir_exists(path)

func get_next():
	if (list_dirs.size()):
		is_cur_dir = true;
		var d = list_dirs.front();
		list_dirs.pop_front();
		return d;
	elif (list_files.size()):
		is_cur_dir = false;
		var f = list_files.front();
		list_files.pop_front();
		return f;
	else:
		return "";

func list_dir_begin( skip_navigational=false, skip_hidden=false ):
	list_dir_end()
	
	var drive = cur_dir.split("://")[0]
	var dir = cur_dir.split("://")[1]
	dir = dir.split("/")
	
	var list = files[drive+"://"]
	for i in dir:
		if i != "":
			list = list[i]
	
	for i in list:
		if skip_navigational && (i == "." || i == ".."):
			continue
		if list[i] != null:
			list_dirs.push_back(i)
		else:
			list_files.push_back(i)

func list_dir_end():
	list_dirs.clear()
	list_files.clear()
	return

func get_space_left():
	return 0

func get_drive_count():
	return files.size()

func get_current_drive():
	var drive = cur_dir.split("://")[0]
	var keys = files.keys()
	return keys.rfind(drive+"://")

func get_drive( idx ):
	var keys = files.keys()
	if keys.size()>idx:
		return keys[idx]
	return ""

#func open( path ):
	#return ERR_UNAVAILABLE
#func copy( from, to ):
	#return ERR_UNAVAILABLE
#func make_dir( path ):
	#return ERR_UNAVAILABLE
#func make_dir_recursive( path ):
	#return ERR_UNAVAILABLE
#func remove( path ):
	#return ERR_UNAVAILABLE
#func rename( from, to ):
	#return ERR_UNAVAILABLE
