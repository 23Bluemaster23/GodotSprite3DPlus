shader_type spatial;
uniform vec3 billboard;void vertex() {
    vec3 billboard_offset = VERTEX - billboard;
    VERTEX.xz = normalize(INV_VIEW_MATRIX[0].xz) * billboard_offset.x + normalize(INV_VIEW_MATRIX[2].xz) * billboard_offset.z;
    VERTEX.y = billboard_offset.y;
}

void fragment() {
	// Called for every pixel the material is visible on.
}

void light() {
	// Called for every pixel for every light affecting the material.
}
