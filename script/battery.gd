extends Node2D

var life
var top
var auraNode
var timer = 1050.0
var auraTimer = 0.0
var frame = 0
var rate = 1.0

func _ready():
	pass

func init(l, t, r):
	auraNode = get_node("AuraSprite")
	life = l
	top = t
	rate = r
	var scl = (rate - 880.0) / 280.0 + 1.0
	auraNode.set_scale(Vector2(scl, 1.0))
	auraNode.set_offset(Vector2(scl * 64.0 - 64.0, 0.0))
	if life:
		get_node("Sprite").set_modulate(Color(1.0, 0.5, 1.0))
		auraNode.set_modulate(Color(1.0, 0.5, 1.0))
	else:
		get_node("Sprite").set_modulate(Color(0.5, 1.0, 1.0))
		auraNode.set_modulate(Color(0.5, 1.0, 1.0))
	if top:
		set_pos(Vector2(1050.0, 180.0))
	else:
		set_pos(Vector2(1050.0, 420.0))
		
func isCollect():
	return timer <= 200.0
	
func isTop():
	return top
	
func isLife():
	return life
		
func update(delta):
	timer -= delta * rate
	set_pos(Vector2(timer, get_pos().y))
	var rotation = sin(timer / 96.0) * 0.392699
	if !top:
		rotation += 3.1415
	get_node("Sprite").set_rot(rotation)
	
	auraTimer += delta
	if auraTimer >= 0.075:
		auraTimer -= 0.075
		auraNode.set_flip_v(randi() % 2 == 0)
		auraNode.set_frame(frame % (auraNode.get_vframes() * auraNode.get_hframes()))
		frame += 1