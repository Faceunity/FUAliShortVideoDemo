//
//  AlivcRaceBeautyViewController.m
//  AlivcRaceBeauty
//
//  Created by 孙震 on 2020/2/10.
//

#import "AlivcRaceBeautyViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "FPSLabel.h"


typedef enum : NSUInteger {
    SessionSetupResultSuccess,
    SessionSetupResultnotAuthorized,
    SessionSetupResultconfigurationFailed
} SessionSetupResult;


API_AVAILABLE(ios(10.0))
@interface AlivcRaceBeautyViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    dispatch_queue_t _sessionQueue;
    SessionSetupResult _setupResult;
    AVCaptureVideoOrientation _orientation;
}
@property (weak,nonatomic) UIButton *cameraButton;
@property (strong,nonatomic) AVCaptureDeviceInput *captureDeviceInput;
@property (strong,nonatomic) AVCaptureSession *captureSession;
@property (strong,nonatomic) AVCaptureVideoPreviewLayer *previewView;
@property (assign,nonatomic) BOOL isRunning;
@property (strong,nonatomic) AVCaptureDeviceDiscoverySession *videoDeviceDiscoverySession;
@property (strong,nonatomic) AVCaptureVideoDataOutput *dataOutput;


@end

@implementation AlivcRaceBeautyViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self initData];
    [self grantPermission];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.cameraButton) {
        [self setupUI];
    }
    dispatch_async(self->_sessionQueue, ^{
        switch (self->_setupResult) {
            case SessionSetupResultSuccess:{
                [self addObservers];
                [self.captureSession startRunning];
                self.isRunning = self.captureSession.isRunning;
                break;
            }
            case SessionSetupResultnotAuthorized:{
                //在主线程提示UI alertController
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString* message = NSLocalizedString(@"Race doesn't have permission to use the camera, please change privacy settings", @"Alert message when the user has denied access to the camera");
                    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"AVCam" message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"Alert OK button") style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    // Provide quick access to Settings.
                    UIAlertAction* settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", @"Alert button to open Settings") style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
                        if (@available(iOS 10.0,*)) {
                             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
                        }else{
                             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                        }
                    }];
                    [alertController addAction:settingsAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                });
                break;
            }
            case SessionSetupResultconfigurationFailed:{
                //在主线程提示UI alertController
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString* message = NSLocalizedString(@"Unable to capture media", @"Alert message when something goes wrong during capture session configuration");
                    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"AVCam" message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"Alert OK button") style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                });
                break;
            }
        }
    });
}


- (void)viewWillDisappear:(BOOL)animated {
    dispatch_async(_sessionQueue, ^{
        if (self->_setupResult == SessionSetupResultSuccess) {
            [self.captureSession stopRunning];
            self.isRunning = self.captureSession.isRunning;
            [self removeObservers];
        }
    });
    
    [super viewWillDisappear:animated];
}

- (BOOL) shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}



- (void) OrientationDidChange:(NSNotification *)notification
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;

    if (UIDeviceOrientationIsPortrait(deviceOrientation) || UIDeviceOrientationIsLandscape(deviceOrientation)) {
        dispatch_async(self->_sessionQueue, ^{

            [self.captureSession beginConfiguration];

            AVCaptureConnection * connection = [self.dataOutput connectionWithMediaType:AVMediaTypeVideo];
            //      connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;
            //      self->_orientation = (AVCaptureVideoOrientation)deviceOrientation;
            [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];

            [self.captureSession commitConfiguration];
        });

    }
}

- (void)setupUI {
    UIButton *cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 54, SafeTop, 44, 44)];
    [cameraButton setImage:[AlivcImage imageNamed:@"shortVideo_cameraid"] forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(changeCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraButton];
    self.cameraButton = cameraButton;
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(8, SafeTop, 44, 44)];
    [backButton setImage:[AlivcImage imageNamed:@"avcBackIcon"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    FPSLabel *label = [[FPSLabel alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [self.view addSubview:label];
    label.center = CGPointMake(ScreenWidth * 0.5, SafeTop + 30);
}

- (void)pop {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)initData {
    self.captureSession = [[AVCaptureSession alloc] init];
    _sessionQueue = dispatch_queue_create("sessionQueue", DISPATCH_QUEUE_SERIAL);
    
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] init];
    previewLayer.frame = self.view.bounds;
    self.previewView = previewLayer;
//      [self.view.layer addSublayer:previewLayer];
    previewLayer.session = self.captureSession;
    
}


// 获取授权
- (void)grantPermission {
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        case AVAuthorizationStatusAuthorized:{
            [self setupCaptureSession];
            break;
        }
        case AVAuthorizationStatusNotDetermined:{
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(self->_sessionQueue, ^{
                        [self setupCaptureSession];
                    });
                }else{
                    self->_setupResult = SessionSetupResultnotAuthorized;
                }
            }];
            break;
        }
        case AVAuthorizationStatusDenied:
            _setupResult = SessionSetupResultnotAuthorized;
            return;
        case AVAuthorizationStatusRestricted:
            _setupResult = SessionSetupResultnotAuthorized;
            return;
    }
}

- (void)setupCaptureSession {
    if (_setupResult != SessionSetupResultSuccess) {
        return;
    }
    [self.captureSession beginConfiguration];
    
    // Add video input.
    AVCaptureDevice *defaultCamera = nil;
     
    if (@available(iOS 10.0, *)) {
        defaultCamera = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    } else {
        // Fallback on earlier versions
            for (AVCaptureDevice *device in  [AVCaptureDevice devices]) {
                if (device.position == AVCaptureDevicePositionFront ) {
                    defaultCamera = device;
                }
            }
    }
    
   
    

    
    
    if (!defaultCamera) {
        NSLog(@"Default video device is unavailable.");
        _setupResult = SessionSetupResultconfigurationFailed;
        [self.captureSession commitConfiguration];
        return;
    }
    
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput =
    [AVCaptureDeviceInput deviceInputWithDevice:defaultCamera error:&error];
    
    if(error) {
        NSLog(@"AVCaptureDeviceInput initialization failed.");
        _setupResult = SessionSetupResultconfigurationFailed;
        [self.captureSession commitConfiguration];
        return;
    }
    
    //add input
    if ([self.captureSession canAddInput:videoInput]) {
        [self.captureSession addInput:videoInput];
        self.captureDeviceInput = videoInput;
        
        //
    } else {
        NSLog(@"Couldn't add video device input to the session.");
        _setupResult = SessionSetupResultconfigurationFailed;
        [self.captureSession commitConfiguration];
        return;
    }
    
    
    //add output
    AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    dataOutput.videoSettings = @{
        (NSString*)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)
    };
    [dataOutput setSampleBufferDelegate:self queue:_sessionQueue];
    if ([_captureSession canAddOutput:dataOutput]) {
        [_captureSession addOutput:dataOutput];
        self.dataOutput = dataOutput;
    } else {
        NSLog(@"Could not add data output to the session");
        _setupResult = SessionSetupResultconfigurationFailed;
        [self.captureSession commitConfiguration];
        return;
    }
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (deviceOrientation == UIDeviceOrientationUnknown) {
        deviceOrientation = UIDeviceOrientationPortrait;
    }
    AVCaptureConnection * connection = [self.dataOutput connectionWithMediaType:AVMediaTypeVideo];
    
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    //  connection.videoOrientation = (AVCaptureVideoOrientation)deviceOrientation;
    //  self->_orientation = (AVCaptureVideoOrientation)deviceOrientation;
    
    if(connection.supportsVideoMirroring && defaultCamera.position == AVCaptureDevicePositionFront ){
        connection.videoMirrored = YES;
    }
    self.captureSession.sessionPreset =  AVCaptureSessionPresetHigh;
    
    [self.captureSession commitConfiguration];
}



- (void)addObservers{
    /*
     A session can only run when the app is full screen. It will be interrupted
     in a multi-app layout, introduced in iOS 9, see also the documentation of
     AVCaptureSessionInterruptionReason. Add observers to handle these session
     interruptions and show a preview is paused message. See the documentation
     of AVCaptureSessionWasInterruptedNotification for other interruption reasons.
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionWasInterrupted:) name:AVCaptureSessionWasInterruptedNotification object:self.captureSession];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionInterruptionEnded:) name:AVCaptureSessionWasInterruptedNotification object:self.captureSession];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}
- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void)sessionWasInterrupted:(NSNotification *)notification {
    BOOL showResumeButton = NO;
    
    AVCaptureSessionInterruptionReason reason = [notification.userInfo[AVCaptureSessionInterruptionReasonKey] integerValue];
    NSLog(@"Capture session was interrupted with reason %ld", (long)reason);
    
    if (reason == AVCaptureSessionInterruptionReasonAudioDeviceInUseByAnotherClient ||
        reason == AVCaptureSessionInterruptionReasonVideoDeviceInUseByAnotherClient) {
        showResumeButton = YES;
    }
    else if (reason == AVCaptureSessionInterruptionReasonVideoDeviceNotAvailableWithMultipleForegroundApps) {
        // Fade-in a label to inform the user that the camera is unavailable.
        //      self.cameraUnavailableLabel.alpha = 0.0;
        //      self.cameraUnavailableLabel.hidden = NO;
        //      [UIView animateWithDuration:0.25 animations:^{
        //          self.cameraUnavailableLabel.alpha = 1.0;
        //      }];
    }
    
    if (@available(iOS 11.1,*)) {
        if (reason == AVCaptureSessionInterruptionReasonVideoDeviceNotAvailableDueToSystemPressure) {
            NSLog(@"Session stopped running due to shutdown system pressure level.");
        }
    }
    
    
    
}

- (void)sessionInterruptionEnded:(NSNotification *)notification {
    
}


- (void)changeCamera:(UIButton *)cameraButton {
    NSLog(@"----changeCamera-----");
    //ui operation
    cameraButton.enabled = NO;
    dispatch_async(_sessionQueue, ^{
        //获取当前的信息
        AVCaptureDevice *currentDevice = self.captureDeviceInput.device;
        AVCaptureDevicePosition currentPosition = currentDevice.position;
        
        AVCaptureDevicePosition preferredPosition;
        
        switch (currentPosition) {
            case AVCaptureDevicePositionBack:
                preferredPosition = AVCaptureDevicePositionFront;
                break;
            case AVCaptureDevicePositionFront:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
                
            case AVCaptureDevicePositionUnspecified:
                preferredPosition = AVCaptureDevicePositionFront;
                break;
            default:
                preferredPosition = AVCaptureDevicePositionFront;
                break;
        }
        
        NSArray<AVCaptureDevice *> *devices = nil;
        if (@available(iOS 10.0, *)) {
            devices = [self.videoDeviceDiscoverySession devices];
        } else {
            // Fallback on earlier versions
            devices = [AVCaptureDevice devices];
        }
        AVCaptureDevice *newVideoDevice = nil;
        
        for (AVCaptureDevice *device in devices) {
            if (device.position == preferredPosition) {
                newVideoDevice = device;
                break;
            }
        }
        
        if (newVideoDevice) {
            NSError *error = nil;
            AVCaptureDeviceInput *deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:newVideoDevice error:&error];
            
            if (error) {
                NSLog(@"Error occurred while creating video device input:%@",error);
            }
            
            [self.captureSession beginConfiguration];
            [self.captureSession removeInput:self.captureDeviceInput];
            
            if ([self.captureSession canAddInput:deviceInput]) {
                [self.captureSession addInput:deviceInput];
                self.captureDeviceInput = deviceInput;
            } else {
                [self.captureSession addInput:self.captureDeviceInput];
            }
            
            AVCaptureConnection * connection = [self.dataOutput connectionWithMediaType:AVMediaTypeVideo];
            //      connection.videoOrientation = self->_orientation;
            [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
            
            if(connection.supportsVideoMirroring && newVideoDevice.position == AVCaptureDevicePositionFront ){
                connection.videoMirrored = YES;
            }
            self.captureSession.sessionPreset =  AVCaptureSessionPresetHigh;
            [self.captureSession commitConfiguration];
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //ui operation
            cameraButton.enabled = YES;
        });
    });
    
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
}


- (AVCaptureDeviceDiscoverySession *)videoDeviceDiscoverySession  API_AVAILABLE(ios(10.0)){
    if (@available(iOS 10.0,*)) {
        if (!_videoDeviceDiscoverySession) {
            if (@available(iOS 11.1, *)) {
                _videoDeviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera,AVCaptureDeviceTypeBuiltInDualCamera,AVCaptureDeviceTypeBuiltInTrueDepthCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];
            } else  if (@available(iOS 10.2, *)) {
                _videoDeviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera,AVCaptureDeviceTypeBuiltInDualCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];
            } else {
                _videoDeviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];
            }
           
        }
    }
    return _videoDeviceDiscoverySession;
}


@end
