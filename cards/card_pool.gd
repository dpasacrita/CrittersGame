class_name CardPool
extends RefCounted

const CARDS_ROOT := "res://cards/sets"


## Pass set folder names, e.g. ["core", "forest"]. Empty means every set.
static func get_all_cards(set_names: Array[String] = []) -> Array[CardData]:
	if set_names.is_empty():
		set_names = get_available_sets()

	var cards: Array[CardData] = []
	for set_name in set_names:
		cards.append_array(_load_cards_from_dir(CARDS_ROOT + "/" + set_name))
	return cards


static func get_available_sets() -> Array[String]:
	var sets: Array[String] = []
	for dir_name in DirAccess.get_directories_at(CARDS_ROOT):
		sets.append(dir_name)
	return sets


static func _load_cards_from_dir(dir_path: String) -> Array[CardData]:
	var cards: Array[CardData] = []
	for file in DirAccess.get_files_at(dir_path):
		# Exported games rename resources to "name.tres.remap", so strip that
		var clean_name := file.trim_suffix(".remap")
		if clean_name.ends_with(".tres"):
			var card := load(dir_path + "/" + clean_name) as CardData
			if card:
				cards.append(card)
	return cards
