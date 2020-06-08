//
//  AlivcShortVideoFaceUnityManager.m
//  AliyunVideoClient_Entrance
//
//  Created by 张璠 on 2018/7/13.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AlivcShortVideoFaceUnityManager.h"
#import "FURenderer.h"
#import "authpack.h"

@implementation AlivcShortVideoFaceUnityManager
{
    int items[1];
    int _frameID;
    BOOL FUValid;//faceUnity 是否可用状态标识
}
+ (AlivcShortVideoFaceUnityManager *)shareManager
{
    static AlivcShortVideoFaceUnityManager *shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[AlivcShortVideoFaceUnityManager alloc] init];
    });
    
    return shareManager;
}
- (instancetype)init
{
    if (self = [super init]) {
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"v3.bundle" ofType:nil];
         
         /**这里新增了一个参数shouldCreateContext，设为YES的话，不用在外部设置context操作，我们会在内部创建并持有一个context。
          还有设置为YES,则需要调用FURenderer.h中的接口，不能再调用funama.h中的接口。*/
                [[FURenderer shareRenderer] setupWithData:nil dataSize:0 ardata:nil authPackage:&g_auth_package authSize:sizeof(g_auth_package) shouldCreateContext:YES];
         FUValid = YES;
         
         /* 加载AI模型 */
         [self loadAIModle];
        
        
        
    }
    
    return self;
}


-(void)loadAIModle{
    /* 单独使用美颜场景，只需加载 ai_facelandmarks75,注：美颜和贴纸都用场景用 ai_face_processor*/
//    NSData *ai_facelandmarks75 = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ai_facelandmarks75.bundle" ofType:nil]];
//    [FURenderer loadAIModelFromPackage:(void *)ai_facelandmarks75.bytes size:(int)ai_facelandmarks75.length aitype:FUAITYPE_FACELANDMARKS75];
    
    NSData *ai_face_processor = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ai_face_processor.bundle" ofType:nil]];
    [FURenderer loadAIModelFromPackage:(void *)ai_face_processor.bytes size:(int)ai_face_processor.length aitype:FUAITYPE_FACEPROCESSOR];
}

/**销毁全部道具*/
- (void)destoryItems
{
    if (!FUValid) return;
    [FURenderer destroyAllItems];
    
    /**销毁道具后，为保证被销毁的句柄不再被使用，需要将int数组中的元素都设为0*/
    for (int i = 0; i < sizeof(items) / sizeof(int); i++) {
        items[i] = 0;
    }
    
    /**销毁道具后，清除context缓存*/
    [FURenderer OnDeviceLost];
    
    //    /**销毁道具后，重置默认参数*/
    //    [self setBeautyDefaultParameters];
}

- (NSInteger)OutputVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer textureName:(NSInteger)textureName beautyWhiteValue:(CGFloat)beautyWhiteValue blurValue:(CGFloat)blurValue bigEyeValue:(CGFloat)bigEyeValue slimFaceValue:(CGFloat)slimFaceValue buddyValue:(CGFloat)buddyValue{
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    int h = (int)CVPixelBufferGetHeight(pixelBuffer);
    int w = (int)CVPixelBufferGetWidth(pixelBuffer);
    int stride = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
    
    TIOSDualInput input;
    input.p_BGRA = CVPixelBufferGetBaseAddress(pixelBuffer);
    input.tex_handle = (GLuint)textureName;
    input.format = FU_IDM_FORMAT_BGRA;
    input.stride_BGRA = stride;
    GLuint outHandle;
    
    // 美颜
    if(items[0] == 0){
        NSString *path = [[NSBundle mainBundle] pathForResource:@"face_beautification" ofType:@"bundle"];
        items[0] = [FURenderer itemWithContentsOfFile:path];
    }
    // 设置美颜参数
    // 美白
    [FURenderer itemSetParam:items[0] withName:@"color_level" value:@(beautyWhiteValue)];// 0-1
    
    // 磨皮
    [FURenderer itemSetParam:items[0] withName:@"blur_level" value:@(6.0*blurValue)];// 0-6.0
    [FURenderer itemSetParam:items[0] withName:@"skin_detect" value:@(0)];//1开启，0不开启
    [FURenderer itemSetParam:items[0] withName:@"nonshin_blur_scale" value:@(0.45)];
    
    [FURenderer itemSetParam:items[0] withName:@"heavy_blur" value:@(0)];//1开启朦胧
    [FURenderer itemSetParam:items[0] withName:@"blur_blend_ratio" value:@(0.5)];// 0-1
    // 红润
    [FURenderer itemSetParam:items[0] withName:@"red_level" value:@(buddyValue)];
    
    [FURenderer itemSetParam:items[0] withName:@"eye_enlarging" value:@(bigEyeValue)];//0-1
    // 瘦脸
    [FURenderer itemSetParam:items[0] withName:@"face_shape" value:@(4)];
    [FURenderer itemSetParam:items[0] withName:@"cheek_thinning" value:@(slimFaceValue*1.5)];//0-1
    //亮眼
    [FURenderer itemSetParam:items[0] withName:@"eye_bright" value:@(0)];//facunity亮眼功能有问题，先关闭
    
    fuRenderItemsEx(FU_FORMAT_RGBA_TEXTURE, &outHandle, FU_FORMAT_INTERNAL_IOS_DUAL_INPUT, &input, w, h, _frameID, items, 1);
    _frameID++;
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    return outHandle;
    //    FUOutput output = [[FURenderer shareRenderer] renderPixelBuffer:pixelBuffer bgraTexture:(GLuint)textureName withFrameId:_frameID items:items itemCount:sizeof(items)/sizeof(int)];
    //    _frameID ++ ;
    //    return output.bgraTextureHandle;
}

- (CVPixelBufferRef)RenderedPixelBufferWithRawSampleBuffer:(CMSampleBufferRef)sampleBuffer beautyWhiteValue:(CGFloat)beautyWhiteValue blurValue:(CGFloat)blurValue bigEyeValue:(CGFloat)bigEyeValue slimFaceValue:(CGFloat)slimFaceValue buddyValue:(CGFloat)buddyValue{
    
    if (!FUValid) return CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferRef pixbuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 美颜
    if(items[0] == 0){
        NSString *path = [[NSBundle mainBundle] pathForResource:@"face_beautification" ofType:@"bundle"];
        items[0] = [FURenderer itemWithContentsOfFile:path];
    }
    // 设置美颜参数
    // 美白
    [FURenderer itemSetParam:items[0] withName:@"color_level" value:@(beautyWhiteValue)];// 0-1
    // 红润
    [FURenderer itemSetParam:items[0] withName:@"red_level" value:@(buddyValue)];
    // 磨皮
    [FURenderer itemSetParam:items[0] withName:@"blur_level" value:@(6.0*blurValue)];// 0-6.0
    [FURenderer itemSetParam:items[0] withName:@"skin_detect" value:@(0)];//1开启，0不开启
    [FURenderer itemSetParam:items[0] withName:@"nonshin_blur_scale" value:@(0.45)];
    
    [FURenderer itemSetParam:items[0] withName:@"heavy_blur" value:@(0)];//1开启朦胧
    [FURenderer itemSetParam:items[0] withName:@"blur_blend_ratio" value:@(0.5)];// 0-1
    
    // 大眼
    [FURenderer itemSetParam:items[0] withName:@"eye_enlarging" value:@(bigEyeValue)];//0-1
    // 瘦脸
    [FURenderer itemSetParam:items[0] withName:@"face_shape" value:@(4)];
    [FURenderer itemSetParam:items[0] withName:@"cheek_thinning" value:@(slimFaceValue*1.5)];//0-1
    //亮眼
    [FURenderer itemSetParam:items[0] withName:@"eye_bright" value:@(0)];//facunity亮眼功能有问题，先关闭
    
    //    CVPixelBufferRef pix = [[FURenderer shareRenderer] renderPixelBuffer:pixbuffer withFrameId:_frameID items:items itemCount:1 flipx:YES];
    
    
    static EAGLContext *context;
    if (context == NULL) {
        context = [EAGLContext currentContext];
    }
    
    if (context != [EAGLContext currentContext]) {
        NSLog(@"context change");
        fuOnDeviceLost();
        context = [EAGLContext currentContext];
    }
    
    CVPixelBufferLockBaseAddress(pixbuffer, 0) ;
    int w0 = (int)CVPixelBufferGetWidth(pixbuffer) ;
    int h0 = (int)CVPixelBufferGetHeight(pixbuffer) ;
    int stride0 = (int)CVPixelBufferGetBytesPerRowOfPlane(pixbuffer, 0);
    int stride1 = (int)CVPixelBufferGetBytesPerRowOfPlane(pixbuffer, 1);
    void *byte0 = CVPixelBufferGetBaseAddressOfPlane(pixbuffer, 0) ;
    void *byte1 = CVPixelBufferGetBaseAddressOfPlane(pixbuffer, 1) ;
    
    TNV12Buffer nv12;
    nv12.p_Y = byte0;
    nv12.p_CbCr = byte1;
    nv12.stride_Y = stride0;
    nv12.stride_CbCr = stride1;
    fuRenderItemsEx(FU_FORMAT_NV12_BUFFER, &nv12, FU_FORMAT_NV12_BUFFER, &nv12, w0, h0, _frameID, items, sizeof(items)/sizeof(int));
    
    //    fuRenderItemsEx2(FU_FORMAT_BGRA_BUFFER, byte0, FU_FORMAT_BGRA_BUFFER, byte0, w0, h0, _frameID, items, sizeof(items)/sizeof(int), NAMA_RENDER_FEATURE_FULL, NULL);
    CVPixelBufferUnlockBaseAddress(pixbuffer, 0);
    _frameID++;
    return pixbuffer;
}
@end
