varying lowp vec2 varyTextCoord;
precision highp float;
uniform sampler2D SamplerY;
uniform sampler2D SamplerUV;

void main()
{
//     mediump vec3 yuv;
//     lowp vec3 rgb;
    mediump vec3 yuv;
    lowp vec3 rgb;
     yuv.x = (texture2D(SamplerY, varyTextCoord).r);// - (16.0/255.0));
     yuv.yz = (texture2D(SamplerUV, varyTextCoord).ra - vec2(0.5, 0.5));
//     yuv.x = texture2D(SamplerY, varyTextCoord).r;
//     yuv.yz = texture2D(SamplerUV, varyTextCoord).rg - vec2(0.5, 0.5);
     
     // BT.601, which is the standard for SDTV is provided as a reference
     /*
     rgb = mat3(    1,       1,     1,
                    0, -.34413, 1.772,
                1.402, -.71414,     0) * yuv;
      */
     
     // Using BT.709 which is the standard for HDTV
     rgb = mat3( 1.0,    1.0,    1.0,
     0.0,    -0.343, 1.765,
     1.4,    -0.711, 0.0) * yuv;
     
     gl_FragColor = vec4(rgb, 1);
}

