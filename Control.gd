extends Control

export (float) var duration_instruction_shown

onready var instruction_timer = get_node("Instruction Timer")

func _ready():
	instruction_timer.set_wait_time(duration_instruction_shown)
	instruction_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Instruction_Timer_timeout():
	$"Double Jump".visible = false
	$"Dash".visible = false
