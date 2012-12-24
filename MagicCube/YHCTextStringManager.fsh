varying highp vec4 varTextureCoord;

uniform sampler2D texture;
uniform highp vec3 color;
uniform highp float alpha;

void main()
{
    highp float threshold = 0.90;
    
    gl_FragColor = texture2D(texture, varTextureCoord.st);
    
    if(gl_FragColor.r > threshold && gl_FragColor.g > threshold && gl_FragColor.b > threshold)
        discard;
    
    gl_FragColor.rgb += color.rgb;
    gl_FragColor.a = alpha;
    
}