extends Node2D

var time_press = 0
var time_passed = 0
var time_out = 0
var velocity = 300.0
var acceleration = 1
var position_modifier

func stop():
	velocity = 0
	acceleration = 0

func _ready():
	$vehicle.play("default")
	set_process(true)

func _process(delta):
	var state = Input.get_axis("ui_left", "ui_right")

	if state == -1 and velocity > 0: $vehicle.play("left");
	if state == 0 and velocity > 0:  $vehicle.play("default"); time_press = 0;
	if state == 1 and velocity > 0:  $vehicle.play("right");

	time_passed+=delta
	if time_passed > 2.5 and acceleration < 3 and time_out == 0: acceleration+=1; time_passed = 0.0

	time_press+=delta
	if time_press>=1.0:
		if state == -1 and velocity > 0: $vehicle.play("full_left")
		if state == 1 and velocity > 0: $vehicle.play("full_right")

func handle_with_hills(y_world):
	if y_world < 0 and $vehicle.position.y < 100: $vehicle.position.y += 0.3
	if y_world > 0 and $vehicle.position.y > -100: $vehicle.position.y -= 0.3
	if y_world == 0 and $vehicle.position.y != 0: $vehicle.position.y -= $vehicle.position.y * 0.1

func handle_map_influence(map_direction):
	$vehicle.position.x += map_direction*-2.0

func handle_player_action(player_direction, map_direction):
	if player_direction == -1 and velocity > 0: $vehicle.position.x -= position_modifier
	if player_direction == 0:
		pass
	if player_direction == 1 and velocity > 0: $vehicle.position.x += position_modifier

func handle_with_movimentation(player_direction, map_direction, y_world, road_width, delta):
	position_modifier = 8 + time_press - acceleration
	if($vehicle.position.x > ((road_width)*0.8/2) or $vehicle.position.x < ((road_width)*0.8/-2)): 
		time_out += delta
		if time_out > 2.5:
			acceleration -= 1
			time_out = 0.0
			time_passed = -3.0
			if acceleration == 0: 
				queue_redraw()
				velocity = 0.0
				$vehicle.play("rotating")
				return
	else: time_out = 0;
	
	handle_with_hills(y_world)
	handle_map_influence(map_direction)
	handle_player_action(player_direction, map_direction)


