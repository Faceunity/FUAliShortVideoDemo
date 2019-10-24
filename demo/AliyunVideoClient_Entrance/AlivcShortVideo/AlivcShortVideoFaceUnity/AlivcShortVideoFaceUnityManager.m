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
        [[FURenderer shareRenderer] setupWithDataPath:path authPackage:&g_auth_package authSize:sizeof(g_auth_package) shouldCreateContext:YES];
        
    }
    
    return self;
}

/**销毁全部道具*/
- (void)destoryItems
{
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
    // 大眼
    [FURenderer itemSetParam:items[0] withName:@"face_shape" value:@(4)];
    [FURenderer itemSetParam:items[0] withName:@"eye_enlarging" value:@(bigEyeValue)];//0-1
    // 瘦脸
    [FURenderer itemSetParam:items[0] withName:@"face_shape" value:@(4)];
    [FURenderer itemSetParam:items[0] withName:@"cheek_thinning" value:@(slimFaceValue*1.5)];//0-1
    
    fuRenderItemsEx(FU_FORMAT_RGBA_TEXTURE, &outHandle, FU_FORMAT_INTERNAL_IOS_DUAL_INPUT, &input, w, h, _frameID, items, 1);
    _frameID++;

    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);

    return outHandle;
//    FUOutput output = [[FURenderer shareRenderer] renderPixelBuffer:pixelBuffer bgraTexture:(GLuint)textureName withFrameId:_frameID items:items itemCount:sizeof(items)/sizeof(int)];
//    _frameID ++ ;
//    return output.bgraTextureHandle;
}

- (CVPixelBufferRef)RenderedPixelBufferWithRawSampleBuffer:(CMSampleBufferRef)sampleBuffer beautyWhiteValue:(CGFloat)beautyWhiteValue blurValue:(CGFloat)blurValue bigEyeValue:(CGFloat)bigEyeValue slimFaceValue:(CGFloat)slimFaceValue buddyValue:(CGFloat)buddyValue{
    
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
    [FURenderer itemSetParam:items[0] withName:@"face_shape" value:@(4)];
    [FURenderer itemSetParam:items[0] withName:@"eye_enlarging" value:@(bigEyeValue)];//0-1
    // 瘦脸
    [FURenderer itemSetParam:items[0] withName:@"face_shape" value:@(4)];
    [FURenderer itemSetParam:items[0] withName:@"cheek_thinning" value:@(slimFaceValue*1.5)];//0-1

    CVPixelBufferRef pix = [[FURenderer shareRenderer] renderPixelBuffer:pixbuffer withFrameId:_frameID items:items itemCount:1 flipx:YES];
    _frameID++;
    return pix;
}
@end
