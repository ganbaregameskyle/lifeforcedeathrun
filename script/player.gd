extends Node2D

var lifeNode
var deathNode
var lifeAura
var deathAura
var lifeTop = true
var timer = 0.0
var shiftTimer = 0.0
var frame = 1

func _ready():
	set_process_input(true)
	set_process(true)
	lifeAura = get_node("LifeAura")
	deathAura = get_node("DeathAura")
	var l = load("res://scene/gameplay/lifeforce.tscn")
	var life = l.instance()
	add_child(life)
	lifeNode = get_node("LifeForce")
	lifeNode.set_scale(Vector2(0.65, 0.65))
	lifeNode.set_pos(Vector2(-325.0, -120.0))
	var d = load("res://scene/gameplay/deathrun.tscn")
	var death = d.instance()
	add_child(death)
	deathNode = get_node("DeathRun")
	deathNode.set_scale(Vector2(0.65, -0.65))
	deathNode.set_pos(Vector2(-325.0, 120.0))
	
func _input(event):
	if event.is_action_pressed("switch") and lifeNode.get_node("AniPlayer").get_current_animation() != "die":
		var voiceID = get_node("..").get_node("SamplePlayer").play("shift")
		lifeTop = not lifeTop
		shiftTimer = 0.1
		lifeAura.set_flip_v(!lifeAura.is_flipped_v())
		deathAura.set_flip_v(!deathAura.is_flipped_v())
		if lifeTop:
			get_node("..").get_node("SamplePlayer").set_pitch_scale(voiceID, 1.5)
			lifeNode.set_pos(Vector2(-325.0, -120.0 + 200.0))
			lifeAura.set_pos(Vector2(-390.0, -135.0 + 200.0))
			deathNode.set_pos(Vector2(-325.0, 120.0 - 200.0))
			deathAura.set_pos(Vector2(-390.0, 135.0 - 200.0))
			lifeNode.set_scale(Vector2(0.65, 0.65))
			deathNode.set_scale(Vector2(0.65, -0.65))
		else:
			get_node("..").get_node("SamplePlayer").set_pitch_scale(voiceID, 0.5)
			lifeNode.set_pos(Vector2(-325.0, 120.0 - 200.0))
			lifeAura.set_pos(Vector2(-390.0, 135.0 - 200.0))
			deathNode.set_pos(Vector2(-325.0, -120.0 + 200.0))
			deathAura.set_pos(Vector2(-390.0, -135.0 + 200.0))
			lifeNode.set_scale(Vector2(0.65, -0.65))
			deathNode.set_scale(Vector2(0.65, 0.65))
			
func isLifeTop():
	return lifeTop
	
func _process(delta):
	if shiftTimer > 0.0 and get_node("..").alive:
		shiftTimer -= delta
		if shiftTimer < 0.0:
			shiftTimer = 0.0
		var scl = get_node("..").score * 0.015 + 1.0
		lifeAura.set_scale(Vector2(scl + shiftTimer * 12.0, 1.0))
		deathAura.set_scale(Vector2(scl + shiftTimer * 12.0, 1.0))
		if lifeTop:
			lifeNode.set_pos(Vector2(-325.0, -120.0 + shiftTimer * 2000.0))
			lifeAura.set_pos(Vector2(-290.0 - scl * 100.0, -135.0 + shiftTimer * 2000.0))
			deathNode.set_pos(Vector2(-325.0, 120.0 - shiftTimer * 2000.0))
			deathAura.set_pos(Vector2(-290.0 - scl * 100.0, 135.0 - shiftTimer * 2000.0))
		else:
			lifeNode.set_pos(Vector2(-325.0, 120.0 - shiftTimer * 2000.0))
			lifeAura.set_pos(Vector2(-290.0 - scl * 100.0, 135.0 - shiftTimer * 2000.0))
			deathNode.set_pos(Vector2(-325.0, -120.0 + shiftTimer * 2000.0))
			deathAura.set_pos(Vector2(-290.0 - scl * 100.0, -135.0 + shiftTimer * 2000.0))
	timer += delta
	if timer >= 0.075:
		timer -= 0.075
		lifeAura.set_frame(frame % (lifeAura.get_vframes() * lifeAura.get_hframes()))
		deathAura.set_frame((frame + 4) % (deathAura.get_vframes() * deathAura.get_hframes()))
		frame += 1