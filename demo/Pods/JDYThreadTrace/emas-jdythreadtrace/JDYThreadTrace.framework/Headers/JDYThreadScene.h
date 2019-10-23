//
//  JDYThreadScene.h
//  JDYThreadTrace
//
//  Created by Zhiqiang Bao on 2017/8/4.
//  Copyright © 2017年 Taobao lnc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach.h>

@interface JDYThreadScene : NSObject

@property (nonatomic, strong) NSArray *threadScene;
@property (nonatomic, strong) NSString *sceneTitle;

+ (JDYThreadScene *)captureSceneForThread:(thread_t)thread;

+ (JDYThreadScene *)captureSceneForThreadIndex:(int)index;

@end
