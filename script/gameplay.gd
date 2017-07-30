extends Node2D

var alive = false
var highscore = 0
var score = 0
var timer = 0.0
var collectTimer = 0.0
var deathTimer = 0.0
var bgPos = 0.0
var screenshake = 0.0
var spaceTimer = 0.0
var highPrompt = false
var muted = false
var camNode = null
var fore1 = null
var fore2 = null
var back1 = null
var back2 = null
var playerNode = null
var batteryNode = null
var collectSprite = null
var scoreNode = null
var highScoreNode = null
var sfxNode = null
var bgmNode = null
var menuBgm = null
var gameBgm = null
var bClass = null
var lifeBoom = preload("res://scene/lifeboom.tscn")
var deathBoom = preload("res://scene/deathboom.tscn")

func loadScore():
	var saveFile = File.new()
	if !saveFile.file_exists("lfdr.sav"):
		return 0
	saveFile.open("lfdr.sav", File.READ)
	var result = int(saveFile.get_line())
	saveFile.close()
	return result
	
func saveScore():
	var saveFile = File.new()
	saveFile.open("lfdr.sav", File.WRITE)
	saveFile.store_line(str(highscore))
	saveFile.close()
		
func _ready():
	randomize()
	camNode = get_node("Camera")
	fore1 = get_node("Fore1")
	fore2 = get_node("Fore2")
	back1 = get_node("Back1")
	back2 = get_node("Back2")
	playerNode = get_node("Player")
	batteryNode = get_node("Battery")
	collectSprite = get_node("CollectSprite")
	scoreNode = get_node("ScoreLabel")
	highScoreNode = get_node("HighScoreLabel")
	menuBgm = load("res://bgm/dawning.ogg")
	gameBgm = load("res://bgm/unbalance.ogg")
	sfxNode = get_node("SamplePlayer")
	bgmNode = get_node("StreamPlayer")
	bgmNode.set_stream(menuBgm)
	bgmNode.play()
	bClass = load("res://scene/gameplay/battery.tscn")
	var tClass = load("res://scene/title.tscn")
	var title = tClass.instance()
	title.set_pos(Vector2(525.0, 165.0))
	title.set_scale(Vector2(0.5, 0.5))
	add_child(title)
	highscore = loadScore()
	highScoreNode.set_text("HIGH SCORE: " + str(highscore))
	set_process_input(true)
	set_process(true)
	
func _input(event):
	if event.is_action_pressed("mutetoggle"):
		muted = !muted
		if muted:
			AudioServer.set_stream_global_volume_scale(0.0)
			AudioServer.set_fx_global_volume_scale(0.0)
		else:
			AudioServer.set_stream_global_volume_scale(1.0)
			AudioServer.set_fx_global_volume_scale(1.0)
	elif event.is_action_pressed("fulltoggle"):
		OS.set_window_fullscreen(!OS.is_window_fullscreen())
		if OS.is_window_fullscreen():
			OS.set_window_size(OS.get_screen_size())
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		else:
			OS.set_window_size(Vector2(1024, 600))
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event.is_action_pressed("selfdestruct"):
		get_tree().quit()
	elif !alive and deathTimer <= 0.0 and event.is_action_pressed("switch"):
		if highPrompt:
			highPrompt = false
			get_node("GGSprite").show()
			get_node("Title").show()
			get_node("InstructLabel").show()
			bgmNode.set_stream(menuBgm)
			bgmNode.play()
		else:
			playerNode.get_node("LifeForce").get_node("AniPlayer").play("run")
			playerNode.get_node("DeathRun").get_node("AniPlayer").play("run")
			playerNode.show()
			alive = true
			scoreNode.set_text("SCORE: 0")
			get_node("GGSprite").hide()
			get_node("Title").hide()
			get_node("InstructLabel").hide()
			get_node("SpaceLabel").hide()
			bgmNode.set_stream(gameBgm)
			bgmNode.play()
	
func addBooms():
	var lb = lifeBoom.instance()
	var db = deathBoom.instance()
	lb.set_scale(Vector2(1.5, 1.5))
	db.set_scale(Vector2(1.5, 1.5))
	if playerNode.isLifeTop():
		lb.set_pos(Vector2(187.0, 420.0))
		db.set_pos(Vector2(187.0, 180.0))
	else:
		lb.set_pos(Vector2(187.0, 180.0))
		db.set_pos(Vector2(187.0, 420.0))
	add_child(lb)
	add_child(db)
	for i in range(4):
		var lbInstance = lifeBoom.instance()
		var dbInstance = deathBoom.instance()
		lbInstance.set_pos(Vector2(randf() * 64.0 - 32.0, randf() * 64.0 - 32.0))
		dbInstance.set_pos(Vector2(randf() * 64.0 - 32.0, randf() * 64.0 - 32.0))
		var scale = randf() * 0.5 + 0.25
		lbInstance.set_scale(Vector2(scale, scale))
		scale = randf() * 0.5 + 0.25
		dbInstance.set_scale(Vector2(scale, scale))
		var timeScale = randf() * 2.0 + 1.0
		for c in lbInstance.get_children():
			c.set_time_scale(timeScale)
		timeScale = randf() * 2.0 + 1.0
		for c in dbInstance.get_children():
			c.set_time_scale(timeScale)
		lb.add_child(lbInstance)
		db.add_child(dbInstance)

func updateBG(delta):
	var rate = 2048.0
	if score < 100:
		rate = score * 15.36 + 512.0
	bgPos -= delta * rate
	while bgPos < 0.0:
		bgPos += 2048.0
	fore1.set_pos(Vector2(bgPos - 1024.0, 300.0))
	fore2.set_pos(Vector2(bgPos + 1024.0, 300.0))
	back1.set_pos(Vector2(bgPos / 2.0 - 512.0, 300.0))
	back2.set_pos(Vector2(bgPos / 2.0 + 512.0, 300.0))
	
func _process(delta):
	if screenshake > 0.0:
		screenshake -= delta
		if screenshake <= 0.0:
			camNode.set_offset(Vector2(0.0, 0.0))
		else:
			var shakeRate = 64.0
			if score < 200:
				shakeRate = score * 0.3 + 4.0
			camNode.set_offset(Vector2(randf() * shakeRate - shakeRate / 2.0, randf() * shakeRate - shakeRate / 2.0))
	if alive:
		updateBG(delta)
		if collectTimer > 0.0:
			collectTimer -= delta
			var scl = 0.5 + (2.0 - collectTimer * 10.0)
			collectSprite.set_scale(Vector2(scl, scl))
			collectSprite.set_opacity(collectTimer / 0.2)
		gameloop(delta)
		if !alive:
			sfxNode.play("gameover" + str(randi() % 6))
			get_node("bg").show()
			playerNode.get_node("LifeForce").get_node("AniPlayer").set_current_animation("die")
			playerNode.get_node("DeathRun").get_node("AniPlayer").set_current_animation("die")
			addBooms()
			bgmNode.stop()
			deathTimer = 2.0
			if playerNode.isLifeTop():
				playerNode.lifeNode.set_pos(Vector2(-325.0, -120.0))
				playerNode.deathNode.set_pos(Vector2(-325.0, 120.0))
			else:
				playerNode.lifeNode.set_pos(Vector2(-325.0, 120.0))
				playerNode.deathNode.set_pos(Vector2(-325.0, -120.0))
			playerNode.lifeAura.hide()
			playerNode.deathAura.hide()
	else:
		if deathTimer > 0.0:
			if deathTimer == 2.0: 
				OS.delay_msec(750)
				get_node("bg").hide()
				sfxNode.play("explosion")
				batteryNode.remove_child(batteryNode.get_child(0))
			if deathTimer < 1.5:
				get_node("LifeBoom").set_opacity(deathTimer - 0.5)
				get_node("DeathBoom").set_opacity(deathTimer - 0.5)
			deathTimer -= delta
			camNode.set_offset(Vector2((randf() * 64.0 - 32.0) * deathTimer, (randf() * 64.0 - 32.0) * deathTimer))
			if deathTimer <= 0.0:
				scoreNode.set_text("PREV SCORE: " + str(score))
				if score > highscore:
					sfxNode.play("highscore")
					highscore = score
					saveScore()
					scoreNode.set_text("NEW HIGH SCORE!")
					highPrompt = true
				score = 0
				timer = 0.0
				remove_child(get_node("LifeBoom"))
				remove_child(get_node("DeathBoom"))
				camNode.set_offset(Vector2(0.0, 0.0))
				playerNode.lifeAura.show()
				playerNode.deathAura.show()
				playerNode.hide()
				highScoreNode.set_text("HIGH SCORE: " + str(highscore))
				get_node("SpaceLabel").show()
				if !highPrompt:
					get_node("GGSprite").show()
					get_node("Title").show()
					get_node("InstructLabel").show()
					bgmNode.set_stream(menuBgm)
					bgmNode.play()
		else:
			spaceTimer += delta
			var spaceMod = int(spaceTimer * 1000.0) % 2500
			if spaceMod < 125:
				get_node("SpaceLabel/SpaceSprite").set_offset(Vector2(0.0, spaceMod / 8.0))
			elif spaceMod < 250:
				get_node("SpaceLabel/SpaceSprite").set_offset(Vector2(0.0, (250.0 - spaceMod) / 8.0))
		
func gameloop(delta):
	var prevTimer = timer
	timer += delta
	if timer < 2.0:
		playerNode.set_pos(Vector2(timer * 200.0 + 112.0, 300.0))
	elif prevTimer < 2.0:
		playerNode.set_pos(Vector2(512.0, 300.0))
	if batteryNode.get_child_count() > 0:
		batteryNode.get_child(0).update(delta)
		if batteryNode.get_child(0).isCollect():
			if batteryNode.get_child(0).isTop():
				if batteryNode.get_child(0).isLife():
					if !playerNode.isLifeTop():
						alive = false
				else:
					if playerNode.isLifeTop():
						alive = false
			else:
				if batteryNode.get_child(0).isLife():
					if playerNode.isLifeTop():
						alive = false
				else:
					if !playerNode.isLifeTop():
						alive = false
			if alive:
				var voiceID = sfxNode.play("collect")
				if score < 450:
					sfxNode.set_pitch_scale(voiceID, 1.0 + score / 50.0)
				else:
					sfxNode.set_pitch_scale(voiceID, 10.0)
				score += 1
				var scl = score * 0.015 + 1.0
				playerNode.lifeAura.set_scale(Vector2(scl, 1.0))
				playerNode.deathAura.set_scale(Vector2(scl, 1.0))
				playerNode.lifeAura.set_pos(Vector2(-290.0 - scl * 100.0, playerNode.lifeAura.get_pos().y))
				playerNode.deathAura.set_pos(Vector2(-290.0 - scl * 100.0, playerNode.deathAura.get_pos().y))
				screenshake = 0.1666
				scoreNode.set_text("SCORE: " + str(score))
				collectTimer = 0.2
				collectSprite.set_scale(Vector2(1.0, 1.0))
				collectSprite.set_opacity(1.0)
				if batteryNode.get_child(0).isTop():
					collectSprite.set_pos(Vector2(187.0, 180.0))
				else:
					collectSprite.set_pos(Vector2(187.0, 420.0))
				if batteryNode.get_child(0).isLife():
					collectSprite.set_modulate(Color(1.0, 0.7, 0.95))
				else:
					collectSprite.set_modulate(Color(0.7, 0.95, 1.0))
				batteryNode.remove_child(batteryNode.get_child(0))
	if alive and batteryNode.get_child_count() == 0 and timer >= 2.0:
		var b = bClass.instance()
		b.init(randi() % 2 == 0, randi() % 2 == 0, 4.2 * score + 880.0)
		batteryNode.add_child(b)