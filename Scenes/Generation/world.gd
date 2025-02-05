extends Node3D

var Map : Array
var VisualMap : Array
@export var Size = 20
@export var SizeInc = 4
@onready var VisualSize = Size * SizeInc
@export var Rooms = 200
@export var RoomMax = 8
@export var RoomMin = 5
var arrValidDir : Array = [false, false, false, false]
var PosX : int = 1
var PosY : int = 1
var Completed : bool
var arrRooms : Array
var prevMove

var tree = Tree.new()
var Root = tree.create_item()
var CurrentNode = Root

var DifX
var DifY

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var room = load("res://Scenes/Levels/rooms.tscn")
	#var room_instance = room.instantiate()
	#room_instance.name = 'test'
	#add_child(room_instance)
	
	#get_node("test").position.y = -1
	#InitializeMap()
	
	#CurrentNode.set_text(0, '1;1')
	pass

func InitializeMap():
	PosX = 1
	PosY = 1
	
	Map.clear()
	
	for i in Size:
		Map.append([])
		for k in Size:
			#if statement adds a border around the edges
			if (i == 0) or (i == Size - 1):
				Map[i].append(3)
			else:
				Map[i].append(4)
		#this adds the horisontal border
		Map[i][0] = 3
		Map[i][Size - 1] = 3
	
	Map[1][1] = 1
	VisualMap.clear()
	
	for i in VisualSize - 1:
		VisualMap.append([])
		for k in VisualSize - 1:
			if (i == 0) or (i == (VisualSize * SizeInc)):
				VisualMap[i].append(3)
			else:
				VisualMap[i].append(4)
		VisualMap[i][0] = 3
		VisualMap[i][VisualSize - SizeInc] = 3
	
	VisualMap[SizeInc][SizeInc] = 1

func PlaceRooms():
	arrRooms.clear()
	var counter = 0
	var rooms = 0
	while counter < Rooms:
		var Width = rng.randi_range(RoomMin, RoomMax)
		var Height = rng.randi_range(RoomMin, RoomMax)
		
		#-2 for the map borders
		var BuildPosX = rng.randi_range(2, Size - 2 - Width) 
		var BuildPosY : int = rng.randi_range(2, Size - 2 - Height) 
		
		var overlap = false
		
		#check for overlap
		for i in Width:
			for k in Height:
				if Map[i + BuildPosX][k + BuildPosY] == 2:
					overlap = true
					break
		 
		if overlap == false:
			arrRooms.append([])
			
			#stores the corner information of the rooms
			#0 = top left corner
			arrRooms[rooms].append(str(BuildPosX * SizeInc) + ';' + str(BuildPosY * SizeInc ))
			#1 = top right corner
			arrRooms[rooms].append(str(BuildPosX * SizeInc + Width * SizeInc - SizeInc) + ';' + str(BuildPosY * SizeInc))
			#2 = bottom right
			arrRooms[rooms].append(str(BuildPosX * SizeInc + Width * SizeInc - SizeInc) + ';' + str(BuildPosY * SizeInc + Height * SizeInc - SizeInc))
			#3 = bottom left
			arrRooms[rooms].append(str(BuildPosX * SizeInc) + ';' + str(BuildPosY * SizeInc + Height * SizeInc - SizeInc))
			
			for i in Width:
				for k in Height:
					Map[i + BuildPosX][k + BuildPosY] = 2
			
			#for i in Width * SizeInc + SizeInc - 3:
			#	for k in Height * SizeInc + SizeInc - 3:
			#		VisualMap[i + BuildPosX * SizeInc - SizeInc + 2][k + BuildPosY * SizeInc - SizeInc + 2] = 2
			
			for i in Width * SizeInc - SizeInc + 1:
				for k in Height * SizeInc - SizeInc + 1:
					VisualMap[i + BuildPosX * SizeInc][k + BuildPosY * SizeInc] = 2
			
			rooms += 1
		counter += 1

func BuildMaze():
	#PosX = 1
	#PosY = 1
	#Map[PosX][PosY] = 1
	tree.free()
	tree = Tree.new()
	Root = tree.create_item()
	CurrentNode = Root
	CurrentNode.set_text(0, str(PosX) + ';' + str(PosY))
	
	Completed = false
	
	while Completed == false:
		MovePoint()
	
	Generate()
	
	print("Maze built")

func getValidDirection():
	#0 Upwards
	#1 Right
	#2 Down
	#3 Left
	
	if Map[PosX][PosY + 1] == 4:
		arrValidDir[0] = true
	else:
		arrValidDir[0] = false
	
	if Map[PosX + 1][PosY] == 4:
		arrValidDir[1] = true
	else:
		arrValidDir[1] = false
	
	if Map[PosX][PosY - 1] == 4:
		arrValidDir[2] = true
	else:
		arrValidDir[2] = false
	
	if Map[PosX - 1][PosY] == 4:
		arrValidDir[3] = true
	else:
		arrValidDir[3] = false

func MovePoint():
	getValidDirection()
	
	var arrChooseMove : Array
	
	for i in len(arrValidDir):
		if arrValidDir[i] == true:
			arrChooseMove.append(i)
	
	#if there is a valid move
	if len(arrChooseMove) != 0:
		var MoveIndex
		MoveIndex = rng.randi_range(0, len(arrChooseMove) - 1)
		
		prevMove = arrChooseMove[MoveIndex]
		
		Map[PosX][PosY] = 1
		VisualMap[PosX * SizeInc][PosY * SizeInc] = 1
		
		if arrChooseMove[MoveIndex] == 0:
			PosY += 1
		
		if arrChooseMove[MoveIndex] == 1:
			PosX += 1
		
		if arrChooseMove[MoveIndex] == 2:
			PosY += -1
		
		if arrChooseMove[MoveIndex] == 3:
			PosX += -1
		
		Map[PosX][PosY] = 1
		CurrentNode = CurrentNode.create_child()
		CurrentNode.set_text(0, str(PosX) + ';' + str(PosY))
		
		# using get dir here so that i can multiply it with the amount you need to move
		var Dir = getDir(CurrentNode.get_text(0), CurrentNode.get_parent().get_text(0))
		
		for i in SizeInc:
			VisualMap[PosX * SizeInc - i * Dir[0]][PosY * SizeInc - i * Dir[1]] = 1
		
	else:
		if CurrentNode == Root:
			#checks for unpopulated spots that were blocked through rooms
			var populated = true
			
			for i in Size:
				for k in Size:
					if Map[i][k] == 4:
						PosX = i
						PosY = k
						#Map[PosX][PosY] = 1
						tree.free()
						tree = Tree.new()
						Root = tree.create_item()
						Root.set_text(0, str(PosX) + ';' + str(PosY))
						CurrentNode = Root
						#CurrentNode.set_text(0, str(PosX) + ';' + str(PosY))
						
						#Root.set_text(0, str(PosX) + ';' + str(PosY))
						#CurrentNode = Root
						
						getValidDirection()
						#this is so that it doesnt loop forever if there arent any valid directions
						var arrCheckMove : Array
						for j in len(arrValidDir):
							if arrValidDir[j] == true:
								arrCheckMove.append(j)
						
						if len(arrCheckMove) != 0:
							populated = false
							print('isolated: ' + str(PosX) + ':' + str(PosY))
							
							break
						else:
							print('single')
							Map[PosX][PosY] = 5
			
			if populated == true:
				Completed = true
		else:
			Reverse()
			MovePoint()

func getDif(CurrentPos : String, ConnectedPos : String):
	var Coord = getCoords(CurrentPos)
	var conCoord = getCoords(ConnectedPos)
	
	var XDif = Coord[0] - conCoord[0]
	var YDif = Coord[1] - conCoord[1]
	return [XDif, YDif]

func getDir(Pos1 : String, Pos2 : String):
	#like get dif but instead gets direction between farther points
	#also should only be used for points in parralel
	var Coord1 = getCoords(Pos1)
	var Coord2 = getCoords(Pos2)
	
	var XDif = Coord1[0] - Coord2[0]
	var YDif = Coord1[1] - Coord2[1]
	
	if XDif > 0:
		return [1, 0]
	else:
		if XDif < 0:
			return [-1, 0]
		else:
			if YDif > 0:
				return [0, 1]
			else:
				if YDif < 0:
					return [0, -1]
				else:
					return [0, 0]

func Reverse():
	if CurrentNode != Root:
		CurrentNode = CurrentNode.get_parent()
		
		var Coord = getCoords(CurrentNode.get_text(0))
		
		PosX = Coord[0]
		PosY = Coord[1]

func getCoords(Coord : String):
	#sets PosX and PosY to the coords of the current selected node
	var Index = Coord.find(';')
	
	return [int(Coord.erase(Index, len(Coord) - Index)), int(Coord.erase(0, Index + 1))]
	
	#PosY = int(Coord.erase(0, Index + 1))
	#print(PosY)
	#PosX = int(Coord.erase(Index, len(Coord) - Index))
	#print(PosX)

func FindRoomConnectors():
	
	#1 is hallway
	#2 is unconnected room
	
	for i in len(arrRooms):
		var Connections = rng.randi_range(1, 6)
		var arrConnectionPoints = []
		
		if Connections >= 2 and Connections <= 4:
			Connections = 2
		
		if Connections == 5 or Connections == 6:
			Connections = 3
		
		#get connections
		
		for k in len(arrRooms[i]):
			#if k is at 3 it should compare with coord 0
			# so when its at 3 it becomes 4 mod 4
			# which is 0
			var Difference = getDif(arrRooms[i][k], arrRooms[i][(k + 1) % len(arrRooms[i])])
			var Coordinate = getCoords(arrRooms[i][k])
			var CurrentX = Coordinate[0]
			var CurrentY = Coordinate[1]
			
			#making sure that dif is always positive
			# because dif will be my counter in the for loop
			
			var DifIndex
			for j in 2:
				if Difference[j] < 0 or Difference[j] > 0:
					DifIndex = j
			
			if Difference[DifIndex] < 0:
				Difference[DifIndex] = Difference[DifIndex] * -1
			
			#print(Difference[DifIndex])
			#gets the direction between two points of the room
			var MoveDirection = getDir(arrRooms[i][(k + 1) % len(arrRooms[i])], arrRooms[i][k])
			
			#if the point is moving in a direction you should always check on the other axis
			# e.g. if moving down check left
			# both down and left are negative so only need to change axis
			var checkDir = [0, 0]
			checkDir[0] = MoveDirection[1] * SizeInc
			checkDir[1] = MoveDirection[0] * -SizeInc
			
			# moves to next point and looks for connection points
			for j in Difference[DifIndex] + 1:
				if VisualMap[CurrentX + MoveDirection[0] * j + checkDir[0]][CurrentY + MoveDirection[1] * j + checkDir[1]] == 1 or VisualMap[CurrentX + MoveDirection[0] * j + checkDir[0]][CurrentY + MoveDirection[1] * j + checkDir[1]] == 2:
					#print('connection point at: ' + str(CurrentX + MoveDirection[1] * j + checkDir[0]) + ';' + str(CurrentY + MoveDirection[0] * j + checkDir[1]))
					#VisualMap[CurrentX + MoveDirection[0] * j + checkDir[0] / 2][CurrentY + MoveDirection[1] * j + checkDir[1] / 2] = 5
					#
					#before : sets the current position, after : sets the direction the point should be moved in
					arrConnectionPoints.append(str(CurrentX + MoveDirection[0] * j + checkDir[0] / SizeInc) + ';' + str(CurrentY + MoveDirection[1] * j + checkDir[1] / SizeInc) + ':' + str(checkDir[0] / SizeInc) + ';' + str(checkDir[1] / SizeInc))
		
		#checks for already existing connections made by connected rooms
		var bFound = true
		while bFound == true:
			bFound = false
			for k in len(arrConnectionPoints):
				var Index = arrConnectionPoints[k].find(':')
				var Coord = getCoords(arrConnectionPoints[k].erase(Index + 1, len(arrConnectionPoints[k]) - Index))
				#print(str(Coord[0]) + ';' + str(Coord[1]))
				if VisualMap[Coord[0]][Coord[1]] == 1:
					arrConnectionPoints = RemoveAroundIndex(arrConnectionPoints, k, RoomMin * 2)
					bFound = true
					Connections -= 1
					break
		
		# place connections
		for k in Connections:
			if len(arrConnectionPoints) > 0:
				#check connections first
				
				var ConnectionPointIndex = rng.randi_range(0, len(arrConnectionPoints) - 1)
				var Index = arrConnectionPoints[ConnectionPointIndex].find(':')
				var ConnectionCoord = getCoords(arrConnectionPoints[ConnectionPointIndex].erase(Index + 1, len(arrConnectionPoints[ConnectionPointIndex]) - Index))
				var ConX = ConnectionCoord[0]
				var ConY = ConnectionCoord[1]
				
				#VisualMap[ConX][ConY] = 1
				var Dir = getCoords(arrConnectionPoints[ConnectionPointIndex].erase(0, Index + 1))
				#same code used in the movepoint function
				for j in SizeInc - 1:
					VisualMap[ConX + j * Dir[0]][ConY + j * Dir[1]] = 1
				
				#remove close connections
				arrConnectionPoints = RemoveAroundIndex(arrConnectionPoints, ConnectionPointIndex, RoomMin * 2)
				

func RemoveAroundIndex(arrPoints : Array, RemoveIndex, RemoveAmount : int):
	for i in RemoveAmount:
		if len(arrPoints) > 0:
			if RemoveIndex - RemoveAmount / 2 + i < 0:
				arrPoints.remove_at(len(arrPoints) - RemoveAmount / 2 + i)
			else:
				arrPoints.remove_at((RemoveIndex - RemoveAmount / 2 + i) % len(arrPoints))
	
	return arrPoints

func CleanDeadEnds():
	var Cleaned = true
	
	while Cleaned == true:
		Cleaned = false
		for i in len(VisualMap) - 1:
			for k in len(VisualMap[i]) - 1:
				if VisualMap[i][k] == 1:
					
					var Walls = 0
					
					if VisualMap[i + 1][k] == 4:
						Walls += 1
					
					if VisualMap[i - 1][k] == 4:
						Walls += 1
					
					if VisualMap[i][k + 1] == 4:
						Walls += 1
					
					if VisualMap[i][k - 1] == 4:
						Walls += 1
					
					if Walls >= 3:
						Cleaned = true
						#print('test')
						VisualMap[i][k] = 4

func Generate():
	for i in VisualSize - 2:
		for k in VisualSize - 2:
			if VisualMap[i][k] == 1:
				$Tiles.set_cell_item(Vector3(i - VisualSize / 2, 0 ,k - VisualSize / 2), 7, 0)
			
			if VisualMap[i][k] == 4: 
				$Tiles.set_cell_item(Vector3(i - VisualSize / 2, 0 ,k - VisualSize / 2), 3, 0)
			
			if VisualMap[i][k] == 2:
				$Tiles.set_cell_item(Vector3(i - VisualSize / 2, 0 ,k - VisualSize / 2), 4, 0)
			
			if VisualMap[i][k] == 5:
				$Tiles.set_cell_item(Vector3(i - VisualSize / 2, 0 ,k - VisualSize / 2), 1, 0)
			
			if VisualMap[i][k] == 6:
				$Tiles.set_cell_item(Vector3(i - VisualSize / 2, 0 ,k - VisualSize / 2), 7, 0)

func _process(_delta: float) -> void:
	#if Input.is_action_just_pressed('test'):
		#MovePoint()
		#Generate()
		
		#InitializeMap()
		#PlaceRooms()
		#BuildMaze()
		
		#getCoords()
		#BuildMaze()
		
		#FindRoomConnectors()
		
		#CleanDeadEnds()
		
		#Generate()
		pass

func _on_generate_pressed():
	$Tiles.clear()
	Size = $CanvasLayer/Control/MarginContainer/VBoxContainer/MapSize.currentvalue
	SizeInc = $CanvasLayer/Control/MarginContainer/VBoxContainer/NodeSize.currentvalue
	Rooms = $CanvasLayer/Control/MarginContainer/VBoxContainer/RoomAttempts.currentvalue
	RoomMin = $CanvasLayer/Control/MarginContainer/VBoxContainer/RoomMin.currentvalue
	RoomMax = $CanvasLayer/Control/MarginContainer/VBoxContainer/RoomMax.currentvalue
	VisualSize = Size * SizeInc
	$CanvasLayer/Control/Camera3D.position.y = VisualSize * 1.3
	
	InitializeMap()
	PlaceRooms()
	BuildMaze()
	FindRoomConnectors()
	if $CanvasLayer/Control/MarginContainer/VBoxContainer/chkDeadends.button_pressed == true:
		CleanDeadEnds()
	Generate()
