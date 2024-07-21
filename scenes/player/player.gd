class_name Player
extends CharacterBody2D

@onready var collider = $CollisionShape2D as CollisionShape2D
@onready var nav_agent = $NavigationAgent2D as NavigationAgent2D

enum STATUS {MOVE, SHOOT} #TODO: add more

var size := 5
var team := PlayerController.TEAM.CT
var team_name := "CT"

var level := "unset"

var movemode := PlayerController.MOVEMODE.TARGET
var speed := 100
var acceleration := 7

var nav_target:Vector2

var cone_ray_number := 100
var cone_angle := 90
var cone_distance := 400
var cone_rays: Array[RayCast2D]

var status := STATUS.MOVE
var shoot_target: Player
var time_since_last_shot: float = 0

var health:int = 100
var accuracy:int = 100
var damage:int = 10
var rate_of_fire:int = 600

var gamertag := "default_player"

signal got_damage(damage: int, health: int)
signal died(shooter: Player)

func _ready():
	collider.shape.radius = size
	create_cone()
	#get_rand_nav_point()

func _process(delta):
	check_cones()
	check_shoot(delta)

func _draw():
	draw_circle(Vector2(0,0), size, PlayerController.team_color[team])
	
func create_cone():
	cone_rays = []
	
	for i in cone_ray_number:
		var new_ray := RayCast2D.new()
		var new_ray_angle := (float(cone_angle) / float(cone_ray_number)) * float(i)
		new_ray.exclude_parent = true
		new_ray.target_position = Vector2(0, cone_distance)
		new_ray.rotation = deg_to_rad(new_ray_angle)
		new_ray.collision_mask = Utils.get_collision_layers([1,2,3,4])
		
		add_child(new_ray)
		cone_rays.append(new_ray)

func check_cones():
	var ray_hits: Array[Player]
	
	for ray in cone_rays:
		if ray.is_colliding():
			var ray_collider = ray.get_collider()
			
			if ray_collider is Player:
				if ray_collider.team != team:
					ray_hits.append(ray_collider)
					
	if ray_hits.size() == 0:
		shoot_target = null
		return
	
	if ray_hits.has(shoot_target):
		return
	else:
		shoot_target = ray_hits[int(ray_hits.size() / 2)]

func check_shoot(delta: float):
	time_since_last_shot += delta
	if shoot_target == null:
		status = STATUS.MOVE
		return
	
	status = STATUS.SHOOT
	
	var shots_per_sec: float = rate_of_fire / 60
	var limit: float = 1 / shots_per_sec
	
	if time_since_last_shot < limit:
		return
	
	var hit_roll := randi_range(0, accuracy)
	
	#print(name + " shoots " + shoot_target.name)
	
	if hit_roll > 50:
		shoot_target._on_get_shot(shoot_target, damage, self)
	
	time_since_last_shot = 0

func _on_get_shot(target: Player, damage: int, shooter: Player):
	health -= damage
	
	#print(shooter.gamertag + " hit " + target.gamertag + " for " + str(damage))
	got_damage.emit(damage, health)
	
	if health <= 0:
		died.emit(shooter)
		target.queue_free()
	

func _physics_process(delta):
	if status == STATUS.MOVE:
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
