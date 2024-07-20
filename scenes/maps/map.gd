class_name Map
extends Node2D

@onready var map_image = $Map_Image as Sprite2D
@onready var levels_parent = $Levels as Node

var spawns := {
		"ct": {
			"level": "unset",
			"points": [null] as Array[Node2D]
		},
		"t": {
			"level": "unset",
			"points": [null] as Array[Node2D]
		}
	}

func _ready():
	create_colliders()
	store_spawns()
	print(name + " loaded")

func create_colliders():
	var levels = levels_parent.get_children()
	for i in levels.size():
		var level = levels[i] as Node
		var static_body := StaticBody2D.new()
		level.add_child(static_body)
		
		var nav_layer = level.find_child("Nav") as NavigationRegion2D
		
		for polygon in nav_layer.get_children():
			var collison_polygon := CollisionPolygon2D.new()
			static_body.add_child(collison_polygon)
			
			collison_polygon.polygon = polygon.polygon

func store_spawns():
	var levels = levels_parent.get_children()
	
	for level in levels:
		var spawn_parent := level.find_child("Spawns", false)
		
		if spawn_parent:
			var ct_spawn_parent:= spawn_parent.find_child("CT",false)
			if ct_spawn_parent:
				spawns.ct.level = level.name
				spawns.ct.points = ct_spawn_parent.get_children()
			var t_spawn_parent:= spawn_parent.find_child("T",false)
			if t_spawn_parent:
				spawns.t.level = level.name
				spawns.t.points = t_spawn_parent.get_children()
