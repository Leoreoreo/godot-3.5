extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func open_scene_in_editor(node_id):
	# Construct the path to the .tscn file
	var scene_path = str(node_id) + ".tscn"
	
	# Check if the scene file exists
	if ResourceLoader.exists(scene_path):
		# Load the scene
		var scene = load(scene_path)
		
		# Ensure it's a valid PackedScene resource
		if scene is PackedScene:
			# Change to the desired scene in the editor
			# This is pseudo-code; actual functionality depends on editor's API
			editor_interface.open_scene_from_path(scene_path)
		else:
			print("The specified file is not a valid scene.")
	else:
		print("Scene file not found: " + scene_path)
