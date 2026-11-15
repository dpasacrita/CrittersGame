class_name PlayerState
extends RefCounted

var display_name: String
var deck: Array[CardData] = []
var hand: Array[CardData] = []


func _init(p_name: String) -> void:
	display_name = p_name


func build_placeholder_deck(size: int = 20) -> void:
	for i in size:
		var card := CardData.new()
		card.card_name = "Critter %d" % (i + 1)
		card.cost = randi_range(1, 5)
		card.attack = randi_range(1, 5)
		card.health = randi_range(1, 5)
		if i % 4 == 0:
			card.ability_text = "Placeholder ability"
		deck.append(card)
	deck.shuffle()


func draw_cards(count: int) -> void:
	for i in count:
		if deck.is_empty():
			return
		hand.append(deck.pop_back())


func play_card(card: CardData) -> void:
	hand.erase(card)
	card.trigger_ability()
