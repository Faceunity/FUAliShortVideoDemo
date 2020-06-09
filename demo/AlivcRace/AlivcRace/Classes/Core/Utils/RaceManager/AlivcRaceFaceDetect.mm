//
//  AlivcRaceFaceDetect.m
//  AlivcRace
//
//  Created by 孙震 on 2020/2/20.
//

#import "AlivcRaceFaceDetect.h"
#import <AVFoundation/AVFoundation.h>

uint32_t pixelWidth = 0;
uint32_t pixelHeight = 0;

@interface AlivcRaceFaceDetect()
@property (nonatomic,assign)CGSize size;
@property (nonatomic,assign) BOOL hasInit;
@property (nonatomic,assign) int initResult;

@end

static race_t faceHandle = nullptr;

@implementation AlivcRaceFaceDetect



- (instancetype)init {
    if (self =[super init]) {
        self.size = CGSizeZero;
        self.hasInit = NO;
        self.initResult = 0;
    }
    return self;
}

- (void)clear { 
    self.hasInit = NO;
    self.initResult = 0;
    aliyun_face_destroy(faceHandle);
    faceHandle = nullptr;
}

- (aliyun_face_info_t)faceLocationsWithBuffer:(CMSampleBufferRef)sampleBuffer rotation:(int)rotation error:(int *)error;{
     aliyun_face_info_t faceInfo;
    
    if (!faceHandle) {
        int  result = aliyun_face_default_create(&faceHandle,ALR_FACE_DETECT_MODE_VIDEO);
         *error = result;
        if (result < 0) {
            NSLog(@"race sdk 初始化失败！！！！可能是由于license过期导致,请检查license");
            return faceInfo;
        }
        aliyun_face_setParam(faceHandle, ALR_FACE_PARAM_DETECT_INTERVAL, 5);
    }
    *error = 0;
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer((CMSampleBufferRef)sampleBuffer);
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    uint8_t *buffer = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer,0);
   
    uint32_t width = (uint32_t)CVPixelBufferGetWidth(pixelBuffer);
    pixelWidth = width;
    uint32_t height = (uint32_t)CVPixelBufferGetHeight(pixelBuffer);
    pixelHeight = height;
    OSType pixelfmt = CVPixelBufferGetPixelFormatType(pixelBuffer);
    uint32_t bytesPerRow = (uint32_t)CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
    auto planes = CVPixelBufferGetPlaneCount(pixelBuffer);
   
    aliyun_rotation_t raceRotation = (aliyun_rotation_t)rotation;
//    Rotation raceRotation = (Rotation)0;
    if (planes) {
        aliyun_image_format_t formatIn = ALR_IMAGE_FORMAT_RGBA;
        switch (pixelfmt)
        {
//            case kCVPixelFormatType_24RGB:
//                formatIn = ALR_IMAGE_FORMAT_RGB;
//                break;
            case kCVPixelFormatType_32RGBA:
                formatIn = ALR_IMAGE_FORMAT_RGBA;
                break;
            case kCVPixelFormatType_32BGRA:
                formatIn = ALR_IMAGE_FORMAT_BGRA;
                break;
            case kCVPixelFormatType_420YpCbCr8BiPlanarFullRange:
                formatIn = ALR_IMAGE_FORMAT_NV21;
                break;
            default:
                formatIn = ALR_IMAGE_FORMAT_NV21;
        }
        if (buffer == nullptr) {
            NSLog(@"buffer null");
        }
         
        auto ret = aliyun_face_detect(faceHandle,buffer, formatIn, width, height, bytesPerRow, raceRotation, 0, raceRotation, 0, &faceInfo);
      
//        NSLog(@"faceCount:%d ret %d",faceInfo.face_count, ret);
 

        CVPixelBufferUnlockBaseAddress(pixelBuffer,0);
        return faceInfo;
    }
    CVPixelBufferUnlockBaseAddress(pixelBuffer,0);
    return faceInfo;
}


@end
