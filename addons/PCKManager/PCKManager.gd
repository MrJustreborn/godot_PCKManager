@tool
extends EditorPlugin

var managerDock
var inspectorDock

var PckCustomizer = preload("res://addons/PCKManager/PCKCustomizer/pck_customizer.gd").new()

func _enter_tree() -> void:
	managerDock = preload("res://addons/PCKManager/assets/PCKManagerDock.tscn").instantiate()
	#inspectorDock = preload("res://addons/PCKManager/assets/PCKInspectorDock.tscn").instantiate()
	
	#add_control_to_dock( DOCK_SLOT_LEFT_UL, managerDock)
	#add_control_to_dock( DOCK_SLOT_LEFT_BL, inspectorDock)
	
	
	#var props = get_editor_interface().get_base_control().get_theme().get_property_list()
	#print(get_editor_interface().get_base_control().get_theme().get_icon_list("EditorIcons"))
	
	#for p in props:
		#if p.has("name") && p["name"].find("Folder")>0:
			#print(p)
			#pass
	
	add_export_plugin(PckCustomizer)
	EditorInterface.get_editor_main_screen().add_child(managerDock)
	_make_visible(false)

func _exit_tree() -> void:
	#remove_control_from_docks( managerDock )
	#remove_control_from_docks( inspectorDock )
	#managerDock.free()
	managerDock.free()
	
	remove_export_plugin(PckCustomizer)

func _has_main_screen() -> bool:
	return true


func _make_visible(visible: bool) -> void:
	if managerDock:
		managerDock.visible = visible


func _get_plugin_name() -> String:
	return "PCKManager"


func _get_plugin_icon() -> Texture2D:
	# Must return some kind of Texture for the icon.
	return EditorInterface.get_editor_theme().get_icon("Filesystem", "EditorIcons")
