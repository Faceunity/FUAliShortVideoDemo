attribute vec4 point_position;
attribute float point_size;

//uniform mat4 scaleMatrix;

void main()
{
//     vec4 vPos = point_position * scaleMatrix;
    gl_Position = point_position;
//    gl_Position = vec4(vPos.x -1.0 , 1.0-vPos.y,1,1) ;
    gl_PointSize = 8.0;
}
