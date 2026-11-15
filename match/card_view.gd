class_name CardView
extends Button

var card: CardData
var locked := false


func setup(p_card: CardData) -> void:
	card = p_card
	text = card.get_display_text()
	custom_minimum_size = Vector2(140, 180)
	# PASS lets drops fall through to the slot or hand underneath this card
	mouse_filter = Control.MOUSE_FILTER_PASS


func _get_drag_data(_at_position: Vector2) -> Variant:
	if locked:
		return null

	var preview := Button.new()
	preview.text = text
	preview.custom_minimum_size = custom_minimum_size
	set_drag_preview(preview)

	return {"card_view": self}
