shader_type spatial;
render_mode diffuse_lambert_wrap,cull_disabled;

uniform float rows:hint_range(1.0, 100.0, 1) = 1;
uniform float columns:hint_range(1.0, 100.0, 1) = 1;
uniform float frame:hint_range(0.0, 100.0, 1) = 0;
uniform bool invert_rows_columns = false;
uniform sampler2D sprite:filter_nearest_mipmap;
uniform int mode:hint_range(0, 1, 1) = 1;
varying vec3 look_dir;


float billboard_mode_a(vec3 CAMERA_POSITION,vec3 NODE_POSITION, mat4 MODEL_MAT,float directions){
	vec3 direction_to_camera = normalize(CAMERA_POSITION-NODE_POSITION);
	float angle_to_camera = atan(direction_to_camera.x,direction_to_camera.z);
	vec4 model_direction = MODEL_MAT*vec4(1.0,0.0,0.0,0.0);
	float y_angle = atan(model_direction.x,model_direction.z)-PI/2.0;
	float final_angle = angle_to_camera-y_angle;
	float int_y_angle = round((final_angle / TAU) * float(directions)) / float(directions);
	return int_y_angle;
}
float billboard_mobe_b(vec3 CAMERA_POSITION,mat4 MODEL_MAT,mat4 VIEW_MAT,float directions,int ret){
	
    vec3 ray_origin = CAMERA_POSITION;
      
    vec3 object_origin = (MODEL_MAT * vec4(0.0,0.0,0.0,1.0)).xyz;
    vec3 cam_dir = object_origin - ray_origin;
    cam_dir = normalize((VIEW_MAT * vec4(cam_dir, 0.0)).xyz);

    float angle = 180.0 - degrees(acos(dot(normalize(cam_dir.xz), normalize(look_dir.xz))));
    float _direction = round(angle/180.0 * directions);

    float flip = sign((look_dir.x * cam_dir.z) - (look_dir.z * cam_dir.x));
	
    flip = mix(flip, 1.0, max(step(_direction, 0.0), step(directions, _direction)));
	float retu = ret == 0 ? _direction : flip;
	return retu ;
}
void vertex() {
		 MODELVIEW_MATRIX = VIEW_MATRIX * mat4(vec4(normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz)), 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0), MODEL_MATRIX[3]);
		look_dir = MODELVIEW_NORMAL_MATRIX * NORMAL;
		MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	switch (mode){
		case 0:
			float y = invert_rows_columns == true ? billboard_mode_a(CAMERA_POSITION_WORLD,NODE_POSITION_WORLD,MODEL_MATRIX,rows) : billboard_mode_a(CAMERA_POSITION_WORLD,NODE_POSITION_WORLD,MODEL_MATRIX,columns);
			float x = invert_rows_columns == true ? frame/columns:frame/rows;
			UV /= vec2(rows,columns);
			UV += invert_rows_columns == true ?vec2(y,x):vec2(x,y);
			break;	
		case 1:
			float x = invert_rows_columns == true ? frame/columns:frame/rows;
			float y = billboard_mobe_b(CAMERA_POSITION_WORLD,MODEL_MATRIX,VIEW_MATRIX,rows,0);
			float f = billboard_mobe_b(CAMERA_POSITION_WORLD,MODEL_MATRIX,VIEW_MATRIX,rows,1);
			if (invert_rows_columns){
				y = billboard_mobe_b(CAMERA_POSITION_WORLD,MODEL_MATRIX,VIEW_MATRIX,columns,0);
				f = billboard_mobe_b(CAMERA_POSITION_WORLD,MODEL_MATRIX,VIEW_MATRIX,columns,1);
			}
			UV.y += invert_rows_columns == true ? x:y;
			UV /=vec2(rows,columns);
			UV.x +=  invert_rows_columns == true ? y : x;
			UV *= invert_rows_columns == true ? vec2(1.0,f):vec2(f,1.0);
			break;
	};
}	

void fragment() {
	vec4 sprite_texture;
	sprite_texture = texture(sprite,UV);
	ALBEDO = sprite_texture.rgb;
	ALPHA = sprite_texture.a;
}

