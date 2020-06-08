//
//  AlivcRaceBeautyOpenGLVC.m
//  AlivcRace
//
//  Created by 孙震 on 2020/2/25.
//

#import "AlivcRaceBeautyOpenGLVC.h"
#import <AVFoundation/AVFoundation.h>
#import "AlivcGLView.h"
#import "AlivcRaceBeauty.h"
#import "AlivcRaceRecordBeautyView.h"

@interface AlivcRaceBeautyOpenGLVC ()

@property (nonatomic, strong) AlivcRaceBeauty *raceBeauty;
@property (nonatomic, weak) AlivcGLView *renderView;
@property (nonatomic, strong) AlivcRaceRecordBeautyView *beautyView;        //美颜view
@property (nonatomic, assign) BOOL openBeauty;
@property (nonatomic, weak) UISwitch *beautySwitch;
@end

@implementation AlivcRaceBeautyOpenGLVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AlivcGLView *view = [[AlivcGLView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    [self.view addSubview:view];
    self.renderView = view;
    
     
     [self addBeautyButton];
     
     [self addBeautySwitch];
    
}

- (void)dealloc {
    [self.raceBeauty clear];
}


- (void)addBeautyButton {
    UIButton *beautyButton = [[UIButton alloc] initWithFrame:CGRectMake(10, ScreenHeight - 96, 96, 96)];
    [beautyButton setImage:[AlivcImage imageNamed:@"AlivcIconBeauty"] forState:UIControlStateNormal];
    [beautyButton addTarget:self.beautyView action:@selector(show) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:beautyButton];
    
}

- (void)addBeautySwitch {
    self.openBeauty = YES;
    UISwitch *beautySwitch = [[UISwitch alloc] init];
    beautySwitch.center = CGPointMake(120, 100);
    beautySwitch.on = YES;
    [self.view addSubview:beautySwitch];
    self.beautySwitch = beautySwitch;
    UILabel *beautyLabel = [[UILabel alloc] init];
    beautyLabel.text = @"开启美颜";
    beautyLabel.textColor = [UIColor grayColor];
    [beautyLabel sizeToFit];
     beautyLabel.center = CGPointMake(50, 100);
    
    [self.view addSubview:beautyLabel];
     
    [beautySwitch addTarget:self action:@selector(beautySwitchClick) forControlEvents:UIControlEventValueChanged];
     
}

- (void)beautySwitchClick {
    self.openBeauty = !self.openBeauty;
}
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    CFRetain(sampleBuffer);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer((CMSampleBufferRef)sampleBuffer);
        uint32_t width = (uint32_t)CVPixelBufferGetWidth(pixelBuffer);
        uint32_t height = (uint32_t)CVPixelBufferGetHeight(pixelBuffer);
        self.renderView.tWidth = width;
        self.renderView.tHeight = height;
        if (self.openBeauty) {
            int texture = [self customRenderedTextureWithRawSampleBuffer:sampleBuffer];
            if (texture) {
                [self.renderView draw:texture];
                self.renderView.hidden = NO;
            }else {
               self.openBeauty = NO;
               self.beautySwitch.on = NO;
               self.renderView.hidden = YES;
            }
        }else {
//            self.renderView.hidden = YES;
            [self.renderView drawWithPixelBuffer:pixelBuffer];
        }
        CFRelease(sampleBuffer);
    });
    
}



 
 
- (int)customRenderedTextureWithRawSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
    //注意这里美颜美型的参数是分开的beautyParams和beautySkinParams
    //美颜参数设置(这里用的是beautyParams)
    CGFloat beautyBuffing = self.beautyView.beautyParams.beautyBuffing/100.0f;
    CGFloat beautyWhite = self.beautyView.beautyParams.beautyWhite/100.0f;
    CGFloat beautySharpen = self.beautyView.beautyParams.beautyRuddy/100.0f; //race中，这个是锐化
    //美型参数设置(这里用的是beautySkinParams)
    CGFloat beautyBigEye = self.beautyView.beautySkinParams.beautyBigEye/100.0f;
    CGFloat beautyThinFace = self.beautyView.beautySkinParams.beautySlimFace/100.0f;
    CGFloat longFace = self.beautyView.beautySkinParams.longFace/100.0f;
    CGFloat cutFace = self.beautyView.beautySkinParams.cutFace/100.0f;
    CGFloat lowerJaw = self.beautyView.beautySkinParams.lowerJaw/100.0f;
    CGFloat mouthWidth = self.beautyView.beautySkinParams.mouthWidth/100.0f;
    CGFloat thinNose = self.beautyView.beautySkinParams.thinNose/100.0f;
    CGFloat thinMandible = self.beautyView.beautySkinParams.thinMandible/100.0f;
    CGFloat cutCheek = self.beautyView.beautySkinParams.cutCheek/100.0f;
    
    
    int texture = [self.raceBeauty customRenderWithBuffer:sampleBuffer skinBuffing:beautyBuffing skinWhitening:beautyWhite sharpen:beautySharpen bigEye:beautyBigEye longFace:longFace cutFace:cutFace thinFace:beautyThinFace lowerJaw:lowerJaw mouthWidth:mouthWidth thinNose:thinNose thinMandible:thinMandible cutCheek:cutCheek];
    
    return texture;
}


#pragma mark - AlivcRecordBeautyViewDelegate
- (void)alivcRecordBeautyDidChangeBeautyType:(AlivcBeautySettingViewStyle)type{
    
}
- (void)alivcRecordBeautyDidChangeBaseBeautyLevel:(NSInteger)level{
    
}

- (void)alivcRecordBeautyDidSelectedGetFaceUnityLink{
    
}

- (AlivcRaceBeauty *)raceBeauty {
    if (!_raceBeauty) {
        _raceBeauty = [[AlivcRaceBeauty alloc] init];
    }
    return _raceBeauty;
}


- (AlivcRaceRecordBeautyView *)beautyView{
    if (!_beautyView) {
        AlivcRaceBottomMenuHeaderViewItem *item1 =[AlivcRaceBottomMenuHeaderViewItem createItemWithTitle:[@"美颜" localString] icon:[AlivcImage imageNamed:@"AlivcIconBeauty"] tag:1];
        AlivcRaceBottomMenuHeaderViewItem *item2 =[AlivcRaceBottomMenuHeaderViewItem createItemWithTitle:[@"美型" localString] icon:[AlivcImage imageNamed:@"shortVideo_beautySkin"] tag:2]; //fu的美型
        
        AlivcRaceBottomMenuHeaderViewItem *item3 =[AlivcRaceBottomMenuHeaderViewItem createItemWithTitle:[@"美型" localString] icon:[AlivcImage imageNamed:@"shortVideo_beautySkin"] tag:3];  //race的美型
        NSArray *items; 
        items =@[item1,item3];
        CGFloat safeTop = 78;
        _beautyView =[[AlivcRaceRecordBeautyView alloc]initWithFrame:CGRectMake(0, ScreenHeight-200-safeTop, ScreenWidth, 200+safeTop) withItems:items];
        _beautyView.safeTop = safeTop;
        _beautyView.showHeaderViewSelectedFlag = YES;
        _beautyView.delegate = self;
        [_beautyView setLevelViewTitle:@"race"];
        //        }
        [self.view addSubview:_beautyView];
    }
    return _beautyView;
}


@end
