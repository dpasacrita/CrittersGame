class_name CardData
extends Resource

@export var card_name: String = "Critter"
@export var cost: int = 1
@export var attack: int = 1
@export var health: int = 1
@export var ability_text: String = ""


func get_display_text() -> String:
	var text := "%s\nCost: %d\nATK %d / HP %d" % [card_name, cost, attack, health]
	if ability_text != "":
		text += "\n" + ability_text
	return text


func trigger_ability() -> void:
	if ability_text != "":
		print("%s triggered: %s" % [card_name, ability_text])
