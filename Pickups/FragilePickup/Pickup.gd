@tool
extends Area2D

const SMALL = preload("res://Pickups/Pick Up Small.wav")
const BIG = preload("res://Pickups/Pickup Big.wav")

@export var description = {"Name":"Fragile Item", "Icon":"res://UserInterface/Map/Candy Icon.png", "Description":"It's that quest item another npc asked for to progress the main story", "Fragile":false} 
@export var sprite_num = 0: set = change_animation

var save_path
var rads := 0.0
var should_disappear := false

@onready var sprite := $Sprite2D
@onready var timer := $Timer

func _ready():
	sprite.frame = sprite_num
	if description.has("Icon"):
		sprite.queue_free()
		sprite = Sprite2D.new()
		add_child(sprite)
		sprite.hframes = 1
		sprite.vframes = 1
		sprite.frame = 0
		sprite.texture = load(description.get("Icon"))
	if not Engine.is_editor_hint():
		if GlobalVars.get_from_inventory(description["Name"]):
			queue_free()

func disappear():
	GlobalVars.play_sound(BIG if description.has("BigSound") else SMALL)
	queue_free()

func _physics_process(delta):
	if not Engine.is_editor_hint():
		sprite.global_position.y -= 3 * sin(rads)
		rads += delta * 4.5
		sprite.global_position.y += 3 * sin(rads)
		var distance = get_tree().current_scene.player.bullet_center.global_position - global_position
		if distance.length() < 5:
			GlobalVars.add_to_inventory(description)
			disappear()
			GameSaver.obj_save()
		elif distance.length() < 50:
			global_position += distance.normalized() * 100/distance.length()

func change_animation(new_animation):
	sprite_num = new_animation
	$Sprite2D.frame = sprite_num
