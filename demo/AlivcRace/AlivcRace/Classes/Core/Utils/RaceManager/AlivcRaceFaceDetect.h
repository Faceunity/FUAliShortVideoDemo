//
//  AlivcRaceFaceDetect.h
//  AlivcRace
//
//  Created by 孙震 on 2020/2/20.
//

#import <Foundation/Foundation.h>
#import <AliyunRace/aliyun_face_detect.h>
#import <AVFoundation/AVFoundation.h>

extern uint32_t pixelWidth;
extern uint32_t pixelHeight;

NS_ASSUME_NONNULL_BEGIN

@interface AlivcRaceFaceDetect : NSObject


- (void)clear;


- (aliyun_face_info_t)faceLocationsWithBuffer:(CMSampleBufferRef)sampleBuffer rotation:(int)rotation error:(int *)error;

@end

NS_ASSUME_NONNULL_END
