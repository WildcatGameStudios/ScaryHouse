extends Node

var score: int = 0
var combo_count: int = 0
var current_levels: Array[String] = ["_RIP"]

# Called when the node enters the scene tree for the first time.
func _ready():
	Shoe_Shine_Signals.IncrementScore.connect(IncrementScore)
	Shoe_Shine_Signals.IncrementCombo.connect(IncrementCombo)
	Shoe_Shine_Signals.ResetCombo.connect(ResetCombo)
	Shoe_Shine_Signals.openLevelSelect.connect(openLevelSelect)
	Shoe_Shine_Signals.startLevel.connect(startLevel)

func IncrementScore(incr: int):
	score += incr
	%ScoreLabel.text = " " + str(score) + " pts."

func IncrementCombo():
	combo_count += 1
	%ComboLabel.text = " " + str(combo_count) + "X combo"
	
func ResetCombo():
	combo_count = 0
	%ComboLabel.text = ""

func openLevelSelect(levels: Array[String]):
	# show correct screen
	$InGameLayer.hide()
	$LevelSelectLayer.show()
	# give player mouse
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# Add levels to this scope
	current_levels = levels
	# Add levels to drop down menu
	%SongSelect.clear()
	for i in range(levels.size()):
		%SongSelect.add_item(levels[i], i)

func startLevel(_level):
	# Correct showing and no mouse
	$LevelSelectLayer.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	$InGameLayer.show()
	# Reset score
	score = 0
	combo_count = 0
	%ScoreLabel.text = " " + str(score) + " pts."
	%ComboLabel.text = " " + str(combo_count) + "X combo"


func _on_start_button_pressed():
	if %SongSelect.get_selected_id() != -1:
		# Start level
		Shoe_Shine_Signals.startLevel.emit(current_levels[%SongSelect.get_selected_id()])
