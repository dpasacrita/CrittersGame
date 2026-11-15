class_name HandBox
extends HBoxContainer


func _ready() -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	custom_minimum_size.y = 190   # keeps a drop area when the hand is empty


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("card_view")


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var view: CardView = data["card_view"]
	view.reparent(self, false)
