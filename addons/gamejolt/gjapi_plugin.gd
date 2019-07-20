tool
extends EditorPlugin


func _enter_tree():
	# When this plugin node enters tree, add the custom type

	add_custom_type("HighGameJoltAPI", "Node", preload("res://addons/gamejolt/high_api.gd"), preload("res://addons/gamejolt/gj_icon.png"))
	add_custom_type("LowGameJoltAPI", "HTTPRequest", preload("res://addons/gamejolt/low_api.gd"), preload("res://addons/gamejolt/gj_icon.png"))
func _exit_tree():
	# When the plugin node exits the tree, remove the custom type

	remove_custom_type("GameJoltAPI")




	
