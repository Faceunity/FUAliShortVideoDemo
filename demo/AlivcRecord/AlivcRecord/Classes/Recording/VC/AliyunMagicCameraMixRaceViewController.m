//
//  AliyunMagicCameraMixRaceViewController.m
//  AliyunVideoClient_Entrance
//
//  Created by 郦立 on 2019/10/11.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AliyunMagicCameraMixRaceViewController.h"
#import "AlivcShortVideoRaceManager.h"
#import "AVC_ShortVideo_Config.h"

@interface AliyunMagicCameraMixRaceViewController ()

@end

@implementation AliyunMagicCameraMixRaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#if SDK_VERSION == SDK_VERSION_CUSTOM
// 集成race
- (int)customRenderedTextureWithRawSampleBuffer:(CMSampleBufferRef)sampleBuffer {
      if ([[AlivcShortVideoRoute shared] currentBeautyType] == AlivcBeautyTypeFaceUnity) {
          return 0;
      }
      if (self.beautyView.currentBeautyType == AlivcBeautySettingViewStyle_ShortVideo_BeautyFace_Base) {
          return 0;
      }
      
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
      int rander = [[AlivcShortVideoRaceManager shareManager] customRenderWithBuffer:sampleBuffer skinBuffing:beautyBuffing skinWhitening:beautyWhite sharpen:beautySharpen bigEye:beautyBigEye longFace:longFace cutFace:cutFace thinFace:beautyThinFace lowerJaw:lowerJaw mouthWidth:mouthWidth thinNose:thinNose thinMandible:thinMandible cutCheek:cutCheek];
      return rander;
}
#endif


@end
