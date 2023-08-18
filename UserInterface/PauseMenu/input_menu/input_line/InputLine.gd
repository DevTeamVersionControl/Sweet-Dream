#MIT License
#
#Copyright (c) 2017 Nathan Lovato
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.
extends HBoxContainer

signal change_button_pressed

var can_change
var mouse_inside := false

func initialize(action_name, key, new_can_change):
	$Action.text = action_name.capitalize()
	$Key.text = OS.get_keycode_string(key)
	can_change = new_can_change

func update_key(keycode):
	$Key.text = OS.get_keycode_string(keycode)

func _on_mouse_entered():
	if can_change:
		mouse_inside = true
		$Action.set("theme_override_colors/font_color", Color.DEEP_PINK)
		$Label.set("theme_override_colors/font_color", Color.DEEP_PINK)
		$Key.set("theme_override_colors/font_color", Color.DEEP_PINK)

func _on_mouse_exited():
	if can_change:
		mouse_inside = false
		$Action.set("theme_override_colors/font_color", Color("45326c"))
		$Label.set("theme_override_colors/font_color", Color("45326c"))
		$Key.set("theme_override_colors/font_color", Color("45326c"))

func _input(event):
	if event is InputEventMouseButton and mouse_inside:
		emit_signal("change_button_pressed")
