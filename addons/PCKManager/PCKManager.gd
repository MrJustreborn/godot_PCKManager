@tool
extends EditorPlugin

var managerDock
var inspectorDock

var PckCustomizer = preload("res://addons/PCKManager/PCKCustomizer/pck_customizer.gd").new()

func _enter_tree() -> void:
	managerDock = preload("res://addons/PCKManager/assets/PCKManagerDock.tscn").instantiate()
	
	add_autoload_singleton("PCKLoader", "res://addons/PCKManager/pck_loader.gd")
	add_export_plugin(PckCustomizer)
	EditorInterface.get_editor_main_screen().add_child(managerDock)
	_make_visible(false)

func _exit_tree() -> void:
	managerDock.free()
	
	remove_autoload_singleton("PCKLoader")
	remove_export_plugin(PckCustomizer)

func _has_main_screen() -> bool:
	return true


func _make_visible(visible: bool) -> void:
	if managerDock:
		managerDock.visible = visible
		if !visible:
			managerDock.save_cfg()
		else:
			managerDock._ready()


func _get_plugin_name() -> String:
	return "PCKManager"


func _get_plugin_icon() -> Texture2D:
	# Must return some kind of Texture for the icon.
	return EditorInterface.get_editor_theme().get_icon("Filesystem", "EditorIcons")
