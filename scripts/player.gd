class_name Player

extends CharacterBody2D

enum TEAM {CT, T}
enum MOVEMODE {Mouse, Random}

const self_scene = preload("res://scenes/player.tscn")

var player_id: int

# draw player
@export_group("Player")
@export var team: TEAM = TEAM.CT
@export var size := 7
@onready var collider := $Collider

# init nav
@onready var nav := $NavigationAgent2D
@export var speed := 100
@export var accel := 7
@export var movemode := MOVEMODE.Mouse # Change default later
@onready var target := get_new_target()

# init Vision
@export_group("Vision")
@export_range(0, 360) var Angle := 90
@export var Distance := 500
@export var RayNumber := 100
@onready var rays: Array[RayCast2D] = [] 

var rayHits: Array[Player] = [] #TODO: Setter that makes this a Set
var visionTarget: Player = null
var visionTargetAngle:float= 0

var timeSinceLastShot:float = 0

@export_group("Player Stats")
@export var accuracy := 100
@export var health := 100
@export var rateOfFire:float= 600

signal player_dead(player: Player)

var timeSinceLastRedirect: float = 0

func _ready():
	create_cone()

func _process(delta):
	if health == 0:
		print(name + " died")
		queue_free()
		player_dead.emit(self)
	check_rays()
	rotate_to_target()
	if visionTarget != null:
		shoot(visionTarget, delta)

func _draw():
	var color = Color.GREEN
	if team == TEAM.CT:
		color = Color.BLUE
	elif team == TEAM.T:
		color = Color.RED
	collider.shape.radius = size
	draw_circle(Vector2(0,0), size, color)

#navigation
func _physics_process(delta):
	nav_to_point(delta)
	
	if movemode == MOVEMODE.Mouse:
		target = get_new_target()
		
	if movemode == MOVEMODE.Random:
		timeSinceLastRedirect += delta
		if timeSinceLastRedirect >= 10:
			get_new_target()
			timeSinceLastRedirect = 0

func nav_to_point(delta:float):
	var direction := Vector2()
	if visionTarget != null:
		velocity = Vector2(0,0)
		rotation = visionTargetAngle - 90
	else:
		nav.target_position = target
	
		direction = nav.get_next_path_position() - global_position
		direction = direction.normalized()
	
		velocity = velocity.lerp(direction * speed, accel * delta)
		rotation = velocity.angle() - 90
	
	move_and_slide()

func get_new_target() -> Vector2:
	if movemode == MOVEMODE.Mouse:
		return get_global_mouse_position()
	elif movemode == MOVEMODE.Random:
		return get_new_random_target()
	else:
		return Vector2(0,0)

func get_new_random_target() -> Vector2:
	var game := get_parent()
	var map = game.find_child("Map")

	if map == null:
		return Vector2(get_viewport_rect().size / 2)
	
	var currentMap = map.get_child(0)
	var mapSize:Vector2 = currentMap.texture.get_size()
	var currentMapPos:Vector2 = currentMap.global_position
	
	return Vector2(
		randi_range(
			currentMapPos.x - (mapSize.x - 20) / 2, currentMapPos.x + mapSize.x / 2),
		randi_range(
			currentMapPos.y - mapSize.y / 2, currentMapPos.y + mapSize.y /2)
			)

func _on_navigation_agent_2d_target_reached():
	target = get_new_target()

#viewcones
func create_cone():
	for i in range(RayNumber):
		add_child(RayCast2D.new())
	
	var children := get_children()
	
	var newRays: Array[RayCast2D] = []
	
	for child in children:	
		if child is RayCast2D:
			newRays.append(child)
	
	for i in newRays.size():
		var ray := newRays[i]
		var rayAngle := (float(Angle) / float(RayNumber)) * float(i)
		ray.exclude_parent = true
		ray.target_position = Vector2(0, Distance)
		ray.rotation = deg_to_rad(rayAngle)
		ray.collision_mask = pow(2, 1-1) + pow(2, 2-1)
			
	rays = newRays

func check_rays():
	if rayHits.size() > 0:
		if visionTarget in rayHits:
			pass
		else:
			visionTarget = rayHits[0]
		
	rayHits = []
	#TODO: remove visionTarget if leaving cone
	for ray in rays:
		if !ray.is_colliding():
			#ray.target_position = Vector2(0, Distance)
			return
			
		var rayCollider := ray.get_collider()
		#var collidePoint := ray.get_collision_point()
		#
		#var newDistance := global_position.distance_to(collidePoint)
		#ray.target_position = Vector2(0, newDistance)
		
		
		if rayCollider is Player:
			if rayCollider.team == team:
				pass
			elif rayCollider.team != team:
				if rayCollider in rayHits:
					pass
				else:
					rayHits.append(rayCollider)

func rotate_to_target():
	if (visionTarget == null):
		return
	var targetPosition := visionTarget.global_position
	var visionTargetVector := targetPosition - global_position
	visionTargetAngle = visionTargetVector.angle()

func shoot(shootTarget: Player, delta: float):
	timeSinceLastShot += delta
	var perSec := rateOfFire / 60
	var limit := 1 / perSec

	if timeSinceLastShot < limit:
		return
	
	var hitValue := randi_range(0, accuracy)
	print(name + " shoots " + shootTarget.name + " " + str(shootTarget.health))
	
	if hitValue > 50:
		# replace with signal
		shootTarget.health = shootTarget.health - 10
	
	timeSinceLastShot = 0
