attribute vec4 position;
attribute vec2 textCoordinate;
uniform mat4 rotateMatrix;
varying lowp vec2 varyTextCoord;

void main()
{
    varyTextCoord = textCoordinate;

//    vec4 vPos = position;
//    vPos = vPos * rotateMatrix;
    
    gl_Position = position * rotateMatrix;
//    gl_Position = vec4(position.x, position.y, position.z, 1.0);
}
