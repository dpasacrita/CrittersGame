extends Control

const HAND_SIZE := 5
const CARD_SIZE := Vector2(140, 180)

@onready var opponent_hand_box: HBoxContainer = $MarginContainer/VBoxContainer/OpponentHand
@onready var player_hand_box: HBoxContainer = $MarginContainer/VBoxContainer/PlayerHand
@onready var opponent_played_label: Label = $MarginContainer/VBoxContainer/PlayArea/OpponentPlayedLabel
@onready var status_label: Label = $MarginContainer/VBoxContainer/PlayArea/StatusLabel
@onready var player_played_label: Label = $MarginContainer/VBoxContainer/PlayArea/PlayerPlayedLabel
@onready var quit_button: Button = $MarginContainer/VBoxContainer/Controls/QuitButton

var player := PlayerState.new("You")
var opponent := PlayerState.new("Opponent")
var card_played := false


func _ready() -> void:
	opponent_hand_box.alignment = BoxContainer.ALIGNMENT_CENTER
	player_hand_box.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# Buttons
	quit_button.pressed.connect(_on_quit_pressed)

	player.build_deck_from_pool(20, ["core"])
	opponent.build_deck_from_pool(20, ["core"])
	player.draw_cards(HAND_SIZE)
	opponent.draw_cards(HAND_SIZE)

	status_label.text = "Pick a card to play"
	_refresh_hands()


func _refresh_hands() -> void:
	for child in player_hand_box.get_children():
		child.queue_free()
	for child in opponent_hand_box.get_children():
		child.queue_free()

	for card in player.hand:
		var button := Button.new()
		button.text = card.get_display_text()
		button.custom_minimum_size = CARD_SIZE
		button.disabled = card_played
		button.pressed.connect(_on_player_card_pressed.bind(card))
		player_hand_box.add_child(button)

	# Opponent's cards are shown face down
	for i in opponent.hand.size():
		var back := Button.new()
		back.text = "?"
		back.custom_minimum_size = CARD_SIZE
		back.disabled = true
		opponent_hand_box.add_child(back)


func _on_player_card_pressed(card: CardData) -> void:
	if card_played:
		return
	card_played = true

	player.play_card(card)
	player_played_label.text = "You played:\n" + card.get_display_text()

	# AI opponent picks a random card
	var ai_card: CardData = opponent.hand.pick_random()
	opponent.play_card(ai_card)
	opponent_played_label.text = "Opponent played:\n" + ai_card.get_display_text()

	status_label.text = "Both players have played"
	_refresh_hands()

func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/title_screen.tscn")
