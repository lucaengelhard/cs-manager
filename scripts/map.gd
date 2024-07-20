class_name Map

extends Node2D

var levelColliders: Array[StaticBody2D]
var levelData: CanvasGroup
var levelColliderGroup: CanvasGroup
var levels: Array[Node]

@export var areas: CanvasGroup
@export var ctSpawn: Area2D
@export var tSpawn: Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	create_colliders()

func create_colliders():
	levelData = find_child("Level_Data")
	levelColliderGroup = find_child("Level_Collider")
	levels = levelData.get_children()
	
	
	for i in levels.size():
		var level := levels[i]
		levelColliderGroup.add_child(StaticBody2D.new())
		var StaticBody := levelColliderGroup.get_children()[i]
		var levelPolygons: Array[PackedVector2Array]
		for polygon in level.get_children():
			if polygon is Polygon2D:
				levelPolygons.append(polygon.polygon)
				StaticBody.add_child(CollisionPolygon2D.new())


		var colliders := StaticBody.get_children()
		for c in colliders.size():
			var collider = colliders[c]
			var polygon = levelPolygons[c]
			if collider is CollisionPolygon2D:
				collider.polygon = levelPolygons[c]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
