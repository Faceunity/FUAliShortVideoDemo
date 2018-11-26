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
#import <CoreMotion/CoreMotion.h>

@interface AlivcShortVideoFaceUnityManager ()
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic) int deviceOrientation;
/* 重力感应道具 */
@property (nonatomic,assign) BOOL isMotionItem;
@end

@implementation AlivcShortVideoFaceUnityManager
{
    int items[3];
    int _frameID;
    BOOL _isFlipx;
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
        [self setupDeviceMotion];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"v3.bundle" ofType:nil];
        
        /**这里新增了一个参数shouldCreateContext，设为YES的话，不用在外部设置context操作，我们会在内部创建并持有一个context。
         还有设置为YES,则需要调用FURenderer.h中的接口，不能再调用funama.h中的接口。*/
        [[FURenderer shareRenderer] setupWithDataPath:path authPackage:&g_auth_package authSize:sizeof(g_auth_package) shouldCreateContext:YES];
        [FURenderer setAsyncTrackFaceEnable:0];
        // 开启表情跟踪优化功能
        NSData *animModelData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"anim_model.bundle" ofType:nil]];
        int res0 = fuLoadAnimModel((void *)animModelData.bytes, (int)animModelData.length);
        NSLog(@"fuLoadAnimModel %@",res0 == 0 ? @"failure":@"success" );
        
        NSData *arModelData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ardata_ex.bundle" ofType:nil]];
        int res1 = fuLoadExtendedARData((void *)arModelData.bytes, (int)arModelData.length);
        NSLog(@"fuLoadExtendedARData %@",res1 == 0 ? @"failure":@"success" );
        
        NSData *tongueData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tongue.bundle" ofType:nil]];
        int ret2 = fuLoadTongueModel((void *)tongueData.bytes, (int)tongueData.length) ;
        NSLog(@"fuLoadTongueModel %@",ret2 == 0 ? @"failure":@"success" );
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
    
    
    // 在未识别到人脸时根据重力方向设置人脸检测方向
    if ([self isDeviceMotionChange]) {
        fuSetDefaultOrientation(self.deviceOrientation);
        if (self.isMotionItem) {
            [FURenderer itemSetParam:items[1] withName:@"rotMode" value:@(self.deviceOrientation)];
        }
        
    }
    
    //在使用动漫滤镜时，如果在初始化时最后一个参数设置的为YES，且调用的是不会传入纹理的接口时，需要将动漫滤镜中的“glver”的值设为3，其他情况则依据调用render接口时当前的glcontext版本来设置此参数的值。
    [FURenderer itemSetParam:items[1] withName:@"glVer" value:@(3)];
    
    CVPixelBufferRef pix = [[FURenderer shareRenderer] renderPixelBuffer:pixbuffer withFrameId:_frameID items:items itemCount:sizeof(items)/sizeof(int) flipx:_isFlipx];
    _frameID++;
    return pix;
}


- (void)loadItem:(NSString *)itemName{

    int destoryItem = items[1];
    
    if (itemName != nil && ![itemName isEqual: @"noitem"]) {
        /**先创建道具句柄*/
        NSString *path = [[NSBundle mainBundle] pathForResource:[itemName stringByAppendingString:@".bundle"] ofType:nil];
        
        int itemHandle = [FURenderer itemWithContentsOfFile:path];
        
        // 人像驱动 设置 3DFlipH
        BOOL isPortraitDrive = [itemName hasPrefix:@"picasso_e"];
        BOOL isAnimoji = [itemName hasSuffix:@"_Animoji"];
        
        if (isPortraitDrive || isAnimoji) {
             int value = _isFlipx ? 1 : 0;
            [FURenderer itemSetParam:itemHandle withName:@"is3DFlipH" value:@(value)];
            [FURenderer itemSetParam:itemHandle withName:@"isFlipExpr" value:@(value)];
        }
        
        if ([itemName isEqualToString:@"ctrl_rain"] || [itemName isEqualToString:@"ctrl_snow"] || [itemName isEqualToString:@"ctrl_flower"]) {//带重力感应道具
            [FURenderer itemSetParam:itemHandle withName:@"rotMode" value:@(self.deviceOrientation)];
            self.isMotionItem = YES;
        }else{
            self.isMotionItem = NO;
        }
        
        /**将刚刚创建的句柄存放在items[1]中*/
        items[1] = itemHandle;
    }else{
        /**为避免道具句柄被销毁会后仍被使用导致程序出错，这里需要将存放道具句柄的items[1]设为0*/
        items[1] = 0;
    }
    NSLog(@"faceunity: load item");
    
    /**后销毁老道具句柄*/
    if (destoryItem != 0)
    {
        NSLog(@"faceunity: destroy item");
        [FURenderer destroyItem:destoryItem];
    }
}



- (void)loadAnimojiFaxxBundle{
    /**先创建道具句柄*/
    NSString *path = [[NSBundle mainBundle] pathForResource:@"fxaa.bundle" ofType:nil];
    int itemHandle = [FURenderer itemWithContentsOfFile:path];
    
    /**销毁老的道具句柄*/
    if (items[2] != 0) {
        NSLog(@"faceunity: destroy item");
        [FURenderer destroyItem:items[2]];
    }
    
    /**将刚刚创建的句柄存放在items[3]中*/
    items[2] = itemHandle;
}

#pragma  mark ----  重力感应  -----
-(void)setupDeviceMotion{
    
    // 初始化陀螺仪
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = 0.5;// 1s刷新一次
    
    if ([self.motionManager isDeviceMotionAvailable]) {
        [self.motionManager startAccelerometerUpdates];
    }
}

#pragma  mark ----  设备类型  -----
-(BOOL)isDeviceMotionChange{
    if (![FURenderer isTracking]) {
        CMAcceleration acceleration = self.motionManager.accelerometerData.acceleration ;
        int orientation = 0;
        if (acceleration.x >= 0.75) {
            orientation = 1;
        } else if (acceleration.x <= -0.75) {
            orientation = 3;
        } else if (acceleration.y <= -0.75) {
            orientation = 0;
        } else if (acceleration.y >= 0.75) {
            orientation = 2;
        }
        
        if (self.deviceOrientation != orientation) {
            self.deviceOrientation = orientation ;
            return YES;
        }
    }
    return NO;
}




- (BOOL)switchFlipx{
    _isFlipx = !_isFlipx;
    int value = _isFlipx ? 1 : 0;
    [FURenderer itemSetParam:items[1] withName:@"is3DFlipH" value:@(value)];
    [FURenderer itemSetParam:items[1] withName:@"isFlipExpr" value:@(value)];

    return _isFlipx;
}

@end
