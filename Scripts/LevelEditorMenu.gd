extends CanvasLayer

const LEVEL_DIR: String = "res://SavedLevels/"
onready var tab_container: CanvasLayer = get_node("/root/LevelEditor/ItemSelect")
onready var level_editor: Node2D = get_node("/root/LevelEditor/")
onready var level = get_node("/root/LevelEditor/Level")
onready var tile_map : TileMap = level.get_node("TileMap")

onready var visBtn: Button = $VisibilityButton
onready var saveBtn: Button = $SaveButton
onready var loadBtn: Button = $LoadButton
onready var exitBtn: Button = $ExitButton


# Called when the node enters the scene tree for the first time.
func _ready():
	visBtn.connect("pressed", self, "_on_visBtn_pressed")
	saveBtn.connect("pressed", self, "_on_saveBtn_pressed")
	loadBtn.connect("pressed", self, "_on_loadBtn_pressed")
	exitBtn.connect("pressed", self, "_on_exitBtn_pressed")


func _on_visBtn_pressed():
	print("Visibility button pressed")
	if (!Global.filesystem_shown):
			Global.playing = !Global.playing
			tab_container.visible = !Global.playing
	# Your existing or new logic here...

func _on_saveBtn_pressed():
	print("Save button pressed")
	var title		: String = "My awesome level"
	var description	: String = "Welcome to my awesome level"
	var is_initial	: bool = false
	var is_final		: bool = true
	var level		: Node2D = get_node("/root/LevelEditor/Level")
	# Pack scene and save
	var save_path	: String = LEVEL_DIR + title + ".tscn"
	var toSave 		: PackedScene = PackedScene.new()
	toSave.pack(level)
	ResourceSaver.save(save_path, toSave)
	# Request to save to server
	var err = "";
	var ret = "";
	# FIXME remove after adding main menu for user to log in
	if (!Client.LOGGED_IN):
		err = Client.login("LsZCFWRNMl", "PASS")
		ret = yield(Client, "login_completed")
		print(ret.get("code", "not found"))
		# TODO add visual error handling
		if (err != "" or ret.get("code", "not found") != "200"):
			print("Error in logging in.")
		
	err = Client.create_node(title, description, is_initial, is_final, save_path)
	# TODO add visual error handling
	if (err != ""):
		print("Error in saving the level.")

func _on_loadBtn_pressed():
	print("Load button pressed")
	var title		: String = ""
	var description	: String = ""
	var is_initial	: bool = false
	var is_final		: bool = true
	# Pack scene and save
	var load_path	: String = ""
	var toLoad 		: PackedScene = PackedScene.new()
	var err = "";
	var ret = "";
	
	if (!Client.LOGGED_IN):
		err = Client.login("LsZCFWRNMl", "PASS")
		ret = yield(Client, "login_completed")
		print(ret.get("code", "not found"))
		# TODO add visual error handling
		if (err != "" or ret.get("code", "not found") != "200"):
			print("Error in logging in.")
	
	# TODO: add an interface to show all the nodes stored in the server
	# load scenes from the server

	Client.get_level("My awesome level")
	
	## imported from previous load method
	# add it to current scene
	if (err != ""):
		print("Error in saving the level.")
	
	toLoad = ResourceLoader.load(load_path)
	var this_level = toLoad.instance()
	level_editor.remove_child(level)
	level.queue_free()
	
	level_editor.add_child(this_level)
	# Update attributes
	tile_map = level_editor.get_node("Level/TileMap")
	level = this_level

	var node_id: String = ""
	assert(Client.get_level(node_id) == "")
	ret = yield(Client, "get_level_completed")
	assert(ret.get("message", "error") == "level")
		
	# add it to current scene
	# https://forum.godotengine.org/t/how-to-load-a-scene-from-a-filepath/9953/2
	var level_path: String = "res://SavedLevels/" + node_id + ".tscn"
	var loaded_level: PackedScene = load(level_path)
	if loaded_level == null:
		print("Error in loading level " + level_path)
	else:
		get_tree().root.add_child(loaded_level.instance())


func _on_exitBtn_pressed():
	print("Exit button pressed")
	# connect to the main menu
	get_tree().change_scene("res://Scenes/Menu/PlayerMain/PlayerMain.tscn")
	
func _on_request_completed(result, response_code, headers, body):
	if response_code != 200:
		print("Failed to load level from server: ", response_code)
		return

	var packed_scene = PackedScene.new()
	var error = packed_scene.pack(body)
	if error != OK:
		print("Failed to load PackedScene: ", error)
		return

	var scene = packed_scene.instance()
	if scene:
		get_tree().change_scene_to(packed_scene)
	else:
		print("Failed to instance scene.")
		
	
