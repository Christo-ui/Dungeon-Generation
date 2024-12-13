class_name Room_Component
extends Node3D

@export var Connected_Rooms : Array[Room_Component] = []
@export var Size : int = 15
@export var Base_Tiles : MeshLibrary
@export var Deco_Tiles : MeshLibrary
@export var Room_Info : Array = []

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Base_Tiles.mesh_library = Base_Tiles
	$Deco_Tiles.mesh_library = Deco_Tiles
	
	#0 upwards
	#1 right
	#2 down
	#3 left
	
	for i in Size:
		for k in Size:
			$Base_Tiles.set_cell_item(Vector3(i- Size / 2, 0 ,k- Size / 2), 3, 0)
