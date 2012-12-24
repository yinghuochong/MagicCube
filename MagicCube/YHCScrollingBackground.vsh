attribute vec4 vertex;

attribute vec4 texture_coord;

varying vec4 varTextureCoord;

void main()
{
    gl_Position = vertex;
    varTextureCoord = texture_coord;
}