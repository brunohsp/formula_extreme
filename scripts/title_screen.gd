extends Control


func _ready():
	pass 


func _process(delta):
	pass


func _on_start_btn_pressed():
	get_tree().change_scene_to_file("res://scenes/pista_1.tscn")


func _on_exit_btn_pressed():
	get_tree().quit()
