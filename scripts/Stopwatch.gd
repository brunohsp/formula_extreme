extends Control

var started = false
var running = false
var start_time

@onready var label = $timer

func _ready():
	started = false
	running = false

func _process(delta):
	if(!started): await get_tree().create_timer(2.0).timeout; started = true; running = true;start_time = Time.get_unix_time_from_system();
	if running:	get_time(delta)

func get_time(delta):
	var time_now = Time.get_unix_time_from_system()
	var elapsed = time_now - start_time
	var seconds = fmod(elapsed, 60)
	var minutes = elapsed / 60
	var elapsed_time = "%02d:%02d" % [minutes, seconds]
	label.text = elapsed_time

func stop():
	running = false
