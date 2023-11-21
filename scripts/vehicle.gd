extends Node2D

var rule = [0,1,2,3]; 
var t = 0; 
var state = 2;
var velocity = 300.0;var position_modifier

func _ready(): 
	$vehicle.play("default")
	set_process(true)

func _process(delta):
	var state = Input.get_axis("ui_left", "ui_right")
	
	if state == -1: $vehicle.play("left");
	if state == 0:  $vehicle.play("default"); t = 0;
	if state == 1:  $vehicle.play("right");
	
	t+=delta
	if t>=1.0:
		if state == -1 and velocity > 0: $vehicle.play("full_left")
		if state == 1 and velocity > 0: $vehicle.play("full_right")
	# da pra adicionar a animacao de virar muito pra cada lado, tavez fique legal

func handle_with_hills(y_world):
	if y_world < 0 and $vehicle.position.y < 100: $vehicle.position.y += 0.3
	if y_world > 0 and $vehicle.position.y > -100: $vehicle.position.y -= 0.3
	if y_world == 0 and $vehicle.position.y != 0: $vehicle.position.y -= $vehicle.position.y * 0.1

func handle_map_influence(map_direction):
	$vehicle.position.x += (map_direction*-0.5)
	
func handle_player_action(player_direction, map_direction):
	if player_direction == -1 and velocity > 0: $vehicle.position.x -= (2*position_modifier)
	if player_direction == 0:
		pass
	if player_direction == 1 and velocity > 0: $vehicle.position.x += (2*position_modifier)

func handle_with_movimentation(player_direction, map_direction, y_world):
	position_modifier = 0
	if t <= 5: position_modifier = t+1
	handle_with_hills(y_world)
	handle_map_influence(map_direction)
	handle_player_action(player_direction, map_direction)
	#print($vehicle.position.x)
	
	
