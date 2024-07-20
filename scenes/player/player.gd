class_name Player
extends CharacterBody2D

@onready var collider = $CollisionShape2D as CollisionShape2D
@onready var nav_agent = $NavigationAgent2D as NavigationAgent2D

var size := 5
var team := PlayerController.TEAM.CT

var level := "unset"

var movemode := PlayerController.MOVEMODE.TARGET
var speed := 100
var acceleration := 7

var nav_target:Vector2

func _ready():
	collider.shape.radius = size
	#get_rand_nav_point()

func _draw():
	draw_circle(Vector2(0,0), size, PlayerController.team_color[team])
	
func _physics_process(delta):
	var direction := Vector2()
	nav_target = get_new_nav_target()
	
	nav_agent.target_position = nav_target
	nav_agent.debug_enabled = true #TODO: disable
	direction = nav_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	velocity = velocity.lerp(direction * speed, acceleration * delta)
	rotation = velocity.angle() - 90
	
	move_and_slide()

func get_new_nav_target() -> Vector2:
	if movemode == PlayerController.MOVEMODE.MOUSE:
		return get_global_mouse_position()
	elif movemode == PlayerController.MOVEMODE.RANDOM:
		return Vector2(0,0) #TODO
	else:
		return Vector2(0,0)

# TODO:
func get_rand_nav_point():
	var currentMap = get_parent().get_parent().find_child("MapController").currentMap as Map
	var levels = currentMap.find_child("Levels").get_children()
	var rand_level = levels[randi_range(0, levels.size() - 1)]
	var rand_level_nav = rand_level.find_child("Nav") as NavigationRegion2D
	
	print(rand_level_nav.navigation_polygon.polygons)
