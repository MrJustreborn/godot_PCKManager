tool
extends EditorPlugin

var managerDock
var inspectorDock

func _enter_tree():
	managerDock = preload("res://addons/PCKManager/assets/PCKManagerDock.tscn").instance()
	inspectorDock = preload("res://addons/PCKManager/assets/PCKInspectorDock.tscn").instance()
	
	add_control_to_dock( DOCK_SLOT_LEFT_UL, managerDock)
	add_control_to_dock( DOCK_SLOT_LEFT_BL, inspectorDock)

func _exit_tree():
	remove_control_from_docks( managerDock )
	remove_control_from_docks( inspectorDock )
	managerDock.free()
	inspectorDock.free()
