extends Node

# Set this constant before game start
var levels: Array[String] = []

# IF File fails to load set defauts
const DEFAULT_MUSIC = preload("res://scenes/levels/shine_shoes/Music/RIP.wav")
var DEFAULT_FILE = FileAccess.open("res://scenes/levels/shine_shoes/Music/RIP.txt", FileAccess.READ)

@onready var music_player = $MusicPlayer
const PETTER_GUN_RIP_1_MIN = preload("res://scenes/levels/shine_shoes/Music/RIP.wav")

# Time it takes for falling key to reach critical spot
const fk_fall_time: float = 2

#	Level_info dictionary
#	"Level_name": {
#		"fk_times": "[[...]...]"
#		"music": (Audio_Stream)
#	}
var level_info = {
	
}

#"RIP": {
#		"fk_times": "[[8.89306163787842, 15.6007251739502, 18.8979587554932, 19.5916557312012, 21.7569160461426, 26.0003623962402, 32.6586837768555, 35.973331451416, 36.6467132568359, 38.5652618408203, 40.6782760620117, 42.8116111755371, 44.9565544128418, 51.5916557312012, 51.8470764160156, 52.4217681884766, 52.9674377441406, 53.765625, 54.0007247924805, 54.5231742858887, 55.100772857666, 55.8467102050781], [6.75972747802734, 11.0902490615845, 13.4470748901367, 15.8474369049072, 17.8414516448975, 18.5467567443848, 19.3246250152588, 19.847074508667, 21.9804077148438, 23.8786392211914, 28.1453056335449, 30.5340576171875, 32.9228134155273, 34.8878021240234, 35.5698852539063, 36.3912925720215, 36.925350189209, 38.7916564941406, 40.9336967468262, 43.0583229064941, 45.211971282959, 47.3336944580078, 52.1228103637695, 53.5102043151855, 54.2880706787109, 55.5999984741211], [13.2119731903076, 16.1463947296143, 16.3902034759521, 16.7733325958252, 17.1361446380615, 17.4263954162598, 18.2478008270264, 30.2786407470703, 33.213062286377, 33.4568710327148, 33.8719291687012, 34.2144203186035, 34.5133781433105, 35.3144683837891, 39.0673904418945, 41.2239456176758, 43.3340606689453, 45.47900390625, 52.7207260131836, 53.2663955688477, 54.8221321105957, 55.3678016662598]]",
#		"music": PETTER_GUN_RIP_1_MIN
#	}

# Path to tracklist file
@export var trackList: String = "res://scenes/levels/shine_shoes/Music/_trackList.txt"

# Called when the node enters the scene tree for the first time.
func _ready():
	getLevels()
	buildLevelInfo(levels)
	Shoe_Shine_Signals.startLevel.connect(startLevel)
	Shoe_Shine_Signals.openLevelSelect.emit(levels)

func getLevels():
	var file = FileAccess.open(trackList, FileAccess.READ)
	if file == null:
		return
	
	while file.get_position() < file.get_length():
		levels.append(file.get_line())

func startLevel(level: String):
	var music_stream = level_info.get(level).get("music")
	
	var fk_times = level_info.get(level).get("fk_times")
	var fk_times_arr = str_to_var(fk_times)
	
	music_player.stream = music_stream
	music_player.play()
	
	var counter: int = 0
	for key in fk_times_arr:
		
		var button_name: String = ""
		match counter:
			0:
				button_name = "Shine_left"
			1:
				button_name = "Shine_middle"
			2:
				button_name = "Shine_right"
		
		for delay in key:
			SpawnFallingKey(button_name, delay)
		
		counter += 1
	pass

func SpawnFallingKey(button_name: String, delay: float):
	await  get_tree().create_timer(delay).timeout
	Shoe_Shine_Signals.CreateFallingKey.emit(button_name)

func buildLevelInfo(levelNames: Array[String]):
	# For each levelName
	for name in levelNames:
		# Make new dictionary
		var current: Dictionary = {}
		# Open file
		var file = FileAccess.open("res://scenes/levels/shine_shoes/Music/" + name + ".txt", FileAccess.READ)
		# Check open
		if file == null:
			file  = DEFAULT_FILE
		# Get falling times string
		var fk_times = getFK_times(file)
		# Add fk_times to dictionary
		current["fk_times"] = fk_times
		# Load wav file
		var music = load("res://scenes/levels/shine_shoes/Music/" + name + ".wav")
		# Check load
		if music == null:
			music = DEFAULT_MUSIC
		# Add music to dictionary
		current["music"] = music
		# Add level_name to level_info
		level_info[name] = current
	return

func getFK_times(file: FileAccess) -> String:
	const ERROR = ["ERROR"]
	# Get times from file
	var channel_times: Array = readMusicFile(file)
	# Adjust times for falling
	for channel in channel_times:
		for i in range(channel.size()):
			channel[i] -= fk_fall_time
	
	# Turn into string
	var fk_times: String = str(channel_times)
	
	return fk_times

func readMusicFile(file: FileAccess) -> Array:
	const ERROR = ["ERROR"]
	# tokenize file
	var token_lines = tokenizeMusicFile(file)
	
	# parse tokens for times
	var channel_times = parseMusicTokens(token_lines)
	
	return channel_times

func tokenizeMusicFile(file: FileAccess) -> Array:
	const ERROR = ["ERROR"]
	# Types of Tokens:
	#	alpha
	#	num
	#	punctuation:
	#		'-'   '='   ':'   '/'   ','   ';'
	#	end-line
	const ALPHA_TYPE = "A"
	const NUM_TYPE = "N"
	const PUNCT_TYPE = "P"
	const ENDL_TYPE = "E"
	const VALID_ALPHA = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j',
						'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't',
						'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D',
						'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N',
						'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
						'Y', 'Z', '_']
	const VALID_NUM = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.']
	const VALID_PUNCT = ['-', '=', ':', '/']
	const VALID_WHITE_SPACE = [' ', '\t', ',']
	
	# Each token is a dictionary with entries "type" and "data"
	# 	type corrosponds with one of the types listed above
	#	data depends on type:
	#		ALPHA: string of alphabetical characters and _
	#		NUM: either intigers or floats
	#		PUNCT: one of the characters in VALID_PUNCT
	const TYPE: String = "type"
	const DATA: String = "data"
	const BLANK_TOKEN: Dictionary = {TYPE: "", DATA: ""}
	
	# Make array for lines of tokens
	var token_lines: Array = []
	
	# While file can still be read
	var line_i = 0
	while file.get_position() < file.get_length():
		line_i += 1
		# read line from file
		var str_line: String = file.get_line()
		
		# Make array for tokens
		var token_line: Array[Dictionary] = []
		
		# Make tokens
		# for each character
		var i = 0;
		while(i < str_line.length()):
			var char = str_line[i]
			# if comment
			if char == '#':
				# end reading this line
				break;
			# elif whitespace
			elif char in VALID_WHITE_SPACE:
				# ignore
				i += 1
			# elif numarical
			elif char in VALID_NUM:
				# make number token (include decimal point if there)
				var token = BLANK_TOKEN.duplicate()
				token.set(TYPE, NUM_TYPE)
				# extract data for number type
				var data = ""
				while char in VALID_NUM:
					data += char
					i += 1
					if(i < str_line.length()):
						char = str_line[i]
					else:
						break
				# make sure is a valid number and cast
				if data.is_valid_int():
					data = int(data)
				elif data.is_valid_float():
					data = float(data)
				else:
					# Print error and return error
					print("Invalid Number token at row: " + str(line_i) + 
							" col: " + str(i-data.length() + 1))
					return ERROR
				# add data to token
				token.set(DATA, data)
				# add token to line
				token_line.append(token)
			# elif alphabetical
			elif char in VALID_ALPHA:
				# make alphabet token
				var token = BLANK_TOKEN.duplicate()
				token.set(TYPE, ALPHA_TYPE)
				# extract data for alpha type
				var data = ""
				while char in VALID_ALPHA:
					data += char
					i += 1
					if i < str_line.length():
						char = str_line[i]
					else:
						break
				# add data to token
				token.set(DATA, data)
				# add token to line
				token_line.append(token)
			# elif puctuation
			elif char in VALID_PUNCT:
				# make punctuation token
				var token = BLANK_TOKEN.duplicate()
				token.set(TYPE, PUNCT_TYPE)
				# add data to token
				token.set(DATA, char)
				# add token to line
				token_line.append(token)
				i += 1
			# else error
			else:
				print("Invalid character at row: " + str(line_i) + 
							" col: " + str(i + 1))
				return ERROR
		# Add the line of tokens to the array of token lines if there are tokens
		if token_line.size() > 0:
			# Also append endl token
			var endl_token = BLANK_TOKEN.duplicate()
			endl_token.set(TYPE, ENDL_TYPE)
			token_line.append(endl_token)
			token_lines.append(token_line)
	return token_lines

func parseMusicTokens(token_lines: Array) -> Array:
	# constants
	const ERROR = ["ERROR"]
	const ALPHA_TYPE = "A"
	const NUM_TYPE = "N"
	const PUNCT_TYPE = "P"
	const ENDL_TYPE = "E"
	const TYPE: String = "type"
	const DATA: String = "data"
	const VARS: Dictionary = {
		"BPM": "BPM",
		"NUM": "NUM",
		"N_CHAN": "N_CHANNELS"
	}
	# In file variables
	var BPM: float = 120.0
	var NUM: int = 4
	var N_CHANNELS: int = 1
	
	# Timeline variables
	var timeFromStart: float = 0.0	# The time of the next beat
	var currMeasure: int = 0	# The current measure you are on (0 at start)
		# Defined within a measure
	var currBeat: int = 0		# The current beat you are on (1 at new measure)
	var beatDivision: int = 0	# The number of subdivision in the current beat (0 at new measure)
		# Definced within a beat
	var currChannel: int = -1	# The channel you just wrote to (-1 at new beat)
	var currSubDiv: int = 0		# The subdivision you are on (0 at new beat)
	
	# The output
	var channel_times: Array = []
	
	# Make sure we weren't given error
	if token_lines == ERROR:
		print("Given ERROR as parsing input!")
		return ERROR
	
	# Parsing Loop
	# Through every line
	var i: int = 0
	while i < token_lines.size():
		var line: Array = token_lines[i]
		
		# Go through each token Parsing groups of tokens
		var j: int = 0
		while j < line.size():
			var initToken = line[j]
			
			# if Alpha token try to define variable
			if initToken.get(TYPE) == ALPHA_TYPE:
				# Make sure next token is '='
				j += 1
				if line[j].get(TYPE) == PUNCT_TYPE and line[j].get(DATA) == '=':
					# Make sure next token is NUM
					j += 1
					if line[j].get(TYPE) == NUM_TYPE:
						var data = line[j].get(DATA)
						# Set var types based off of initToken
						match initToken.get(DATA):
							VARS.BPM:
								# Make sure greater than 0
								if data <= 0:
									print("BPM must be > 0: Line: " + str(i) + ", Token: " + str(j))
									return ERROR
								BPM = data
							VARS.NUM:
								# ERROR if not int
								if not (data is int):
									print("Expected Int, got " + str(typeof(data)) +
											"Line: " + str(i) + ", Token: " + str(j))
									return ERROR
								# ERROR if not > 0
								if data <= 0:
									print("NUM must be > 0: Line: " + str(i) + ", Token: " + str(j))
									return ERROR
								# Otherwise set value
								NUM = data
							VARS.N_CHAN:
								# ERROR if not int
								if not (data is int):
									print("Expected Int, got " + str(typeof(data)) +
											"Line: " + str(i) + ", Token: " + str(j))
									return ERROR
								# ERROR if not > 0
								if data <= 0:
									print("N_CHANNELS must be > 0: Line: " + str(i) + ", Token: " + str(j))
									return ERROR
								# Otherwise set value
								N_CHANNELS = data
							_:
								# Anything else gets error
								print("UNKNOWN VAR: " + initToken.get(DATA) +
								": Line: " + str(i) + ", Token: " + str(j))
			# if number token see what time we are defining
			elif initToken.get(TYPE) == NUM_TYPE:
				# Get data
				var data = initToken.get(DATA)
				# Make sure data is an int
				if not (data is int):
					print("Expected Int, got " + str(typeof(data)) +
							"Line: " + str(i) + ", Token: " + str(j))
					return ERROR
				# Make sure next token is punctuation
				j += 1
				var punctToken = line[j]
				if (punctToken.get(TYPE) != PUNCT_TYPE):
					print("Expected punctuation after int on Line: " + str(i) +
							", Token: " + str(j))
					return ERROR
				# Go into different cases based on punctuation
				match punctToken.get(DATA):
					# ':' means new measure
					':':
						# Make sure measure is > current
						var newMeasure = data
						if newMeasure <= currMeasure:
							print("New Measure must be > previous! Line: " + 
							str(i) + " Token: " + str(j))
						# calculate beats skipped
						# Get beats from multiple measures
						var skippedBeats: float = NUM * (newMeasure - currMeasure - 1)
						# If current measure != 0, add remaing beats in measure
						if currMeasure != 0:
							# If current beat == 0, add all beats in a measure
							if currBeat == 0:
								skippedBeats += NUM
							# Else add remaing subdivision an beats
							else:
								skippedBeats += (NUM - currBeat) + ((beatDivision - currSubDiv) / float(beatDivision))
						# Adjust time
						var BPS: float = BPM / 60.0
						var seconds = skippedBeats / BPS
						timeFromStart += seconds
						# Set measure
						currMeasure = newMeasure
						# Reset current beat and subivision
						currBeat = 0
						beatDivision = 0
						currChannel = -1
						currSubDiv = 0
					# '/' means new beat
					'/': 
						var newBeat = data
						# Make sure current measure is not 0
						if currMeasure == 0:
							print("Must be in a measure before defining a beat! Line: " +
							str(i) + " Token: " + str(j))
							return ERROR
						# Make sure next token is number
						j += 1
						var subDivToken = line[j]
						if subDivToken.get(TYPE) != NUM_TYPE:
							print("Expected number after '/'. Line: " +
							str(i) + " Token: " + str(j))
							return ERROR
						# Get data from token
						var newBeatDiv = subDivToken.get(DATA)
						# Make sure data is int
						if not (newBeatDiv is int):
							print("Expected Int, got " + str(typeof(newBeatDiv)) +
							"Line: " + str(i) + ", Token: " + str(j))
							return ERROR
						# Make sure next token is '='
						j += 1
						var equalSignToken = line[j]
						if not (equalSignToken.get(TYPE) == PUNCT_TYPE and equalSignToken.get(DATA) == '='):
							print("Expected '=' after beat decleration. " + 
							"Line: " + str(i) + ", Token: " + str(j))
							return ERROR
						# Make sure beat is > current and <= NUM
						if not (newBeat > currBeat and newBeat <= NUM):
							print("Invalid beat # of " + str(newBeat) + 
							"Line: " + str(i) + ", Token: " + str(j))
							return ERROR
						# Make sure division > 0
						if not (newBeatDiv > 0):
							print("Invalid division # of " + str(newBeat) + 
							"Line: " + str(i) + ", Token: " + str(j))
							return ERROR
						# calculate beats skipped
						var skippedBeats: float = (newBeat - currBeat - 1)
						# if currBeat != 0 add subdivision skipped
						if currBeat != 0:
							skippedBeats += ((beatDivision - currSubDiv) / float(beatDivision))
						# Adjust time
						var BPS: float = BPM / 60.0
						var seconds = skippedBeats / BPS
						timeFromStart += seconds
						# Set beat and division
						currBeat = newBeat
						beatDivision = newBeatDiv
						currChannel = -1
						currSubDiv = 0
					# '-' means new pulse
					'-':
						var channel = data
						# Make sure current measure is != 0
						if currMeasure == 0:
							print("Must be in a measure before defining a pulse! Line: " +
							str(i+1) + " Token: " + str(j))
							return ERROR
						# Make sure current beat is != 0
						if currBeat == 0:
							print("Must be in a beat before defining a pulse! Line: " +
							str(i+1) + " Token: " + str(j))
							return ERROR
						# Make sure next token is number
						j += 1
						var subDivToken = line[j]
						if subDivToken.get(TYPE) != NUM_TYPE:
							print("Expected number after '/'. Line: " +
							str(i+1) + " Token: " + str(j))
							return ERROR
						# Get data from token (subdivision)
						var newSubDiv = subDivToken.get(DATA)
						# Make sure data is int
						if not (newSubDiv is int):
							print("Expected Int, got " + str(typeof(newSubDiv)) +
							". Line: " + str(i+1) + ", Token: " + str(j))
							return ERROR
						# Make sure subdivision is >= current and less than beatDivision
						if not (newSubDiv >= currSubDiv and newSubDiv < beatDivision):
							print("Invalid subdivision of " + str(newSubDiv) +
							". Line: " + str(i+1) + ", Token: " + str(j))
							return ERROR
						# If subdivision == current, make sure channel is > current
						if newSubDiv == currSubDiv and not (channel > currChannel):
							print("Invalid Channel of " + str(channel) +
							". Line: " + str(i+1) + ", Token: " + str(j))
							return ERROR
						# Make sure channel < N_CHANNELS
						if not (channel < N_CHANNELS):
							print("Invalid Channel of " + str(channel) +
							". Line: " + str(i+1) + ", Token: " + str(j))
							return ERROR
						# calculate skipped beats
						var skippedBeats = ((newSubDiv - currSubDiv) / float(beatDivision))
						# Adjust time
						var BPS: float = BPM / 60.0
						var seconds = skippedBeats / BPS
						timeFromStart += seconds
						# change vars
						currSubDiv = newSubDiv
						currChannel = channel
						# Add pulse to channels
						# Make sure there are enough channel arrays
						while (channel_times.size() < N_CHANNELS):
							channel_times.append([])
						# Add time to correct channel
						channel_times[channel].append(timeFromStart)
					# otherwise error
					_:
						print("Enexpected punctuation '" + punctToken.get(DATA) + 
						"'. Line: " + str(i) + ", Token: " + str(j))
				pass 
			# if punctuation token error
			elif initToken.get(TYPE) == PUNCT_TYPE:
				print("UNEXPECTED PUNCTUATION: Line: " + str(i+1) + ", Token: " +
						str(j+1))
				return ERROR
			# if endline break
			elif initToken.get(TYPE) == ENDL_TYPE:
				break;
			# else ERROR: unknown token
			else:
				print("_UNKNOWN_TOKEN: You shouldn't see this\n\t" + "Line: " + 
				str(i+1) + ", Token: " + str(j+1))
				return ERROR
			j += 1
		# Go to next line
		i += 1
	return channel_times

func convertDataToNum(data):
	if data.is_valid_int():
		data = int(data)
	elif data.is_valid_float():
		data = float(data)
	return data

func _on_music_player_finished():
	
	Shoe_Shine_Signals.openLevelSelect.emit(levels)
