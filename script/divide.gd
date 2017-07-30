extends Sprite

var timer = 0.0
var frame = 0

func _ready():
	set_process(true)
	
func _process(delta):
	timer += delta
	if timer > 0.075:
		timer -= 0.075
		set_flip_h(randi() % 2 == 0)
		set_flip_v(randi() % 2 == 0)
		set_frame(frame % get_vframes())
		frame += 1