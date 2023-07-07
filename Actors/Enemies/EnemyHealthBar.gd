extends VBoxContainer
class_name HealthBar

var icons := {GlobalTypes.STATUS.slow:preload("res://Environment/Light/light.png")}
var effects := {}

func _ready():
	pass # Replace with function body.

func update_health(max_health = 10.0, current_health = 5.0):
	$HealthBar.max_value = max_health
	$HealthBar.value = current_health

func add_status_effect(status = GlobalTypes.STATUS.slow):
	if effects.find_key(status):
		effects[status].get_children(0).text = str(1 + int(effects[status].get_children(0).text))
	else:
		effects[status] = add_icon(icons[status])

func add_icon(icon:CompressedTexture2D) -> HBoxContainer:
	var box = HBoxContainer.new()
	
	var label = Label.new()
	label.set("theme_override_font_sizes/font_size", 130)
	label.text = str(1)
	
	var texture = TextureRect.new()
	texture.texture = icon
	texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	
	box.add_child(label)
	box.add_child(texture)
	$StatusEffects.add_child(box)
	return box
