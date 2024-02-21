extends Node


const SAVE_PATH = "res://savegame.bin"


func saveGame():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data:Dictionary = {
		"level1": Game.level1,
		"level1HS": Game.level1HS,
		"level2": Game.level2,
		"level2HS": Game.level2HS,
		"level3": Game.level3,
		"level3HS": Game.level3HS,
		"level4": Game.level4,
		"level4HS": Game.level4HS
	} 
	var jstr = JSON.stringify(data)
	file.store_line(jstr)


func loadGame():
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ) 
	if FileAccess.file_exists(SAVE_PATH):
		if not file.eof_reached():
			var current_line = JSON.parse_string(file.get_line())
			if current_line:
				Game.level1 = current_line["level1"]
				Game.level1HS = current_line["level1HS"]
				Game.level2 = current_line["level2"]
				Game.level2HS = current_line["level2HS"]
				Game.level3 = current_line["level3"]
				Game.level3HS = current_line["level3HS"]
				Game.level4 = current_line["level4"]
				Game.level4HS = current_line["level4HS"]
