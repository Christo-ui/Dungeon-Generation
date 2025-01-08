extends VBoxContainer

@export var min = 1
@export var max = 100
@export var currentvalue = 0
@export var title = 'Title'

# Called when the node enters the scene tree for the first time.
func _ready():
	$lblTitle.text = title
	$SliderContainer/HSlider.min_value = min
	$SliderContainer/HSlider.max_value = max
	$SliderContainer/HSlider.value = currentvalue

func _on_h_slider_value_changed(value):
	$SliderContainer/lblSlider.text = str($SliderContainer/HSlider.value)
	currentvalue = $SliderContainer/HSlider.value
