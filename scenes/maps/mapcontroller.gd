extends Node2D
class_name MapController

@onready var map_selector = $SelectMap as OptionButton

var maps: PackedStringArray
var currentMapName: String
var currentMap: Map

signal map_loaded(currentMap: Map)

func _ready():
	var map_dir := DirAccess.open("res://scenes/maps")
	maps = map_dir.get_directories()
	
	for map in maps:
		map_selector.add_item(map)
		
	load_map(map_selector.get_item_text(0))

func load_map(map_name: String):
	var current_loaded = get_child(2)
	if current_loaded:
		current_loaded.queue_free()
	
	var loaded = load("res://scenes/maps/" + map_name + "/" + map_name + ".tscn") as PackedScene
	var instance := loaded.instantiate() as Map
	
	currentMapName = map_name
	currentMap = instance
	add_child(instance)
	map_loaded.emit(instance)

func _on_select_map_item_selected(index):
	load_map(map_selector.get_item_text(index))
