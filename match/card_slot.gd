class_name CardSlot
extends PanelContainer

signal card_changed

var slot_name := ""
var hand_box: Control          # where a replaced card goes back to
var accepts_drops := true      # false for the opponent's slots

var _holder: CenterContainer
var _result_label: Label


func _ready() -> void:
	custom_minimum_size = Vector2(170, 260)

	var vbox := VBoxContainer.new()
	add_child(vbox)

	var title := Label.new()
	title.text = slot_name
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	_holder = CenterContainer.new()
	_holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_holder.child_order_changed.connect(func(): card_changed.emit())
	vbox.add_child(_holder)

	_result_label = Label.new()
	_result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_result_label)


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return accepts_drops and data is Dictionary and data.has("card_view")


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	place_card(data["card_view"])


func place_card(view: CardView) -> void:
	# If the slot is already occupied, send that card back to the hand
	var existing := get_card_view()
	if existing and existing != view and hand_box:
		existing.reparent(hand_box, false)

	if view.get_parent():
		view.reparent(_holder, false)
	else:
		_holder.add_child(view)


func get_card_view() -> CardView:
	if _holder.get_child_count() == 0:
		return null
	return _holder.get_child(0) as CardView


func get_card() -> CardData:
	var view := get_card_view()
	return view.card if view else null


func set_result(message: String) -> void:
	_result_label.text = message

func clear() -> void:
	var view := get_card_view()
	if view:
		# Remove first so get_card() returns null immediately
		_holder.remove_child(view)
		view.queue_free()
	_result_label.text = ""
