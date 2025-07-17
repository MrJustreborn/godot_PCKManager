extends Node



func _ready():
	prints(
		ResourceLoader.has_cached("res://dlcs/dlc_1/icon.png"),
		ResourceLoader.has_cached("res://dlcs/dlc_2/icon.png")
		)
	if ResourceLoader.exists("res://dlcs/dlc_1/icon.png"):
		$Icon.texture = load("res://dlcs/dlc_1/icon.png")
	elif ResourceLoader.exists("res://dlcs/dlc_2/icon.png"):
		$Icon.texture = load("res://dlcs/dlc_2/icon.png")
	
	var t = TestNameInDLC.new()
	prints("new TestNameInDLC", t)
