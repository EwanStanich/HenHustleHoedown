extends Node

#var level1 = false
#var level2 = false
#var level3 = false
#var level4 = false


# Test
var level1 = true
var level2 = true
var level3 = true
var level4 = true
var level5 = true
var level6 = true


var level1HS:Array = [["--:--.--", ""], ["--:--.--", ""], ["--:--.--", ""], ["--:--.--", ""], ["--:--.--", ""]]
var level2HS:Array = [["--:--.--", ""], ["--:--.--", ""], ["--:--.--", ""], ["--:--.--", ""], ["--:--.--", ""]]
var level3HS:Array = [["--:--.--", ""], ["--:--.--", ""], ["--:--.--", ""], ["--:--.--", ""], ["--:--.--", ""]]
var level4HS:Array = [["--:--.--", ""], ["--:--.--", ""], ["--:--.--", ""], ["--:--.--", ""], ["--:--.--", ""]]
var level5HS:Array = [["--:--.--", ""], ["--:--.--", ""], ["--:--.--", ""], ["--:--.--", ""], ["--:--.--", ""]]
var level6HS:Array = [["--:--.--", ""], ["--:--.--", ""], ["--:--.--", ""], ["--:--.--", ""], ["--:--.--", ""]]


func compare_times(a, b):
	if a[0] == "--:--.--":
		return false
	elif b[0] == "--:--.--":
		return true
	return a[0] < b[0]

func update_HS(HS, time, name):
	var updatedHS = HS
	updatedHS.append([time, name])
	updatedHS.sort_custom(compare_times)
	while updatedHS.size() > 5:
		updatedHS.pop_back()
	HS = updatedHS

