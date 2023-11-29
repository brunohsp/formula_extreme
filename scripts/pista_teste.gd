extends Node2D

var color := {
	"grass_dark"   : Color("008208"),
	"grass_light"  : Color("03ac0e"),
	"border_dark"  : Color.RED,
	"border_light" : Color.WHITE_SMOKE,
	"road_dark"    : Color(0.42, 0.42, 0.42),
	"road_light"   : Color(0.4, 0.4, 0.4),
	"strip_dark"   : Color(0, 0, 0, 0),
	"strip_light"  : Color(1, 1, 1),
}

var new_vehicle = load("res://scenes/vehicle.tscn")
var vehicle = new_vehicle.instantiate()

var width := 1280
var height := 720
var road_width :=860
var seg := 300.0
var cam := 0.8
var tiles := []
var pos := 0
var num
var skyline_pos := 0.0
var skyline_h := 0
var x_cam_shift := 0
var lap = 0
var max_turns = 3

var road_lenght := 7200
var direction := 0

@onready var skyline: Sprite2D = $background

func _ready():
	for i in range(road_lenght):
		vehicle.position = Vector2(540.0, 520.0)
		
		add_child(vehicle)
		tiles.append({ x_world = 0, y_world = 0, z_world = 0, x_viewport = 0, y_viewport = 0, w_viewport = 0, scale = 0, curve = 0})
		tiles[i].z_world = i * seg + 1
		
		if i > 1000 and i <  2000: tiles[i].curve = 3.0
		if i > 2500 and i <  3500: tiles[i].curve = -1.0
		if i > 3800 and i <  4600: tiles[i].curve = 2.0
		if i > 5200 and i <  6600: tiles[i].curve = -3.0
		
		
		if i >= 900 and i <= 1800: tiles[i].y_world = sin(i*0.0174533) * 2400.0
		if i >= 2700 and i <= 3600: tiles[i].y_world = sin(i*0.0174533) * 2400.0
		if i >= 4500 and i <= 5200: tiles[i].y_world = sin(i*0.0174533) * 2400.0
		if i >= 6300 and i <= 7200: tiles[i].y_world = sin(i*0.0174533) * 2400.0
	
	num = tiles.size()
	
func _process(delta):
	if (pos/seg == 0): lap += 1;print("fsadjfnasdiufaisf")
	if(lap == max_turns+1): vehicle.stop();
	if vehicle.velocity == 0: $Stopwatch.stop(); return;
	queue_redraw()
	
	$current_lap.text = "%2d/%2d" % [lap, max_turns]
	
	
	var button = Input.get_axis("ui_left", "ui_right")
	
	vehicle.handle_with_movimentation(button, tiles[pos / seg].curve, tiles[pos / seg].y_world, road_width, delta)
	
	$speedometer.update(vehicle.acceleration)
	
	if(tiles[pos / seg].curve != 0 and x_cam_shift < 300 and x_cam_shift > -300): 
		x_cam_shift += 1
		vehicle.position.x +=  1
	elif(tiles[pos / seg].curve == 0 and x_cam_shift != 0.0): 
		vehicle.position.x += x_cam_shift*-0.1
		x_cam_shift += x_cam_shift*-0.1
	elif(tiles[pos / seg].curve == 0 and x_cam_shift == 0.0):
		vehicle.position.x = 540
	
	pos += vehicle.velocity * vehicle.acceleration

func _draw_road(color, x1, y1, w1, x2, y2, w2):
	var a = Vector2(int(x1 - w1), int(y1))
	var b = Vector2(int(x2 - w2), int(y2))
	var c = Vector2(int(x2 + w2), int(y2))
	var d = Vector2(int(x1 + w1), int(y1))
	
	var new_point = [a, b, c, d]
	
	draw_primitive(PackedVector2Array(new_point), PackedColorArray([color]), PackedVector2Array([]))

func _tile_normalizer(tile, cam_x, cam_y, cam_z):
	tile.scale = cam / (tile.z_world - cam_z)
	tile.x_viewport = (1 + tile.scale * (tile.x_world - cam_x)) * width / 2
	tile.y_viewport = (1 - tile.scale * (tile.y_world - cam_y)) * height / 2
	tile.w_viewport = tile.scale * road_width * (width / 2)
	return tile

func _draw() -> void:
	if pos >= num * seg or pos < 0:
		pos = 0
			
	var num_pos = 0
	var start_point = int(int(pos) / int(seg))
	var cam_h = 1500 + tiles[start_point].y_world
	var cutoff = height
	var x = 0
	var dx = 0
	
	skyline_h = -tiles[start_point].y_world * 0.005
	skyline.set_region_rect(Rect2(skyline_pos, skyline_h, 1920,320))
		
	for n in range(start_point, start_point+300):
		if n >= num:
			num_pos = num * seg
		else:
			num_pos = 0
			
		var new_tile = _tile_normalizer(tiles[fmod(n, num)], -x, cam_h, pos - num_pos)
		var previous_tile = tiles[fmod(n - 1, num)]
		x += dx
		dx += new_tile.curve
		
		if new_tile.y_viewport >= cutoff:
			continue
			
		cutoff = new_tile.y_viewport
		
		var border = color.border_dark if fmod((n / 10), 2) else color.border_light
		var road   = color.road_dark   if fmod((n / 10), 2) else color.road_light
		var grass  = color.grass_dark  if fmod((n / 5), 2) else color.grass_light
		var strip  = color.strip_dark  if fmod((n / 8), 2) else color.strip_light

		_draw_road(grass, 0, previous_tile.y_viewport, width, 0, new_tile.y_viewport, width)
		_draw_road(border, previous_tile.x_viewport + x_cam_shift, previous_tile.y_viewport, previous_tile.w_viewport * 1.2, new_tile.x_viewport + x_cam_shift, new_tile.y_viewport, new_tile.w_viewport * 1.2)
		_draw_road(road, previous_tile.x_viewport + x_cam_shift, previous_tile.y_viewport, previous_tile.w_viewport, new_tile.x_viewport + x_cam_shift, new_tile.y_viewport, new_tile.w_viewport)
		_draw_road(strip, previous_tile.x_viewport + x_cam_shift, previous_tile.y_viewport, previous_tile.w_viewport * 0.01, new_tile.x_viewport + x_cam_shift, new_tile.y_viewport, new_tile.w_viewport * 0.01)
