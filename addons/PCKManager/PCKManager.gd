@tool
extends EditorPlugin

var managerDock
var inspectorDock

var PckCustomizer = preload("res://addons/PCKManager/PCKCustomizer/pck_customizer.gd").new()

func _enter_tree():
	#managerDock = preload("res://addons/PCKManager/assets/PCKManagerDock.tscn").instance()
	inspectorDock = preload("res://addons/PCKManager/assets/PCKInspectorDock.tscn").instantiate()
	
	#add_control_to_dock( DOCK_SLOT_LEFT_UL, managerDock)
	add_control_to_dock( DOCK_SLOT_LEFT_BL, inspectorDock)
	
	#var props = get_editor_interface().get_base_control().get_theme().get_property_list()
	#print(get_editor_interface().get_base_control().get_theme().get_icon_list("EditorIcons"))
	
	#for p in props:
		#if p.has("name") && p["name"].find("Folder")>0:
			#print(p)
			#pass
	
	add_export_plugin(PckCustomizer)

func _exit_tree():
	#remove_control_from_docks( managerDock )
	remove_control_from_docks( inspectorDock )
	#managerDock.free()
	inspectorDock.free()
	
	remove_export_plugin(PckCustomizer)
