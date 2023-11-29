extends Control

func _ready():
	$acc3.visible = false
	$acc3.visible = false
	$acc3.visible = false

func _process(delta):
	pass

func update(acceleration):
	queue_redraw()
	if(acceleration == 3):
		$acc3.visible = true
		$acc2.visible = true
		$acc1.visible = true
		
	elif (acceleration == 2):
		$acc3.visible = false
		$acc2.visible = true
		$acc1.visible = true
		
	elif (acceleration == 1):
		$acc3.visible = false
		$acc2.visible = false
		$acc1.visible = true
		
	else:
		$acc3.visible = false
		$acc2.visible = false
		$acc1.visible = false
		
