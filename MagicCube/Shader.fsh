//varying lowp vec4 colorVarying;

varying highp vec2 texCoordVarying;
uniform sampler2D texture;
void main()
{
    //gl_FragColor = colorVarying;
    gl_FragColor = texture2D(texture, texCoordVarying);
}
