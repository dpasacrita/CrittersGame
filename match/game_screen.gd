extends Control

const HAND_SIZE := 5
const SLOT_NAMES := ["Plains", "River", "Forest"]
const TITLE_SCENE := "res://menus/title_screen.tscn"

@onready var opponent_hand_box: HBoxContainer = $MarginContainer/VBoxContainer/OpponentHand
@onready var opponent_slots_box: HBoxContainer = $MarginContainer/VBoxContainer/OpponentSlots
@onready var status_label: Label = $MarginContainer/VBoxContainer/StatusLabel
@onready var player_slots_box: HBoxContainer = $MarginContainer/VBoxContainer/PlayerSlots
@onready var submit_button: Button = $MarginContainer/VBoxContainer/SubmitButton
@onready var player_hand_box: HandBox = $MarginContainer/VBoxContainer/PlayerHand
@onready var control_bar: HBoxContainer = $MarginContainer/VBoxContainer/ControlBar
@onready var next_hand_button: Button = $MarginContainer/VBoxContainer/ControlBar/NextHandButton
@onready var quit_button: Button = $MarginContainer/VBoxContainer/ControlBar/QuitButton
@onready var stats_label: Label = $StatsPanel/StatsLabel

var stats := GameStats.new(SLOT_NAMES)
var player := PlayerState.new("You")
var opponent := PlayerState.new("Opponent")
var player_slots: Array[CardSlot] = []
var opponent_slots: Array[CardSlot] = []


func _ready() -> void:
	opponent_hand_box.alignment = BoxContainer.ALIGNMENT_CENTER
	for box in [opponent_slots_box, player_slots_box]:
		box.alignment = BoxContainer.ALIGNMENT_CENTER
		box.add_theme_constant_override("separation", 24)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	control_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	control_bar.add_theme_constant_override("separation", 24)

	# Build the three slots for each side
	for slot_name in SLOT_NAMES:
		var p_slot := CardSlot.new()
		p_slot.slot_name = slot_name
		p_slot.hand_box = player_hand_box
		player_slots_box.add_child(p_slot)
		p_slot.card_changed.connect(_update_submit_button)
		player_slots.append(p_slot)

		var o_slot := CardSlot.new()
		o_slot.slot_name = slot_name
		o_slot.accepts_drops = false
		opponent_slots_box.add_child(o_slot)
		opponent_slots.append(o_slot)

	# Decks and hands
	player.build_deck_from_pool()
	opponent.build_deck_from_pool()
	player.draw_cards(HAND_SIZE)
	opponent.draw_cards(HAND_SIZE)
	_refresh_player_hand()
	_refresh_opponent_hand()

	submit_button.text = "Submit"
	submit_button.pressed.connect(_on_submit_pressed)

	next_hand_button.text = "Next Hand"
	next_hand_button.disabled = true  # enabled once a round has been submitted
	next_hand_button.pressed.connect(_on_next_hand_pressed)

	quit_button.text = "Quit"
	quit_button.pressed.connect(_on_quit_pressed)

	status_label.text = "Drag a card into each slot, then submit"
	_update_submit_button()
	_update_stats_panel()


func _refresh_player_hand() -> void:
	for child in player_hand_box.get_children():
		player_hand_box.remove_child(child)
		child.queue_free()
	for card in player.hand:
		var view := CardView.new()
		view.setup(card)
		player_hand_box.add_child(view)


func _update_stats_panel() -> void:
	var lines: Array[String] = []
	lines.append("GAME STATUS")
	lines.append("Hands played: %d" % stats.hands_played)
	lines.append("")
	lines.append("Records (W-L-T)")
	lines.append("")
	lines.append("Overall")
	lines.append("  You: %s" % stats.player_overall.to_text())
	lines.append("  Opponent: %s" % stats.opponent_overall.to_text())

	for slot_name in SLOT_NAMES:
		lines.append("")
		lines.append(slot_name)
		lines.append("  You: %s" % stats.player_slots[slot_name].to_text())
		lines.append("  Opponent: %s" % stats.opponent_slots[slot_name].to_text())

	stats_label.text = "\n".join(lines)
	

func _refresh_opponent_hand() -> void:
	for child in opponent_hand_box.get_children():
		opponent_hand_box.remove_child(child)
		child.queue_free()
	for i in opponent.hand.size():
		var back := Button.new()
		back.text = "?"
		back.custom_minimum_size = Vector2(70, 100)
		back.disabled = true
		opponent_hand_box.add_child(back)


func _update_submit_button() -> void:
	if not is_inside_tree() or is_queued_for_deletion():
		return
	if not is_instance_valid(submit_button):
		return

	for slot in player_slots:
		if slot.get_card() == null:
			submit_button.disabled = true
			return
	submit_button.disabled = false


func _on_submit_pressed() -> void:
	submit_button.disabled = true
	_lock_player_cards()

	# The AI fills each slot with a random card from its hand
	var ai_cards: Array = opponent.hand.duplicate()
	ai_cards.shuffle()
	for i in opponent_slots.size():
		var ai_card: CardData = ai_cards[i]
		var view := CardView.new()
		view.setup(ai_card)
		view.locked = true
		opponent_slots[i].place_card(view)

	# Compare each slot and trigger abilities
	var wins := 0
	var results: Array[int] = []
	for i in SLOT_NAMES.size():
		var mine: CardData = player_slots[i].get_card()
		var theirs: CardData = opponent_slots[i].get_card()

		player.play_card(mine)
		opponent.play_card(theirs)

		var result := _compare(mine, theirs)
		results.append(result)

		match result:
			1:
				player_slots[i].set_result("Win")
				opponent_slots[i].set_result("Lose")
				wins += 1
			-1:
				player_slots[i].set_result("Lose")
				opponent_slots[i].set_result("Win")
			_:
				player_slots[i].set_result("Tie")
				opponent_slots[i].set_result("Tie")

	stats.record_hand(SLOT_NAMES, results)
	_update_stats_panel()

	status_label.text = "You won %d of %d slots" % [wins, SLOT_NAMES.size()]
	_refresh_opponent_hand()
	next_hand_button.disabled = false


func _on_next_hand_pressed() -> void:
	next_hand_button.disabled = true

	# Reset the slots
	for slot in player_slots:
		slot.clear()
	for slot in opponent_slots:
		slot.clear()

	# Refill both hands up to the max
	player.draw_cards(HAND_SIZE - player.hand.size())
	opponent.draw_cards(HAND_SIZE - opponent.hand.size())
	_refresh_player_hand()
	_refresh_opponent_hand()

	# Not enough cards left to fill every slot
	if player.hand.size() < SLOT_NAMES.size() or opponent.hand.size() < SLOT_NAMES.size():
		status_label.text = "Out of cards!"
		return

	status_label.text = "Drag a card into each slot, then submit"
	_update_submit_button()


func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file(TITLE_SCENE)


# Placeholder comparison: higher attack wins the slot.
# Returns 1 (mine wins), -1 (theirs wins), or 0 (tie).
func _compare(mine: CardData, theirs: CardData) -> int:
	return signi(mine.attack - theirs.attack)


func _lock_player_cards() -> void:
	for child in player_hand_box.get_children():
		(child as CardView).locked = true
	for slot in player_slots:
		slot.get_card_view().locked = true
