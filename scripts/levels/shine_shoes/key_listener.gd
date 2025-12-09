extends Sprite2D

@onready var falling_key = preload("res://scenes/levels/shine_shoes/falling_key.tscn")
@onready var score_text = preload("res://scenes/levels/shine_shoes/score_press_text.tscn")

@export var key_name: String = ""

var falling_key_queue = []

# If distance_from_pass is less than threshold, give that score
var perfect_press_threshold: float = 50
var great_press_threshold: float = 70
var good_press_threshold: float = 90
var ok_press_threshold: float = 110
# otherwise miss

var perfect_press_score: float = 250
var great_press_score: float = 100
var good_press_score: float = 50
var ok_press_score: float = 20

func _ready():
	Shoe_Shine_Signals.CreateFallingKey.connect(CreateFallingKey)
	# When open level select hide key listeners
	Shoe_Shine_Signals.openLevelSelect.connect(onOpenLevelSelect)
	# When start level, show key listeners
	Shoe_Shine_Signals.startLevel.connect(onStartLevel)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_just_pressed(key_name):
		Shoe_Shine_Signals.KeyListenerPress.emit(key_name, frame/2)
		
	
	# Make sure there is a falling key to check for this given key
	if falling_key_queue.size() > 0:
		
		# If that key has passed, remove it from the queue
		if falling_key_queue.front().has_passed:
			falling_key_queue.pop_front()
			
			# Print MISS
			var st_inst = score_text.instantiate()
			get_tree().get_root().call_deferred("add_child", st_inst)
			st_inst.SetTextInfo("MISS")
			st_inst.global_position = global_position + Vector2(0, -20)
			Shoe_Shine_Signals.ResetCombo.emit()
			
		# Else If key is pressed, pop from the queue and calculate distance from critical point
		elif Input.is_action_just_pressed(key_name):
			var key_to_pop = falling_key_queue.pop_front()
			
			var distance_from_pass = abs(key_to_pop.pass_threshold - key_to_pop.global_position.y)
			
			var press_score_text: String = ""
			if distance_from_pass < perfect_press_threshold:
				Shoe_Shine_Signals.IncrementScore.emit(perfect_press_score)
				press_score_text = "PERFECT"
				Shoe_Shine_Signals.IncrementCombo.emit()
			elif distance_from_pass < great_press_threshold:
				Shoe_Shine_Signals.IncrementScore.emit(great_press_score)
				press_score_text = "GREAT"
				Shoe_Shine_Signals.IncrementCombo.emit()
			elif distance_from_pass < good_press_threshold:
				Shoe_Shine_Signals.IncrementScore.emit(good_press_score)
				press_score_text = "GOOD"
				Shoe_Shine_Signals.IncrementCombo.emit()
			elif distance_from_pass < ok_press_threshold:
				Shoe_Shine_Signals.IncrementScore.emit(ok_press_score)
				press_score_text = "OK"
				Shoe_Shine_Signals.IncrementCombo.emit()
			else:
				press_score_text = "MISS"
				Shoe_Shine_Signals.ResetCombo.emit()
			
			key_to_pop.queue_free()
			
			var st_inst = score_text.instantiate()
			get_tree().get_root().call_deferred("add_child", st_inst)
			st_inst.SetTextInfo(press_score_text)
			st_inst.global_position = global_position + Vector2(0, -20)

func CreateFallingKey(button_name: String):
	if button_name == key_name:
		var fk_inst = falling_key.instantiate()
		get_tree().get_root().call_deferred("add_child", fk_inst)
		fk_inst.Setup(position.x, frame + 1)
		
		falling_key_queue.push_back(fk_inst)


func _on_random_spawn_timer_timeout():
	#CreateFallingKey()
	#$RandomSpawnTimer.wait_time = randf_range(0.4, 3)
	#$RandomSpawnTimer.start()
	pass

func onOpenLevelSelect(_levels):
	hide();

func onStartLevel(_levels):
	show()
