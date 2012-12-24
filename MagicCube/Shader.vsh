attribute vec4 position;
//attribute vec4 color;

//varying vec4 colorVarying;
attribute vec4 texture_coord;
varying vec2 texCoordVarying;

uniform mat4 mvp_matrix;
void main()
{
    gl_Position = mvp_matrix * position;
    //colorVarying = color;
    texCoordVarying = texture_coord.st;
}
