//
//  AlivcRaceFaceDetectGLPointVC.m
//  AlivcRace
//
//  Created by 孙震 on 2020/2/26.
//

#import "AlivcRaceFaceDetectGLPointVC.h"
#import <CoreMotion/CoreMotion.h>
#import "AlivcRaceFaceDetect.h"
#import "AlivcRaceBeauty.h"
#import "AlivcGLView.h"
@import AVFoundation;
@import GLKit;

@interface AlivcRaceFaceDetectGLPointVC ()

@property (atomic,assign) BOOL openFaceDetect;
@property (nonatomic, strong) CMMotionManager *motionManager;   //陀螺仪
@property (nonatomic, strong) AlivcRaceFaceDetect *faceDetect;
//@property (nonatomic, strong) AlivcRaceBeauty *raceBeauty;
@property (nonatomic, weak) AlivcGLView *renderView;
@property (nonatomic, assign) int cameraRotate;
@end

@implementation AlivcRaceFaceDetectGLPointVC
{
     NSOperationQueue *_queue;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    AlivcGLView *view = [[AlivcGLView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
       [self.view addSubview:view];
       self.renderView = view;
    
     [self addFacePointSwitch];
    
    self.openFaceDetect = YES;
}

- (void)addFacePointSwitch {
    
    UISwitch *faceDetectSwitch = [[UISwitch alloc] init];
    faceDetectSwitch.center = CGPointMake(120, 100);
    [self.view addSubview:faceDetectSwitch];
    faceDetectSwitch.on =YES;
     
    UILabel *faceDetectLabel = [[UILabel alloc] init];
    faceDetectLabel.text = @"绘制点位";
    [faceDetectLabel sizeToFit];
    faceDetectLabel.center = CGPointMake(50, 100);
    faceDetectLabel.textColor = [UIColor grayColor];
     
    [self.view addSubview:faceDetectLabel];
    
    [faceDetectSwitch addTarget:self action:@selector(faceDetectSwitchClick) forControlEvents:UIControlEventValueChanged];
}

- (void)faceDetectSwitchClick {
    self.openFaceDetect = !self.openFaceDetect;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startRetainCameraRotate];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.motionManager stopDeviceMotionUpdates];
}
- (void)dealloc {   
    [self.faceDetect clear];
//    [self.raceBeauty clear];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    CFRetain(sampleBuffer);
    dispatch_async(dispatch_get_main_queue(), ^{
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer((CMSampleBufferRef)sampleBuffer);
        uint32_t width = (uint32_t)CVPixelBufferGetWidth(pixelBuffer);
        uint32_t height = (uint32_t)CVPixelBufferGetHeight(pixelBuffer);
        self.renderView.tWidth = width;
        self.renderView.tHeight = height;

        if (self.openFaceDetect) {
            int error;
            aliyun_face_info_t faceInfo = [self.faceDetect faceLocationsWithBuffer:sampleBuffer rotation:self.cameraRotate error:&error];
            if (error == 0 && faceInfo.face_count) {
                //初始化成功
                NSMutableArray *points = @[].mutableCopy;
                for (int j = 0; j < faceInfo.face_count; j++) {
                    for (int i = 0; i < 106; i++) {
                        aliyun_point_t point = faceInfo.p_faces[j].landmarks_array[i];
                        CGFloat x = point.x / pixelWidth * 2 - 1.0f;
                        CGFloat y = 1 - point.y / pixelHeight * 2;
                        [points addObject:@(x)];
                        [points addObject:@(y)];
                    }
                }
                [self.renderView draw:pixelBuffer facePoint:points];
                     
            } else {
                [self.renderView drawWithPixelBuffer:pixelBuffer];
            }
        } else {
            [self.renderView drawWithPixelBuffer:pixelBuffer];
        }
        
        CFRelease(sampleBuffer);
    });
}

- (void)startRetainCameraRotate {
    //初始化全局管理对象
    if (!self.motionManager) {
        self.motionManager = [[CMMotionManager alloc] init];
    }
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
    }
    if ([self.motionManager isDeviceMotionAvailable]) {
        self.motionManager.deviceMotionUpdateInterval =1;
        [self.motionManager startDeviceMotionUpdatesToQueue:_queue withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            // Gravity 获取手机的重力值在各个方向上的分量，根据这个就可以获得手机的空间位置，倾斜角度等
            double gravityX = motion.gravity.x;
            double gravityY = motion.gravity.y;
            double xyTheta = atan2(gravityX,gravityY)/M_PI*180.0;//手机旋转角度。
            if (xyTheta >= -45 && xyTheta <= 45) {//down
                self->_cameraRotate =180;
            } else if (xyTheta > 45 && xyTheta < 135) {//left
                self->_cameraRotate = 90;
            } else if ((xyTheta >= 135 && xyTheta < 180) || (xyTheta >= -180 && xyTheta < -135)) {//up
                self->_cameraRotate = 0;
            } else if (xyTheta >= -135 && xyTheta < -45) {//right
                self->_cameraRotate = 270;
            }
//            NSLog(@"手机旋转的角度为 --- %d", self->_cameraRotate);
        }];
    }
}


- (AlivcRaceFaceDetect *)faceDetect {
    if (!_faceDetect) {
        _faceDetect = [[AlivcRaceFaceDetect alloc] init];
    }
    return _faceDetect;
}


@end
