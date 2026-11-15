class_name GameStats
extends RefCounted


class Record:
	var wins := 0
	var losses := 0
	var ties := 0

	# result: 1 = win, -1 = loss, 0 = tie
	func add(result: int) -> void:
		match result:
			1:
				wins += 1
			-1:
				losses += 1
			_:
				ties += 1

	func to_text() -> String:
		return "%d-%d-%d" % [wins, losses, ties]


var hands_played := 0
var player_overall := Record.new()
var opponent_overall := Record.new()
var player_slots := {}    # slot name -> Record
var opponent_slots := {}  # slot name -> Record


func _init(slot_names: Array) -> void:
	for slot_name in slot_names:
		player_slots[slot_name] = Record.new()
		opponent_slots[slot_name] = Record.new()


## results[i] is the player's result for slot i: 1 = win, -1 = loss, 0 = tie
func record_hand(slot_names: Array, results: Array[int]) -> void:
	hands_played += 1

	var net := 0
	for i in slot_names.size():
		net += results[i]
		player_slots[slot_names[i]].add(results[i])
		opponent_slots[slot_names[i]].add(-results[i])

	# The hand goes to whoever won more slots
	player_overall.add(signi(net))
	opponent_overall.add(-signi(net))
