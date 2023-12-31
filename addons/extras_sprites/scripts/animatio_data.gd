extends Resource

class_name AnimationData

signal  value_changed
@export var name:String="idle":
	set(value):
		name = value
		value_changed.emit()
@export var sprite:Texture:
	set(value):
		sprite = value
		if !value:
			rows = 1
			columns = 1
		value_changed.emit()
	get:
		return sprite
var frame:float=0:
	set(value):
		frame = value
		value_changed.emit()
@export_range(1,100,1) var rows:float=1:
	set(value):
		if sprite:rows = value
		value_changed.emit()
	get:
		return rows

@export_range(1,100,1) var columns:float=1:
	set(value):
		columns = value
		value_changed.emit()
	get:
		return columns

@export var invert_rows_columns:bool=false:
	set(value):
		invert_rows_columns = value
		value_changed.emit()

@export_enum("Mode A","Mode B") var mode:int = 0:
	set(value):
		mode = value
		value_changed.emit()
