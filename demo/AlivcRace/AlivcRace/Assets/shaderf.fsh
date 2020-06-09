varying lowp vec2 varyTextCoord;
uniform sampler2D colorMap;

void main()
{
//    gl_FragColor = vec4(1.0, 0.0, 0.0, 0.0);
    gl_FragColor = texture2D(colorMap, varyTextCoord);
    
}
