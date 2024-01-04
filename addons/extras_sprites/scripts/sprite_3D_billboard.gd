# Clase Sprite3DPlus que extiende MeshInstance3D y utiliza ShaderMaterial para renderizar sprites en 3D
@icon("../assets/8BillBoardICon.svg")
@tool
extends MeshInstance3D
class_name Sprite3DBillBoard

# Carga de recursos
@onready var smiley_spr = preload("../assets/smiley.png")  # Textura de la cara sonriente
@onready var shader_loc = preload("../shaders/billboard.gdshader")  # Ubicación del shader para el billboard

# Variables de miembro
var spr_mesh :PlaneMesh
var material:ShaderMaterial
var shader:Shader

# Propiedades exportadas
@export var animations_array:Array[AnimationData]:  # Array de datos de animación
	set(value):
		animations_array = value
		for i in range(animations_array.size()):
			if !animations_array[i]:
				animations_array[i]=AnimationData.new()  # Inicializa los datos de animación si no están presentes
		if is_node_ready():
			notify_property_list_changed()  # Notifica cambios en la lista de propiedades

@export var update_animation:bool:  # Actualización de la animación
	set(value):
		update_animation=false
		if is_node_ready():
			setup_shader()
			notify_property_list_changed()

# Datos de animación y propiedades relacionadas
var animation_data:AnimationData
var animation:int = 0:
	set(value):
		var ant_anim = animation
		animation = value
		animation_data = clone_animation_data(animations_array[animation])
		if is_node_ready():
			setup_shader()
		if value != ant_anim:
			notify_property_list_changed()

# Propiedades del sprite
var sprite:Texture:
	set(value):
		sprite = value
		mesh.material.set_shader_parameter("sprite",value)  # Establece el parámetro del shader para la textura del sprite

var frame:float:  # Cuadro de animación actual
	set(value):
		frame = value
		mesh.material.set_shader_parameter("frame",value)  # Establece el parámetro del shader para el cuadro de animación

var rows:float= 1:  # Número de filas en la hoja de sprites
	set(value):
		rows = value
		mesh.material.set_shader_parameter("rows",value)
		if is_node_ready():
			setup_shader()  # Actualiza el shader si el nodo está listo

var columns:float= 1:  # Número de columnas en la hoja de sprites
	set(value):
		columns = value
		mesh.material.set_shader_parameter("columns",value)
		if is_node_ready():
			setup_shader()  # Actualiza el shader si el nodo está listo

var invert:bool= false:  # Indica si se invierten las filas y columnas
	set(value):
		invert = value
		mesh.material.set_shader_parameter("invert_rows_columns",value)

var mode:int= 0:  # Modo de renderizado
	set(value):
		mode = value
		mesh.material.set_shader_parameter("mode",value)

var sprite_scale:float = 0.01:  # Escala del sprite
	set(value):
		sprite_scale = value
		if is_node_ready():
			set_sprite_scale()  # Establece la escala del sprite si el nodo está listo

# Método llamado al inicio
func _ready():
	setup_animations()  # Inicializa las animaciones
	setup_mesh()  # Configura la malla
	setup_shader()  # Configura el shader

# Configura las animaciones
func setup_animations():
	if animations_array.size() <= 0:
		animations_array.append(AnimationData.new())
	animations_array = animations_array.duplicate(true)
	for i in range(animations_array.size()):
		animations_array[i] = clone_animation_data(animations_array[i])
	animation_data = animations_array[animation]

# Configura la malla
func setup_mesh():
	spr_mesh = PlaneMesh.new()
	spr_mesh.orientation = PlaneMesh.FACE_Z
	material = ShaderMaterial.new()
	material.shader = shader_loc.duplicate()
	spr_mesh.material = material
	mesh = spr_mesh
	
# Configura el shader
func setup_shader():
	var data = animation_data
	var shader_sprite = data.sprite if data.sprite else smiley_spr
	var sprite_size = shader_sprite.get_size()
	var sprite_slice = Vector2(data.rows,data.columns)
	mesh.size = (sprite_size / sprite_slice) * sprite_scale
	if material:
		material.set_shader_parameter("sprite",shader_sprite)
		material.set_shader_parameter("rows",data.rows)
		material.set_shader_parameter("columns",data.columns)
		material.set_shader_parameter("invert_rows_columns",data.invert_rows_columns)
		material.set_shader_parameter("mode",data.mode)

# Configura la escala del sprite
func set_sprite_scale()->void:
	var data = animation_data
	var shader_sprite = data.sprite if data.sprite else smiley_spr
	var sprite_size = shader_sprite.get_size()
	var sprite_slice = Vector2(data.rows,data.columns)
	mesh.size = (sprite_size / sprite_slice) * sprite_scale

# Clona los datos de la animación
func clone_animation_data(source:AnimationData)-> AnimationData:
	var clone : AnimationData = AnimationData.new()
	clone.name = source.name
	clone.sprite = source.sprite
	clone.rows = source.rows
	clone.columns = source.columns
	clone.invert_rows_columns = source.invert_rows_columns
	clone.mode = source.mode
	return clone

# Obtiene la lista de propiedades
func _get_property_list():
	var data = animation_data
	
	var properties = []
	
	var total_frames
	
	var animation_enum = []
	
	if animation_data:
		total_frames = data.columns-1 if data.invert_rows_columns else data.rows-1
	for animation in animations_array:
		if animation:animation_enum.append(animation.name)
	properties.append({
		"name": "animation",
		"type": TYPE_INT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": ",".join(animation_enum)
		}
	)
	properties.append({
		"name": "frame",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0,%s,1" %total_frames
		}
	)
	properties.append({
		"name": "sprite_scale",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_DEFAULT,
		}
	)
	return properties
