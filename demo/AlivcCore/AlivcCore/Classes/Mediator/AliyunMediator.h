//
//  AliyunMediator.h
//  AliyunVideo
//
//  Created by Worthy on 2017/5/4.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *const AliyunShortVideoModuleString_VideoShooting;
extern NSString *const AliyunShortVideoModuleString_VideoEdit;
extern NSString *const AliyunShortVideoModuleString_VideoClip;
extern NSString *const AliyunShortVideoModuleString_MagicCamera;

@interface AliyunMediator : NSObject

+ (instancetype)shared;

- (UIViewController *)recordModule;

- (UIViewController *)magicCameraModule;
- (UIViewController *)editModule;
- (UIViewController *)cropModule;
- (UIViewController *)liveModule;
- (UIViewController *)uiComponentModule;

//- (UIViewController *)recordViewController;
- (UIViewController *)configureViewController;
- (UIViewController *)recordViewController_Basic;
- (UIViewController *)compositionViewController;
- (UIViewController *)editViewController;
- (UIViewController *)cropViewController;
- (UIViewController *)photoViewController;

@end
