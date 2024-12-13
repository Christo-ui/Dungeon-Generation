extends Node3D

var Map : Array
var VisualMap : Array
var Size = 35
var VisualSize = Size * 2
var Rooms = 1
var RoomMax = 8
var RoomMin = 5
var arrValidDir : Array = [false, false, false, false]
var PosX : int = 1
var PosY : int = 1
var Completed : bool
var arrRooms : Array


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
	InitializeMap()
	
	CurrentNode.set_text(0, '1;1')

func InitializeMap():
	PosX = 0
	PosY = 0
	
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
	
	Map[0][0] = 1
	VisualMap.clear()
	
	for i in VisualSize - 1:
		VisualMap.append([])
		for k in VisualSize - 1:
			if (i == 0) or (i == (VisualSize * 2)):
				VisualMap[i].append(3)
			else:
				VisualMap[i].append(4)
		VisualMap[i][0] = 3
		VisualMap[i][VisualSize - 2] = 3
	
	VisualMap[2][2] = 1

func PlaceRooms():
	arrRooms.clear()
	var counter = 0
	
	while counter < Rooms:
		var Width = rng.randi_range(RoomMin, RoomMax)
		var Height = rng.randi_range(RoomMin, RoomMax)
		
		#if Width % 2 == 1:
		#	Width -= 1
		
		#if Height % 2 == 1:
		#	Height -= 1
		
		var BuildPosX = rng.randi_range(2, Size - 2 - Width) 
		var BuildPosY : int = rng.randi_range(2, Size - 2 - Height) 
		
		var overlap = false
		
		#check for overlap
		for i in Height:
			for k in Width:
				if Map[i + BuildPosX][k + BuildPosY] == 2:
					overlap = true
					break
		 
		if overlap == false:
			arrRooms.append([])
			
			#stores the corner information of the rooms
			#0 = top left corner
			arrRooms[counter].append(str(BuildPosX * 2) + ';' + str(BuildPosY * 2 ))
			#1 = top right corner
			arrRooms[counter].append(str(BuildPosX * 2 + Width * 2 - 2) + ';' + str(BuildPosY * 2))
			#2 = bottom right
			arrRooms[counter].append(str(BuildPosX * 2 + Width * 2 - 2) + ';' + str(BuildPosY * 2 + Height * 2 - 2))
			#3 = bottom left
			arrRooms[counter].append(str(BuildPosX * 2) + ';' + str(BuildPosY * 2 + Height * 2 - 2))
			
			for i in Width:
				for k in Height:
					Map[i + BuildPosX][k + BuildPosY] = 2
			
			for i in Width * 2 - 1:
				for k in Height * 2 - 1:
					VisualMap[i + BuildPosX * 2][k + BuildPosY * 2] = 2
			
			counter += 1

func BuildMaze():
	Completed = false
	
	while Completed == false:
		MovePoint()
	
	for i in Size:
		for k in Size: 
			if Map[i][k] == 4:
				Map[i][k] = 3
	
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
	
	if len(arrChooseMove) != 0:
		var MoveIndex = rng.randi_range(0, len(arrChooseMove) - 1)
		
		if arrChooseMove[MoveIndex] == 0:
			PosY += 1
		
		if arrChooseMove[MoveIndex] == 1:
			PosX += 1
		
		if arrChooseMove[MoveIndex] == 2:
			PosY += -1
		
		if arrChooseMove[MoveIndex] == 3:
			PosX += -1
		
		Map[PosX][PosY] = 1
		VisualMap[PosX * 2][PosY * 2] = 1
		CurrentNode = CurrentNode.create_child()
		CurrentNode.set_text(0, str(PosX) + ';' + str(PosY))
		
		# i *should* use getDir here but because they are always 1 tile apart getDif will 
		# return the direction without the use of if statements so its faster
		var Dif = getDif(CurrentNode.get_text(0), CurrentNode.get_parent().get_text(0))
		VisualMap[PosX * 2 - Dif[0]][PosY * 2 - Dif[1]] = 1
	else:
		if CurrentNode == Root:
			#checks for unpopulated spots that were blocked through rooms
			var populated = true
			
			for i in Size:
				for k in Size:
					if Map[i][k] == 4:
						tree.queue_free()
						
						tree = Tree.new()
						Root = tree.create_item()
						CurrentNode = Root
						
						CurrentNode.set_text(0, str(i) + ';' + str(k))
						PosX = i
						PosY = k
						populated = false
			
			if populated == true:
				Completed = true
		else:
			Reverse()
			MovePoint()
	
	#print(str(PosX) + ';' + str(PosY))

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
	var roomfound = false
	
	#1 is hallway
	#2 is unconnected room
	
	for i in len(arrRooms):
		var Connections = rng.randi_range(1, 6)
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
			
			print(Difference[DifIndex])
			
			var MoveDirection = getDir(arrRooms[i][(k + 1) % len(arrRooms[i])], arrRooms[i][k])
			var DirIndex
			
			for j in 2:
				if MoveDirection[j] < 0 or MoveDirection[j] > 0:
					DirIndex = j
					if j == 1:
						print('x')
					else:
						print('y')
					print(MoveDirection[j])
			
			#if the point is moving in a direction you should always check on the other axis
			# e.g. if moving down check left
			# both down and left are negative so only need to change axis
			var checkDir = [0, 0]
			checkDir[0] = MoveDirection[1] * 2
			checkDir[1] = MoveDirection[0] * -2
			
			# moves to next point and looks for connection points
			for j in Difference[DifIndex] + 1:
				if VisualMap[CurrentX + MoveDirection[0] * j + checkDir[0]][CurrentY + MoveDirection[1] * j + checkDir[1]] == 1:
					print('connection point at: ' + str(CurrentX + MoveDirection[1] * j + checkDir[0]) + ';' + str(CurrentY + MoveDirection[0] * j + checkDir[1]))
					VisualMap[CurrentX + MoveDirection[0] * j][CurrentY + MoveDirection[1] * j] = 5
			#VisualMap[CurrentX][CurrentY] = 5
		
		# place connection
		
		# remove close connection to remove double doors

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

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('test'):
		#MovePoint()
		#Generate()
		
		InitializeMap()
		PlaceRooms()
		#BuildMaze()
		
		#getCoords()
		BuildMaze()
		
		FindRoomConnectors()
		
		Generate()
		
		for i in len(arrRooms):
			var Concat : String
			for k in 4:
				Concat += arrRooms[i][k] + ' '
			print(Concat)
