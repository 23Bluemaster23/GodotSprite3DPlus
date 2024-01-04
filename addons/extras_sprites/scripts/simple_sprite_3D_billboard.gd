@tool
@icon("../assets/8BillBoardICon.svg")
extends MeshInstance3D
class_name SimpleSprite3DBillboard
# Carga de recursos
@onready var smiley_spr = preload("../assets/smiley.png")  # Textura de la cara sonriente
@onready var shader_loc = preload("../shaders/billboard.gdshader")  # Ubicación del shader para el billboard
@export var sprite:Texture:
	set(value):
		if value != sprite:
			sprite = value
			setup_shader()
@export var sprite_scale:float = 0.01:
	set(value):
		if value != sprite_scale:
			sprite_scale = value
			setup_shader()
var rows:float = 1:
	set(value):
		if value != rows:
			rows = value
			setup_shader()
			update_total_frames()
		notify_property_list_changed()
var columns:float = 1:
	set(value):
		if value != columns:
			columns = value
			setup_shader()
			update_total_frames()
		notify_property_list_changed()
var invert_rows_columns:bool
var mode:int
var frame:float = 0:
	set(value):
		frame = value
		material.set_shader_parameter("frame",frame)
var spr_mesh
var material
var total_frames
func _ready():
	setup_mesh()
	setup_shader()
func setup_mesh():
	spr_mesh = PlaneMesh.new()
	spr_mesh.orientation = PlaneMesh.FACE_Z
	material = ShaderMaterial.new()
	material.shader = shader_loc.duplicate()
	spr_mesh.material = material
	mesh = spr_mesh
func setup_shader():
	var shader_sprite = sprite if sprite else smiley_spr
	var sprite_size = shader_sprite.get_size()
	var sprite_slice = Vector2(rows,columns)
	mesh.size = (sprite_size / sprite_slice) * sprite_scale
	if material:
		material.set_shader_parameter("sprite",shader_sprite)
		material.set_shader_parameter("rows",rows)
		material.set_shader_parameter("columns",columns)
		material.set_shader_parameter("invert_rows_columns",invert_rows_columns)
		material.set_shader_parameter("mode",mode)
func _get_property_list():
	var prop = []
	prop.append({
		name = "rows",
		type = typeof(rows),
		hint = PROPERTY_HINT_RANGE,
		hint_string = "1,999,1",
	})
	prop.append({
		name = "columns",
		type = typeof(columns),
		hint = PROPERTY_HINT_RANGE,
		hint_string = "1,999,1",
	})
	prop.append({
		name = "invert_rows_columns",
		type = TYPE_BOOL,
	})
	prop.append({
		name = "mode",
		type = TYPE_INT,
		hint = PROPERTY_HINT_ENUM,
		hint_string = "Mode A,Mode B",
	})
	
	prop.append({
		name = "frame",
		type = TYPE_FLOAT,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "0,%s,1" % total_frames,
	})
	return prop

func update_total_frames()->void: total_frames = columns - 1 if invert_rows_columns else rows - 1
