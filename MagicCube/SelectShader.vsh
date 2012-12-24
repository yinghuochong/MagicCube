attribute vec4 position;
attribute vec4 color;

varying vec4 colorVarying;


uniform mat4 mvp_matrix;
void main()
{
    gl_Position = mvp_matrix * position;
    colorVarying = color;
}
