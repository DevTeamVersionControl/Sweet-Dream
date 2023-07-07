@tool
extends Area2D

const SMALL = preload("res://Pickups/Pick Up Small.wav")
const BIG = preload("res://Pickups/Pickup Big.wav")

@export var description = {"Name":"Quest Item", "Icon":"Item 3.png", "Price":"30","Unit":"artifacts", "Description":"It's that quest item another npc asked for to progress the main story"} 
@export var sprite_num = 0: set = change_animation

var should_delete := false 
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
#		sprite.update()
	if not Engine.is_editor_hint():
		save_path = GameSaver.save_path
		if should_disappear:
			timer.start()

func _on_Artifact_body_entered(body):
	if body is Player and not Engine.is_editor_hint():
		GlobalVars.add_to_inventory(description)
		disappear()
		GameSaver.obj_save()

func obj_save(game_data):
	if not Engine.is_editor_hint():
		game_data[get_tree().current_scene.current_level.scene_file_path + name] = should_delete

func obj_load(game_data):
	if not Engine.is_editor_hint():
		if game_data.has(get_tree().current_scene.current_level.scene_file_path + name):
			if game_data.get(get_tree().current_scene.current_level.scene_file_path + name):
				queue_free()

func disappear():
	GlobalVars.play_sound(BIG if description.has("BigSound") else SMALL)
	should_delete = true
	GameSaver.obj_save()
	GameSaver.partial_save(self)
	queue_free()

func delete():
	queue_free()

func _physics_process(delta):
	if not Engine.is_editor_hint():
		sprite.global_position.y -= 3 * sin(rads)
		rads += delta * 4.5
		sprite.global_position.y += 3 * sin(rads)

func change_animation(new_animation):
	sprite_num = new_animation
	$Sprite2D.frame = sprite_num
