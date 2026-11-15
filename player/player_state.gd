class_name PlayerState
extends RefCounted

var display_name: String
var deck: Array[CardData] = []
var hand: Array[CardData] = []
const MAX_COPIES_PER_DECK := 4


func _init(p_name: String) -> void:
	display_name = p_name


func build_deck_from_pool(size: int = 20, set_names: Array[String] = []) -> void:
	deck.clear()

	var slots: Array[CardData] = []
	for card in CardPool.get_all_cards(set_names):
		var allowed_copies := mini(MAX_COPIES_PER_DECK, card.max_available)
		for i in allowed_copies:
			slots.append(card)

	# Shuffling the slots and taking the first N is a random pull
	# that can never exceed any card's limit
	slots.shuffle()

	var deck_size := mini(size, slots.size())
	if deck_size < size:
		push_warning("Card pool only allows %d cards; wanted %d." % [slots.size(), size])

	for i in deck_size:
		# duplicate() so each copy is its own instance
		deck.append(slots[i].duplicate() as CardData)


func draw_cards(count: int) -> void:
	for i in count:
		if deck.is_empty():
			return
		hand.append(deck.pop_back())


func play_card(card: CardData) -> void:
	hand.erase(card)
	card.trigger_ability()
