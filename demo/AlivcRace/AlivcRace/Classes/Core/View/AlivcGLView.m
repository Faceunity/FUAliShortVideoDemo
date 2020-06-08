//
//  AlivcGLView.m
//  AlivcRace
//
//  Created by 孙震 on 2020/2/25.
//

#import "AlivcGLView.h"
#import <OpenGLES/ES3/gl.h>

@interface AlivcGLView()
//apple supply
@property (nonatomic,strong) CAEAGLLayer *myEagLayer;
@property (nonatomic,strong) EAGLContext *myContext;

@property (nonatomic,assign) GLuint renderBuffer;
@property (nonatomic,assign) GLuint frameBuffer;

@property (nonatomic,assign) GLuint myProgram;
@property (nonatomic,assign) GLuint myPointProgram;
@property (nonatomic,assign) GLuint myYUVProgram;
 

@end


GLfloat attrArr[] =
 {
     
    //es3 坐标
     -1, -1,  0.0f,  0.0f, 0.0f,
     1, -1,  0.0f,  1.0f, 0.0f,
     -1,  1,  0.0f,  0.0f, 1.0f,
     1,  1,  0.0f,  1.0f, 1.0f,
     
//      -1, -1,  0.0f,  1.0f, 1.0f,
//        1, -1,  0.0f,  0.0f, 1.0f,
//        -1,  1,  0.0f,  1.0f, 0.0f,
//        1,  1,  0.0f,  0.0f, 0.0f,
 };

@implementation AlivcGLView
{
    CVOpenGLESTextureCacheRef _textureCache;
    CVOpenGLESTextureRef _outTexture0;
    CVOpenGLESTextureRef _outTexture1;
}


- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        //1.创建图层
        [self setupLayer];
        //2.创建上下文
        [self setupContext];
        //3.清理缓冲区
        [self deleteRenderAndFrameBuffer];
        //4.设置renderBuffer 渲染缓冲区
        [self setupRenderBuffer];
        //5.设置frameBuffer  帧缓冲区
        [self setupFrameBuffer];
        [self setupCache];
        [self loadProgram];
        [self loadPointProgram];
        [self loadYUVProgram];
      
       
    }
    return self;
}

- (void)setupCache {
      int result =  CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, self.myContext, NULL, &_textureCache);
    if (result < 0) {
        NSLog(@"create cache error");
    }
      
}
- (void)draw:(CVPixelBufferRef)pixelBuffer facePoint:(NSArray *)points {
    [self renderPixelBuffer:pixelBuffer];
    [self renderFacePoint:points];
    [self presentRenderbuffer];
}

- (void)draw:(int)texture {
    [self renderTexture:texture];
    [self presentRenderbuffer];
}

- (void)renderPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    uint32_t width = (uint32_t)CVPixelBufferGetWidth(pixelBuffer);
       uint32_t height = (uint32_t)CVPixelBufferGetHeight(pixelBuffer);
       //创建亮度纹理；
       glActiveTexture(GL_TEXTURE0);
       
       int result = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCache, pixelBuffer, NULL, GL_TEXTURE_2D, GL_LUMINANCE, width, height, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0, &_outTexture0);
        
       if (result) {
           NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", result);
       }
       
       glBindTexture(CVOpenGLESTextureGetTarget(_outTexture0), CVOpenGLESTextureGetName(_outTexture0));
       glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
       glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
       glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
       glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
       
       glActiveTexture(GL_TEXTURE1);
       //色度纹理
       result = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCache, pixelBuffer, NULL, GL_TEXTURE_2D, GL_LUMINANCE_ALPHA, width/2, height/2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 1, &_outTexture1);
        
       if (result) {
           NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", result);
       }
       
       glBindTexture(CVOpenGLESTextureGetTarget(_outTexture1), CVOpenGLESTextureGetName(_outTexture1));
       glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
       glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
       glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
       glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
       
       //6.开始绘制
       glClearColor(0.3f, 0.45f, 0.5f, 1.0f);
       glClear(GL_COLOR_BUFFER_BIT);
       
       glUseProgram(self.myYUVProgram);
       
       GLint mDisplayWidth, mDisplayHeight;
       glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &mDisplayWidth);
       glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &mDisplayHeight);
       
       if (self.tWidth > 0 && self.tHeight > 0) {
           int width = self.tWidth;
           int height = self.tHeight;
           float ar = self.tHeight / (float) self.tWidth;
           if (mDisplayWidth / (float) mDisplayHeight > ar) {
               int scaleHeight = mDisplayWidth * height / width;
               int offset = (mDisplayHeight - scaleHeight) / 2;
               glViewport(0, offset, mDisplayWidth, scaleHeight);
           } else {
               int scaleWidth = mDisplayHeight * width / height;
               int offset = (mDisplayWidth - scaleWidth) / 2;
               glViewport(offset, 0, scaleWidth, mDisplayHeight);
           }
       } else {
           glViewport(0, 0, mDisplayWidth, mDisplayHeight);
       }
       
       
       GLuint position = glGetAttribLocation(self.myYUVProgram, "position");
       glEnableVertexAttribArray(position);
       //设置读取方式
       glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GL_FLOAT) * 5, attrArr);
       
       //4.纹理数据
       GLuint textCoordinate = glGetAttribLocation(self.myYUVProgram, "textCoordinate");
       glEnableVertexAttribArray(textCoordinate);
       glVertexAttribPointer(textCoordinate, 2, GL_FLOAT, GL_FALSE, sizeof(GL_FLOAT) * 5, attrArr +3);
       
       //5.加载纹理
       
       int SamplerY = glGetUniformLocation(self.myYUVProgram, "SamplerY");
       int SamplerUV=  glGetUniformLocation(self.myYUVProgram, "SamplerUV");
       
       
       glUniform1i(SamplerY, 0);
       glUniform1i(SamplerUV, 1);
       
       //解决纹理翻转
       [self rotateTextureImage];
       
       glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
       
       
}

- (void)drawWithPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    [self renderPixelBuffer:pixelBuffer];
    [self presentRenderbuffer];
}

-(void)rotateTextureImage
{
    //注意，想要获取shader里面的变量，这里记得要在glLinkProgram后面，后面，后面！
    //1. rotate等于shaderv.vsh中的uniform属性，rotateMatrix
    GLuint rotate = glGetUniformLocation(self.myYUVProgram, "rotateMatrix");
    
    //2.获取渲旋转的弧度
    float radians = 180 * 3.14159f / 180.0f;
   
    //3.求得弧度对于的sin\cos值
    float s = sin(radians);
    float c = cos(radians);
    
    //4.因为在3D课程中用的是横向量，在OpenGL ES用的是列向量
    /*
     参考Z轴旋转矩阵
     */
//    GLfloat zRotation[16] = {
//        c,-s,0,0,
//        s,c,0,0,
//        0,0,1,0,
//        0,0,0,1
//    };
    
    
    GLfloat xRotation[16] = {
          1,0,0,0,
          0,c,-s,0,
          0,s,c,0,
          0,0,0,1
      };
      
    
    //5.设置旋转矩阵
    /*
     glUniformMatrix4fv (GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
     location : 对于shader 中的ID
     count : 个数
     transpose : 转置
     value : 指针
     */
    glUniformMatrix4fv(rotate, 1, GL_FALSE, xRotation);
    
    
}

-(void)cleanupTextures{
  
    if (_outTexture0) {
       CFRelease(_outTexture0);
       _outTexture0 = NULL;
    }
    
    if (_outTexture1) {
        CFRelease(_outTexture1);
        _outTexture1 = NULL;
    }
    
    CVOpenGLESTextureCacheFlush(_textureCache, 0);
}
- (void)renderTexture:(int)texture {
    //6.开始绘制
     glClearColor(0.3f, 0.45f, 0.5f, 1.0f);
     glClear(GL_COLOR_BUFFER_BIT);
     
     glUseProgram(self.myProgram);
     
     GLint mDisplayWidth, mDisplayHeight;
     glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &mDisplayWidth);
     glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &mDisplayHeight);
    
    if (self.tWidth > 0 && self.tHeight > 0) {
        int width = self.tWidth;
        int height = self.tHeight;
        float ar = self.tHeight / (float) self.tWidth;
        if (mDisplayWidth / (float) mDisplayHeight > ar) {
            int scaleHeight = mDisplayWidth * height / width;
            int offset = (mDisplayHeight - scaleHeight) / 2;
            glViewport(0, offset, mDisplayWidth, scaleHeight);
        } else {
            int scaleWidth = mDisplayHeight * width / height;
            int offset = (mDisplayWidth - scaleWidth) / 2;
            glViewport(offset, 0, scaleWidth, mDisplayHeight);
        }
    } else {
        glViewport(0, 0, mDisplayWidth, mDisplayHeight);
    }
     
      
     GLuint position = glGetAttribLocation(self.myProgram, "position");
     glEnableVertexAttribArray(position);
     //设置读取方式
     glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(GL_FLOAT) * 5, attrArr);
     
     //4.纹理数据
     GLuint textCoordinate = glGetAttribLocation(self.myProgram, "textCoordinate");
     glEnableVertexAttribArray(textCoordinate);
     glVertexAttribPointer(textCoordinate, 2, GL_FLOAT, GL_FALSE, sizeof(GL_FLOAT) * 5, attrArr +3);
     
    //5.加载纹理
    
    int colorMap = glGetUniformLocation(self.myProgram, "colorMap");
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    glUniform1i(colorMap, 0);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


- (void)renderFacePoint:(NSArray *)points {

    glUseProgram(self.myPointProgram);
    
     GLsizei count = (GLsizei)points.count / 2;
    
    //设置坐标
    GLfloat *vertex = malloc(sizeof(CGFloat) * points.count);
    for(int i = 0; i < points.count;i++) {
        vertex[i] = [points[i] floatValue];
    }
    
//    GLfloat size[] = {10.0f,10.0f};
//    CGFloat translateX = 0;
//    CGFloat translateY = 0;
//    CGFloat scaleX = 1;
//    CGFloat scaleY = 1;
//    CGFloat scaleX = 2.0/width ;
//    CGFloat scaleY = 2.0/height;
    
//    //平移矩阵
//    GLfloat translate[16] = {
//        1,0,0,0,
//        0,1,0,0,
//        0,0,1,0,
//        -1,0,0,1
//    };
    
    //缩放矩阵
//    GLfloat scale[16] = {
//        scaleX,0,0,0,
//        0,scaleY,0,0,
//        0,0,1,0,
//        0,0,0,1
//    };
    
    GLuint point_position = glGetAttribLocation(self.myPointProgram, "point_position");
    glEnableVertexAttribArray(point_position);
    
    glVertexAttribPointer(point_position, 2, GL_FLOAT, GL_FALSE, sizeof(GL_FLOAT)*2, vertex);
    
//    GLuint point_size = glGetAttribLocation(self.myPointProgram, "point_size");
//    glEnableVertexAttribArray(point_size);
//    glVertexAttribPointer(point_size, 1, GL_FLOAT, GL_FALSE, 0, size);
//
    
     
//    GLuint transalte_position = glGetUniformLocation(self.myPointProgram, "transalteMatrix");
//    glUniformMatrix4fv(transalte_position, 1, GL_FALSE, translate);

   
//    GLuint scale_position = glGetUniformLocation(self.myPointProgram, "scaleMatrix");
//    glUniformMatrix4fv(scale_position, 1, GL_FALSE, scale);
//    CGFloat
    
   
    glDrawArrays(GL_POINTS, 0, count);
     
}



- (void)presentRenderbuffer {
     [self.myContext presentRenderbuffer:GL_RENDERBUFFER];
     [self cleanupTextures];
}
- (BOOL)loadPointProgram {
    // 读取顶点片元着色器
    NSString *vertexFile = [[NSBundle mainBundle] pathForResource:@"shaderPointv" ofType:@"vsh"];
    NSString *fragFile = [[NSBundle mainBundle] pathForResource:@"shaderPointf" ofType:@"fsh"];
    
    NSLog(@"vertFile:%@",vertexFile);
    NSLog(@"fragFile:%@",fragFile);
    
    self.myPointProgram = [self loadSharders:vertexFile withFragpath:fragFile];
    
    //4 link program
    glLinkProgram(self.myPointProgram);
    GLint linkStatus;
    glGetProgramiv(self.myPointProgram, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        //打印失败信息
        GLchar message[512];
        glGetProgramInfoLog(self.myPointProgram, sizeof(message), 0, message);
        NSString *messageStr = [NSString stringWithUTF8String:message];
        NSLog(@"myPointProgram link error :%@",messageStr);
        return NO;
    }
    NSLog(@"myPointProgram link Success");
    
    //5 use program
    glUseProgram(self.myPointProgram);
    return YES;
}


- (BOOL)loadYUVProgram {
    
    // 读取顶点片元着色器
      NSString *vertexFile = [[NSBundle mainBundle] pathForResource:@"shaderYUV" ofType:@"vsh"];
      NSString *fragFile = [[NSBundle mainBundle] pathForResource:@"shaderYUV" ofType:@"fsh"];
      
      NSLog(@"vertFile:%@",vertexFile);
      NSLog(@"fragFile:%@",fragFile);
      
      self.myYUVProgram = [self loadSharders:vertexFile withFragpath:fragFile];
      
      //4 link program
      glLinkProgram(self.myYUVProgram);
      GLint linkStatus;
      glGetProgramiv(self.myYUVProgram, GL_LINK_STATUS, &linkStatus);
      if (linkStatus == GL_FALSE) {
          //打印失败信息
          GLchar message[512];
          glGetProgramInfoLog(self.myYUVProgram, sizeof(message), 0, message);
          NSString *messageStr = [NSString stringWithUTF8String:message];
          NSLog(@"myYUVProgram link error :%@",messageStr);
          return NO;
      }
      NSLog(@"myYUVProgram link Success");
      
      //5 use program
      glUseProgram(self.myYUVProgram);
      return YES;
}
- (BOOL)loadProgram {
    // 读取顶点片元着色器
    NSString *vertexFile = [[NSBundle mainBundle] pathForResource:@"shaderv" ofType:@"vsh"];
    NSString *fragFile = [[NSBundle mainBundle] pathForResource:@"shaderf" ofType:@"fsh"];
    
    NSLog(@"vertFile:%@",vertexFile);
    NSLog(@"fragFile:%@",fragFile);
    
    self.myProgram = [self loadSharders:vertexFile withFragpath:fragFile];
    
    //4 link program
    glLinkProgram(self.myProgram);
    GLint linkStatus;
    glGetProgramiv(self.myProgram, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        //打印失败信息
        GLchar message[512];
        glGetProgramInfoLog(self.myProgram, sizeof(message), 0, message);
        NSString *messageStr = [NSString stringWithUTF8String:message];
        NSLog(@"program link error :%@",messageStr);
        return NO;
    }
    NSLog(@"Program link Success");
    
    //5 use program
    glUseProgram(self.myProgram);
    return YES;
}

- (GLuint)loadSharders:(NSString *)vertexFile withFragpath:(NSString *)fragFile{
    
    GLuint verShader, fragShader;
    
    GLuint program = glCreateProgram();
    
    //编译shader
    [self compileShader:&verShader type:GL_VERTEX_SHADER file:vertexFile];
    
    [self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragFile];
    
    glAttachShader(program, verShader);
    glAttachShader(program, fragShader);
    
    glDeleteShader(verShader);
    glDeleteShader(fragShader);
    
    return program;
}

- (void)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
    
    //1.读取文件
    NSString *content = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = (GLchar *)[content UTF8String];
    
    //2.创建shader
    *shader = glCreateShader(type);
    
    //3 把源码添加到shader
    glShaderSource(*shader, 1, &source, NULL);
    
    //4 编译
    glCompileShader(*shader);
    
}

- (void)setupFrameBuffer {
    GLuint frameBuffer;
    glGenFramebuffers(1, &frameBuffer);
    self.frameBuffer = frameBuffer;
    
    glBindFramebuffer(GL_FRAMEBUFFER, self.frameBuffer);
    
    //将randerbuffer和frameBuffer 绑定在一起
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.renderBuffer);
    
    
}
- (void)setupRenderBuffer {
    //定义缓冲区
    GLuint renderBuffer;
    glGenRenderbuffers(1, &renderBuffer);
    
    self.renderBuffer = renderBuffer;
    
    glBindRenderbuffer(GL_RENDERBUFFER, self.renderBuffer);
    
    //将eagllayer 绑定到 renderbuffer
    [self.myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.myEagLayer];
}
- (void)deleteRenderAndFrameBuffer {
    //清空renderBuffer
    glDeleteBuffers(1, &_renderBuffer);
    self.renderBuffer = 0;
    
    //清空帧缓存区
    glDeleteBuffers(1, &_frameBuffer);
    self.frameBuffer = 0;
}

- (void)setupContext {
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES3;
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:api];
    if (!context) {
        NSLog(@"create context failed");
        return;
    }
    
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"set current context failed");
        return;
    }
    
    self.myContext  = context;
    
}


- (void)setupLayer {
    //1.创建eagllayer
    self.myEagLayer = (CAEAGLLayer *)self.layer;
    
    //2设置scale
    self.myEagLayer.contentsScale = [UIScreen mainScreen].scale;
    
    //3.描述属性
    self.myEagLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking:@(NO),kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8};
    
}


+ (Class)layerClass {
    //apple 提供给opengl使用的
    return [CAEAGLLayer class];
}


@end
