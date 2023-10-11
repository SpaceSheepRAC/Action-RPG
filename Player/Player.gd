extends KinematicBody2D

const PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")

export var MAX_SPEED = 80
export var ACCELERATION = 500
export var FRICTION = 500
export var ROLL_SPEED = 125

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.RIGHT
var stats = PlayerStats
var input_vector = Vector2.ZERO
var joystick_vector = Vector2.ZERO

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordCollisionShape2D = $Position2D/SwordHitBox/CollisionShape2D
onready var swordHitBox = $Position2D/SwordHitBox
onready var hurtBox = $HurtBox
onready var blinkAnimationPlayer = $BlinkAnimationPlayer

func _ready():
	stats.connect("no_health", self, "queue_free")
	animationTree.active = true
	swordCollisionShape2D.disabled = true
	swordHitBox.knockback_vector = roll_vector

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)

func move_state(delta):
	set_input_vector()
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitBox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move()
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK

func move():
	velocity = move_and_slide(velocity)

func set_input_vector():
	if joystick_vector == Vector2.ZERO:
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	else:
		input_vector = joystick_vector

func roll_state(delta):
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()

func attack_state(delta):
	velocity = Vector2.ZERO
#	move()
	animationState.travel("Attack")

func roll_animation_finished():
	state = MOVE

func attack_animation_finished():
	state = MOVE

func _on_HurtBox_area_entered(area):
	stats.health -= area.damage
	hurtBox.start_invincibility(0.5)#无敌时间
	hurtBox.create_hit_effect()
	var playerHurtSound = PlayerHurtSound.instance()
	get_tree().current_scene.add_child(playerHurtSound)

func _on_HurtBox_invincibility_started():
	blinkAnimationPlayer.play("Start")

func _on_HurtBox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")
	
func _on_Joystick_position_changed(joystick_position):
	joystick_vector = joystick_position
