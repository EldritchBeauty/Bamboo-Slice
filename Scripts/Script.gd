extends Node2D

@onready var BambooStalk = load("res://Scenes/bamboo_stalk.tscn")
@onready var HeartFull = load("res://Assets/heartfull.png")
@onready var HeartEmpty = load("res://Assets/heartempty.png")
@onready var slashTime = $SlashTimer
@onready var memoryTime = $MemoryTime
@onready var timeLabel = $CanvasLayer/TimeLabel
@onready var levelLabel = $CanvasLayer/LevelLabel
@onready var grid = $BoxContainer
@onready var Animator = $AnimationPlayer
@onready var slice = $Pixel

@onready var Hearts = [$CanvasLayer/HeartContainer/Health1, $CanvasLayer/HeartContainer/Health2, $CanvasLayer/HeartContainer/Health3]
var inputStream: Array;
var requiredInputs: Array = [];
var poleAccess: Array;
var level = 1;
var currentCount = 0;
var currentInput = 0;
var timerStarted = false;
var checkingInputs: bool = false;
var Win = false;
var focusing = false;
var health = 2;

func _ready():
	CreatePoles();

func _physics_process(delta):
	timeLabel.text = str(memoryTime.get_time_left()).pad_decimals(1)
	if checkingInputs:
		currentInput = getButtonPressed();
		if inputStream.size() < currentCount and !currentInput == 0:
			inputStream.append(currentInput);
	currentInput = 0;
	if Input.is_action_just_pressed("Options"):
		beginFocusing();

func getButtonPressed():
	if Input.is_action_just_pressed("DPadUp"):
		currentInput = 1
	elif Input.is_action_just_pressed("DPadRight"):
		currentInput = 2
	elif Input.is_action_just_pressed("DPadDown"):
		currentInput = 3
	elif Input.is_action_just_pressed("DPadLeft"):
		currentInput = 4
	elif Input.is_action_just_pressed("ButtonUp"):
		currentInput = 5
	elif Input.is_action_just_pressed("ButtonRight"):
		currentInput = 6
	elif Input.is_action_just_pressed("ButtonDown"):
		currentInput = 7
	elif Input.is_action_just_pressed("ButtonLeft"):
		currentInput = 8
	if !currentInput == 0:
		if !timerStarted and focusing:
			slashTime.start()
			timerStarted = true;
			Animator.play("Swish")
	return currentInput;

func CreatePoles():
	requiredInputs = [];
	poleAccess = [];
	inputStream = [];
	currentCount = level + 2
	levelLabel.text = str(level)
	for i in currentCount:
		var obj = BambooStalk.instantiate();
		grid.call_deferred("add_child", obj)
		poleAccess.append(obj)
		var randNum = randi_range(1,8)
		poleAccess[i].call_deferred("SetButton", randNum)
		requiredInputs.append(randNum)
		focusing = false;
	memoryTime.start();
	timeLabel.show()

func CutPoles(GoodInputs):
	for i in GoodInputs:
		poleAccess[i].call_deferred("CutBamboo")

func beginFocusing():
	if !focusing:
		Animator.play("LevelOpening")
		timeLabel.hide();

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "VictoryAnimation":
		level += 1;
		var gridChildren = grid.get_children()
		for i in grid.get_child_count():
			gridChildren[i].queue_free()
		CreatePoles();
	if anim_name == "FailureAnimation":
		if health < 0:
			level = 1;
			health = 2;
			Hearts[0].set_texture(HeartFull)
			Hearts[1].set_texture(HeartFull)
			Hearts[2].set_texture(HeartFull)
		var gridChildren = grid.get_children()
		for i in grid.get_child_count():
			gridChildren[i].queue_free()
		CreatePoles();
	if anim_name == "Swish":
		slice.hide()
	if anim_name == "LevelOpening":
		slice.show();
		focusing = true;
		checkingInputs = true;
	if anim_name == "LevelClosing":
		if Win == true:
			Animator.play("VictoryAnimation")
		else:
			Hearts[health].set_texture(HeartEmpty)
			health -= 1;
			Animator.play("FailureAnimation")

func _on_slash_timer_timeout():
	var successes = 0;
	checkingInputs = false;
	timerStarted = false;
	for i in requiredInputs.size():
		if inputStream.size() < i + 1:
			CutPoles(successes);
			Win = false;
			break;
		elif inputStream[i] != requiredInputs[i]:
			CutPoles(successes);
			Win = false;
			break;
		successes += 1;
	if successes == requiredInputs.size():
		CutPoles(successes)
		Win = true;
		Animator.play("LevelClosing")
	else:
		CutPoles(successes)
		Win = false;
		Animator.play("LevelClosing")

func _on_memory_time_timeout():
	beginFocusing();
