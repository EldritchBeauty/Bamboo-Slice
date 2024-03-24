extends Control

@onready var ButtonTexture = $ButtonIcon
@onready var SpriteTexture = $Sprite

var MyButton;

func CutBamboo():
	ButtonTexture.hide();
	SpriteTexture.set_frame_and_progress(1,0);

func SetButton(Number):
	MyButton = Number;
	ButtonTexture.set_frame_and_progress(Number,0);
