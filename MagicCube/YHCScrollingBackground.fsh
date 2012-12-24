varying highp vec4 varTextureCoord;

uniform sampler2D texture;

void main()
{
    gl_FragColor = texture2D (texture, varTextureCoord.st);
}