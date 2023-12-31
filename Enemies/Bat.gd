extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var FRICTION = 200
export var ACCELERATION = 200
export var MAX_SPEED = 50
export var WANDER_TARGET_RANGE = 4

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var state = IDLE

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var softCollsion = $SoftCollsion
onready var hurtBox = $HurtBox
onready var wanderController = $WanderController
onready var animationPlayer = $AnimationPlayer

enum  {
	IDLE,
	WANDER,
	CHASE
}

func _ready():
	randomize()
	pick_random_state([IDLE,WANDER])

func create_enemy_effect():
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
		
		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
			accelerate_towards_point(wanderController.target_position, delta)
			if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_RANGE:
				update_wander()
		
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				accelerate_towards_point(player.global_position, delta)
			else:
				state = IDLE
			sprite.flip_h = velocity.x < 0
	if softCollsion.is_colliding():
		velocity = softCollsion.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func update_wander():
	state = pick_random_state([IDLE,WANDER])
	wanderController.start_wander_timer(rand_range(1, 3))

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_HurtBox_area_entered(area):
	hurtBox.create_hit_effect()
	hurtBox.start_invincibility(0.4)
	stats.health -= area.damage
	knockback = area.knockback_vector * 120

func _on_Stats_no_health():
	create_enemy_effect()
	queue_free()

func _on_HurtBox_invincibility_started():
	animationPlayer.play("Start")

func _on_HurtBox_invincibility_ended():
	animationPlayer.play("Stop")
