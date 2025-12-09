extends Control

# perfect 	ffbe00
const PERFECT_COLOR: String = "ffbe00"
# great		e2dd25
const GREAT_COLOR: String = "e2dd25"
# good		a7dd25
const GOOD_COLOR: String = "a7dd25"
# ok		8dbfc7
const OK_COLOR: String = "8dbfc7"
# miss		5a5758
const MISS_COLOR: String = "5a5758"


func SetTextInfo(text: String):
	$ScoreTextLabel.text = "[center]" + text
	
	match text:
		"PERFECT":
			$ScoreTextLabel.set("theme_override_colors/default_color", Color(PERFECT_COLOR))
		"GREAT":
			$ScoreTextLabel.set("theme_override_colors/default_color", Color(GREAT_COLOR))
		"GOOD":
			$ScoreTextLabel.set("theme_override_colors/default_color", Color(GOOD_COLOR))
		"OK":
			$ScoreTextLabel.set("theme_override_colors/default_color", Color(OK_COLOR))
		"MISS":
			$ScoreTextLabel.set("theme_override_colors/default_color", Color(MISS_COLOR))
